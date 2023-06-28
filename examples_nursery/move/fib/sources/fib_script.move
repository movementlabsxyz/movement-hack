script {
    use 0x2::fib;
    use std::debug;

    fun main(account: signer, n: u64) {
        
        debug::print<u64>(fib::fib(n));

    }
}