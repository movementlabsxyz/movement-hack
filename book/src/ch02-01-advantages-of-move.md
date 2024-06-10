# Advantages of Move

In this lesson, you'll learn fundamental properties of Move, including resource-orientation and type linearity, and how Move addresses specific smart contract vulnerabilities.

## Resource-orientation and the blockchain

Resource-orientation is a fundamental concept in programming languages like Move that greatly benefits the blockchain ecosystem. By aligning with the principles of resource-oriented programming, the blockchain can enhance security, efficiency, and reliability of smart contracts.

## Stack Model Programming and Function Ownership

In resource-oriented programming, like Move, the stack model is employed to manage data ownership and control access. Take for example the following unsafe C program.

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void printAndFree(char* data) {
    printf("Data: %s\n", data);
    free(data); // Function takes ownership and frees the memory
}

int main() {
    char* value = (char*)malloc(strlen("Hello") + 1);
    strcpy(value, "Hello");
    
    printAndFree(value); // Pass ownership of 'value' to the function

    // Attempt to access the value after it has been freed
    printf("Data after freeing: %s\n", value); // Unsafe access!

    return 0;
}
```

{{#quiz ../quizzes/ch02-01-unsafe-access.toml}}

In Move, this kind of unsafe access would not be possible because of strict ownership conditions.

Each function owns any resources it creates and is responsible for its lifecycle. This ownership model ensures that resources are properly managed and prevents unauthorized access or modification, bolstering the security of blockchain-based applications.

## Access Restriction All the Way Down

Resource-oriented programming languages like Move implement access restrictions at all levels of code execution. From the top-level contract to individual functions, access to resources is strictly controlled. This granular access control minimizes the risk of unauthorized operations and ensures that only authorized parties can interact with specific resources, promoting secure and auditable transactions on the blockchain.

## Type Linearity and Ownership

*Linear type:* a type with an enforced the restriction that variables or values of the type can be used exactly once. In other words, each linear value has a unique owner or consumer, and it must be used or consumed linearly without duplication or uncontrolled consumption.

```javascript
f(a) -> g(a) -> h(a)
```

*Non-linear type:* a type without an enforced the restriction that variables or values of the type can be used exactly once. Variables or values of non-linear types can be used or accessed multiple times without restrictions.

```javascript
f(a) ->
    g(a)
    + h(a) -> 
        c(a)
        + k(a)
        + p(a)
```

Type linearity is a crucial aspect of resource-oriented programming that enforces the linear use of resources. In Move, resources generally have linear types, meaning they can only be consumed or moved, not duplicated. This feature prevents resource duplication, reduces memory consumption, and eliminates the risk of double-spending, ensuring the integrity and accuracy of transactions on the blockchain.

{{#quiz ../quizzes/ch02-01-type-linearity.toml}}

## How does Move address common smart contract vulnerabilities?

The resource-orientation and type-linearity of the Move programming language play a significant role in avoiding common smart contract vulnerabilities. Here's how these features address specific vulnerabilities:

>**1. Reentrancy Attacks:** In a reentrancy attack, a malicious contract calls back into the calling contract before the first execution completes, potentially leading to unexpected behavior or loss of funds. Move's resource-orientation ensures that resources (which include digital assets) cannot be duplicated and are used in a linear fashion. This linearity means that once a resource is moved, it cannot be accessed again within the same transaction, thereby mitigating reentrancy risks.
>
>**2. Integer Overflow and Underflow:** These occur when an operation attempts to create a numerical value outside the range that can be represented with a given number of bits. Move's type system can enforce range checks on numeric values, reducing the risk of overflow and underflow errors.
>
>**3. Unintended Ether Loss:** In Ethereum, contracts can be accidentally destroyed with ether still inside, leading to permanent loss of funds. Move's resource model can prevent this by ensuring that resources are accounted for at all times, making it much harder to lose them accidentally.
>
>**4. Frozen Ether:** Ether can become frozen in a contract due to bugs. Move's stronger guarantees about the state and its manipulation help avoid such scenarios, as the language is designed to make the effects of code more predictable and transparent.
>
>**5. Timestamp Dependence and Miner Manipulation:** Some contracts rely on block timestamps, which can be slightly manipulated by miners. Move's approach to resources and transactions doesn't inherently solve this, but its more predictable environment can help developers avoid relying on such external and manipulable factors.
>
>**6. Short Address/Parameter Attack:** This happens due to inconsistent handling of input data length. Move's strong typing and explicit resource management can help avoid this by enforcing correct input handling and data lengths.
>
>**7. Denial of Service (DoS) via Block Gas Limit:** Attackers might stuff blocks with expensive computations to exhaust a contract's gas. While this is more of a systemic issue, Move's efficiency and predictability in resource handling can mitigate some of the risks.
>
>**8. Unknown Function Calls:** In Ethereum, sending Ether to unknown functions can lead to vulnerabilities. Move's explicit resource accounting can help avoid such scenarios by making it clear where and how resources are flowing.
>

Move’s focus on safety, predictability, and explicit resource management addresses these vulnerabilities effectively, helping developers write safer smart contracts. This is particularly crucial in blockchain environments, where contract bugs and vulnerabilities can lead to significant financial losses and are often irreversible due to the immutable nature of blockchain technology.
