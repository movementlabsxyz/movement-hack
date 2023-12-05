# Debugging Basic Smart Contracts
This section introduces a few basic smart contracts from this repository as a starting point for programming activites.

## 💻 `hello_world`
This very simple program for `Movement Move VM`. You can find it at `examples/movement/hello_world` prints values to debug console. Note the differences in encodings between the `b""` and `string::utf8` versions of the string.

> Learnings leveraged:
> - Basic Move syntax
> - Byte strings

```rust
module hello_world::hello_world {
    
    use std::string;
    use std::signer;
    use aptos_std::debug;

   
    #[test(account = @0x1)]
    public entry fun hello_world(account: signer) {
        let addr = signer::address_of(&account);
        debug::print<address>(&addr);
        let message = b"Hello, world!";
        debug::print(&message);
        let str_message = string::utf8(message);
        debug::print(&str_message);
    }

}
```
To test run...
```bash
movement aptos move test
> [debug] @0x1
> [debug] 0x48656c6c6f2c20776f726c6421
> [debug] "Hello, world!"
```
If you want to double-check the output hex...
```bash
echo 48656c6c6f2c20776f726c6421 | xxd -r - p
```

## 💻 `fib`
The obligatory Move program that computes the _nth_ Fibonacci number. We will refer to this later when we do  💻 MulticontractFib. You can find it and instructions to run it `examples/movement/fib`. 

> Learnings leveraged:
> - Basic Move syntax
> - Move recursion.

## 💻 `data_structures`
From scratch implementation of a priority queue, a couple variations of a hash map, and a binary tree. This may be a useful reference point for building more challenging projects that require custom data strucures. You can find it at `examples/movement/data_structures`. 

> Learnings leveraged:
> - Basic Move syntax
> - Vectors
> - BCS
> - Move idioms

## 💻 `resource_roulette`
A game of roulette on MoveVM. Place your address on an element in the vector. Contains methods `public fun bid` and `public fun spin`. Receive a payout if you placed your address on the correct cell. You can find it and instructions to run it at `examples/movement/resource_roulette`. 

> Learnings leveraged:
> - Basic Move syntax
> - Signer and address types
> - Borrows
> - Initialization
> - Move idioms

```rust
module resource_roulette::resource_roulette {
  use std::vector;
  use std::signer;

  const ENO_UNAUTHORIZED_ADDRESS : u64 = 0;

  // ResourceRoulette struct representing the contract state
  struct ResourceRoulette has key {
    bids: vector<vector<address>>,
    owner: address,
    state : u64
  }

  struct RouletteWinnings has key {
    amount : u64
  }

  // Initialization function for the ResourceRoulette contract
  public fun init(account: &signer) {

    assert!(signer::address_of(account) == @resource_roulette, ENO_UNAUTHORIZED_ADDRESS);

    let bids = vector::empty<vector<address>>();
    let i = 0;
    while (i < 32) {
      vector::push_back(&mut bids, vector::empty<address>());
      i = i + 1;
    };

    move_to(account, ResourceRoulette {
      bids,
      owner: @resource_roulette,
      state : 17203943403948
    });

  }

  // Initializes winnings for a signer
  public fun init_winnings(account: &signer) {
    move_to(account, RouletteWinnings {
      amount: 0,
    });
  }

  // Bid function to allow signers to bid on a specific slot
  public fun bid(account : &signer, slot: u8) acquires ResourceRoulette {

    if (!exists<RouletteWinnings>(signer::address_of(account))) {
      init_winnings(account);
    };

    let self = borrow_global_mut<ResourceRoulette>(@resource_roulette);
    roll_state(self);
    let bids_size = vector::length(&self.bids);
    assert!(slot < (bids_size as u8), 99);
    let slot_bids = vector::borrow_mut(&mut self.bids, (slot as u64));
    vector::push_back(slot_bids, signer::address_of(account));

  }

  public fun total_bid() : u64 {
    // Make this more complex to support actual bidding
    return 100
  }

  // rolls state using xoroshiro prng
  fun roll_state(self :&mut ResourceRoulette) {
    let state = (self.state as u256);
    let x = state;
    let y = state >> 64;

    let t = x ^ y;
    state = ((x << 55) | (x >> 9)) + y + t;

    y = y ^ x;
    state = state + ((y << 14) | (y >> 50)) + x + t;
    
    state = state + t;
    state = state % (2^128 - 1);
    self.state = (state as u64);

  }

  public fun get_noise() : u64 {
    1
  }

  fun empty_bids(self : &mut ResourceRoulette){

    // empty the slots
    let bids = vector::empty<vector<address>>();
    let i = 0;
    while (i < 32) {
      vector::push_back(&mut bids, vector::empty<address>());
      i = i + 1;
    };
    self.bids = bids;

  }

  // Roll function to select a pseudorandom slot and pay out all signers who selected that slot
  public fun spin() acquires ResourceRoulette, RouletteWinnings {

    let self = borrow_global_mut<ResourceRoulette>(@resource_roulette);

    // get the winning slot
    let bids_size = vector::length(&self.bids);
    roll_state(self);
    let winning_slot = (get_noise() * self.state % (bids_size as u64)) ;

    // pay out the winners
    let winners = vector::borrow(&self.bids, winning_slot);
    let num_winners = vector::length(winners);

    if (num_winners > 0){
      let balance_per_winner = total_bid()/( num_winners as u64);
      let i = 0;
      while (i < num_winners) {
        let winner = vector::borrow(winners, i);
        let winnings = borrow_global_mut<RouletteWinnings>(*winner);
        winnings.amount = winnings.amount + balance_per_winner;
        i = i + 1;
      };
    };

    empty_bids(self);

  }

  // tests...

}
```