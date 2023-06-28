module ResourceRoulette {
  use std::vector;

  // ResourceRoulette struct representing the contract state
  struct ResourceRoulette {
    resource_vector: vector<u8>,
    bids: vector<vector<address>>,
    owner: address,
  }

  // Initialization function for the ResourceRoulette contract
  public fun init(): ResourceRoulette {
    ResourceRoulette {
      resource_vector: vector<u8>(10), // Change the size of the vector as per your requirement
      bids: vector<vector<address>>(10),
      owner: 0x0,
    }
  }

  // Bid function to allow signers to bid on a specific slot
  public fun bid(slot: u8, sender: address) {
    let self = &mut borrow_global_mut<ResourceRoulette>();
    let resource_vector_size = Vector::length(&self.resource_vector);
    assert(slot < resource_vector_size, 99);

    let bids = self.bids.get_mut(slot);
    let slot_bids = Vector::unwrap_or_create(bids, vector<address>(0));
    Vector::push(slot_bids, sender);
    self.bids.push(slot_bids);
  }

  // Roll function to select a pseudorandom slot and pay out all signers who selected that slot
  public fun roll() {
    let self = &mut ResourceRoulette::borrow_global_mut();
    assert(sender() == self.owner, 98);

    let resource_vector_size = Vector::length(&self.resource_vector);
    let winning_slot = (0x1u64 % move(resource_vector_size) as u64) as u8;

    let winners = self.bids.get(winning_slot);
    let winners_vec = Vector::unwrap_or_create(winners, vector<address>(0));

    let num_winners = Vector::length(&winners_vec);
    let balance_per_winner = Libra.balance() / move(num_winners) as u64;

    let mut i = 0;
    while i < move(num_winners) {
      let winner = Vector::borrow(&winners_vec, move(i));
      Libra.transfer_from_sender(move(winner), move(balance_per_winner));
      i = i + 1;
    }

    self.bids.pop(winning_slot);
  }

  // GetBidCount function to retrieve the number of bids placed on a specific slot
  public fun get_bid_count(slot: u8): u64 {
    let self = &ResourceRoulette::borrow_global();
    let bids = self.bids.get(slot);
    let bids_vec = Vector::unwrap_or_create(bids, vector<address>(0));
    Vector::length(&bids_vec) as u64
  }
}

