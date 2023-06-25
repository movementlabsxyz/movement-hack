# Week 2: **Advanced Move & Building Basic DeFi Smart Contracts**

## Type constraints,  polymorphism, and generics

- No subtyping
- Abilities (again)
- Generics deep dive
    - Storage polymorphism
    - Phantom type parameters
    - Practical uses
- **💻** MoveNav: Dijkstra's algorithm for navigating over a graph with different navigation types.
- [MSL](https://github.com/move-language/move/blob/main/language/move-prover/doc/user/spec-lang.md#quantifiers)

## Safety

- Linear programming again
- Resource safety again
- The Move Prover again

## Testing

- Test runner
    - Relevant directives
    - Assertions
- Organization
    - Recommended organization pattern
- Mocks and stubs
    - A guide for state-based simulation

## **Introduction to Smart Contracts**

- History
- Solidity
    - **💻** MulticontractFib: compute fib(n) using shared recursion amongst several contracts.
- Anchor
    - **💻** MulticontractFib: compute fib(n) using shared recursion amongst several contracts.
- Move
    - **💻** MulticontractFib: compute fib(n) using shared recursion amongst several contracts.

## Design Patterns

- This will basically just be https://www.move-patterns.com/transferable-witness.html, until I learn some more things for myself.

## Smart Contracts development and staging

- Tools
    - `move-cli`
    - `aptos`
- e2e testing
    - Aptos devnet
- Staging
    - `move-cli sandbox`
    - [Aptos devnet](https://aptos.dev/)
    - [Aptos local testnet](https://aptos.dev/nodes/local-testnet/local-testnet-index)
    - M1
- **💻** DayAtTheTrack: create, wager, and run a PRNG-based horse race—intended to go on Aptos devnet for shared resources.