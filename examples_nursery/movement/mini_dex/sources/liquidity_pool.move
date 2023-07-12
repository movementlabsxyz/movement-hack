module mini_dex::liquidity_pool {
    use std::signer;
    use std::string::utf8;
    // use std::vector;
    use std::option::Self;
    use aptos_framework::coin::{Self, Coin, MintCapability, FreezeCapability, BurnCapability};
    use aptos_framework::account::{Self, SignerCapability};
    
    use mini_dex::math::{ sqrt, min };
    use mini_dex::lp_account;
    use mini_dex_lp::lp_coin::LPCoin;

    /// pool data
    struct LiquidityPool<phantom X, phantom Y> has key {
        coin_x_reserve: Coin<X>,
        coin_y_reserve: Coin<Y>,
        lp_mint_cap: MintCapability<LPCoin<X, Y>>,
        lp_freeze_cap: FreezeCapability<LPCoin<X, Y>>,
        lp_burn_cap: BurnCapability<LPCoin<X, Y>>,
    }

    /// global config data
    struct PlatformData has key {
        signer_cap: SignerCapability,
    }

    const MINIMUM_LIQUIDITY: u64 = 1000;
    const MAX_U64: u64 = 18446744073709551615u64;

    // When initializer assert error
    const EINVLIAD_INITIALIZER: u64 = 1;
    /// When contract error
    const EINTERNAL_ERROR: u64 = 2;
    /// When user is not admin
    const ERR_FORBIDDEN: u64 = 3;
    /// When not enough amount for pool
    const EINSUFFICIENT_AMOUNT: u64 = 4;
    /// When not enough liquidity amount
    const EINSUFFICIENT_LIQUIDITY: u64 = 5;
    /// When not enough liquidity minted
    const ENSUFFICIENT_LIQUIDITY_MINT: u64 = 6;
    /// When not enough liquidity burned
    const EINSUFFICIENT_LIQUIDITY_BURN: u64 = 7;
    /// When not enough X amount
    const EINSUFFICIENT_X_AMOUNT: u64 = 8;
    /// When not enough Y amount
    const EINSUFFICIENT_Y_AMOUNT: u64 = 9;
    /// When not enough input amount
    const EINSUFFICIENT_INPUT_AMOUNT: u64 = 10;
    /// When not enough output amount
    const EINSUFFICIENT_OUTPUT_AMOUNT: u64 = 11;
    /// When already exists on account
    const EPAIR_ALREADY_EXIST: u64 = 12;
    /// When not exists on account
    const EINVALID_PAIR: u64 = 13;

    // initialize
    fun init_module(mini_dex_admin: &signer) {
        assert!(signer::address_of(mini_dex_admin) == @mini_dex, EINVLIAD_INITIALIZER);
        
        let signer_cap = lp_account::retrieve_signer_cap(mini_dex_admin);
        move_to(mini_dex_admin, PlatformData {
            signer_cap,
        });
    }

    /**
     *  View functions
     */

    /// Function to get reserves size of Pool<X, Y>
    public fun get_reserves_size<X, Y>(): (u64, u64) acquires LiquidityPool {
        if (exists<LiquidityPool<X, Y>>(@pool_resource_account)) {
            let lp = borrow_global<LiquidityPool<X, Y>>(@pool_resource_account);
            (coin::value(&lp.coin_x_reserve), coin::value(&lp.coin_y_reserve))
        } else if (exists<LiquidityPool<Y, X>>(@pool_resource_account)){
            let lp = borrow_global<LiquidityPool<Y, X>>(@pool_resource_account);
            (coin::value(&lp.coin_y_reserve), coin::value(&lp.coin_x_reserve))
        } else {
            (0, 0)
        }
    }

    /// Function to get amounts in of Swap X->Y
    public fun get_amounts_in<X, Y>(
        amount_out: u64
    ): u64 acquires LiquidityPool {
        let (reserve_in, reserve_out) = get_reserves_size<X, Y>();
        let amount_in = get_amount_in(amount_out, reserve_in, reserve_out);
        amount_in
    }

    /// Funtion to get Signer Capability of Resource account
    fun admin_account_signer_cap(): signer acquires PlatformData {
        let signer_cap = &borrow_global<PlatformData>(@pool_resource_account).signer_cap;
        account::create_signer_with_capability(signer_cap)
    }

    /// Calculate optimal amounts of coins to add
    public fun calc_optimal_coin_values<X, Y>(
        amount_x_desired: u64,
        amount_y_desired: u64,
        amount_x_min: u64,
        amount_y_min: u64
    ): (u64, u64) acquires LiquidityPool {
        let lp = borrow_global<LiquidityPool<X, Y>>(@pool_resource_account);
        let (reserve_x, reserve_y) = (coin::value(&lp.coin_x_reserve), coin::value(&lp.coin_y_reserve));
        if (reserve_x == 0 && reserve_y == 0) {
            (amount_x_desired, amount_y_desired)
        } else {
            let amount_y_optimal = quote(amount_x_desired, reserve_x, reserve_y);
            if (amount_y_optimal <= amount_y_desired) {
                assert!(amount_y_optimal >= amount_y_min, EINSUFFICIENT_Y_AMOUNT);
                (amount_x_desired, amount_y_optimal)
            } else {
                let amount_x_optimal = quote(amount_y_desired, reserve_y, reserve_x);
                assert!(amount_x_optimal <= amount_x_desired, EINTERNAL_ERROR);
                assert!(amount_x_optimal >= amount_x_min, EINSUFFICIENT_X_AMOUNT);
                (amount_x_optimal, amount_y_desired)
            }
        }
    }

    /**
     * Entry functions
     */

    /// Add liquidity. If pair not exist, create pair first
    public entry fun add_liquidity_entry<X, Y>(
        account: &signer,
        amount_x_desired: u64,
        amount_y_desired: u64,
        amount_x_min: u64,
        amount_y_min: u64,
    ) acquires LiquidityPool, PlatformData {
        if (!exists<LiquidityPool<X, Y>>(@pool_resource_account)) {
            create_pair<X, Y>();
        };
        add_liquidity<X, Y>(account, amount_x_desired, amount_y_desired, amount_x_min, amount_y_min);
    }

    /// Remove liquidity
    public entry fun remove_liquidity_entry<X, Y>(
        account: &signer,
        liquidity: u64,
        amount_x_min: u64,
        amount_y_min: u64,
    ) acquires LiquidityPool {
        let coins = coin::withdraw<LPCoin<X, Y>>(account, liquidity);
        let (x_out, y_out) = remove_liquidity<X, Y>(coins, amount_x_min, amount_y_min);
        // transfer
        let account_addr = signer::address_of(account);
        coin::deposit(account_addr, x_out);
        coin::deposit(account_addr, y_out);
    }

    /// Swap exact X to Y
    public entry fun swap_exact_coins_for_coins_entry<X, Y>(
        account: &signer,
        amount_in: u64,
        amount_out_min: u64,
    ) acquires LiquidityPool {
        // swap
        let coins_in = coin::withdraw<X>(account, amount_in);
        let coins_out;
        coins_out = swap_coins_for_coins<X, Y>(coins_in);
        assert!(coin::value(&coins_out) >= amount_out_min, EINSUFFICIENT_OUTPUT_AMOUNT);
        register_coin<Y>(account);
        coin::deposit<Y>(signer::address_of(account), coins_out);
    }

    /// Swap X -> exact Y
    public entry fun swap_coins_for_exact_coins_entry<X, Y>(
        account: &signer,
        amount_out: u64,
        amount_in_max: u64,
    ) acquires LiquidityPool {
        let amount_in = get_amounts_in<X, Y>(amount_out);
        assert!(amount_in <= amount_in_max, EINSUFFICIENT_INPUT_AMOUNT);
        let coins_in = coin::withdraw<X>(account, amount_in);
        let coins_out;
        coins_out = swap_coins_for_coins<X, Y>(coins_in);
        register_coin<Y>(account);
        coin::deposit<Y>(signer::address_of(account), coins_out);
    }

    /**
     *  Router functions, can be called by other contracts
     */

    /// Create pair, and register events
    public fun create_pair<X, Y>() acquires PlatformData {
        assert!(!exists<LiquidityPool<X, Y>>(@pool_resource_account), EPAIR_ALREADY_EXIST);
        let resource_account_signer = admin_account_signer_cap();
        // create lp coin
        let (lp_burn_cap, lp_freeze_cap, lp_mint_cap) = 
            coin::initialize<LPCoin<X, Y>>(
                &resource_account_signer, 
                utf8(b"Mini DEX LP"), 
                utf8(b"LpCoin"), 
                8, 
                true
            );
        // register coin
        register_coin<LPCoin<X, Y>>(&resource_account_signer);
        // register LiquidityPool
        move_to(&resource_account_signer, LiquidityPool<X, Y>{
            coin_x_reserve: coin::zero<X>(),
            coin_y_reserve: coin::zero<Y>(),
            lp_mint_cap,
            lp_freeze_cap,
            lp_burn_cap,
        });
    }

    /// Add liquidity
    public fun add_liquidity<X, Y>(
        account: &signer,
        amount_x_desired: u64,
        amount_y_desired: u64,
        amount_x_min: u64,
        amount_y_min: u64,
    ) acquires LiquidityPool, PlatformData {
        // check lp exist
        assert!(exists<LiquidityPool<X, Y>>(@pool_resource_account), EINVALID_PAIR);
        let (amount_x, amount_y) = calc_optimal_coin_values<X, Y>(amount_x_desired, amount_y_desired, amount_x_min, amount_y_min);
        let coin_x = coin::withdraw<X>(account, amount_x);
        let coin_y = coin::withdraw<Y>(account, amount_y);
        let lp_coins = mint<X, Y>(coin_x, coin_y);

        let acc_addr = signer::address_of(account);
        if (!coin::is_account_registered<LPCoin<X, Y>>(acc_addr)) {
            coin::register<LPCoin<X, Y>>(account);
        };
        coin::deposit(acc_addr, lp_coins);
    }

    /// Remove liquidity
    public fun remove_liquidity<X, Y>(
        coins: Coin<LPCoin<X, Y>>,
        amount_x_min: u64,
        amount_y_min: u64,
    ): (Coin<X>, Coin<Y>) acquires LiquidityPool {
        let (x_out, y_out) = burn<X, Y>(coins);
        assert!(coin::value(&x_out) >= amount_x_min, EINSUFFICIENT_X_AMOUNT);
        assert!(coin::value(&y_out) >= amount_y_min, EINSUFFICIENT_Y_AMOUNT);
        (x_out, y_out)
    }

    /// Swap X to Y
    public fun swap_coins_for_coins<X, Y>(
        coins_in: Coin<X>,
    ): Coin<Y> acquires LiquidityPool {
        let amount_in = coin::value(&coins_in);
        let (reserve_in, reserve_out) = get_reserves_size<X, Y>();
        let amount_out = get_amount_out(amount_in, reserve_in, reserve_out);
        
        let (zero, coins_out);
        if (exists<LiquidityPool<X, Y>>(@pool_resource_account)) {
            (zero, coins_out) = swap<X, Y>(coins_in, 0, coin::zero(), amount_out);
        } else if (exists<LiquidityPool<Y, X>>(@pool_resource_account)){
            (coins_out, zero) = swap<Y, X>(coin::zero(), amount_out, coins_in, 0);
        } else abort 0;
        coin::destroy_zero<X>(zero);
        coins_out
    }

    /// Mint new LPCoin
    public fun mint<X, Y>(
        coin_x: Coin<X>,
        coin_y: Coin<Y>
    ): Coin<LPCoin<X, Y>> acquires LiquidityPool, PlatformData {
        assert!(exists<LiquidityPool<X, Y>>(@pool_resource_account), EINVALID_PAIR);

        let amount_x = coin::value(&coin_x);
        let amount_y = coin::value(&coin_y);
        // get reserve
        let lp = borrow_global_mut<LiquidityPool<X, Y>>(@pool_resource_account);
        let (reserve_x, reserve_y) = (coin::value(&lp.coin_x_reserve), coin::value(&lp.coin_y_reserve));
        coin::merge(&mut lp.coin_x_reserve, coin_x);
        coin::merge(&mut lp.coin_y_reserve, coin_y);

        let total_supply = option::extract(&mut coin::supply<LPCoin<X, Y>>());
        let liquidity;
        if (total_supply == 0) {
            liquidity = sqrt(amount_x, amount_y) - MINIMUM_LIQUIDITY;
            mint_coin<X, Y>(&admin_account_signer_cap(), MINIMUM_LIQUIDITY, &lp.lp_mint_cap);
        } else {
            // normal tx should never overflow
            let amount_1 = ((amount_x as u128) * total_supply / (reserve_x as u128) as u64);
            let amount_2 = ((amount_y as u128) * total_supply / (reserve_y as u128) as u64);
            liquidity = min(amount_1, amount_2);
        };
        assert!(liquidity > 0, ENSUFFICIENT_LIQUIDITY_MINT);
        let coins = coin::mint<LPCoin<X, Y>>(liquidity, &lp.lp_mint_cap);
        coins
    }

    /// Burn LPCoin and get back coins
    public fun burn<X, Y>(
        liquidity: Coin<LPCoin<X, Y>>
    ): (Coin<X>, Coin<Y>) acquires LiquidityPool {
        let liquidity_amount = coin::value(&liquidity);
        // get lp
        let lp = borrow_global_mut<LiquidityPool<X, Y>>(@pool_resource_account);
        let (reserve_x, reserve_y) = (coin::value(&lp.coin_x_reserve), coin::value(&lp.coin_y_reserve));

        let total_supply = option::extract(&mut coin::supply<LPCoin<X, Y>>());
        let amount_x = ((liquidity_amount as u128) * (reserve_x as u128) / total_supply as u64);
        let amount_y = ((liquidity_amount as u128) * (reserve_y as u128) / total_supply as u64);
        let x_coin_to_return = coin::extract(&mut lp.coin_x_reserve, amount_x);
        let y_coin_to_return = coin::extract(&mut lp.coin_y_reserve, amount_y);
        assert!(amount_x > 0 && amount_y > 0, EINSUFFICIENT_LIQUIDITY_BURN);
        coin::burn<LPCoin<X, Y>>(liquidity, &lp.lp_burn_cap);
        (x_coin_to_return, y_coin_to_return)
    }

    /// Swap coins
    public fun swap<X, Y>(
        coins_x_in: Coin<X>,
        amount_x_out: u64,
        coins_y_in: Coin<Y>,
        amount_y_out: u64,
    ): (Coin<X>, Coin<Y>) acquires LiquidityPool {
        let amount_x_in = coin::value(&coins_x_in);
        let amount_y_in = coin::value(&coins_y_in);
        assert!(amount_x_in > 0 || amount_y_in > 0, EINSUFFICIENT_INPUT_AMOUNT);
        assert!(amount_x_out > 0 || amount_y_out > 0, EINSUFFICIENT_OUTPUT_AMOUNT);
        let lp = borrow_global_mut<LiquidityPool<X, Y>>(@pool_resource_account);
        
        coin::merge(&mut lp.coin_x_reserve, coins_x_in);
        coin::merge(&mut lp.coin_y_reserve, coins_y_in);
        let coins_x_out = coin::extract(&mut lp.coin_x_reserve, amount_x_out);
        let coins_y_out = coin::extract(&mut lp.coin_y_reserve, amount_y_out);
        (coins_x_out, coins_y_out)
    }
        
    public fun quote(
        amount_x: u64,
        reserve_x: u64,
        reserve_y: u64
    ) :u64 {
        assert!(amount_x > 0, EINSUFFICIENT_AMOUNT);
        assert!(reserve_x > 0 && reserve_y > 0, EINSUFFICIENT_LIQUIDITY);
        let amount_y = ((amount_x as u128) * (reserve_y as u128) / (reserve_x as u128) as u64);
        amount_y
    }

    public fun get_amount_out(
        amount_in: u64,
        reserve_in: u64,
        reserve_out: u64
    ): u64 {
        assert!(amount_in > 0, EINSUFFICIENT_INPUT_AMOUNT);
        assert!(reserve_in > 0 && reserve_out > 0, EINSUFFICIENT_LIQUIDITY);
        let _amount_in = (amount_in as u128) * 10000;
        let numerator = _amount_in * (reserve_out as u128);
        let denominator = (reserve_in as u128) * 10000 + _amount_in;
        let amount_out = numerator / denominator;
        (amount_out as u64)
    }

    public fun get_amount_in(
        amount_out: u64,
        reserve_in: u64,
        reserve_out: u64
    ): u64 {
        assert!(amount_out > 0, EINSUFFICIENT_OUTPUT_AMOUNT);
        assert!(reserve_in > 0 && reserve_out > 0, EINSUFFICIENT_LIQUIDITY);
        let numerator = (reserve_in as u128) * (amount_out as u128) * 10000;
        let denominator = ((reserve_out - amount_out) as u128) * 10000;
        let amount_in = numerator / denominator + 1;
        (amount_in as u64)
    }

    fun mint_coin<X, Y>(
        account: &signer,
        amount: u64,
        mint_cap: &MintCapability<LPCoin<X, Y>>
    ) {
        let acc_addr = signer::address_of(account);
        if (!coin::is_account_registered<LPCoin<X, Y>>(acc_addr)) {
            coin::register<LPCoin<X, Y>>(account);
        };
        let coins = coin::mint<LPCoin<X, Y>>(amount, mint_cap);
        coin::deposit(acc_addr, coins);
    }

    fun register_coin<CoinType>(
        account: &signer
    ) {
        let account_addr = signer::address_of(account);
        if (!coin::is_account_registered<CoinType>(account_addr)) {
            coin::register<CoinType>(account);
        };
    }

    #[test_only]   
    public fun test_init_module(resource_account: &signer) {
        move_to(resource_account, PlatformData {
            signer_cap: account::create_test_signer_cap(signer::address_of(resource_account)),
        });
    }
}