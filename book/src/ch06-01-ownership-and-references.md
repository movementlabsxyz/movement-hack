# Ownership and References

In this lesson, you'll gain a deep understanding of ownership, including when to use mutable and immutable references in a variety of contexts.

Understanding ownership, move semantics, copy functionality, and references is crucial for effective Move programming. This guide will dive into these concepts with real-world examples, highlighting their importance in Move's Rust-like ownership model.

## `move` and `copy`

In Move, the concepts of "move" and "copy" dictate how data is transferred and duplicated across functions, ensuring secure and efficient data management.

## `move_to`

Using the `move_to` keyword explicitly transfers ownership of a variable to another scope or function. Once moved, the original variable is no longer accessible.

**Example: Transferring Ownership of a Ticket**

```rust
module TokenManager {
    use Std::Signer;
​
    struct Token has key, store {
        id: u64,
    }
​
    public fun create_token(owner: &signer, token_id: u64) {
        let new_token = Token { id: token_id };
        move_to(owner, new_token); // Moves `new_token` into global storage
    }
​
    public fun transfer_token(sender: &signer, receiver: address, token_id: u64) {
        let token = move_from<Token>(Signer::address_of(sender), token_id); // Moves out `Token` from sender's storage
        move_to(&receiver, move token); // Use `move` keyword to transfer ownership
    }
}
```

In this scenario, issuing a ticket creates a `Ticket` instance. When `transfer_ticket` is called with a `Ticket`, the `ticket`'s ownership is moved, simulating a real-world ticket transfer.

## Keyword `copy`

The `copy` keyword creates a duplicate of a value, allowing the original and the copy to coexist.

**Example: Cloning a Digital Asset**

```rust
module AssetManager {
    struct Asset has copy {
        asset_id: u64,
    }
​
    public fun replicate_asset(asset: &Asset): Asset {
        // Explicitly copying the asset
        *asset
    }
}
```

Here, `replicate_asset` takes a reference to an Asset and uses dereferencing (`*`) to implicitly use `copy`. This creates a duplicate asset of digital items that can be replicated.

## References

References allow functions to access or modify data without taking ownership, marked with & for immutable references and &mut for mutable references.

Move's borrow checker ensures references do not outlive the data they point to, preventing dangling references and ensuring data safety.

**Example: Borrowing a Book from a Library**

```rust
module Library {
    struct Book {
        title: vector<u8>,
    }
​
    public fun borrow_book(book: &Book) {
        // Temporarily accessing the book's title
        let _ = &book.title;
    }
}
```

This example demonstrates borrowing a reference to a Book to read its title without moving or copying the entire Book struct, ensuring the original Book remains unmodified and owned by the library.

## Dereferencing

Dereferencing, using the * operator, accesses the value a reference points to. In Move, this often implicitly involves copying the referenced value if it has the copy ability.

**Example: Accessing Account Balance**

```rust
module AccountManager {
    struct Account {
        balance: u64,
    }

    public fun check_balance(account: &Account): u64 {
        // Dereferencing to access balance
        *(&account.balance)
    }
}
```

In `check_balance`, dereferencing is used to read the `balance` field of an `Account` reference, illustrating safe data access patterns.

## Referencing Primitive Types

Primitive types in Move, such as `u64`, are inherently equipped with the copy ability, making them easy to pass by value without explicit references.

**Example: Updating a Score**

```rust
module Game {
    public fun update_score(score: u64, points: u64) -> u64 {
        score + points
    }
}
```

Here, update_score directly manipulates u64 values, demonstrating the straightforward handling of primitive types without the need for references.

## Conclusion

Ownership, move semantics, copying, and references form the backbone of Move's approach to data safety and management. By leveraging these features, developers can write secure, efficient, and expressive smart contracts, effectively managing complex data structures and relationships in blockchain applications. This guide's examples illustrate practical applications of these concepts, from asset management to digital libraries, highlighting Move's robustness and flexibility in various real-world scenarios.
