# Testing
This section examines testing strategies for Move smart contracts on Movement. We will cover both automated and manual strategies for testing functionality.

## Movement profile configuration

```bash
movement init --network testnet
```

When building and testing an application, you will want to work against either the Movement testnet or a local network. The `movement` devcontainer is equipped with the `movement` CLI and uses `docker-compose` to start a local network; both options are available without additional setup when working with the devcontainer.

When beginning a project, run `movement init` and specify either `testnet` or `local`. The first profile you create will be called `default`.

To create a new profile run `movement init --profile <name-of-profile>`. You can then specify which profile you would like to use in various commands by `--profile <name-of-profile>`, e.g., `move run --profile default ...`.

You can inspect the details of all of your profiles at `.movement/config.yaml` in your working directory.

```yaml
# config.yaml
---
profiles:
  default:
    private_key: "0x23978a9c5a8c9291c3cb0283f5c4eee243f7ae81d62b3d3243aa06ac0fcde2cf"
    public_key: "0xf6ad6834565bda0f3fa8a093311f1a1308855773d2108cd04dd770da9c078ecd"
    account: 29f06cb1f4139484e8c3dcd9f915ad39acb2aee9a8e8064ee48cfc255ecf10ca
    rest_url: "https://fullnode.devnet.aptoslabs.com/"
    faucet_url: "https://faucet.devnet.aptoslabs.com/"
```

## Automated testing
Movement's CLI `movement` provides an `aptos`-like interface for building and testing Move smart contracts. The built-in testing functionality is best suited for unit testing. You can define tests in the same module or separately.

```rust
// hello_blockchain.move
module hello_blockchain::message {
    use std::error;
    use std::signer;
    use std::string;
    use aptos_framework::account;
    use aptos_framework::event;

    // ...

    #[test(account = @0x1)]
    public entry fun sender_can_set_message(account: signer) acquires MessageHolder {
        let addr = signer::address_of(&account);
        aptos_framework::account::create_account_for_test(addr);
        set_message(account,  string::utf8(b"Hello, Blockchain"));

        assert!(
          get_message(addr) == string::utf8(b"Hello, Blockchain"),
          ENO_MESSAGE
        );
    }
}
```

```rust
// hello_blockchain_test.move
#[test_only]
module hello_blockchain::message_tests {
    use std::signer;
    use std::unit_test;
    use std::vector;
    use std::string;

    use hello_blockchain::message;

    fun get_account(): signer {
        vector::pop_back(&mut unit_test::create_signers_for_testing(1))
    }

    #[test]
    public entry fun sender_can_set_message() {
        let account = get_account();
        let addr = signer::address_of(&account);
        aptos_framework::account::create_account_for_test(addr);
        message::set_message(account,  string::utf8(b"Hello, Blockchain"));

        assert!(
          message::get_message(addr) == string::utf8(b"Hello, Blockchain"),
          0
        );
    }
}
```

You can then run tests for the package containing modules from the movement CLI.

