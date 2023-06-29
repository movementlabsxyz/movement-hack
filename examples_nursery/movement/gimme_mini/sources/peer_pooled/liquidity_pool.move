module account::pp_lend_coin {
    use std::signer;
    use std::string::utf8;

    use aptos_framework::coin;

    struct PpLendCoin {}

    public entry fun initialize(account: &signer) {
        let (burn_cap, freeze_cap, mint_cap) = coin::initialize<PpLend>(
            account,
            utf8(b"PpLend"),
            utf8(b"MC"),
            6,
            true,
        );

        let coins = coin::mint(1000000000000, &mint_cap);
        coin::register<PpLendCoin>(account);
        coin::deposit(signer::address_of(account), coins);

        coin::destroy_burn_cap(burn_cap);
        coin::destroy_freeze_cap(freeze_cap);
        coin::destroy_mint_cap(mint_cap);
    }
}

module liquidity_pool::liquidity_pool {
    use std::signer;

    use liquidswap::router_v2;
    use liquidswap::curves::Uncorrelated;
    use liquidswap::coin_helper::is_sorted;

    use liquidswap_lp::lp_coin::LP;

    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::coin;

    use account::pp_lend_coin::PpLendCoin;

    public entry fun create_pool(account: &signer) {
        // Check generics sorted.
        assert!(is_sorted<PpLend, AptosCoin>(), 0);

        router_v2::register_pool<PpLendCoin, AptosCoin, Uncorrelated>(
            account,
        );
    }

    public entry fun add_liquidity<X>(
        account: &signer,
        desired_x: u64
    ) {
        assert!(is_sorted<PpLendCoin, AptosCoin>(), 0);

        let account_addr = signer::address_of(
            account
        );

        let pp_lend = router_v2::get_amount_out<AptosCoin, PpLend>(desired_x);

        let (min_pp_lend_coin_liq, min_aptos_coin_liq) = router_v2::calc_optimal_coin_values<PpLend, AptosCoin, Uncorrelated>(
            desired_x,
            pp_lend,
            desired_x - 10,
            pp_lend - 10
        );

        let pp_lend_coin_liq = coin::withdraw<PpLendCoin>(account, min_pp_lend_coin_liq);
        let aptos_liq = coin::withdraw<AptosCoin>(account, min_aptos_coin_liq);

        let (pp_lend_coin_remainder, aptos_remainder, lp) = router_v2::add_liquidity<PpLend, AptosCoin, Uncorrelated>(
            pp_lend_coin_liq,
            min_pp_lend_coin_liq,
            aptos_liq,
            min_aptos_coin_liq,
        );

        coin::deposit(account_addr, pp_lend_coin_remainder);
        coin::deposit(account_addr, aptos_remainder);

        if (!coin::is_account_registered<LP<PpLendCoin, AptosCoin, Uncorrelated>>(account_addr)) {
            coin::register<LP<PpLendCoin, AptosCoin, Uncorrelated>>(account);
        };

        coin::deposit(account_addr, lp);
    }

    public entry fun remove_liquidity<X>(
        account : &signer,
        desired_x : u64
    ) {
        assert!(is_sorted<PpLendCoin, AptosCoin>(), 0);

        let account_addr = signer::address_of(account);

        let pp_lend = router_v2::get_amount_out<AptosCoin, PpLend>(desired_x);

        let (min_pp_lend_coin_liq, min_aptos_coin_liq) = router_v2::calc_optimal_coin_values<PpLend, AptosCoin, Uncorrelated>(
            desired_x,
            pp_lend,
            desired_x - 10,
            pp_lend - 10
        );

        let (pp_lend, aptos_coin) = router_v2::remove_liquidity<PpLend, AptosCoin, Uncorrelated>(
            lp,
            min_pp_lend_coin_liq,
            min_aptos_coin_liq,
        );

        coin::deposit(account_addr, aptos_coin);
    }

}