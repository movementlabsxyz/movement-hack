script {
    use 0x3::test;
    fun test_script(account: signer) {
        test::publish(&account, 10)
    }
}