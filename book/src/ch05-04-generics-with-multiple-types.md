# Generics with Multiple Types in Move

Generics aren't limited to single-type scenarios; Move allows defining structs and functions with multiple generic types, expanding the versatility and reusability of code. This feature is particularly useful when designing complex data structures or functions that need to operate on more than one type of data.

**Example: Pair Storage**

Imagine a module that needs to store pairs of items, which could be of any type. Using generics with multiple types, you can create a struct that accommodates pairs of different types.

```rust
module PairManager {
    struct Pair<T1, T2> {
        first: T1,
        second: T2,
    }

    public fun create_pair<T1, T2>(first: T1, second: T2): Pair<T1, T2> {
        Pair { first, second }
    }
}
```

This `Pair` struct can hold any combination of types, making it a flexible solution for various scenarios, such as storing key-value pairs where keys and values are of different types.

## Practical Application: Currency Conversion Rates

Consider an application that needs to manage currency conversion rates, which involve a pair of currencies and their conversion rate.

```rust
module CurrencyConverter {
    struct CurrencyCode {}

    struct ConversionRate<T1, T2> {
        from_currency: T1,
        to_currency: T2,
        rate: f64,
    }

    public fun set_rate<T1, T2>(from: T1, to: T2, rate: f64): ConversionRate<T1, T2> {
        ConversionRate { from_currency: from, to_currency: to, rate }
    }
}
```

In this example, `ConversionRate` uses generics to allow for flexibility in the types of currencies it can accept, potentially accommodating various currency representations.

## Working with Multiple Generic Types

A common utility operation is swapping the values of two variables. With generics, you can create a versatile swap function that works with any type.

```rust
module Utils {
    public fun swap<T1, T2>(first: &mut T1, second: &mut T2) {
        let temp = *first;
        *first = *second;
        *second = temp;
    }
}
```

This swap function can interchange the values of two variables of different types, showcasing the power of generics in creating highly reusable code components.

## Constraints on Multiple Generic Types

When working with multiple generic types, you can apply constraints to each type parameter independently, ensuring they meet certain requirements or abilities.

**Example: Key-Value Storage with Constraints**

```rust
module Storage {
    struct KeyValue<T1: key, T2: store> {
        key: T1,
        value: T2,
    }

    public fun create_key_value<T1: key, T2: store>(key: T1, value: T2): KeyValue<T1, T2> {
        KeyValue { key, value }
    }
}
```

In this `KeyValue` struct, constraints ensure that the `key` has the `key` ability (making it suitable for use as a unique identifier) and the `value` has the `store` ability (ensuring it can be saved in global storage).

### Conclusion

From asset management to e-commerce, the practical examples illustrated here demonstrate how generics underpin Move's versatility and safety. Generics with multiple types enhance the capability to write flexible and reusable code in Move. Generics underline Move's strength in supporting the development of complex smart contracts and decentralized applications.

### Chapter Quiz: Get credit on Galxe for weekly rewards

<iframe data-tally-src="https://tally.so/embed/w2ezrV?alignLeft=1&hideTitle=1&transparentBackground=1&dynamicHeight=1" loading="lazy" width="100%" height="415" frameborder="0" marginheight="0" marginwidth="0" title="Movement Hack Chapter 5 Quiz"></iframe><script>var d=document,w="https://tally.so/widgets/embed.js",v=function(){"undefined"!=typeof Tally?Tally.loadEmbeds():d.querySelectorAll("iframe[data-tally-src]:not([src])").forEach((function(e){e.src=e.dataset.tallySrc}))};if("undefined"!=typeof Tally)v();else if(d.querySelector('script[src="'+w+'"]')==null){var s=d.createElement("script");s.src=w,s.onload=v,s.onerror=v,d.body.appendChild(s);}</script>