```bash
movement move test --named-addresses hello_blockchain=default
```
For advanced use of `movement` for automated testing, such as coverage, see the `movement` CLI [documentation](https://docs.movemnt.dev/movement/).

## Manual testing
Often, automated unit testing will be insufficient to determine that your smart contracts are ready for production. You will want to apply a set of end-to-end strategies to ensure smart contract quality. At the moment, all of these strategies are manual; however, automation can be built on-top of them.

> **Contribution**
> {: .contributor-block}
> Help us develop better tools for automated e2e and integration testing. 

### With `movement`
There three key instructions for manual testing using `movement`:
- `movement move publish`: publishes modules and scripts to the Movement blockchain.
- `movement move run`: runs a module or script.
- `movement account list`: lists resources values.

When testing manually, you will typically adopt a flow of `publish->run->list`. In the examples provided with this book's repository, you will commonly see bash scripts for running and testing Movement smart contract that orchestrate these three commands. The following is an example from our `hello_blockchain` contract:

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

begin "Setting hello_blockchain message to 'goodbye!'..."
echo "y" | movement move run --function-id default::message::set_message --args string:goodbye!
finish "Set hello_blockchain message to 'goodbye'!"

begin "Querying resources for account..."
movement account list --query resources --account default
finish "Queryed resourced for account!"
```

### Semi-automation
In many cases, you will find opportunities to automate the inspection of resources via `bash`, `python`, and other scripts. As you develop any of these testing strategies, we encourage you to share them with us so that we might make improvements to our CLI's capabilities.

> **Share**
> Share your semi-automated workflows with us!

## Testing directives
Movement provides several directives for testing which are important to understand.
### `#[test]`
Marks a test function. Can be provided with arguments.

When testing procedures that require signers, you will need set their values in the directive. Take the example below from 💻 ResourceRoulette

```rust
 #[test(account = @resource_roulette, bidder_one = @0x3)]
#[expected_failure(abort_code = FLAG_WINNER)]
public fun test_wins(account : &signer, bidder_one : &signer) acquires 
```

Here our test expects both resource account, i.e., `resource_roulette`, and a bidder signer, i.e., `bidder_one`. We will discuss how these are used below.

### `#[test_only]`
Test only is used for defining symbols that will only be compiled when testing. It can be useful for creating mocks and stubs, test boundaries and more.

### `#[expect_failure]`
Allows you to check if a routine aborts as expected, i.e., matching a certain error code.

In addition to asserting intended failures, you can use this behavior to define more complex tests that are based on boundary conditions being crossed. The example below from 💻 Resource Roulette uses this pattern to test whether winners emerge from the pseudorandom spinner.

```rust
#[test_only]
const BOUNDARY_WINNER : u64 = 1;

// Under the current state rolling implementation this will work
// More robust testing would calculate system dynamics
#[test(account = @resource_roulette, bidder_one = @0x3)]
#[expected_failure(abort_code = FLAG_WINNER)]
public fun test_wins(account : &signer, bidder_one : &signer) acquires ResourceRoulette, RouletteWinnings {

    init(account);
    let i : u64 = 0;
    while (i < 1_000) {
        bid(bidder_one, 7);
        spin();

        let winnings = borrow_global<RouletteWinnings>(signer::address_of(bidder_one));
        if (winnings.amount > 0) {
        abort BOUNDARY_WINNER
        };

        i = i + 1;
    };

}
```

## Mocks, stubs, and state-based simulation
In order to simulate and control the behavior of dependencies or external systems during testing, you may whish to apply mocking, stubbing, and stated-based simulation strategies. 

### Mocks and stubs
Mocks and stubs are both techniques used to simulate or replace certain components of a system being tested. A mock is a fake implementation of a method or an object, meant to simulate its real behavior. Stubs, on the other hand, are simplified implementations that do not imitate the real behavior. Instead, stubs produce a predefined response to a specific method call or input. Thus, mocks verify the behavior of code and stubs verify the state of the code.

Some of the modules in the standard library and framework will be suitable for mocking. The example below uses a resource account function to mock a specialized publishing process. A good strong understanding of the standard library can result in much cleaner solutions to mocking problems.

```rust
#[test_only]
public entry fun set_up_test(origin_account: &signer, resource_account: &signer) {
    use std::vector;

    account::create_account_for_test(signer::address_of(origin_account));

    // create a resource account from the origin account, mocking the module publishing process
    resource_account::create_resource_account(origin_account, vector::empty<u8>(), vector::empty<u8>());
    init_module(resource_account);
}
```

### State-based simulation
State-based simulation is a testing technique that focuses on verifying a program based the correctness of its state transitions. First, one must identify and define the states that the program can be in. Next, the events or actions that trigger a transition between states must be defined. Using this information, proper test cases should be generated to explore different state transitions and scenarios. 

### For `movement`
Beyond the `test` and `test_only` directives, Movement does not not provide any additional ergonomics for mocking, stubbing, or state-based simulation. However, opting for a common environment module may be suitable for more complex cases. The example below uses storage polymorphism to implement a common environment store.

```rust
address 0x42::Environment {

    // Unused type for global storage differentiation
    struct VariableA {}
    struct VariableB {}

    // A generic variable type that can be instantiated with different types
    struct VariableStore<phantom K, V> has store {
        value: V,
    }

    // Set the value of a variable
    public fun set_variable<K, V>(value: V) acquires VariableStore<K, V> {
        move_to<VariableStore<K, V>>(account, VariableSore { value })
    }

    // Get the value of a variable
    public fun get_variable<K, V>(): V acquires VariableStore<K, V> {
        borrow_global<VariableStore<K, V>>(addr).value
    }
}
```

When setting up your tests, you would then want to run something like the below. You'll likely want to simply create a type bridge in the module above to enable external sets from the CLI.

```bash
#!/bin/bash -e

# set environment
begin "Setting environment to slow..."
echo "y" | movement move run --function-id default::message::set_slow_variable --args string:slow
finish "Set environment to slow!"
```

> **Contribution**
> Help us develop mocking and stubbing tools for Movement. 