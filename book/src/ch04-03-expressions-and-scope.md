# Expressions and scope

By the end of this lesson, you'll demonstrate mastery of expressions and scope, including being able to evaluate when variables are accessible and what the values of experssions will be after execution.

In Move, expressions and scope are fundamental concepts that dictate how data is manipulated and accessed within your programs. Let's delve deeper into these concepts with more examples to illustrate their practical use in blockchain development.

## Expressions: The Heart of Logic and Calculation

Expressions in Move are any segments of code that compute a value. They're the workhorses of your program, responsible for everything from basic arithmetic to complex function calls. Here are various forms of expressions illustrated with examples:

* **Arithmetic Expressions:** Perform calculations using operators.

```rust
script {
    fun arithmetic_examples() {
        let sum = 5 + 3; // Adds up to 8
        let product = 4 * 7; // Multiplies to 28
        let is_greater = 10 > 5; // Evaluates to true
    }
}
```

* **Function Calls as Expressions:** When functions return a value, calling them is an expression.

```rust
script {
    fun add(a: u64, b: u64): u64 {
        a + b
    }
    fun function_call_example() {
        let result = add(2, 3); // 'add' function call returns 5
    }
}
```

* **Conditional Expressions:** Use conditions to determine values.

```rust
script {
    fun max(a: u64, b: u64): u64 {
        if (a > b) { a } else { b }
    }
}
```

Expressions enable you to encode the logic of your blockchain application, from simple value assignments to decision-making processes.

## Scope: Organizing Access and Visibility

Scope defines where in your code a variable or function is accessible. It's like having different boxes for your tools, where each tool is only available within its designated box.

* **Function Scope:** Variables are accessible only within the function they're declared in.

```rust
script {
    fun function_scope_example() {
        let in_function = "visible inside this function";
        // Access 'in_function' here
    }
    // 'in_function' is not accessible here
}
```

* **Block Scope:** A more granular level of scope within {}, affecting visibility of variables.

```rust
script {
    fun block_scope_example() {
        {
            let in_block = "visible inside this block";
            // Access 'in_block' here
        }
        // 'in_block' is not accessible here
    }
}
```

Understanding scope is crucial for managing data effectively and ensuring that your program's structure is both secure and logical.

## Combining Expressions with Scope

By combining expressions with a clear understanding of scope, you can write concise and powerful Move code. Here’s how they work together in a more complex example:

```rust
script {
    fun guess_the_number(guess: u8) {
        let secret_number = 7u8; // Only accessible within this function
        if (guess == secret_number) { // Conditional expression
            // Code to execute if the guess is correct
        } else {
            // Code for an incorrect guess
        }
    }
}
```

In this example, the variable secret_number is scoped to the guess_the_number function, and a conditional expression is used to compare guess to secret_number. This structure ensures that secret_number remains hidden outside the function, encapsulating the game's logic securely within its scope.

## Block Return Values

A block, delineated by curly braces {}, can contain a series of expressions and has the ability to return a value. This feature is particularly useful for executing a sequence of operations and then utilizing the result of the last expression as the block's output.

Consider you're programming a feature in a blockchain-based game where players can earn rewards based on their achievements. Let's say the reward calculation is slightly complex, involving multiple steps, but you want to keep your code clean and modular. Here's how you might use a block's return value to achieve this:

```rust
script {
    fun calculate_reward(points: u64): u64 {
        // A block to calculate the bonus multiplier based on points
        let bonus_multiplier = {
            if (points > 100) { 2 } // More than 100 points doubles the reward
            else if (points > 50) { 1 } // More than 50 points gives a standard reward
            else { 0 } // 50 points or less yields no bonus
            // The last expression's value is returned from the block
        };

        points * bonus_multiplier // The calculated bonus_multiplier is used here
    }

    fun main() {
        let player_points = 75;
        let reward = calculate_reward(player_points);
        // Use `reward` for further operations, like crediting to the player's account
    }
}
```

In this example, the calculate_reward function includes a block to determine the bonus_multiplier based on the player's points. The block evaluates the conditions and directly returns the multiplier value, which is then used to calculate the total reward. The absence of a semicolon after the conditionals within the block signifies that the result of the last evaluated expression is the return value of the entire block.

## Conclusion

Expressions and scope in Move are not just theoretical concepts but practical tools that shape how you interact with the blockchain. They allow you to perform calculations, make decisions, and structure your code in a way that aligns with the decentralized and secure nature of blockchain applications. By mastering these elements, you'll be well-equipped to tackle the challenges of blockchain development with Move.
