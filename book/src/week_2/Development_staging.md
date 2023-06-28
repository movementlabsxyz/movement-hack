# Smart Contracts development and staging

## Development
When building smart contracts for `movement` you can use both the `move` client and `movement` itself.

### `move`
The `move` CLI is a suitable tool for early and primitive development. You will not have access to the same onchain resources as when working with the `movement` CLI, such as access to our DEX. However, you will be able to use the `move sandbox` to build and run contracts. 

To make sure you are building with out standard library, include the following in your `Move.toml`.

```toml
[package]
name = "hello_world"
version = "0.0.0"

[dependencies]
# MoveNursery = { git = "https://github.com/move-language/move.git", subdir = "language/move-stdlib/nursery", rev = "main" }
MovementFramework = {  git = "https://github.com/movemntdev/movement-subnet.git", subdir = "vm/aptos-vm/aptos-move/aptos-framework", rev = "main" }

[addresses]
std =  "0x1"
hello_blockchain = "_"
```

### `movement`
The `movement` CLI provides an `aptos`-like interface for running Move language scripts and modules. For more details see the `movement` CLI docs.

When using `movement` in its default configuration, you will test and run contracts against our testnet. This is ideal for most Movement development.

## Staging 
The best way to publicly stage smart contracts for Movement is simply to us a `movement` CLI. If you are interested in a more private staging environment, you may use the `movement` CLI with the provided `movement` devcontainer to compose and stage against a local network.

> **Contribution**
> {: .contributor-block}
> Help us develop better tools for movement staging!