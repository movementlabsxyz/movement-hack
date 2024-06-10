# Getter and setter functions

In this lesson, you'll implement "getter" and "setter" functions to access and change the values of fields in custom types.

## Getter Functions

Getter functions are public functions that allow reading the values of private fields in a struct. They are essential for accessing data encapsulated within a struct from outside the module.

**Example: Accessing Account Information**

```rust
module AccountManager {
    struct Account {
        id: address,
        balance: u64,
    }
​
    public fun create_account(id: address, initial_balance: u64): Account {
        Account { id, balance: initial_balance }
    }
​
    // Getter for account ID
    public fun get_id(account: &Account): address {
        account.id
    }
​
    // Getter for account balance
    public fun get_balance(account: &Account): u64 {
        account.balance
    }
}
```

In this example, `get_id` and `get_balance` are getter functions allowing external access to an Account struct's id and balance fields, respectively.

## Setter Functions

Getter functions allow external code to read struct fields values. Setter functions allowing external code to "write" or modify the values of private fields in a struct. These functions allow you to update data in a controlled manner, ensuring any modifications are valid and safe.

**Example: Updating Account Balance**

```rust
module AccountManager {
    // Assuming Account struct is defined as before...
​
    // Setter for updating account balance
    public fun set_balance(account: &mut Account, new_balance: u64) {
        // Additional logic can be included here to validate the new balance
        account.balance = new_balance;
    }
}
```

The `set_balance` function allows the balance of an Account to be updated from outside the module. It takes a mutable reference to an Account and a new balance value, updating the balance field directly.

## Considerations for Getter and Setter Functions

- **Validation:** Setter functions can include validation logic to ensure that attempts to modify a struct's field adhere to specific rules or constraints. This is crucial for maintaining the integrity of the application's state.

- **Performance:** Frequent use of getter and setter functions may have implications on performance, especially in a blockchain context where operations have a cost. It's important to balance the need for external access with efficiency.

- **Security:** Getter and setter functions should be designed with security in mind, especially when dealing with sensitive or critical data. Proper validation and access controls can help prevent unauthorized or harmful modifications.

## Conclusion

Getter and setter functions in Move provide a safe and structured way to access and modify the fields of a struct from outside the module where it's defined. By carefully implementing these functions, developers can ensure data encapsulated within structs is accessible and mutable in a controlled and secure manner.
