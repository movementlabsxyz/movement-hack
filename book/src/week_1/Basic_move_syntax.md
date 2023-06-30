# Basic Move Syntax, Comparing with Rust
This section treats with basic Move syntax, comparing the language to Rust. This is merely intended to provide some guidance for booklet participants. More comprehensive gudies can be found at [move-book.com](https://move-book.com/) and [move-language.github.io](https://move-language.github.io/move/).


## Allocation and the Move Memory Model
Move's resource-oriented language model leads to a unique memory model:
- Resources in Move are allocated and deallocated implicitly based on their defined lifespan and ownership semantics. This ensures proper resource management without the need for explicit memory allocation or deallocation.
- Resources are created and stored on the blockchain as part of a transaction, providing a persistent and tamper-resistant storage mechanism.
- Global storage in Move allows for the storage of resource data that can be accessed across multiple transactions and smart contracts.

While function ownership in Move is similar to Rust, it is less permissive and closer to being purely linear--restricting the set of possible borrows.

## Expressions and Control Flow
### Expressions
Move use a similar expression-orientation to Rusts. Block returns are possible. 
```rust
fun eight() : u8 {
    8
}
```

### `if`
Branching in Move is accomplished via `if` and `else` statements. There is not an `else if` statement.
```rust
if (a) {
    debug::print<u8>(&0);
} else {
    debug::print<u8>(&99);
};
```
`if` is an expression.
```rust
let value = if (true) { 8 } else {0}; // value set to 8
```

Move syntax for expressions and control flow shares similarities with Rust. Basic control flow constructs like if, while, and loop are present in Move as well. However, Move has a more limited set of expressions and control flow features compared to Rust.

### `while` and `loop`
Move supports `while` and `loop` looping constructs. `while` loops while  condition is true. `loop` loops infinitely. There is no `for` loop, both `while` and `loop` are roughly equally used as replacements.

```rust
// example of while loop
while (i < 10) {
    Vector::push_back(&mut a, i);
    i = i + 1;
};
```

## Types
### Primitives 
- Move has the primitive types `boolean`, `u8`, `u64`, `u128`, `address`, and `signer`.
- Move also supports hex- and byte-string literals.
```rust
let val = b"hello, world!"; // hex string
let val = x"hello, world!"; // byte string
```
- Integers can be type cast with the `as` keyword.
- The signer type represents the sender of a transaction and is used for access control and authentication.

### Abilities
Type abilities in Move specify certain primitive memory behaviors and constraints for types. These abilities are perhaps most similar to different pointer types in Rust.
- `copy`: The `copy` ability allows for the type's value to be cloned.
- `drop`: The `drop` ability enables the necessary cleanup actions when the type goes out of scope.
- `store`: The `store` ability allows the type to be stored inside global storage.
- `key`: The `key` ability allows the type's value to be used as a unique identifier or index in the global storage of the Move blockchain.
- Conditional abilities allow types to have different behaviors based on conditions.

### Generic and behavior
- Move supports generics for structs and functions.
- It's possible to achieve polymorphic behavior with generics and phantom types.
- Often you will want to [nest](https://www.move-patterns.com/nestable-resources.html) generic structures inside of resources to achieve polymorphism. See the `LiquidityPool` generic structure below for an example.

```rust
// polymorphic coin fee obtainment from liquidswap.
/// Get fee for specific pool.
public fun get_fee<X, Y, Curve>(): u64 acquires LiquidityPool {
    assert!(coin_helper::is_sorted<X, Y>(), ERR_WRONG_PAIR_ORDERING);
    assert!(exists<LiquidityPool<X, Y, Curve>>(@liquidswap_pool_account), ERR_POOL_DOES_NOT_EXIST);

    let pool = borrow_global<LiquidityPool<X, Y, Curve>>(@liquidswap_pool_account);
    pool.fee
}
```

## Resources, References, and Mutation
- You can borrow a reference with `&`. 
- Reference 
- Global storage operators `move_to`, `move_from`, `borrow_global_mut`, `borrow_global`, and `exists` in Move enable reading from and writing to resources stored in the blockchain's global storage.
- The acquires keyword is used to specify which resources a function acquires ownership of a resource during execution.
```rust
module collection::collection {

    struct Item has store, drop {}
    struct Collection has key, store {
        items: vector<Item>
    }

    public fun add_item(account: &signer) acquires Collection {
        let collection = borrow_global_mut<Collection>(Signer::address_of(account));

        Vector::push_back(&mut collection.items, Item {});
    }
}
```
Move allows the creation of read-only references to resources, ensuring that functions cannot modify them.
Here's a small code snippet demonstrating the use of Move syntax:

## Misc. syntax
- The `public` keyword in Move indicates that a function can be invoked from outside the current module.
- The `native` keyword is used to declare functions that are implemented in the blockchain runtime or in an external module.
- There are VM specific directives; in Movement we will address `#[inline]`, `#[test_only]`, and `#[test]`.