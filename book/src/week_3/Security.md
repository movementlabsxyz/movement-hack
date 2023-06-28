# Security
This section provides a high-level overview of common blockchain concerns and points to features of Movement or modules from the Movement standard library that can be used to help.

## M1
When working with M1 you will be able benefit from Avalanche's adaptive security and Move's strict programming model to avoid many of the vulnerabilities you would commonly encounter in smart contract development. You should, of course, remain aware of the vectors of attack.

## Attack Surface

### Blockchain
#### Network layer
The network layer of a blockchain application is susceptible to various attacks, such as distributed denial-of-service (DDoS) attacks, eclipse attacks, and Sybil attacks. These attacks can disrupt the network's functionality and compromise its security.

#### Consensus
The consensus mechanism used in a blockchain application can be targeted by attackers through attacks like 51% attacks, where they gain majority control over the network's computing power and manipulate transactions or block validation.

Thankfully, Avalanche consensus--which underpins movement--is designed to resist various attacks, including sybil attacks, distributed denial-of-service (DDoS) attacks, and collusion attacks. Its probabilistic nature ensures that the consensus outcome converges to the desired state, even when the network is under attack.

#### Blockchain protocol:
The underlying blockchain protocol may have vulnerabilities that can be exploited by attackers. Weaknesses in the protocol's cryptographic algorithms, consensus algorithms, or validation mechanisms can lead to security breaches.

### Smart contracts
#### Environment
Smart contracts rely on the execution environment in which they run. Insecure environments can expose smart contracts to attacks, such as sandbox escapes or unauthorized access to system resources.

#### External dependencies
Smart contracts often interact with external systems or data sources. These dependencies can introduce security risks, such as malicious data feeds or vulnerabilities in the connected systems.

#### Code vulnerabilities
Flaws in the code of smart contracts can lead to various vulnerabilities, including reentrancy attacks, integer overflow/underflow, and logic errors. These vulnerabilities can be exploited to manipulate contract behavior or steal funds.

Thankfully, thanks to its type-system, resource-orientation, and linear programming model, the Move language makes it difficult to publish code with many of the common smart contract vulnerabilities.

#### Upgradability
The ability to upgrade smart contracts introduces potential security risks. Unauthorized or malicious upgrades can compromise the integrity of the contract or introduce vulnerabilities that can be exploited.

Thankfully, the Move language introduces the concept of modules, which are self-contained units of code that encapsulate the functionality of smart contracts. Unlike traditional smart contracts, Move modules can be upgraded without disrupting the entire system or requiring complex migration processes.

### dApps

#### Integration risks 
Decentralized applications (dApps) often integrate with external services or APIs. Insecure integration points can expose dApps to security risks, such as unauthorized data access or injection of malicious code.

## Handling User Data

### Data minimization
Blockchain applications should follow the principle of data minimization, collecting only the necessary data and avoiding the storage of sensitive information that is not required for the application's functionality.

### Access control
Proper access control mechanisms should be implemented to ensure that only authorized individuals or entities can access sensitive user data. This includes authentication, authorization, and secure role-based access control.

Move uses an account-based ownership model where each account has its own address and associated permissions. Access control can be enforced at the account level, ensuring that only authorized users can perform specific actions.

### Encryption
Sensitive user data stored in the blockchain or associated systems should be encrypted to protect it from unauthorized access. Encryption algorithms and protocols should be carefully chosen and implemented.

### Pseudonymization
To enhance privacy, blockchain applications can pseudonymize user data by replacing personally identifiable information with pseudonyms or cryptographic identifiers. This makes it difficult to directly link user identities to their data.

## DoS
Denial-of-Service (DoS) attacks aim to disrupt the availability of a blockchain application or the entire network by overwhelming the system with an excessive amount of requests or by exploiting vulnerabilities in the network's infrastructure. DoS attacks can result in service unavailability or degradation, impacting the application's functionality and user experience. Implementing robust DoS mitigation strategies is essential to protect against such attacks.

As mentioned above, Avalanche's adaptive security approach it difficult to successfully deny network service.