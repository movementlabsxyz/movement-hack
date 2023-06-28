# Debugging Basic Smart Contracts
This section introduces a few basic smart contracts from this repository as a starting point for programming activites.

## 💻 HelloWorld
Is a very simple program for `MoveVM`. You can find it at `examples/move/hello_world`. 

```rust
script {
    use std::debug;
    // use std::vector;
    fun debug_script(account : signer) {

        // Encode the "Hello, world!" as a byte string.
        let hello = b"Hello, world!";

        // Print the byte string as a vector<u8> by passing a reference to the byte string.
        debug::print<vector<u8>>(&hello);

    }
}
```
To run...
```bash
move sandbox run sources/hello_world_script.move --signers 0xf
> [debug] 0x48656c6c6f2c20776f726c6421
```
Double-check the output hex...

```bash
echo 48656c6c6f2c20776f726c6421 | xxd -r - p
```

## 💻 Fib
The obligatory Move program that computes the $nth$ Fibonacci number. We will refer to this later when we do  💻 MulticontractFib. You can find it and instructions to run it `examples/move/fib`. 

## 💻 ResourceRoulette
A game of roulette on MoveVM. Place your address on an element in the vector. Contains methods `public fun bid` and `public fun spin`. Receive a payout if you placed your address on the correct cell. You can find it and instructions to run it `examples/move/resource_roulette`. 