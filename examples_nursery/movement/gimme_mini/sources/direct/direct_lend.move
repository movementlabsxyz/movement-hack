module direct_lend::direct_lend {
    use std::option;
    use std::signer;
    use std::string::{Self, String};
    use std::vector;

    use aptos_std::math64;
    use aptos_std::simple_map::{Self, SimpleMap};
    use aptos_framework::fungible_asset::{Self, FungibleAsset, Metadata, MintRef, BurnRef, TransferRef, FungibleStore};
    use aptos_framework::object::{Self, Object, ExtendRef};
    use aptos_framework::primary_fungible_store;

    const CTOKEN_DECIMALS: u8 = 8;
    const CTOKEN_NAME_PREFIX: vector<u8> = b"MdLend ";
    const CTOKEN_SYMBOL_PREFIX: vector<u8> = b"M";
    const BPS_BASE: u64 = 10000;
    const DEFAULT_LIQUIDATION_INCENTIVE_BPS: u64 = 50;
    const DEFAULT_CLOSE_FACTOR_BPS: u64 = 2000;

    const ERR_UNAUTHORIZED: u64 = 1;
    const ERR_SHORTFALL: u64 = 2;
    const ERR_NO_SHORTFALL: u64 = 3;
    const ERR_INSUFFICIENT_BALANCE: u64 = 4;
    const ERR_MARKET_MISMATCH: u64 = 5;
    const ERR_REPAY_OVER: u64 = 6;
    const ERR_LIQUIDATE_SELF: u64 = 7;

    struct Lending has key {
        liquidation_incentive_bps: u64,
        close_factor_bps: u64,
    }

    struct Market has key {
        extend_ref: ExtendRef,
        ctoken_mint_ref: MintRef,
        ctoken_burn_ref: BurnRef,
        ctoken_transfer_ref: TransferRef,
        total_borrow: u64
    }

    struct Vault has key {
        collaterals: vector<Object<Market>>,
        debts: SimpleMap<Object<Market>, u64>
    }

    fun init_module(admin: &signer) {
        assert!(signer::address_of(admin) == @lending, ERR_UNAUTHORIZED);

        move_to(admin, Lending {
            liquidation_incentive_bps: DEFAULT_LIQUIDATION_INCENTIVE_BPS,
            close_factor_bps: DEFAULT_CLOSE_FACTOR_BPS,
        });
    }

    public fun init_market(admin: &signer, underlying_asset: Object<Metadata>): Object<Market> {
        assert!(signer::address_of(admin) == @lending, ERR_UNAUTHORIZED);

        let ctoken_name = ctoken_name_via_asset_name(fungible_asset::name(underlying_asset));
        let constructor_ref = object::create_named_object(admin, *string::bytes(&ctoken_name));
        let market_signer = object::generate_signer(&constructor_ref);

        // Underlying asset fungible store
        fungible_asset::create_store(&constructor_ref, underlying_asset);

        // Initialize CToken
        let (ctoken_mint_ref, ctoken_burn_ref, ctoken_transfer_ref) = {
            let ctoken_symbol = ctoken_symbol_via_asset_symbol(fungible_asset::symbol(underlying_asset));
            let constructor_ref = object::create_named_object(&market_signer, *string::bytes(&ctoken_name));
            primary_fungible_store::create_primary_store_enabled_fungible_asset(
                &constructor_ref,
                option::none(),
                ctoken_name,
                ctoken_symbol,
                CTOKEN_DECIMALS,
                string::utf8(b"http://example.com/favicon.ico"),
                string::utf8(b"http://example.com"),
            );
            (
                fungible_asset::generate_mint_ref(&constructor_ref),
                fungible_asset::generate_burn_ref(&constructor_ref),
                fungible_asset::generate_transfer_ref(&constructor_ref),
            )
        };

        move_to(&market_signer, Market {
            extend_ref: object::generate_extend_ref(&constructor_ref),
            ctoken_mint_ref,
            ctoken_burn_ref,
            ctoken_transfer_ref,
            total_borrow: 0
        });

        object::object_from_constructor_ref<Market>(&constructor_ref)
    }

    public fun supply(
        account: &signer,
        market_obj: Object<Market>,
        underlying_fa: FungibleAsset
    ): FungibleAsset acquires Vault, Market {
        assert!(
            fungible_asset::asset_metadata(&underlying_fa) == fungible_asset::store_metadata(market_obj),
            ERR_MARKET_MISMATCH
        );

        let underlying_amount = fungible_asset::amount(&underlying_fa);

        // update market fungible store
        fungible_asset::deposit(market_obj, underlying_fa);

        // mint ctoken
        let ctoken_amount = underlying_to_ctoken(market_obj, underlying_amount);
        let market = borrow_global_mut<Market>(object::object_address(&market_obj));
        let ctoken = fungible_asset::mint(&market.ctoken_mint_ref, ctoken_amount);

        // update user vault
        init_vault_if_not_exists(account);
        let vault = borrow_global_mut<Vault>(signer::address_of(account));
        if (!vector::contains(&vault.collaterals, &market_obj)) {
            vector::push_back(&mut vault.collaterals, market_obj);
        };

        ctoken
    }

    public fun redeem(
        redeemer: address,
        market_obj: Object<Market>,
        ctoken_fa: FungibleAsset
    ): FungibleAsset acquires Market, Vault {
        assert!(ctoken_metadata(market_obj) == fungible_asset::asset_metadata(&ctoken_fa), ERR_MARKET_MISMATCH);

        // burn ctoken
        let ctoken_amount = fungible_asset::amount(&ctoken_fa);
        let underlying_amount = ctoken_to_underlying(market_obj, ctoken_amount);
        let market = borrow_global<Market>(object::object_address(&market_obj));
        fungible_asset::burn(&market.ctoken_burn_ref, ctoken_fa);

        // update market fungible store
        let market_signer = object::generate_signer_for_extending(&market.extend_ref);
        let underlying = fungible_asset::withdraw(&market_signer, market_obj, underlying_amount);

        let (_, shortfall) = account_liquidity(redeemer);
        assert!(shortfall == 0, ERR_SHORTFALL);

        underlying
    }

    public fun borrow(
        borrower: address,
        market_obj: Object<Market>,
        amount: u64
    ): FungibleAsset acquires Market, Vault {
        // update market fungible store and total_borrow
        let market = borrow_global_mut<Market>(object::object_address(&market_obj));
        let total_borrow = &mut market.total_borrow;
        *total_borrow = *total_borrow + amount;
        let market_signer = object::generate_signer_for_extending(&market.extend_ref);
        let fa = fungible_asset::withdraw(&market_signer, market_obj, amount);

        // update user vault
        let vault = borrow_global_mut<Vault>(borrower);
        if (!simple_map::contains_key(&vault.debts, &market_obj)) {
            simple_map::add(&mut vault.debts, market_obj, amount);
        } else {
            let debt = simple_map::borrow_mut(&mut vault.debts, &market_obj);
            *debt = *debt + amount;
        };

        let (_, shortfall) = account_liquidity(borrower);
        assert!(shortfall == 0, ERR_SHORTFALL);

        fa
    }

    public fun repay(repayer: address, market_obj: Object<Market>, fa: FungibleAsset) acquires Vault, Market {
        assert!(fungible_asset::asset_metadata(&fa) == fungible_asset::store_metadata(market_obj), ERR_MARKET_MISMATCH);

        let amount = fungible_asset::amount(&fa);

        // update market fungible store
        fungible_asset::deposit(market_obj, fa);
        let market = borrow_global_mut<Market>(object::object_address(&market_obj));
        let total_borrow = &mut market.total_borrow;
        *total_borrow = *total_borrow - amount;

        // update user vault
        let vault = borrow_global_mut<Vault>(repayer);
        let debt = simple_map::borrow_mut(&mut vault.debts, &market_obj);
        *debt = *debt - amount;
    }

    public fun liquidate(
        collateral_market: Object<Market>,
        borrow_market: Object<Market>,
        liquidator: address,
        borrower: address,
        repay_fa: FungibleAsset
    ): FungibleAsset acquires Vault, Market, Lending {
        assert!(
            fungible_asset::asset_metadata(&repay_fa) == fungible_asset::store_metadata(borrow_market),
            ERR_MARKET_MISMATCH
        );
        assert!(borrower != liquidator, ERR_LIQUIDATE_SELF);

        let (_, shortfall) = account_liquidity(borrower);
        assert!(shortfall > 0, ERR_NO_SHORTFALL);

        let lending = borrow_global<Lending>(@lending);
        let repay_amount = fungible_asset::amount(&repay_fa);
        let borrow_amount = borrow_amount(borrow_market, borrower);
        let max_close_amount = math64::mul_div(borrow_amount, lending.close_factor_bps, BPS_BASE);
        assert!(repay_amount <= max_close_amount, ERR_REPAY_OVER);

        repay(liquidator, borrow_market, repay_fa);

        // transfer borrower ctoken to liquidator
        // seizeAmount = repayAmount * liquidationIncentive * priceBorrowed / priceCollateral
        // seizeTokens = seizeAmount / exchangeRate
        // = repayAmount * (liquidationIncentive * priceBorrowed) / (priceCollateral * exchangeRate)
        let seize_ctoken_amount = {
            let price_borrowed = asset_price(fungible_asset::store_metadata(borrow_market));
            let price_collateral = asset_price(fungible_asset::store_metadata(collateral_market));
            let b = math64::mul_div(lending.liquidation_incentive_bps, price_borrowed, BPS_BASE);
            let (numerator, denominator) = exchange_rate(collateral_market);
            let c = math64::mul_div(price_collateral, numerator, denominator);
            math64::mul_div(repay_amount, b, c)
        };
        assert!(seize_ctoken_amount <= ctoken_balance(collateral_market, borrower), ERR_INSUFFICIENT_BALANCE);

        let ctoken_transfer_ref = &borrow_global<Market>(object::object_address(&collateral_market)).ctoken_transfer_ref;
        fungible_asset::withdraw_with_ref(
            ctoken_transfer_ref,
            primary_fungible_store::ensure_primary_store_exists(
                borrower,
                fungible_asset::transfer_ref_metadata(ctoken_transfer_ref)
            ),
            seize_ctoken_amount
        )
    }

    /// Returns (liquidity, shortfall)
    public fun account_liquidity(owner: address): (u64, u64) acquires Vault, Market {
        let vault = borrow_global<Vault>(owner);

        let collateral_value = vector::fold(vault.collaterals, 0u64, |acc, market_obj| {
            let ctoken_balance = ctoken_balance(market_obj, owner);
            let underlying_balance = ctoken_to_underlying(market_obj, ctoken_balance);
            let underlying_metadata = fungible_asset::store_metadata(market_obj);
            let price = asset_price(underlying_metadata);
            acc + math64::mul_div(
                underlying_balance,
                price,
                math64::pow(10, (fungible_asset::decimals(underlying_metadata) as u64))
            )
        });

        let liability_value = {
            let (market_objs, debts) = simple_map::to_vec_pair(vault.debts);
            let sum = 0;
            let i = 0;
            let n = vector::length(&market_objs);
            while (i < n) {
                let market_obj = *vector::borrow(&market_objs, i);
                let underlying_metadata = fungible_asset::store_metadata(market_obj);
                let underlying_balance = *vector::borrow(&debts, i);
                let price = asset_price(underlying_metadata);
                sum + math64::mul_div(
                    underlying_balance,
                    price,
                    math64::pow(10, (fungible_asset::decimals(underlying_metadata) as u64))
                );
                i = i + 1;
            };
            sum
        };

        if (collateral_value > liability_value) {
            (collateral_value - liability_value, 0)
        } else {
            (0, liability_value - collateral_value)
        }
    }

    #[view]
    /// ctoken_amount = amount / exchange_rate = amount * denominator / numerator
    public fun underlying_to_ctoken(market_obj: Object<Market>, underlying_amount: u64): u64 acquires Market {
        let (numerator, denominator) = exchange_rate(market_obj);
        math64::mul_div(underlying_amount, denominator, numerator)
    }

    #[view]
    /// amount = ctoken_amount * exchange_rate = ctoken_amount * numerator / denominator
    public fun ctoken_to_underlying(market_obj: Object<Market>, ctoken_amount: u64): u64 acquires Market {
        let (numerator, denominator) = exchange_rate(market_obj);
        math64::mul_div(ctoken_amount, numerator, denominator)
    }

    #[view]
    /// Return exchange rate between asset and ctoken
    /// TODO: count total_reserve
    public fun exchange_rate(market_obj: Object<Market>): (u64, u64) acquires Market {
        let cash = fungible_asset::balance(market_obj);

        let market = borrow_global<Market>(object::object_address(&market_obj));
        let total_borrow = market.total_borrow;

        // TODO: avoid the cast
        let total_supply = (ctoken_supply(market_obj) as u64);

        (cash + total_borrow, total_supply)
    }

    #[view]
    // TODO: IMPLEMENT ME
    public fun asset_price(_asset: Object<Metadata>): u64 {
        1
    }

    #[view]
    public fun borrow_amount(market_obj: Object<Market>, borrower: address): u64 acquires Vault {
        let vault = borrow_global<Vault>(borrower);
        let debt = simple_map::borrow(&vault.debts, &market_obj);
        *debt
    }

    inline fun get_market_signer(market_obj: Object<Market>): signer acquires Market {
        let ref = &borrow_global<Market>(object::object_address(&market_obj)).extend_ref;
        object::generate_signer_for_extending(ref)
    }

    fun init_vault_if_not_exists(account: &signer) {
        if (!exists<Vault>(signer::address_of(account))) {
            let vault = Vault {
                collaterals: vector::empty(),
                debts: simple_map::create()
            };
            move_to(account, vault);
        };
    }

    // utilities

    fun ctoken_supply(market_obj: Object<Market>): u128 acquires Market {
        let asset = ctoken_metadata(market_obj);
        option::destroy_some(fungible_asset::supply(asset))
    }

    fun ctoken_balance(market_obj: Object<Market>, owner: address): u64 acquires Market {
        let store = ctoken_store(market_obj, owner);
        fungible_asset::balance(store)
    }

    fun ctoken_metadata(market_obj: Object<Market>): Object<Metadata> acquires Market {
        let market = borrow_global<Market>(object::object_address(&market_obj));
        fungible_asset::mint_ref_metadata(&market.ctoken_mint_ref)
    }

    fun ctoken_store(market_obj: Object<Market>, owner: address): Object<FungibleStore> acquires Market {
        let asset = ctoken_metadata(market_obj);
        primary_fungible_store::ensure_primary_store_exists(owner, asset)
    }

    fun ctoken_name_via_asset_name(coin_name: String): String {
        let s = &mut string::utf8(CTOKEN_NAME_PREFIX);
        string::append(s, coin_name);
        *s
    }

    fun ctoken_symbol_via_asset_symbol(coin_symbol: String): String {
        let s = &mut string::utf8(CTOKEN_SYMBOL_PREFIX);
        string::append(s, coin_symbol);
        *s
    }
}