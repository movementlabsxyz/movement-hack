# Modules and Imports

In this lesson, you'll gain experience writing Move modules and importing functions and types from other modules.

In Move, a language designed for blockchain development, modules play a crucial role in organizing code, while imports allow for modularization and reusability. Here's an in-depth look at how to create modules and import functions and types from them, illustrated with practical examples.

## Creating Modules in Move

A module in Move is akin to a package of code that contains functions, types, and resources, encapsulating related functionality under a single namespace. Modules are published under a developer's address and can be utilized by scripts and other modules.

## Example: Defining a Simple Math Module

Let's start with a basic example of a module that performs arithmetic operations:

```rust
module 0x1::SimpleMath {
    // A public function to add two numbers
    public fun add(a: u64, b: u64): u64 {
        a + b
    }

    // A public function to subtract two numbers
    public fun subtract(a: u64, b: u64): u64 {
        a - b
    }
}
```

This SimpleMath module provides two functions, add and subtract, which can be used by other parts of your Move application.

## Importing from Modules

To use the functionality defined in a module, you must import it. This can be done in scripts or other modules.

You can directly reference a module by its address when calling its functions:

```rust
script {
    use 0x1::SimpleMath;

    fun demonstrate_arithmetic() {
        let sum = SimpleMath::add(5, 3);
        let difference = SimpleMath::subtract(10, 4);
    }
}
```

In this script, we're using the add and subtract functions from the SimpleMath module to perform arithmetic operations.

## Using `use` to Import Modules

The use keyword simplifies imports, especially when dealing with multiple functions or types from the same module:

```rust
use 0x1::SimpleMath;

script {
    fun utilize_math_operations() {
        let total = SimpleMath::add(20, 15);
        let remainder = SimpleMath::subtract(30, 5);
    }
}
```

By importing SimpleMath at the script's beginning, we make its functions readily available for use.

## Advanced Importing Techniques

Move's importing capabilities also include importing specific members of a module or using aliases to avoid naming conflicts.

If you only need certain functions from a module, you can import them individually:

```rust
use 0x1::SimpleMath::{add, subtract};

script {
    fun math_demo() {
        let sum = add(8, 2); // Directly using the imported `add` function
        let difference = subtract(10, 3); // Using the `subtract` function
    }
}
```

This approach keeps your script clean and focused, importing only what you need.

## Example: A Module for User Management

Consider a module designed for managing user profiles in a decentralized application:

```rust
module user_manager_addr::UserManager {
    struct Profile has key {
        username: vector<u8>,
        age: u8,
    }

    public fun create_profile(username: vector<u8>, age: u8): Profile {
        Profile { username, age }
    }

    public fun update_age(profile: &mut Profile, new_age: u8) {
        profile.age = new_age;
    }
}
```

Here we're using a named address.

For Aptos, in your `Move.toml` file, under `[addresses]` you would add:

```rust
user_manager_addr = "<your-account-address>"`
```

to store the UserManager module in your account.

For Sui, in `Move.toml` under `[addresses]` you could add user_manager_addr="0x0" to indicate that user_manager_addr is the root of the file. When you publish to Sui, the package will be assigned an arbitrary package ID.

This UserManager module defines a Profile struct and provides functions to create and update a user's profile.

## Importing Module Contents into Other Modules

Modules can use functionalities defined in other modules through imports. This promotes code reuse and modularity.

When a module's functionality is needed in another module, you directly reference it using its address and name:

```rust
module profile_analytics_addr::ProfileAnalytics {
    use <value-of-user-manager-addr>::UserManager;

    public fun display_username_length(profile: &UserManager::Profile): u64 {
        UserManager::Profile::username(profile).length() as u64
    }
}
```

In the ProfileAnalytics module, we're using the UserManager::Profile type and directly accessing the username field to compute its length, showcasing how to access types and fields across modules.

## Using `use` for Easier Access

The use statement simplifies access to external modules by allowing you to refer to them without specifying the full path each time:

```rust
address 0x3 {
module EnhancedUserManager {
    use <value-of-user-manager-addr>::UserManager::{Profile, create_profile, update_age};

    public fun birthday(profile: &mut Profile) {
        let current_age = Profile::age(profile);
        UserManager::update_age(profile, current_age + 1);
    }
}
}
```

Here, `EnhancedUserManager` imports specific functions and types from `UserManager`, making it easier to interact with user profiles, such as incrementing a user's age to celebrate a birthday.

## Advanced Import Techniques

Move's flexible import system also supports member imports and aliasing, providing fine-grained control over module content usage.

You can import only the necessary components from a module, reducing namespace clutter:

```rust
module TransactionLogger {
    use <value-of-user-manager-addr>::::UserManager::Profile;

    public fun log_profile_creation(profile: &Profile) {
        // Logic to log profile creation
    }
}
```

This approach imports only the Profile struct, keeping the module focused on its specific logging responsibilities.

## Aliasing with `as`

Aliasing resolves naming conflicts and shortens verbose module names for convenience:

```rust
module SecureUserManager {
    use <value-of-user-manager-addr>::UserManager as UM;

    public fun secure_age_update(profile: &mut UM::Profile, encrypted_age: u8) {
        // Decrypt age and update profile
        let decrypted_age = decrypt(encrypted_age);
        UM::update_age(profile, decrypted_age);
    }
}
```

SecureUserManager uses UM as an alias for UserManager, streamlining access to the original module's functionality while adding an encryption layer.

## Conclusion

By leveraging modules and imports, Move developers can build well-organized, modular, and reusable code. This structured approach facilitates collaboration across large-scale projects by clearly defining, isolating and reusing different components.
