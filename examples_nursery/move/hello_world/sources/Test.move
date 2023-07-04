module 0x3::test {
    use std::signer;

    struct Resource has key { i: u64 }

    public fun publish(account: &signer, value : u64) {
        move_to(account, Resource { i: value })
    }

    public fun write(account: &signer, i: u64) acquires Resource {
        borrow_global_mut<Resource>(signer::address_of(account)).i = i;
    }

    public fun unpublish(account: &signer) acquires Resource {
        let Resource { i: _ } = move_from(signer::address_of(account));
  }
}
