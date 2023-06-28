script {
    use std::debug;
    fun debug_script(account: signer) {

        // Print the account object
        debug::print(&account)
        
    }
}