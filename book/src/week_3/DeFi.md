# DeFi
This section treats with a general overview DeFi problems and solution, and the faculties of Movement M1 to help create these solutions.

## What is DeFi?
Decentralized Finance (DeFi) refers to a category of financial applications and platforms built on blockchain networks that aim to provide open, permissionless, and decentralized alternatives to traditional financial systems. DeFi leverages the transparency, immutability, and programmability of blockchain technology to enable financial activities without the need for intermediaries or centralized authorities.

## Why Decentralize?
Decentralization in DeFi brings several advantages, including increased transparency, censorship resistance, improved accessibility, and reduced reliance on trusted third parties. By removing intermediaries and enabling peer-to-peer transactions, decentralization can enhance efficiency, reduce costs, and empower individuals to have more control over their financial activities.

## Financial Applications of Decentralized Systems
### Purchasing
Decentralized systems allow for the direct peer-to-peer purchase of digital assets, cryptocurrencies, and other goods or services without the need for intermediaries or central authorities.

### Lending
DeFi platforms enable individuals to lend and borrow funds directly from other users through smart contracts, removing the need for traditional financial intermediaries such as banks.

> Check out `examples/movement/gimme_mini` for a toy implementation of both a direct and peer-pooled lending platform.

```rust
// example supply function from gimme_mini direct lending platform
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
```

```rust
module peer_pooled_lend::peer_pooled_lend {

    use std::signer;
    friend mini_lend::LoanOfficer;

    /// Lends funds to liquidity pool.
    /// 1. LoanOfficer will...
    ///     1. Check if account has enough funds to lend.
    ///     2. Check for suspicious activity.
    /// 2. If account has enough funds to lend...
    ///     1. MiniLend will transfer funds from account to liquidity pool.
    public fun lend(account : signer, amount : u64){

        // ...

    }

    /// Allows lender to seek repayment from liquidity pool.
    /// 1. LoanOfficer will...
    ///     1. Determine whether account is lender.
    ///     2. Determine loan period is up.
    /// 2. If the account is a valid lender and the loan period is up...
    ///     1. MiniLend will transfer funds from liquidity pool to account or self-collateralize.
    public fun seek_repayment(account : signer, amount : u64){

        // ...

    }

    /// Borrows funds from liquidity pool.
    /// 1. LoanOfficer will... 
    ///     1. Check if account has enough collateral
    ///     2. Check account credit.
    ///     3. If account has enough collateral and credit...
    /// 2. If account has enough collateral and credit...
    ///     1. MiniLend will borrow funds from liquidity pool
    /// 3. Whether or not the account will successully borrow funds, run the audit function.
    public fun borrow(account : signer, amount : u64){

        // ...

    }

    public fun repay(account : signer, amount : u64){

        // ...

    }

    /// Looks over loan tables and dispatches events to manage loans
    /// Anyone can call this function enabling decentralized book keeping.
    public fun audit(account : signer){

        // ...

    }

}
```


### Trading
Decentralized exchanges (DEXs) facilitate trustless trading of digital assets directly between users, eliminating the need for centralized order books and custody of funds by intermediaries.

> Movement has an ready-made DEX.

## DeFi Phenomena
### Yield Farming
Yield farming involves leveraging various DeFi protocols to maximize returns on cryptocurrencies or digital assets by providing liquidity, staking, or participating in other activities to earn additional rewards.

> Check out `examples/movement/yield_gardner` for a toy implementation of a yield farmer.

### Flash Loans
Flash loans are uncollateralized loans that allow users to borrow funds temporarily for specific transactions within a single blockchain transaction. They exploit the composability and fast transaction finality of smart contracts.

### Automated Market Making
Automated market makers (AMMs) are decentralized protocols that use mathematical formulas to determine asset prices and provide liquidity for trading. They have revolutionized liquidity provision in DeFi by eliminating the need for order books and enabling continuous trading.

> Check out `examples/movement/gimme_mini` for a toy implementation of a lending platform built atop the `liquidswap` AMM.

### Coins
Coins are typically created and recorded on the blockchain through a consensus mechanism, ensuring their authenticity and immutability. They can be transferred between participants on the network, used for transactions, and sometimes serve additional purposes such as voting rights or access to certain functionalities within decentralized applications (dApps) built on the blockchain. Coins play a fundamental role in enabling economic activity and incentivizing participation within the blockchain ecosystem.

> Movement provides built-in utilties to easily create and managed coins at varying levels of abstraction.
```rust
// A managed coin.
//:!:>sun
module sun_coin::sun_coin {
    struct SunCoin {}

    fun init_module(sender: &signer) {
        aptos_framework::managed_coin::initialize<SunCoin>(
            sender,
            b"Sun Coin",
            b"SUN",
            6,
            false,
        );
    }
}
//<:!:sun
```

```rust
// Handling coin transactions
script {
    use aptos_framework::coin;
    use std::vector;

    // There are two ways to approach this problem
    // 1. Withdraw the total then distribute the pieces by breaking it up or
    // 2. Transfer for each amount individually
    fun main<CoinType>(sender: &signer, split : vector<address>, amount: u64) {
        
        let i = 0;
        let len = vector::length(split);
        let coins = coin::withdraw<CoinType>(sender, amount);
        
        while (i < len) {
            let coins_pt = coin::extract(&mut coins, amount / len);
            coin::deposit(
                vector::borrow(split, i), 
                coins_pt
            );
        };
    }
}
```

Stablecoins are a type of coin that aims to maintain a stable value, typically pegged to a fiat currency like the US Dollar or a basket of assets. They provide price stability, making them suitable for various use cases within the decentralized finance ecosystem.

## Important DeFi Algorithms
### Constant Product Market Maker (CPMM) and Constant Mean Market Maker (CMMM)
These algorithms are used in AMMs to maintain liquidity and determine prices based on the constant product or mean principles.

### Fraud Proof and Binary Search
These algorithms enhance security in DeFi protocols by detecting and mitigating potential fraud or malicious activities. Binary search is often used to optimize search and validation processes.

### Modern Portfolio Theory (MPT)
MPT is applied in DeFi to optimize asset allocation and portfolio management, considering risk, returns, and correlations among different assets.

### Risk Models
DeFi relies on various risk models and methodologies to assess and manage risks associated with lending, borrowing, and other financial activities in decentralized systems.
