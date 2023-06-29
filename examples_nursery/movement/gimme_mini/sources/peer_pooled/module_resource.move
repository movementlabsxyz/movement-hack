module peer_pooled_lend::module_resource {
    use std::error;
    // use std::signer;
    use std::string;
    use aptos_framework::account;
    use aptos_framework::event;
    use aptos_framework::signer;
    use aptos_framework::account;
    use aptos_framework::coin::{Coin};
    use aptos_framework::resource_account;
    use aptos_framework::type_info;
    use std::option::{
        Option
    };

    // ERNO
    const ERNO_ADDRESS_MISMATCH: u64 = 1;

    struct ModuleResource has key {
        resource_signer_cap: Option<account::SignerCapability>,
    }

    public fun provide_signer_capability(resource_signer_cap: account::SignerCapability) {
        let account_addr = account::get_signer_capability_address(resource_signer_cap);
        let resource_addr = type_info::account_address(&type_info::type_of<MyModuleResource>());
        assert!(account_addr == resource_addr, ERNO_ADDRESS_MISMATCH);
        let module = borrow_global_mut<ModuleResource>(account_addr); 
        module.resource_signer_cap = option::some(resource_signer_cap);
    }

}