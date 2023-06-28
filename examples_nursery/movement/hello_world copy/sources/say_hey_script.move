script {
    use 0x2::say_hey;

    fun say_hey_script(account : signer){
        say_hey::print_hello();
    }
}