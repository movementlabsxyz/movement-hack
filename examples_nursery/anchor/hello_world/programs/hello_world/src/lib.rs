use anchor_lang::prelude::*;

declare_id!("FnTmCmzADAeEcc1gy9RtfTqw8HcP1hbpyGY5E6PZiiKW");

#[program]
pub mod hello_world {
    use super::*;

    pub fn initialize(ctx: Context<Initialize>) -> Result<()> {
        Ok(())
    }
}

#[derive(Accounts)]
pub struct Initialize {}