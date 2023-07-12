/// The module used to create user resource account
module mini_dex::lp_account {
    use std::signer;

    use aptos_framework::account::{Self, SignerCapability};

    const EInvalidAccount: u64 = 1;

    /// Temporary storage for user resource account signer capability.
    struct CapabilityStorage has key { signer_cap: SignerCapability }

    /// Creates new resource account for Mini Dex, puts signer capability into storage
    /// and deploys LP coin type.
    /// Can be executed only from @mini_dex account.
    public entry fun initialize_lp_account(
        minidx_admin: &signer,
        lp_coin_metadata_serialized: vector<u8>,
        lp_coin_code: vector<u8>
    ) {
        assert!(signer::address_of(minidx_admin) == @mini_dex, EInvalidAccount);

        let (lp_acc, signer_cap) =
            account::create_resource_account(minidx_admin, b"LP_CREATOR_SEED");
        aptos_framework::code::publish_package_txn(
            &lp_acc,
            lp_coin_metadata_serialized,
            vector[lp_coin_code]
        );
        move_to(minidx_admin, CapabilityStorage { signer_cap });
    }

    /// Destroys temporary storage for resource account signer capability and returns signer capability.
    /// It needs for initialization of mini_dex.
    public fun retrieve_signer_cap(minidx_admin: &signer): SignerCapability acquires CapabilityStorage {
        assert!(signer::address_of(minidx_admin) == @mini_dex, EInvalidAccount);
        let CapabilityStorage { signer_cap } =
            move_from<CapabilityStorage>(signer::address_of(minidx_admin));
        signer_cap
    }
}
