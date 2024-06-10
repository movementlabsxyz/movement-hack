# Collections

In this lesson you'll learn how to use vectors and tables to manage collections. You'll also gain an understanding of when it is appropriate to use each type in various real-world contexts.

`Table` is a powerful structure for managing key-value pairs, providing efficient access and modifications by keys.

## Sui Move Example: Account Balances

In Sui Move, Table is used for efficiently mapping keys to values.

```rust
module AccountBalanceManager {
    use sui::table::Table;
​
    struct AccountBalances {
        balances: Table<address, u64>,
    }
​
    public fun initialize() : AccountBalances {
        AccountBalances { balances: Table::new() }
    }
​
    public fun set_balance(balances: &mut AccountBalances, account: address, amount: u64) {
        Table::insert(&mut balances.balances, account, amount);
    }
​
    public fun get_balance(balances: &AccountBalances, account: address): u64 {
        Table::get(&balances.balances, account)
    }
}
```

This Sui Move example demonstrates managing account balances using Table, offering an efficient way to map account addresses to their balances.

## Aptos Move Example: Todo List Application

Aptos Move utilizes `Table` for similar key-value pair management but within its own standard library context.

```rust
module ToDoList {
    use aptos_std::table::{Self, Table};
​
    struct Task {
        id: u64,
        description: vector<u8>,
    }
​
    struct ToDoList {
        tasks: Table<u64, Task>,
    }
​
    public fun new_task(list: &mut ToDoList, id: u64, description: vector<u8>) {
        let task = Task { id, description };
        Table::add(&mut list.tasks, id, task);
    }
​
    public fun remove_task(list: &mut ToDoList, id: u64) {
        Table::remove(&mut list.tasks, id);
    }
}
```

In this example for Aptos Move, a todo list application is constructed using Table to map task IDs to task structs, allowing for efficient task management.

## Conclusion

The Vector and Table data structures in Move provide developers with powerful tools for managing collections within blockchain applications. Whether you're working with Sui Move or Aptos Move, these structures enable efficient data management, from ordered sequences with Vector to key-value pair mappings with Table. The examples provided for both Sui and Aptos demonstrate the practical application of these structures in real-world scenarios.
