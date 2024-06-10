# Control flow

This lesson will help you gain the ability to use control loops safely. You'll be able to write for loops, while loops, and if statements, debug infinite loops, and assert preconditions in Move.

Move is an imperative language. Control flow mechanisms like loops and conditional statements allow developers to dictate the execution path of their code. This lesson provides an overview of these control structures with practical examples to help you understand how to implement and debug them effectively.

## The `if` Expression: Making Decisions

The if expression in Move lets you execute a block of code based on whether a condition is true or false. It's like deciding whether to take an umbrella based on whether it's raining.

```rust
script {
    fun decide_to_wear_sweater(temperature: u8) {
        // If the temperature is less than 20 degrees, wear a sweater.
        if (temperature < 20) {
            // Code to wear a sweater
        } else {
            // Otherwise, no sweater needed
        };
    }
}
```

In this example, the decision to wear a sweater is made based on the temperature. The syntax is: `if (condition) { ... } else { ... }`;

## Iterating with Loops

Move supports two types of loops: while for conditional looping and loop for potentially infinite loops.

## `while` Loop: Conditional Iteration

Use a while loop when you want to repeat an action until a certain condition becomes false. For example, incrementing a counter until it reaches a specified limit.

```rust
script {
    fun countdown(start: u8) {
        let mut counter = start;
        while (counter > 0) {
            // Code to display the countdown
            counter = counter - 1;
        };
    }
}
```

This loop decrements a counter from a starting value until it hits zero, mimicking a countdown timer.

## Infinite loop

An infinite loop will run forever unless explicitly exited with break. It's crucial to use it cautiously to avoid infinite loops that can consume excessive resources (gas) on the blockchain.

```rust
script {
    fun infinite_loop_example() {
        let mut i = 0;
        loop {
            i = i + 1;
            if (i == 5) { break; } // Exit the loop when `i` reaches 5
        };
    }
}
```

In this example, the loop increments i but exits before it becomes an infinite loop thanks to the break statement.

## Debugging Infinite Loops

Understanding how to safely exit a loop is essential for debugging. Use break to exit loops and continue to skip to the next iteration of the loop.

```rust
script {
    fun loop_with_conditions() {
        let mut i = 0;
        loop {
            i = i + 1;
            if (i % 2 == 0) { continue; } // Skip even numbers
            if (i > 10) { break; } // Stop looping when `i` exceeds 10
        };
    }
}
```

This loop increments i, skips even numbers using continue, and stops when i is greater than 10 using break.

## Using `assert!` for Preconditions

Move's assert! function is a powerful tool for checking conditions and aborting execution if the condition is not met, preventing unwanted states in your blockchain applications.

```rust
script {
    fun transfer_tokens(amount: u64) {
        // Ensure the amount is not zero before proceeding with the transfer
        assert!(amount > 0, 400); // 400 is an arbitrary error code
        // Code to transfer tokens
    }
}
```

In this example, assert! ensures that the token amount to be transferred is not zero, aborting the transaction with an error code if the condition fails.

## Conclusion

Control flow structures in Move, such as if expressions, while and loop loops, and the assert! function, are essential for creating dynamic and safe smart contracts. By leveraging these constructs, developers can write more robust and efficient applications on the blockchain. Practicing with these examples will help you become proficient in controlling the flow of your Move programs and debugging them effectively.
