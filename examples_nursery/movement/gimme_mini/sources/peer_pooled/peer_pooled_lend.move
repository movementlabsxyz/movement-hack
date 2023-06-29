module peer_pooled_lend::peer_pooled_lend {

    use std::signer;
    friend mini_lend::LoanOfficer;

    /// Lends funds to liquidity pool.
    /// 1. LoanOfficer will...
    ///     1. Check if account has enough funds to lend.
    ///     2. Check for suspicious activity.
    /// 2. If account has enough funds to lend...
    ///     1. MiniLend will transfer funds from account to liquidity pool.
    public fun lend(account : signer, amount : u64){




    }

    /// Allows lender to seek repayment from liquidity pool.
    /// 1. LoanOfficer will...
    ///     1. Determine whether account is lender.
    ///     2. Determine loan period is up.
    /// 2. If the account is a valid lender and the loan period is up...
    ///     1. MiniLend will transfer funds from liquidity pool to account or self-collateralize.
    public fun seek_repayment(account : signer, amount : u64){

        // Call the audit first so that the books are up to date 
        // and collateralization has been handled.

    }

    /// Borrows funds from liquidity pool.
    /// 1. LoanOfficer will... 
    ///     1. Check if account has enough collateral
    ///     2. Check account credit.
    ///     3. If account has enough collateral and credit...
    /// 2. If account has enough collateral and credit...
    ///     1. MiniLend will borrow funds from liquidity pool
    /// 3. Whether or not the account will successully borrow funds, run the audit function.
    public fun borrow(account : signer, amount : u64){


    }

    public fun repay(account : signer, amount : u64){

        

    }

    /// Looks over loan tables and dispatches events to manage loans
    /// Anyone can call this function enabling decentralized book keeping.
    public fun audit(account : signer){

    }

}

module mini_lend::LoanOfficer {


}