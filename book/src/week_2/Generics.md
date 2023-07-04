# Generics, type constraints, and polymorphism
In this section we will examine Move's support for common type-level program models. Owing to the strictness of its programming model, many of the features found in modern programming languages are not available in Move. 

We conclude with a programming example, _💻 MoveNav_, that implements a polymorphic navigation module using Move.

## Generics 
Generics act as abstract stand-ins for concrete types and allow for type-independent code. A single function written with generics can be used for any type. In the Move language, generics can be applied to struct and function signatures. 

```rust
// source: https://move-language.github.io/move/generics.html
fun id<T>(x: T): T {
    // this type annotation is unnecessary but valid
    (x: T)
}

struct Foo<T> has copy, drop { x: T }

let x = id<bool>(true); // ok!
let x = id<u64>(true); // error! true is not a u64

struct Foo<T> has copy, drop { x: T }

let foo = Foo<bool> { x: 0 }; // error! 0 is not a bool
let Foo<address> { x } = foo; // error! bool is incompatible with address
let bar = Foo<bool> { x : true }; // ok!
```

## Move does not support subtyping or composable type constraints
In Rust you can write code that composes traits to implement functionality similar to subtyping in other languages.
```rust
trait Animal {
    fn make_sound(&self);
}

trait Fly {
    fn fly(&self);
}

trait Swim {
    fn swim(&self);
}

trait FlyingSwimmingAnimal: Animal + Fly + Swim {
    fn do_flying_swimming_stuff(&self) {
        self.make_sound();
        self.fly();
        self.swim();
    }
}

struct Duck {
    name: String,
}

impl Animal for Duck {
    fn make_sound(&self) {
        println!("The duck {} says quack!", self.name);
    }
}

impl Fly for Duck {
    fn fly(&self) {
        println!("The duck {} is flying.", self.name);
    }
}

impl Swim for Duck {
    fn swim(&self) {
        println!("The duck {} is swimming.", self.name);
    }
}

fn perform_actions<T: Animal + Fly + Swim>(animal: &T) {
    animal.make_sound();
    animal.fly();
    animal.swim();
}

fn main() {
    let duck = Duck {
        name: String::from("Donald"),
    };
    
    perform_actions(&duck);
}
```
As part of the strictness of its programming model, Move does not support these constructs. Instead to achieve something similar to subtyping, it is often best to compose structs. That is, while you cannot establish an _is_ relationship between types, you can establish a _has_ relationship. This may be a more familiar model for those used to programming in C.

```rust
module 0x42::Animal {
    use std::string;
    use std::debug;

    struct Animal {
        sound : string;
        name : string;
    }

    struct FlyingAnimal {
        flies : bool;
        speed : u8;
        animal : Animal;
    }

    struct Bird {
        flying_animal : FlyingAnimal;
        feather_description : string;
    }

    fun make_sound(animal : Animal){
        debug::print(animal.sound);
    }

    fun bird_make_sound(bird : Bird){
        make_sound(bird.flying_animal.animal);
    }

}
```
Importantly, however, you cannot compose types to provide bounds on generic functions. An equivalent of `fn perform_actions<T: Animal + Fly + Swim>(animal: &T)` does not exist. 

Further below, we will discuss more advanced means of achieving similar subtyping and polymorphism. However, in most cases, you will be better off simply choosing a simpler programming model.

## The Four Type Abilities: `copy`, `drop`, `store`, and `key`
- `copy`: The `copy` ability allows for the type's value to be cloned.
- `drop`: The `drop` ability enables the necessary cleanup actions when the type goes out of scope.
- `store`: The `store` ability allows the type's value to be stored inside a struct in global storage.
- `key`: The `key` ability allows the type's value to be used as a unique identifier or index in the global storage of the Move blockchain.

These abilites may be used to define type bounds for generic functions and structs.

```rust
// source: https://move-language.github.io/move/global-storage-operators.html#global-storage-operators-with-generics

struct Box<T> has key { t: T }

// Publish a Container storing a type T of the caller's choosing
fun publish_generic_box<T>(account: &signer, t: T) {
    move_to<Box<T>>(account, Box { t })
}

/// Publish a container storing a u64
fun publish_instantiated_generic_box(account: &signer, t: u64) {
    move_to<Box<u64>>(account, Box { t })
}
```

Importantly, in the `publish_generic_box` example above, the type `T` must also have the `has` and `store` abilities owing to Move's rules of ability composition:

- `copy`: All fields must have copy.
- `drop`: All fields must have drop.
- `store`: All fields must have store.
- `key`: All fields must have store.


## Storage polymorphism
Storage polymorphism is the ability to index into global storage via a type parameter chosen at runtime. By leveraging storage polymorphism in combination with generics, Move developers can write generic algorithms, functions, and modules that can work with different resource types stored in the blockchain's storage. 

```rust
// source: https://move-language.github.io/move/global-storage-operators.html#global-storage-operators-with-generics

struct Box<T> has key { t: T }

// Publish a Container storing a type T of the caller's choosing
fun publish_generic_box<T>(account: &signer, t: T) {
    move_to<Box<T>>(account, Box { t })
}

/// Publish a container storing a u64
fun publish_instantiated_generic_box(account: &signer, t: u64) {
    move_to<Box<u64>>(account, Box { t })
}
```

