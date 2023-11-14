# Modules and Build System
This section treats with the basic functionality of the module and build system for Move.

## Packages
A folder with a `Move.toml` and compilable move code is a package. Packages may define external dependencies, which can be local or store at a remote repository. All Move clients used herein will automatically fetch and compile dependencies. When using `movement`, we will also define package addresses in the `Move.toml`.

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

## Program types
Move has two different types of program: _modules_ and _scripts_. As a general rule, you should use _scripts_ for short proofs of concept or as an entrypoint, see [Script Based Design](https://www.move-patterns.com/script-based-design.html). You can define multiple scripts and modules in the same file. 

### Modules 
Modules are great for code reuse. They can be reference and linked.  A module takes the following form.

```rust
module <address>::<identifier> {
    (<use> | <friend> | <type> | <function> | <constant>)*
}
```
When attempting to use logic in a module, you must specify the member function that you wish to call.

### Scripts
Scripts are a slightly easier to use alternative to modules. They take the following form.
```rust
script {
    <use>*
    <constants>*
    fun <identifier><[type parameters: constraint]*>([identifier: type]*) <function_body>
}
```
Scripts can only have one function in their body.

Within the context of `movement`, we will not be using scripts--instead preferring the module construct.

## Building
When developing _modules_ in Move you will need to publish the module before being able to run. The exception to this rule is when using `movement` to run unit tests. `movement move publish` will handle both the building and publication of modules in your current working directory. If you simply want to build the module to inspect its bytecode run `movement move build`.

Below is an example bash script for publishing and running a function in a module end-to-end using the Movement CLI drawn from 💻 `hello_blockchain`.

```bash
#!/bin/bash -e

# Function to echo text as cyan with emoji
function begin() {
  echo -e "🔹 \033[36m$1\033[0m"
}

# Function to echo text as green with increased font-weight and emoji
function finish() {
  echo -e "✅ \033[1;32m$1\033[0m"
}

begin "Funding account for hello_blockchain deployment and call..."
movement account fund-with-faucet --account default
finish "Funded account for hello_blockchain deployment and call!"

begin "Publishing hello_blockchain module..."
echo "y" | movement move publish --named-addresses hello_blockchain=default
finish "Published hello_blockchain module!"

begin "Setting hello_blockchain message to 'hello!'..."
echo "y" | movement move run --function-id default::message::set_message --args string:hello!
finish "Set hello_blockchain message to 'hello'!"

begin "Querying resources for account..."
movement account list --query resources --account default
finish "Queryed resourced for account!"
```

### `named_addresses`
The Move build system enables the usage of named addresses to simplify addressing schemes. These will be replaced at compile time whether they are in the adrress position in a module `<my_address_name>::my_module` or marked with an `@<my_address_name>` elsewhere.

In your `Move.toml`, you may specify these addresses as below.
```toml
[addresses]
std =  "0x1"
<my_address_name> = "_"
```

You may then specify them when compiling using `--<my_address_name>=<my_value>`.

Additional complexities that emerge when using named addresses are well documented in [Diem's original documentation of the Move language](https://diem.github.io/move/packages.html).

## 💻 `resource_roulette` dev-addresses
Resource roulette currently has a value in the `[addresses]` block that is better suited to `[dev-addresses]`. Find it an test the module.
