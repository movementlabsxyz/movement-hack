module 0x2::say_hey {
    use std::debug;
    // use std::vector;

    public fun print_hello() {

        // Encode the "Hello, world!" as a byte string.
        let hello = b"Hello, world!";

        // Print the byte string as a vector<u8> by passing a reference to the byte string.
        debug::print<vector<u8>>(&hello);
        
    }

    public fun print_account(account : signer){

        // Print the account object
        debug::print(&account)

    }
}