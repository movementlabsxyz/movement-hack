# Safety
This section examines the safety features of Move in greater and more theoretical detail. There are no programming exercises designed for this section. It is primarily intended to motivate the usage of Move language in the context of blockchain.

## Linear logic
The Move Language was inspired by linear logic, a formal system of logic that was developed by Jean-Yves Girard in 1987. In linear logic, formulas were regarded as resources which could only be used once. Similarly, in the Move language, resources can only be moved between storage locations, never copied or dropped.

## Move type system
Move's type system enables special safety guarantees for resources. It ensures that move resources can not be duplicated, reused, or implicitly discarded. Attempts to duplicate, reuse, or implicitly discard a resource will result in a bytecode verification error. Notwithstanding these unique safeguards, resources in the Move language possess the characteristics of regular program values. They can be stored in data structures, passed as arguments to procedures, and utilized in similar ways.

```rust
module 0x42::LinearLogicExample {
    use std::vector;
    use std::debug;

    struct Token has drop {
        value: u8,
    }

    fun use_token(token: Token) {
        debug::print<vector<u8>>("Using token.");
        // Perform operations with the token...
    }

    public fun main() {
        let token: Token;

        token = Token { value: 10 };

        debug::print<vector<u8>>(b"Before use:");
        debug::print<u8>(token.value);

        use_token(token);

        debug::print<u8>(token.value);
        // Attempting to access `token` here would result in a compile-time error
    }
}
```

## [The Move Prover](https://www-cs.stanford.edu/~yoniz/cav20.pdf)
[The Move Prover](https://www-cs.stanford.edu/~yoniz/cav20.pdf) is a formal verification tool specifically designed for the Move programming language. The Move Prover performs static analysis of Move programs, exploring all possible execution paths and applying various verification techniques. It can reason about program behaviors, ownership and borrowing rules, resource lifecycles, and other aspects of Move's type system and semantics. By leveraging the Move Prover, developers can gain increased confidence in the correctness and security of their Move smart contracts. This tool helps identify potential issues before deployment, reducing the risk of vulnerabilities, ensuring adherence to best practices, and promoting the development of robust and reliable blockchain applications.

