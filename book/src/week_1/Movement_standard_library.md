# Movement Standard Library
This section examines the standard library and framework that ships with Movement. Both are based on their Aptos namesakes. 

**Disclaimer:** there are many more useful modules in the standard library and framework. We will discuss some of them in this course and encourage you to explore them as you go.

## `std::debug` and `aptos_std::debug`
Prints to a message to the console using a VM `native` func. The associated `[debug]` outputs are easiest to view when unit testing.

```rust
module debug_demo::message {
    use std::string;
    use std::signer;
    use aptos_std::debug;

    struct MessageHolder has key {
        message: string::String,
    }


    public entry fun set_message(account: signer, message_bytes: vector<u8>)
    acquires MessageHolder {
        debug::print_stack_trace();
        let message = string::utf8(message_bytes);
        let account_addr = signer::address_of(&account);
        if (!exists<MessageHolder>(account_addr)) {
            move_to(&account, MessageHolder {
                message,
            })
        } else {
            let old_message_holder = borrow_global_mut<MessageHolder>(account_addr);
            old_message_holder.message = message;
        }
    }

    #[test(account = @0x1)]
    public entry fun sender_can_set_message(account: signer) acquires MessageHolder {
        let addr = signer::address_of(&account);
        debug::print<address>(&addr);
        set_message(account,  b"Hello, Blockchain");
    }
}
```

## `std::vector` and `aptos_std::big_vector`
A useful dynamically size collection with an `aptos_std::` counterpart optimized for a large number of elements.

## `aptos_std::table`
An associative array. 
```rust
fun run_table(account: signer) {
    let t = table::new<u64, u8>();
    let key: u64 = 100;
    let error_code: u64 = 1;
    assert!(!table::contains(&t, key), error_code);
    assert!(*table::borrow_with_default(&t, key, &12) == 12, error_code);
    add(&mut t, key, 1);
    assert!(*table::borrow_with_default(&t, key, &12) == 1, error_code);
    move_to(&account, TableHolder{ t });
}
```

## `std::option`
This module defines the Option type and its methods to represent and handle an optional value. The implementation is based on a vector.

```rust
fun option_contains() {
    let none = option::none<u64>();
    let some = option::some(5);
    let some_other = option::some(6);
    assert!(option::contains(&some, &5), 0);
    assert!(option::contains(&some_other, &6), 1);
    assert!(!option::contains(&none, &5), 2);
    assert!(!option::contains(&some_other, &5), 3);
}
```

## `aptos_framwork::resource_account`
A resource account is used to manage resources independent of an account managed by a user. This is is useful for building things like liquidity providers which we will discuss later in the course.


## 💻 ResourceRoulette pt. 2
A game of roulette on MoveVM. Place your address on an element in the vector. Contains methods `public fun bid` and `public fun spin`. Receive a payout if you placed your address on the correct cell, but only when cash out. Balances are tracked in a `aptos_std::table`. You can find it and instructions to run it `examples/movement/resource_roulette`. 

## 💻 MiniFs
A tiny key value store for `vector<u8>` files. Implements `store` and `load` functionality using a `aptos_framework::resource_account` and a `aptos_std::table`. You can find it and instructions to run it `examples/movement/mini_fs`. 