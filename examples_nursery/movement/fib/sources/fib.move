module fib::fib {

    public fun fib(n: u64) : u64 {
        if (n <= 1) {
            n
        } else {
            fib(n - 1) + fib(n - 2)
        }
    }

    #[test]
    public fun test_fib(){

       assert!(fib(0) == 0, 99);
       assert!(fib(5) == 5, 99);
       assert!(fib(1) == 1, 99);
       assert!(fib(13) == 233, 99);

    }

}