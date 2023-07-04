module DayAtTheTrack {

  // DayAtTheTrack struct representing the contract state
  struct DayAtTheTrack {
    horse_slots: vector<u64>,
    pending_bids: vector<vector<address>>,
    winning_slot: u8,
    payout_threshold: u64,
    owner: address,
  }

  // Initialization function for the DayAtTheTrack contract
  public fun init(payout_threshold: u64): DayAtTheTrack {
    DayAtTheTrack {
      horse_slots: vector<u64>(10), // Change the size of the vector as per your requirement
      pending_bids: vector<vector<address>>(10),
      winning_slot: 0,
      payout_threshold: payout_threshold,
      owner: 0x0,
    }
  }

  // Bid function to place bids on the next horse race
  public fun bid(slot: u8, sender: address) {
    let self = &mut DayAtTheTrack::borrow_global_mut();
    let horse_slots_size = Vector::length(&self.horse_slots);
    assert(slot < horse_slots_size, 99);

    let pending_bids = self.pending_bids.get_mut(slot);
    let mut slot_bids = match pending_bids {
      Some(bids) => bids,
      None => vector<address>(0),
    };
    Vector::push(&mut slot_bids, sender);
    self.pending_bids.push(slot_bids);
  }

  // StartRace function to initiate a new horse race
  public fun start_race() {
    let self = &mut DayAtTheTrack::borrow_global_mut();
    assert(sender() == self.owner, 98);

    // Transfer pending bids to current race bids
    let current_bids = self.pending_bids;
    self.pending_bids = vector<vector<address>>(0);

    // Update the horse slots with the new race bids
    for (slot, bids) in current_bids.into_iter().enumerate() {
      let slot_value = self.horse_slots.get(slot).unwrap_or(0);
      self.horse_slots.replace(slot, slot_value + bids.len() as u64);
    }
  }

  // Cheer function to make the horses run by incrementing their slot values
  public fun cheer(slot: u8) {
    let self = &mut DayAtTheTrack::borrow_global_mut();
    let horse_slots_size = Vector::length(&self.horse_slots);
    assert(slot < horse_slots_size, 99);

    let slot_value = self.horse_slots.get(slot).unwrap_or(0);
    self.horse_slots.replace(slot, slot_value + 1);
  }

  // Payout function to distribute rewards when a horse wins
  public fun payout() {
    let self = &mut DayAtTheTrack::borrow_global_mut();
    assert(self.winning_slot != 0, 97);

    let winners = match self.pending_bids.get(self.winning_slot - 1) {
      Some(winners) => winners,
      None => vector<address>(0),
    };

    let num_winners = Vector::length(&winners);
    let balance_per_winner = Libra.balance() / num_winners as u64;

    for winner in winners {
      Libra.transfer_from_sender(winner, balance_per_winner);
    }

    self.winning_slot = 0;
  }

  // CheckWin function to determine if a horse has crossed the payout threshold
  public fun check_win() {
    let self = &mut DayAtTheTrack::borrow_global_mut();
    let horse_slots_size = Vector::length(&self.horse_slots);

    for slot in 0..horse_slots_size {
      let slot_value = self.horse_slots.get(slot).unwrap_or(0);
      if slot_value >= self.payout_threshold && self.winning_slot == 0 {
        self.winning_slot = slot + 1;
        break;
      }
    }
  }
}
