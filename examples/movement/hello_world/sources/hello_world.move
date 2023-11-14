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