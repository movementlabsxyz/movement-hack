# Introduction to Smart Contracts

## Origins of smart contracts
Long before blockchain technology, American cryptographer and programmer, Nick Szabo, proposed the idea of the smart contracts in 1996. At the time of his proposal, the distributed ledger did not exist, and thus his idea could be not built upon. The first cryptocurrency, Bitcoin, was created in 2008, which helped to motivate the development of smart contracts. In 2013, Ethereum became the first platform to host smart contracts. Now, there are plenty of platforms that are used to bring Szabo's idea to life. 

When it comes to implementing smart contracts, resource orientation plays a crucial role in ensuring security, efficiency, and reliability. Resource-oriented programming languages, such as Move, have emerged as a powerful tool for developing smart contracts on blockchain platforms. Move, specifically designed for the Libra blockchain, places a strong emphasis on resource-oriented programming principles, which have proven to be highly beneficial in the context of smart contracts. Here's why resource orientation is important in languages like Move:

1. Security and Safety: Smart contracts often handle valuable digital assets, and any vulnerability or flaw in the contract's code can lead to disastrous consequences, including financial losses. Resource-oriented programming in Move enforces strict ownership and borrowing rules, ensuring that resources are properly managed and protected. The language's type system guarantees the absence of common vulnerabilities like reentrancy and enables static verification of contracts, minimizing the risk of critical bugs and making smart contracts more secure.

2. Efficient Resource Management: In traditional programming languages, objects or data structures are often copied or cloned when passed between functions or contracts. This can lead to unnecessary memory consumption and performance bottlenecks. Resource-oriented programming in Move takes a different approach. Resources are moved between functions or contracts, rather than being copied, ensuring efficient use of memory and reducing the risk of unintended side effects. Move's ownership model allows for fine-grained control over resource lifecycles, enabling optimized resource management within smart contracts.

3. Immutable and Transparent State: Blockchain technology inherently involves a distributed and immutable ledger that maintains the state of smart contracts. Resource-oriented programming aligns well with these characteristics, as Move enforces immutability for resources. Once a resource is created, its state cannot be modified directly, ensuring the integrity and consistency of the contract's data. This immutability also contributes to the transparency of the blockchain, as the entire history of resource states can be audited and verified by any participant.

4. Concurrent and Parallel Execution: In decentralized blockchain networks, multiple transactions can be executed concurrently, requiring smart contracts to handle concurrent access to shared resources. Resource-oriented programming provides a solid foundation for handling concurrent execution. Move's borrowing mechanism allows for controlled and safe concurrent access to resources, preventing data races and ensuring deterministic execution. This capability enables scalable and efficient execution of smart contracts in a distributed environment.

5. Upgradeability and Evolution: Smart contracts often need to evolve and adapt over time to incorporate new features, fix bugs, or address changing business requirements. Resource-oriented programming facilitates upgradability by decoupling the contract's data from its logic. By defining the behavior of resources separately from the contract's code, Move allows for smooth migration and upgrade of contracts while preserving the integrity of existing data and ensuring backward compatibility.

Resource orientation in languages like Move plays a pivotal role in the development of secure, efficient, and reliable smart contracts. By enforcing ownership and borrowing rules, enabling efficient resource management, ensuring immutability and transparency of state, supporting concurrent execution, and facilitating upgradability, Move empowers developers to build robust and future-proof smart contracts on the blockchain.

## Comparison: 💻 MulticontractFib
We've implemented a multi-contract fibonacci number computation in Solidity, Anchor, and Movement to illustrate the benefits of the move language and Movement. We encourage to run and compare the source for each. We've included devcontainers for Solidity and Anchor in the associated repo.

### Solidity 
Solidity is high-level, object-oriented programming language used to implement smart contracts. It is the primary programming language used on the Ethereum blockchain.

To work with the Solidity implementation, use the `solidity` devcontainer and work from the `examples/solidity/multicontract_fib` directory. 

### Anchor
Anchor is Solana's Sealevel runtime framework. It provides several developer tools for writing smart contracts in order to simplify the process and help developers to focus on their product.

To work with the Anchor implementation, use the `anchor` devcontainer and work from the `examples/anchor/multicontract_fib` directory. 

### Movement
This is us!

To work with the Anchor implementation, use the `movement` devcontainer and work from the `examples/movement/multicontract_fib` directory. 