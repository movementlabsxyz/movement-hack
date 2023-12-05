# Developer Setup
This section examines tooling and provides setup instructions for working with the Movement blockchain and the various examples in covered in this booklet.

## The Move ecosystem
The budding Move ecosystem sports a variety of developer friendly tools. As we list off tools that will be relevant to this booklet, keep in mind that there are number of projects we have not included.

### Virtual machines
As previously discussed, there are several popular virtual machine implementations available for Move development--each of with is paired with particular blockchain. Besides the `Movement VM`, the most well-known Move virtual machines are `Move VM`, `Aptos VM`, and `Sui VM`

We provide a comparison of these different virtual machines in our [docs](https://docs.movementlabs.xyz/#what-is-move). 

When selecting a virtual machine for development it's important to consider performance, ease of use, and stability. `Aptos VM` built upon the original and stable `Move VM` to provide an improved developer experience. The `Movement VM` builds upon `Aptos VM` to provide improved performance.

### CLIs
There are three CLIs worthy of note in the Move language development space. All support building, testing, deploying, and running smart contracts.
- [`move`](https://github.com/move-language/move/tree/main/language/tools/move-cli): the original CLI for Move development. 
- [`aptos`](https://aptos.dev/tools/aptos-cli/install-cli/): the CLI for Aptos development.
- [`movement`](https://docs.movementlabs.xyz/developers/developer-tools/movement-cli): our very own CLI which is currently compatible with the Aptos CLI.

In this booklet we will be working with `movement`. More specifically, we will be working with the `aptos` framework. If you ever need help working with `movement` you can run `movement --help` or `movement <command> --help` for more information.

### Package managers
You can manage Move dependencies by adding them directly to your `Move.toml` file. 
```toml
[package]
name = "hello_world"
version = "0.0.0"

[dependencies]
AptosFramework = {  git = "https://github.com/movemntdev/aptos-core.git", subdir = "aptos-vm/aptos-move/aptos-framework", rev = "testnet" }

[addresses]
std =  "0x1"
hello_blockchain = "_"
```

Our version of the AptosFramework is slightly different from the upstream at https://github.com/aptos-labas/aptos-core.git. Please be mindful that, while our goal is to support the latest version of the Aptos Framework, we may occasionally lag behind the upstream--resulting in incompatibilities.

### IDE
There are several useful development enviroments for Move. This book will be geared towards using VsCode because of the its developer container features and its [Move analyzer](https://marketplace.visualstudio.com/items?itemName=move.move-analyzer). However, syntax highlighting has been implemented for other IDEs including [Vim](https://github.com/rvmelkonian/move.vim).

## Our Setup
We'll be using the `movement` CLI and VsCode most-often running the `movement-dev` Docker container from (mvlbs/m1)[https://hub.docker.com/repository/docker/mvlbs/m1/general].

To get started...
1. Clone the repo from which this book originates: https://github.com/movemntdev/movement-hack
2. Open the repo in VsCode.
3. Reopen the directory using the movement [devcontainer](https://code.visualstudio.com/docs/devcontainers/containers).

Alternatively, when working with `movement-dev` you may:

```
docker image pull mvlbs/m1
docker run -it -v "$(pwd):/workspace" mvlbs/m1 /bin/bash
```

We will also occasionally use Rust, TypeScript, and Python to complete various programming examples.

## Setting Up Your Own Environment
While we recommend using the above, if you want to set up your own project environment, you can install the `movement` CLI and then run `movement aptos init` in your chosen directory. This will create a `.movement` profile. You can then add a `Move.toml` and a sources directory to get started.