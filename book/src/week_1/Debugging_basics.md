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

```rust
module resource_roulette::resource_roulette {
  use std::vector;

  // ResourceRoulette struct representing the contract state
  struct ResourceRoulette {
    bids: vector<vector<address>>,
    owner: address,
  }

  struct RouletteWinnings {
    amount : u64
  }

  // Initialization function for the ResourceRoulette contract
  public entry fun init(account: &signer) {

    let bids = vector::empty<vector<address>>();
    let i = 0;
    while i < 32 {
      vector::push_back(&mut bids, vector::empty<address>())
      i = i + 1;
    };

    move_to<ResourceRoulette>(account, ResourceRoulette {
      bids,
      owner: @resource_roulette,
    });

  }

  // Bid function to allow signers to bid on a specific slot
  public entry fun bid(sender: &signer, slot: u8) acquires ResourceRoulette {
    let roulette = borrow_global_mut<ResourceRoulette>(@resource_roulette);
    let bids_size = vector::length(&roulette.bids);
    assert!(slot < bids_size, 99);
    // assert bids size does not exceed 100
    assert!(bids_size < 100, 0); 

    let slot_bids = vector::borrow_mut(&mut roulette.bids, slot);
    vector::push_back(&mut slot_bids, signer::address_of(sender));
  }

  public fun total_bid(): u64 acquires ResourceRoulette {
    // Make this more complex to support actual bidding
    let roulette = borrow_global<ResourceRoulette>(@resource_roulette);
    vector::length(&roulette.bids)
  }

  // Roll function to select a pseudorandom slot and pay out all signers who selected that slot
  public entry fun spin(sender: &signer) acquires ResourceRoulette {
    let roulette = ResourceRoulette::borrow_global_mut();
    assert!(singer::address_of(sender) == roulette.owner, 98);

    let resource_vector_size = vector::length(&roulette.bids);
    let winning_slot = (0x1000 % resource_vector_size) as u8;

    let winners = vector::borrow(&roulette.bids, winning_slot);

    let num_winners = vector::length(&winners_vec);
    let balance_per_winner = total_bid() / num_winners as u64;

    let mut i = 0;
    while i < num_winners {
      let winner = vector::borrow(&winners_vec, i);
      let mut winnings = borrow_global_mut<RouletteWinnings>(winner);
      winnings.amount = winnings.amount + balance_per_winner;
      i = i + 1;
    };

  }

}
```