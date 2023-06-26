# Type constraints,  polymorphism, and generics

## The concept of subtyping allows a type to be considered a subtype of another type. A subtype inherits the properties and behaviors of its supertype and introduces additional properties or behaviors of its own. The subtype can be used in any context where the supertype is expected. In order to prioritize security, the Move language contains no explicit support for subtyping. 

## There are four type abilities: Copy, Drop, Store, and Key. The Copy ability allows for the type's value to be cloned. The Drop ability enables the necessary cleanup actions when the type goes out of scope. The Store ability allows the type to be stored inside global storage. The Key ability allows the type's value to be used as a unique identifier or index in the global storage of the Move blockchain.

## Generics act as abstract stand-ins for concrete types and allow for type-independent code. A single function written with generics can be used for any type. In the Move language, generics can be applied to struct and function signatures. 
### Storage polymorphism is the ability to index into global storage via a type parameter chosen at runtime. By leveraging storage polymorphism in combination with generics, Move developers can write generic algorithms, functions, and modules that can work with different resource types stored in the blockchain's storage. 

### In order to enforce type constraints at compile-time, unused type parameters can be marked as phantom type parameters. Arguments to phantom type parameters won't be considered when determining the abilities of the generic type. Thus, this eliminates the need for spurious ability annotations. 

### Generics, along with storage polymorphism and phantom type parameters, offer flexibility, code reuse, and type safety. These features make it easier to create modular and reusable code components for safe contracts in the Move language. For instance, generics can be used to define generic data structures such as lists, maps, or queues that can store and manipulate values of any type. In addition, generics enable the creation of templatized algorithms which can operate on different types of data. 

## **💻** MoveNav: Dijkstra's algorithm for navigating over a graph with different navigation types.

## [MSL](https://github.com/move-language/move/blob/main/language/move-prover/doc/user/spec-lang.md#quantifiers)