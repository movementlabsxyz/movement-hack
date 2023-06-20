use anchor_lang::prelude::*;

#[program]
mod fibonacci_program {
    use super::*;

    #[state]
    pub struct FibonacciLeft {}

    impl FibonacciLeft {
        pub fn calculate_fibonacci(&self, n: u64) -> Result<u64, ProgramError> {
            if n == 0 || n == 1 {
                Ok(n)
            } else {
                let right = &self.accounts.right;
                let result = right.calculate_fibonacci(n - 1)? + right.calculate_fibonacci(n - 2)?;
                Ok(result)
            }
        }
    }

    #[derive(Accounts)]
    pub struct FibonacciLeftAccounts<'info> {
        #[account(mut)]
        pub right: Box<Account<'info, FibonacciRight>>,
        pub rent: Sysvar<'info, Rent>,
    }

    #[state]
    pub struct FibonacciRight {}

    impl FibonacciRight {
        pub fn calculate_fibonacci(&self, n: u64) -> Result<u64, ProgramError> {
            if n == 0 || n == 1 {
                Ok(n)
            } else {
                let left = &self.accounts.left;
                let result = left.calculate_fibonacci(n - 1)? + left.calculate_fibonacci(n - 2)?;
                Ok(result)
            }
        }
    }

    #[derive(Accounts)]
    pub struct FibonacciRightAccounts<'info> {
        #[account(mut)]
        pub left: Box<Account<'info, FibonacciLeft>>,
        pub rent: Sysvar<'info, Rent>,
    }
}
