# Common blockchain system design patterns

## Oracles
Oracles play a crucial role in blockchain applications by providing a bridge between the blockchain and the external world. They are trusted entities or mechanisms that bring off-chain data onto the blockchain, making it accessible to smart contracts and decentralized applications. Oracles enable the blockchain to interact with real-world events, data feeds, APIs, and other external systems. By leveraging oracles, blockchain applications can access and process external information in a reliable and secure manner.

> We built 💻 NewsMoves, `examples/movement/new_moves`, as a toy oracle contract that allows a trusted entity to write the latest Google news articles onto the blockchain. Please checkout the directory to publish the contract and run the Python data entity.

```rust
module news_moves::news_moves {

  use std::signer;
  use std::vector;

  // Struct representing a news article entry
  struct Article has copy {
    timestamp: u64,
    title: vector<u8>,
    content: vector<u8>,
  }

  // NewsMoves struct representing the contract state
  struct NewsMoves {
    articles: vector<Article>,
  }

  // Initialization function for the NewsMoves contract
  public fun init() {
    move_to(@news_moves, NewsMoves {
      articles: vector::empty<Article>(),
    });
  }

  public fun update<X, Y, Curve>(
    account: &signer,
    timestamp: u64,
    title: vector<u8>,
    content: vector<u8>,
  ) acquires NewsMoves {

      // update the contract at the account
      let account_addr = signer::address_of(account);
      let self = borrow_global_mut<NewsMoves>(account_addr);

      // add the new article
      vector::push_back(&mut self.articles, Article {
          timestamp: timestamp,
          title: title,
          content: content,
      });

    }

  // Function to get the latest news article from the contract
  public fun getLatestArticle(): Article {

    // Get the latest article from the contrac

    let moves = borrow_global<NewsMoves>(@news_moves);
    let len = vector::length(&articles);
    assert(len > 0, 98); // Ensure there is at least one article
    let latestArticleIndex = len - 1;
    *moves.articles[latestArticleIndex]

  }
  
}
```

## Rollups
Rollups are a layer 2 scaling solution for blockchains that aim to improve scalability and reduce transaction costs. They work by aggregating multiple transactions off-chain and then submitting a summary or proof of those transactions to the main chain. This reduces the burden on the main chain, allowing for faster and more efficient processing. Rollups can significantly increase transaction throughput and enable complex applications to run smoothly on the blockchain while maintaining a high level of security.

> We added a toy dispute mechanism 💻 NewsMoves, `examples/movement/new_moves`  to demonstrate how part of a rollup could implemented.

## Tokenization
Tokenization is the process of representing real-world or digital assets as tokens on a blockchain. It enables the creation of digital representations (tokens) that can be owned, transferred, and managed on the blockchain. Tokenization has broad applications, ranging from representing physical assets like real estate or artwork to creating digital assets like utility tokens or security tokens. By tokenizing assets, blockchain-based systems can provide increased liquidity, fractional ownership, and facilitate seamless transferability of assets in a secure and transparent manner.

> We implement a toy tokenization scheme and separately used our framework's `aptos_token_objects` to augment 💻 NewsMoves, `examples/movement/new_moves` and demonstrate Movement token utilities.


## State Channels
State channels are a scalability solution in blockchain that allows off-chain execution of transactions between participants. They enable fast and low-cost transactions by keeping most of the interactions off-chain, while the final state is settled on the main blockchain. State channels are particularly useful for frequent and fast interactions, such as microtransactions or gaming applications, as they reduce congestion and improve transaction throughput.

## Side Chains
Side chains are separate blockchains that are connected to the main blockchain, often referred to as the "main chain" or "parent chain." They provide an additional layer of scalability and flexibility by allowing specific use cases or applications to operate on their own chain while still being interoperable with the main chain. Side chains can handle transactions and smart contracts independently, reducing the load on the main chain and enabling specialized functionalities.

## Collaborative Governance
Collaborative governance refers to the process of making collective decisions and managing blockchain networks through the participation and collaboration of multiple stakeholders. It involves mechanisms such as voting, consensus-building, and community-driven decision-making to govern the rules, upgrades, and overall direction of a blockchain network. Collaborative governance aims to ensure inclusivity, transparency, and alignment of interests among network participants.

> `aptos_framework::aptos_governance` provides a host of out of the box tools for handling proposals, dynamic voting systems, and member rewards. Using it you can implement a DAO and tests in a about a thousand lines of code.

## Atomic Swaps
Atomic swaps are a mechanism that allows the exchange of different cryptocurrencies or digital assets between two parties without the need for an intermediary or trusted third party. It enables secure peer-to-peer transactions directly between participants, ensuring that either the entire transaction is executed or none of it occurs. Atomic swaps enhance interoperability and facilitate decentralized exchanges by eliminating the need for centralized intermediaries.

## Proofs and Zero-Knowledge
Zero-knowledge proofs are cryptographic techniques that enable a party to prove knowledge of certain information without revealing the actual information itself. They allow for privacy-preserving transactions and interactions on the blockchain, where participants can validate the correctness of a statement or the possession of certain data without disclosing sensitive details. Zero-knowledge proofs enhance confidentiality and confidentiality in blockchain applications, ensuring that privacy-sensitive information remains secure while still being verifiable.

> At Movement, we're working on a Zero-Knowledge VM powered by the Move Prover. 