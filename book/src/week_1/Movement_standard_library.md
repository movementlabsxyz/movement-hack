# Movement Packages
This section examines the Move standard library and Aptos framework. These are the most common starting points in M1 development. 

**Disclaimer:** there are many more useful modules in the standard library and framework. We will discuss some of them in this course and encourage you to explore them as you go.

## `aptos_std::debug` 
`aptos_std::debug::print` serializes and prints a Move value to the console using a VM `native` func. The associated `[debug]` outputs are easiest to view when unit testing.

`aptos_std::debug::print_stack_trace` prints the current stack.

The below is an example demonstrating print string nuances in 💻 `hello_world`.


```rust
module hello_world::hello_world {

    use std::string;
    use std::signer;
    use aptos_std::debug;

   
    #[test(account = @0x1)]
    public entry fun sender_can_set_message(account: signer) {
        let addr = signer::address_of(&account);
        debug::print<address>(&addr);
        let message = b"Hello, world!";
        debug::print(&message);
        let str_message = string::utf8(message);
        debug::print(&str_message);
    }
}
```

## `std::vector` and `aptos_std::big_vector`
A useful dynamically size collection with an `aptos_std::` counterpart optimized for a large number of elements.

The below is an example of searching through `std::vector` in open addressing hash map implementation from 💻 `data_structures`.

```rust
public fun find<K, V>(map: &OaHashMap<K, V>, key: &K) : &Option<Entry<K, V>> {
        
    let index = compute_hash_index(key, map.size);
    let count = 0;
    loop {
        let option_value = vector::borrow(&map.entries, index % map.size);
        if (option::is_none(option_value)) {
            return option_value
        } else {
            let entry = option::borrow(option_value);
            if (key_equals(&entry.key, key)) {
                return option_value
            }
        };
        index = index + 1;
        count = count + 1;
        if (count > map.size) {
            abort ENO_BUFFER_EXHAUSTED
        }
    }

}
```

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

## `aptos_framework::account`
One of the most notable features of the `aptos_framework` is its resource accounts. Per Aptos, "a resource account is a developer feature used to manage resources independent of an account managed by a user, specifically publishing modules and automatically signing for transactions." In some ways, you can think of a resource account as an administrator or service account. In most large projects, you will want to use resource accounts to--in the least--manage deployments.

Using resource accounts takes some practice. We encourage you to closely consider the code in 💻 `mini_dex` to get a better sense of how to use resource accounts. 

```rust
public entry fun initialize_lp_account(
    minidx_admin: &signer,
    lp_coin_metadata_serialized: vector<u8>,
    lp_coin_code: vector<u8>
) {
    assert!(signer::address_of(minidx_admin) == @mini_dex, EInvalidAccount);

    let (lp_acc, signer_cap) =
        account::create_resource_account(minidx_admin, b"LP_CREATOR_SEED");
    aptos_framework::code::publish_package_txn(
        &lp_acc,
        lp_coin_metadata_serialized,
        vector[lp_coin_code]
    );
    move_to(minidx_admin, CapabilityStorage { signer_cap });
}
```

For many common coin and NFT operations, the Aptos framework provides a set of methods that will manage capabilities. For example, the below is a snippet from an `aptos-core` example demonstrating how to initialize a coin:

```rust
/// initialize the module and store the signer cap, mint cap and burn cap within 
fun init_module(account: &signer) {
    // store the capabilities within `ModuleData`
    let resource_signer_cap = resource_account::retrieve_resource_account_cap(account, @source_addr);
    let (burn_cap, freeze_cap, mint_cap) = coin::initialize<ChloesCoin>(
        account,
        string::utf8(b"Chloe's Coin"),
        string::utf8(b"CCOIN"),
        8,
        false,
    );
    move_to(account, ModuleData {
        resource_signer_cap,
        burn_cap,
        mint_cap,
    });

    // destroy freeze cap because we aren't using it
    coin::destroy_freeze_cap(freeze_cap);

    // regsiter the resource account with both coins so it has a CoinStore to store those coins
    coin::register<AptosCoin>(account);
    coin::register<ChloesCoin>(account);
}
```

However, you will also often have to define your own capabilities. In the Aptos Framework, you will usually find it most idiomatic and convenient to use `use aptos_framework::account::SignerCapability` for this. 

Review 💻 `mini_dex` for an example of how to use `SignerCapability` to manage unique capabilities. As a challenge, design your own simple module including resource account logic and a `SignerCapability`.
