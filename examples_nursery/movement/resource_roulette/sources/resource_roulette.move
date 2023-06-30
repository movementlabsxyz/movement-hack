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
  public fun init(): ResourceRoulette {

    let mut bids = vector::empty<u8>();
    let mut i = 0;
    while i < 32 {
      vector::push_back(&self.bids, vector::empty<address>())
      i = i + 1;
    }

    move_to(@resource_roulette, ResourceRoulette {
      bids,
      owner: @resource_roulette,
    })

  }

  // Bid function to allow signers to bid on a specific slot
  public fun bid(slot: u8, sender: address) {
    let self = &mut borrow_global_mut<ResourceRoulette>(@resource_roulette);
    let bids_size = vector::length(&self.bids);
    assert(slot < bids_size, 99);

    let mut slot_bids = vector::borrow_mut(&self.bids, slot);
    vector::push_back(slot_bids, sender);

  }

  public fun total_bid() : u64 {
    // Make this more complex to support actual bidding
    return 100;
  }

  // Roll function to select a pseudorandom slot and pay out all signers who selected that slot
  public fun spin() {
    let self = &mut ResourceRoulette::borrow_global_mut();
    assert(sender() == self.owner, 98);

    let resource_vector_size = vector::length(&self.resource_vector);
    let winning_slot = (0x1u64 % resource_vector_size as u64) as u8;

    let winners = vector::borrow(&self.bids, winning_slot);

    let num_winners = vector::length(&winners_vec);
    let balance_per_winner = total_bid() / num_winners as u64;

    let mut i = 0;
    while i < num_winners {
      let winner = vector::borrow(&winners_vec, i);
      let mut winnings = borrow_global_mut<RouletteWinnings>(winner);
      winnings.amount = winnings.amount + balance_per_winner;
      i = i + 1;
    }

  }

}

