# Developer Setup
This section examines tooling and provides setup instructions for working with the Movement blockchain and the various examples in covered in this booklet.

## The Move ecosystem
The budding Move ecosystem sports a variety of developer friendly tools. As we list off tools that will be relevant to this booklet, keep in mind that there are number of projects we have not included.

### Virtual machines
As previously discussed, there are several virtual machine implementations available for Move development--each of with is paired with particular blockchain. Besides the `Movement VM`, the most well-know Move virtual machines are `Move VM`, `Aptos VM`, and `Sui VM`

We provide a comparison of these different virtual machines in our [docs](https://docs.movementlabs.xyz/#what-is-move). 

When selecting a virtual machine for development its important to consider performance, ease of use, and stability. `Aptos VM` built upon the original and stable `Move VM` to provide an improved developer experience. The `Movement VM` builds upon `Aptos VM` to provide improved performance.

### CLIs
There are three CLIs worth note in the Move language development space. All support building, testing, deploying, and running smart contracts.
- [`move`](https://github.com/move-language/move/tree/main/language/tools/move-cli): the original CLI for Move development. 
- `aptos`: the CLI for Aptos development.
- `movement`: our very own CLI.

In this booklet we will be working with `move` and `movement`. 

### Package managers
Move has a package manager, [movey](https://www.movey.net/). However, generally we will recommend adding dependencies directly to your `Move.toml` file. 
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

### IDE
There are several useful development enviroments for Move. This book will be geared towards using VsCode because of the its developer container features and its [Move analyzer](https://marketplace.visualstudio.com/items?itemName=move.move-analyzer). However, syntax highlighting has been implemented for other IDEs including [Vim](https://github.com/rvmelkonian/move.vim).

## Our Setup
We'll be using the `move` and `movement` CLIs; no package manager; and VsCode most-often running the `movement-dev` Docker container from [public.ecr.aws/c4i6k4r8/movement-dev](public.ecr.aws/c4i6k4r8/movement-dev).

To get started...
1. Clone the repo from which this book originates: https://github.com/movemntdev/movement-hack
2. Open the repo in VsCode.
3. Based on the advice provided for a given project, reopen the repo in one of `move`, `movement`, `anchor`, or `solidity` [devcontainers](https://code.visualstudio.com/docs/devcontainers/containers).

We will also occasionally use Rust and Python to complete various programming examples.

We will also discuss using our proxy service with the JavaScript. The `movement-dev` developer container provides an easy start place for this alternative means of interacting with the [subnet](https://docs.movementlabs.xyz/develop/get-started/deploy-and-interact-with-contract).