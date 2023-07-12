module mini_dex::math {
    // sqrt function
    public fun sqrt(
        x: u64,
        y: u64
    ): u64 {
        sqrt_128((x as u128) * (y as u128))
    }

    
    public fun sqrt_128(
        y: u128
    ): u64 {
        if (y < 4) {
            if (y == 0) {
                0
            } else {
                1
            }
        } else {
            let z = y;
            let x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            };
            (z as u64)
        }
    }

    public fun min(
        x:u64,
        y:u64
    ): u64 {
        if (x < y) x else y
    }

    #[test]
    public entry fun test_sqrt() {
        let a = sqrt(1, 100);
        assert!(a == 10, 0);
        let a = sqrt(1, 1000);
        assert!(a == 31, 0);
        let a = sqrt(10003, 7);
        assert!(a == 264, 0);
        let a = sqrt(999999999999999, 1);
        assert!(a == 31622776, 0);
    }
}