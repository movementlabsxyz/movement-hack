module stable_swap::liquid_stable_swap {
    use std::signer;

    use liquidswap::router_v2;
    use liquidswap::curves::Uncorrelated;
    use test_coins::coins::{USDT};

    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::coin;

    public entry fun buy_usdc(account: &signer, usdt_min_value_to_get: u64) {
        let aptos_amount_to_swap = 1000;
        let aptos_coins_to_swap = coin::withdraw<AptosCoin>(account, aptos_amount_to_swap);

        let usdt = router_v2::swap_exact_coin_for_coin<AptosCoin, USDT, Uncorrelated>(
            aptos_coins_to_swap,
            usdt_min_value_to_get
        );

        let account_addr = signer::address_of(account);

        // Register USDT coin on account in case the account don't have it.
        if (!coin::is_account_registered<USDT>(account_addr)) {
            coin::register<USDT>(account);
        };

        // Deposit on account.
        coin::deposit(account_addr, usdt);
    }
}