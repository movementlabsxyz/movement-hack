# Primitive types

After completing this lession, you'll be able to define and assign values to primitive types (integer types, as operator, boolean, address).

## Understanding Primitive Types in Move with Everyday Examples

In the world of Move, the programming language used for blockchain development, there are some basic building blocks known as primitive types. These are the simple types used to represent numbers, whether something is true or false (boolean values), and unique identifiers for accounts or wallets on the blockchain (addresses). Let's dive into what these primitive types look like, using examples you might encounter in real life.

## Integer Types: Counting and Measuring

Move uses three types of integers: `u8`, `u64`, and `u128`. You can think of integers like the numbers you use to count things. For example:

* `u8` could be used to count the number of books on your shelf (up to 255, because `u8` ranges from 0 to 255).

* `u64` could help you count the number of grains of sand on a beach (up to 18 quintillion!).

* `u128` is for when you really need to count many more things, like all the stars in the universe.

Here's how you might see integers used in a Move script:

```rust
script {
    fun main() {
        let a: u8; // Maybe this is for counting up to 10 cookies.
        a = 10;

        let a: u64 = 10; // Counting something bigger, like 10 whales.

        let a = 10; // Move knows this is a number, likely a small one.

        let a = 10u128; // Now we're counting something huge, like 10 galaxies!

        // Using numbers in decisions
        if (a < 10) {}; // If we have fewer than 10, do something.

        // Specifying the type explicitly
        if (a < 10u8) {}; // Same idea, but we're making sure Move knows the size.
    }
}
```

## Operator `as`: Changing Your Perspective

Sometimes, you need to compare things of different sizes, like if a cup of water will fill a bucket. In Move, you can change the "size" of your integer using the as operator, to make sure you're comparing apples to apples.

```rust
script {
    fun main() {
        let a: u8 = 10; // A small number, like 10 marbles.
        let b: u64 = 100; // A bigger number, like 100 apples.

        // Comparing marbles to apples, we need to make sure they're seen the same way.
        if (a == (b as u8)) abort 11; // Check if 10 marbles are equal to 100 apples, viewed as marbles.
        if ((a as u64) == b) abort 11; // Or vice versa.
    }
}
```

## Boolean: Yes or No, True or False

Booleans are straightforward – they can only be true or false. Think of them like answering a yes-or-no question: "Is it sunny outside?"

```rust
script {
    fun main() {
        // Declaring whether it's sunny or not
        let b : bool; b = true; // Yes, it is sunny.
        let b : bool = true; // Still sunny.
        let b = true; // Move knows it's about whether it's sunny.
        let b = false; // Now it's not sunny.
    }
}
```

## Address: Identifying Where Things Belong

In the blockchain world, an address is like the address of your house, but for your digital wallet or account. It's how you receive things (like cryptocurrency) or where you send them from.

```rust
script {
    fun main() {
        let addr: address; // Like saying, "This is where I live."

        // Use your specific blockchain address here, like your home address but for digital transactions.
        addr = {{sender}}; // Replace `{{sender}}` with your actual address.

        // Addresses look different on different blockchains:
        addr = 0x...; // On some blockchains, it's a long string of numbers and letters.
        addr = wallet1....; // On others, it starts with words and looks a bit friendlier.
    }
}
```

## Wrap-Up

In Move, these primitive types form the foundation of the language, allowing you to count, measure, make decisions, and identify accounts on the blockchain. By understanding integers, booleans, and addresses, you're well on your way to mastering the basics of Move and blockchain programming.
