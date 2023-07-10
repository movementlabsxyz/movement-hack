#[test_only]
module mini_dex::mini_dex_tests {
    use std::signer;
    use std::string::utf8;
    // use std::vector;
    use aptos_framework::coin::{Self, MintCapability, FreezeCapability, BurnCapability};
    use aptos_framework::account;
    use aptos_framework::genesis;
    use aptos_framework::account::create_account_for_test;

    use mini_dex::swap::{ Self, PlatformData, LiquidityPool, LPCoin };

    struct BTC {}
    struct ETH {}
    struct USDT {}
    struct USDC {}
    struct Capability<phantom CoinType> has key {
        mint_cap: MintCapability<CoinType>,
        freeze_cap: FreezeCapability<CoinType>,
        burn_cap: BurnCapability<CoinType>,
    }

    const POOL_SEED: vector<u8> = b"POOL_SEED";
    const TEST_MINT_AMOUNT: u64 = 1_000_000_000;

    // errors in test
    const EInvalidPoolBalance: u64 = 1;
    const EInvalidUserLpBalance: u64 = 2;

    fun mint_coin<CoinType>(creator: &signer, user: &signer) {
        let (burn_cap, freeze_cap, mint_cap) = coin::initialize<CoinType>(creator, utf8(b"Test Coin"), utf8(b"TTT"), 6, true);
        coin::register<CoinType>(user);
        let coins = coin::mint<CoinType>(TEST_MINT_AMOUNT, &mint_cap);
        coin::deposit(signer::address_of(user), coins);
        move_to(creator, Capability<CoinType>  { mint_cap, freeze_cap, burn_cap });
    }

    fun setup_env(creator: &signer, user: &signer) {
        genesis::setup();
        create_account_for_test(signer::address_of(user));
        create_account_for_test(signer::address_of(creator));
        swap::test_init_module(creator);

        mint_coin<BTC>(creator, user);
        mint_coin<USDT>(creator, user);
    }

    #[test(creator = @mini_dex, alice = @0xbbb)]
    public entry fun test_add_remove_liquidity(creator: &signer, alice: &signer) {

        // setup environment
        setup_env(creator, alice);
        
        let alice_addr = signer::address_of(alice);

        // should takes 10000/10000 coin and gives 9000 LPCoin (AnimeSwapPoolV1Library::sqrt(10000*10000)-1000)
        swap::add_liquidity_entry<BTC, USDT>(alice, 10_000, 10_000, 1, 1);
        {
            let (coin_x_reserve, coin_y_reserve) = swap::get_reserves_size<BTC, USDT>();
            assert!(coin_x_reserve == 10_000, EInvalidPoolBalance);
            assert!(coin_y_reserve == 10_000, EInvalidPoolBalance);
            assert!(coin::balance<LPCoin<BTC, USDT>>(alice_addr) == 9000, EInvalidUserLpBalance);
            assert!(coin::balance<BTC>(alice_addr) == TEST_MINT_AMOUNT - 10000, EInvalidUserLpBalance);
            assert!(coin::balance<USDT>(alice_addr) == TEST_MINT_AMOUNT - 10000, EInvalidUserLpBalance);
        };

        // // should takes 100/100 coin and gives 100 LPCoin
        // add_liquidity_entry<BTC, USDT>(alice, 1000, 100, 1, 1);
        // {
        //     let lp = borrow_global<LiquidityPool<BTC, USDT>>(RESOURCE_ACCOUNT_ADDRESS);
        //     assert!(coin::value(&lp.coin_x_reserve) == 10100, EInvalidPoolBalance);
        //     assert!(coin::value(&lp.coin_y_reserve) == 10100, EInvalidPoolBalance);
        //     assert!(coin::balance<LPCoin<BTC, USDT>>(alice_addr) == 9100, EInvalidUserLpBalance);
        //     assert!(coin::balance<BTC>(alice_addr) == TEST_MINT_AMOUNT - 10100, EInvalidUserLpBalance);
        //     assert!(coin::balance<USDT>(alice_addr) == TEST_MINT_AMOUNT - 10100, EInvalidUserLpBalance);
        // };

        // // should takes 9000 LPCoin and gives 9000/9000 coin
        // remove_liquidity_entry<BTC, USDT>(alice, 9000, 9000, 9000);
        // {
        //     let lp = borrow_global<LiquidityPool<BTC, USDT>>(RESOURCE_ACCOUNT_ADDRESS);
        //     assert!(coin::value(&lp.coin_x_reserve) == 1100, EInvalidPoolBalance);
        //     assert!(coin::value(&lp.coin_y_reserve) == 1100, EInvalidPoolBalance);
        //     assert!(coin::balance<LPCoin<BTC, USDT>>(alice_addr) == 100, EInvalidUserLpBalance);
        //     assert!(coin::balance<BTC>(alice_addr) == TEST_MINT_AMOUNT - 1100, EInvalidUserLpBalance);
        //     assert!(coin::balance<USDT>(alice_addr) == TEST_MINT_AMOUNT - 1100, EInvalidUserLpBalance);
        // };
    }

}