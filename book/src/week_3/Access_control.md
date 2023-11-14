# Access Control
This section briefly covers some considerations of blockchain access control and highlights places where Movement and this repo may be helpful.

## Signatures and certificates

Signatures and certificates play a crucial role in access control on the blockchain. They enable authentication and ensure that only authorized entities can perform specific actions or access certain resources. Signatures provide proof of ownership and authenticity, while certificates verify the identity and permissions of participants. By utilizing strong cryptographic signatures and certificates, blockchain applications can establish secure and tamper-proof access control mechanisms.

> Avalanche uses Transport Layer Security, TLS, to protect node-to-node communications from eavesdroppers. The Avalanche virtual machine uses elliptic curve cryptography, specifically `secp256k1`, for its signatures on the blockchain, and signs all messages.

## ACLs, RBAC, and ABAC

Access Control Lists (ACLs), Role-Based Access Control (RBAC), and Attribute-Based Access Control (ABAC) are common frameworks used to manage and enforce access control policies in blockchain applications. ACLs define permissions based on a list of entities and their associated access rights. RBAC assigns permissions to roles, allowing for more centralized management of access control. ABAC grants access based on attributes, such as user attributes or environmental conditions. Each framework has its strengths and can be tailored to meet specific access control requirements in a blockchain  application.

A rudimentary pattern in Move and Movement development is to assert a contract owner. Using named addresses, `@named_address`. 

```rust
script owner_address::important_script {

    const ERNO_OWNER_ONLY : u64 = 0

    fun do_important_thing(signer : address){

        assert!(signer == @owner_address, ERNO_OWNER_ONLY);

        // do thing...

    }

}
```

Manipulation of addresses often serves as the basis for Movement access control mechanisms.

> The Move language provides host of unique safe ways to implement access controls for resources. `aptos_framework::aptos_governance` provides an easy to use module for governance which can allow for decentralized managed of these control lists.

## Permissioned chains

Permissioned chains are blockchain networks that restrict participation to authorized entities only. Unlike public or permissionless blockchains, permissioned chains require participants to obtain explicit permission or be part of a predefined set of trusted entities. Permissioned chains are often employed in enterprise or consortium settings, where privacy, confidentiality, and control over network participants are paramount. By leveraging permissioned chains, blockchain applications can enforce stricter access control and maintain a trusted network environment.

> While the Movement testnet is not a permissioned chain, our virtual machines strong access controls--due to the Move language--make it easy to restrict access to select resources.