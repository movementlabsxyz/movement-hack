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