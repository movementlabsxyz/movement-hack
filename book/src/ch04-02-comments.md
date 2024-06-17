# Comments in Move

After completing this lesson, you'll be able to add in-line and block comments to Move code. And you'll understand best practices for using comments in Move.

Comments in Move programming are like the margin notes in a textbook: they're there to provide clarity, explanations, or to momentarily sideline pieces of code. Comments don't affect the execution of the program. But they can be invaluable for maintaining code readability and understanding, especially when working in teams or revisiting old code.

## Line Comments: Quick Notes and Side Comments

Line comments start with // and extend to the end of the line. They're perfect for brief explanations or temporarily disabling code lines. Here's how to use them:

```rust
script {
    fun main() {
        // This is a line comment explaining the following variable
        let cups_of_coffee = 2;

        // The next line is commented out and won't execute
        // let cups_of_tea = 3;

        let cups_of_water = 1; // This comment is at the end of a line
    }
}
```

Line comments are straightforward: anything after `//` on the same line is a comment and ignored during code execution. Use them to add quick notes or disable specific lines of code temporarily.

## Block Comments: For Longer Explanations and Large Sections

When you need to annotate more extensively or disable multiple lines of code, block comments are your go-to. These start with /*and end with*/, spanning across as many lines as needed:

```rust
script {
    fun calculate_beverages() {
        /* This block comment covers multiple lines, providing a space for
           more detailed explanations or for commenting out larger code sections
           without affecting readability. */
        let total_beverages = 10;

        /* Block comments can also be used inline to comment out
           specific parts of a line or expression. */
        let result = total_beverages /* - 5 */;
    }
    /* Entire functions or sections can be sidelined using block comments,
    making it easy to test different parts of the code.
    fun unused_function() {
        // Code here is not executed
    }
    */
}
```

Block comments offer flexibility for detailed annotations or for excluding chunks of code from execution. They're useful during debugging or when you want to provide comprehensive explanations within your code.

## Best Practices for Commenting

* **Clarity Over Quantity:** Write comments that clarify complex logic or decisions in your code, but avoid stating the obvious. Good code is self-explanatory for the most part.

* **Maintenance:** Keep comments updated as you modify your code. Outdated comments can be more misleading than no comments at all.

* **Disable With Care:** While commenting out code is handy for quick tests, avoid leaving chunks of unused code in your final version. It clutters the codebase and can confuse others.

## Conclusion

Comments are a simple yet powerful feature in Move, enhancing the readability and maintainability of your blockchain applications. Whether you're jotting down a quick note with a line comment or explaining a complex algorithm with a block comment, these annotations are key to building understandable and collaborative codebases.
