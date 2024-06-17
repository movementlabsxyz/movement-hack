# Custom types (structs)

In this lesson, you'll create structs to define custom types. And you'll apply abilities to structs to make them work in real-world applications.

Structs in Move are foundational for defining custom types, allowing developers to encapsulate and manage complex data within blockchain applications. This lesson delves into creating structs with various real-world examples, illustrating their versatility and power in data modeling.

## Struct Definition

A struct is defined using the struct keyword, followed by its name and a list of fields enclosed in curly braces. Each field must have a specified type.

**Example: A User Profile**

```rust
module UserProfile {
    struct Profile {
        username: vector<u8>,
        email: vector<u8>,
        age: u64,
    }
}
```

This `Profile` struct represents a user profile in an application, with fields for the username, email, and age.

## Nested Structs

Structs can contain other structs, enabling the modeling of complex hierarchical data.

**Example: Product Catalog**

```rust
module ProductCatalog {
    struct Price {
        amount: u64,
        currency: vector<u8>,
    }
​
    struct Product {
        id: u64,
        name: vector<u8>,
        price: Price,
    }
​
    struct Catalog {
        products: vector<Product>,
    }
}
```

Here, ProductCatalog defines a system for managing products, each with a `Price`. The Catalog struct holds a collection of Product instances.

## Struct Abilities

Structs in Move can be annotated with abilities that define how they can be used, such as copy, drop, store, or key.

**Example: A Tradable Asset**

module AssetManager {
    struct Asset has store {
        id: u64,
        owner: address,
        value: u64,
    }
}
The Asset struct is marked with the store ability, indicating it can be stored persistently in global storage, suitable for representing tradable assets.
Creating and Initializing Structs
Struct instances are typically created and initialized within functions. Move allows for direct field initialization or using variable names that match struct fields.

**Example: Creating a New Asset**

```rust
module AssetManager {
    // Assuming Asset struct is defined above...
​
    public fun create_asset(owner: address, asset_id: u64, asset_value: u64): Asset {
        Asset { owner: owner, id: asset_id, value: asset_value }
        // Or simply: Asset { owner, id: asset_id, value: asset_value }
    }
}
```

This function demonstrates creating a new Asset, highlighting the flexibility in struct initialization.

## Accessing Struct Fields

Access to struct fields is determined by their visibility. Within the module, fields can be accessed directly. Outside, accessor methods are needed.

**Example: Accessing and Modifying Asset Value**

```rust
module AssetManager {
    // Assuming Asset struct and create_asset function are defined...

    public fun get_asset_value(asset: &Asset): u64 {
        asset.value
    }

    public fun update_asset_value(asset: &mut Asset, new_value: u64) {
        asset.value = new_value;
    }
}
```

These functions provide read and write access to an Asset's value, showcasing field access control.

## Structs with Vectors

Vectors within structs enable dynamic collections of elements, useful for managing lists of items or records.

**Example: A Voting System**

```rust
module VotingSystem {
    struct Vote {
        candidate_id: u64,
        voter_id: address,
    }

    struct Ballot {
        votes: vector<Vote>,
    }

    public fun cast_vote(ballot: &mut Ballot, vote: Vote) {
        Vector::push_back(&mut ballot.votes, vote);
    }
}
```

In `VotingSystem`, `Ballot` holds a collection of `Vote` structs, with functionality to cast new votes.

## Conclusion

Structs in Move are a powerful tool for defining custom types, enabling the modeling of complex data structures essential for blockchain applications. From simple user profiles to intricate product catalogs, structs offer the flexibility to create nuanced and sophisticated data models.
