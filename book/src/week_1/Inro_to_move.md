# Introduction to Move and Movement: its history, design principles, use cases, particularly in DeFi applications.
This section is intended to orient the reader on the history of the language and various Move virtual machine implementations.

## Libra/Diem
The Move programming language was originally developed by Facebook's Libra project, now known as Diem, to facilitate the creation of smart contracts on its blockchain platform. The language takes its name from the underlying concept of moving resources rather than copying them, aligning with the principles of resource-oriented programming. Move was designed to address the unique challenges of blockchain development, such as security, efficiency, and scalability. Its origins can be traced back to the vision of creating a blockchain-based financial infrastructure that would be accessible to billions of people around the world. Today, Move continues to evolve as an open-source language, with a growing ecosystem and community supporting its development and adoption.

## Resource-orientation and the blockchain

Resource-orientation is a fundamental concept in programming languages like Move that greatly benefits the blockchain ecosystem. By aligning with the principles of resource-oriented programming, the blockchain can enhance security, efficiency, and reliability of smart contracts.

### Stack Model Programming and Function Ownership

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

In Move, this kind of unsafe access would not be possible because of strict ownership conditions.

Each function owns the resources it creates and is responsible for their lifecycle. This ownership model ensures that resources are properly managed and prevents unauthorized access or modification, bolstering the security of blockchain-based applications.

### Access Restriction All the Way Down

Resource-oriented programming languages like Move implement access restrictions at all levels of code execution. From the top-level contract to individual functions, access to resources is strictly controlled. This granular access control minimizes the risk of unauthorized operations and ensures that only authorized parties can interact with specific resources, promoting secure and auditable transactions on the blockchain.

### Type Linearity and Ownership

Type linearity is a crucial aspect of resource-oriented programming that enforces the linear use of resources. In Move, resources have linear types, meaning they can only be consumed or moved, not duplicated. This feature prevents resource duplication, reduces memory consumption, and eliminates the risk of double-spending, ensuring the integrity and accuracy of transactions on the blockchain.

### Double-Spending

Double-spending is a significant concern in decentralized systems where digital assets are involved. Resource-oriented programming, like Move, mitigates the risk of double-spending by enforcing strict ownership and borrowing rules. Resources can only be moved or consumed once, preventing malicious actors from creating multiple transactions using the same resource and effectively eliminating the possibility of double-spending attacks.

## Virtual machines and the blockchain

Virtual machines play a crucial role in the blockchain ecosystem, particularly in executing and enforcing the logic of smart contracts. They ensure that all nodes on the blockchain network run the same logic, enabling verification and consensus among participants.

### Smart Contracts: Nodes Running the Same Logic

Smart contracts are self-executing agreements with predefined conditions encoded in code. In the blockchain context, smart contracts are executed by nodes across the network. Virtual machines, such as the Move Virtual Machine (Move VM) used in the Move programming language, ensure that all nodes interpret and execute the smart contract code uniformly. This guarantees that the same logic is executed across the network, promoting trust and enabling reliable transaction execution.

### Verification: Nodes Talking About Running the Same Logic

Verification is a critical aspect of the blockchain ecosystem. Nodes need to agree on the validity of transactions and smart contract execution. Virtual machines facilitate this verification process by providing a standardized environment where nodes can discuss and agree upon the execution of the same logic. By achieving consensus on the outcomes, nodes can ensure the integrity and consistency of the blockchain.

### Virtual Machine: Makes Sure the Same Logic is the Same Logic

The virtual machine acts as an execution environment for smart contracts and other blockchain operations. It ensures that the same logic applied to a smart contract on one node is identical to the logic applied on every other node. This consistency is essential for achieving consensus and maintaining the immutability of the blockchain. Virtual machines, such as the Move VM, enforce the rules and protocols defined by the blockchain platform, allowing for secure and reliable execution of smart contracts.

### Move Virtual Machines
Several implementations of the Move virtual machine exist, including the Move VM, Aptos VM, and Sui VM. These implementations provide alternative approaches to executing Move code and offer flexibility and compatibility with different blockchain platforms and ecosystems. Each implementation has its own characteristics, optimizations, and use cases, catering to diverse blockchain development requirements.

### Limitations and Movement

The transaction processing speed (TPS) of the underlying blockchain is a primary limitation on smart contract complexity. Higher TPS allows for more intricate and computationally intensive smart contracts to be executed within a given time frame.

Movement facilitates a theoretical maximum TPS of 160,000 by combining the technologies of Move and Avalanche Snowball consensus. This scalability enhancement enables more sophisticated and resource-intensive smart contracts to be processed efficiently.

In addition to its high TPS, Movement provides developer-friendly features via its Aptos-based VM and an ergonomic standard library .