While not as flexible as general polymorphism found in some languages, Move's storage polymorphism can quickly compose complex and useful operations for the blockchain. The below is an example of function for adding liquidity from Movement's dex router. Under the hood, global storage polymorphism is being used to enable to the publication of generic coins.

```rust
/// Add liquidity to pool `X`/`Y` with rationality checks.
/// * `coin_x` - coin X to add as liquidity.
/// * `min_coin_x_val` - minimum amount of coin X to add as liquidity.
/// * `coin_y` - coin Y to add as liquidity.
/// * `min_coin_y_val` - minimum amount of coin Y to add as liquidity.
/// Returns remainders of coins X and Y, and LP coins: `(Coin<X>, Coin<Y>, Coin<LP<X, Y, Curve>>)`.
///
/// Note: X, Y generic coin parameters must be sorted.
public fun add_liquidity<X, Y, Curve>(
    coin_x: Coin<X>,
    min_coin_x_val: u64,
    coin_y: Coin<Y>,
    min_coin_y_val: u64,
): (Coin<X>, Coin<Y>, Coin<LP<X, Y, Curve>>) {
    assert!(coin_helper::is_sorted<X, Y>(), ERR_WRONG_COIN_ORDER);

    let coin_x_val = coin::value(&coin_x);
    let coin_y_val = coin::value(&coin_y);

    assert!(coin_x_val >= min_coin_x_val, ERR_INSUFFICIENT_X_AMOUNT);
    assert!(coin_y_val >= min_coin_y_val, ERR_INSUFFICIENT_Y_AMOUNT);

    let (optimal_x, optimal_y) =
        calc_optimal_coin_values<X, Y, Curve>(
            coin_x_val,
            coin_y_val,
            min_coin_x_val,
            min_coin_y_val
        );

    let coin_x_opt = coin::extract(&mut coin_x, optimal_x);
    let coin_y_opt = coin::extract(&mut coin_y, optimal_y);

    let lp_coins = liquidity_pool::mint<X, Y, Curve>(coin_x_opt, coin_y_opt);
    (coin_x, coin_y, lp_coins)
}
```

## Unused and phantom types
In order to enforce type constraints at compile-time, unused type parameters can be marked as phantom type parameters. Arguments to phantom type parameters won't be considered when determining the abilities of the generic type. Thus, this eliminates the need for spurious ability annotations. 

Generics, along with storage polymorphism and phantom type parameters, offer flexibility, code reuse, and type safety. These features make it easier to create modular and reusable code components for safe contracts in the Move language. For instance, generics can be used to define generic data structures such as lists, maps, or queues that can store and manipulate values of any type. In addition, generics enable the creation of templatized algorithms which can operate on different types of data. 

```rust
// source: https://move-language.github.io/move/generics.html?highlight=phantom%20types#unused-type-parameters
module 0x2::m {
    // Currency Specifiers
    struct Currency1 {}
    struct Currency2 {}

    // A generic coin type that can be instantiated using a currency
    // specifier type.
    //   e.g. Coin<Currency1>, Coin<Currency2> etc.
    struct Coin<Currency> has store {
        value: u64
    }

    // Write code generically about all currencies
    public fun mint_generic<Currency>(value: u64): Coin<Currency> {
        Coin { value }
    }

    // Write code concretely about one currency
    public fun mint_concrete(value: u64): Coin<Currency1> {
        Coin { value }
    }
}
```

## 💻 MoveNav
💻 MoveNav implements Dijkstra's algorithm for navigating over a graph with different navigation types in move. 

We'll use a simple approach to domain modeling outlined below.

```rust
// redacted version of examples/movement/MoveNav
module 0x42::MoveNav {
    use std::vector;
    use std::option;
    use std::debug;

    struct Graph {
        nodes: vector<Vector3>,
        edges: vector<Edge>,
    }

    struct Vector3 {
        x: u8,
        y: u8,
        z: u8,
    }

    struct Edge {
        source: u8,
        target: u8,
        weight: u8,
    }

    struct Navigation {
        graph: Graph,
        navigation_type: NavigationType,
    }

    struct NavigationType {
        name: string,
        speed: u8,
    }

    fun navigate(nav: Navigation, start: Vector3, end: Vector3): option::Option<vector::Vector3> {
        debug::print("Navigating from ", start, " to ", end);

        let nav_type = &nav.navigation_type;

        if nav_type.name == "Walk" {
            debug::print("Walking at speed ", nav_type.speed);
            // Perform walking navigation logic
            return option::None;
        } 
        
        if nav_type.name == "Run" {
            debug::print("Running at speed ", nav_type.speed);
            // Perform running navigation logic
            return option::None;
        } 
        
        if nav_type.name == "Fly" {
            debug::print("Flying at speed ", nav_type.speed);
            // Perform flying navigation logic
            return option::None;
        } else {
            debug::print("Unsupported navigation type");
            return option::None;
        }

    
    }

    fun set_graph(nav: &mut Navigation, graph: Graph) {
        nav.graph = graph;
    }

    fun set_navigation_type(nav: &mut Navigation, nav_type: NavigationType) {
        nav.navigation_type = nav_type;
    }
}
```

To dive into the project, please clone this book's repo, and navigate to `examples/movement/MoveNav`.

## The future of Move type programming
The [MSL](https://github.com/move-language/move/blob/main/language/move-prover/doc/user/spec-lang.md#quantifiers) specification provides for more advanced type-level constructs. For ambitious developers, these may be powerful contribution objectives!