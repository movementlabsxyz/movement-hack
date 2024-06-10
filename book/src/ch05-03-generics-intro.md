# Generics Introduction

Generics are a cornerstone of Move's design, offering flexibility and reusability in smart contract development. This guide will break down the concept of generics in Move with practical, real-world examples.

Generics allow the creation of functions and structs that can operate on many data types, making code more reusable and adaptable.

## Move and copy Generics

Suppose you want to transfer different types of assets (e.g., tokens, NFTs) using the same function. Generics make this possible.

```rust
module AssetManager {
    struct Asset<T> has key, store {
        id: u64,
        content: T,
    }
​
    public fun transfer<T: key + store>(asset: Asset<T>, new_owner: address) {
        // Implementation for transferring asset to new_owner
    }
}
```

This function can now be used to transfer any asset, regardless of its content type, as long as it conforms to the key + store constraints, ensuring the asset can be stored and uniquely identified.

## The `copy` Keyword in Generics

Suppose you need to clone a container holding any type of item.

```rust
module BoxManager {
    struct Box<T> has copy {
        item: T,
    }
​
    public fun clone_box<T: copy>(original: &Box<T>): Box<T> {
        Box { item: *original.item }
    }
}
```

Here, `clone_box` can duplicate any box with contents that have the `copy` ability. This is called using generics to constrain abilities.

## References and Borrow Checking

Generics combined with references enable functions to work with any account model while ensuring safety through borrow checking.

```rust
module AccountManager {
    struct Account<T> {
        balance: T,
    }
​
    public fun deposit<T>(account: &mut Account<T>, amount: T) where T: copy + std::ops::Add<T, Output = T> {
        account.balance = account.balance + amount;
    }
}
```

This function allows adding funds to any account type, leveraging Move's generics and references to ensure type safety and flexibility.
