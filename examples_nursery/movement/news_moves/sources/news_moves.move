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

    let self = borrow_global<NewsMoves>(@news_moves);
    assert(self.articles.len() > 0, 98); // Ensure there is at least one article
    let latestArticleIndex = self.articles.len() - 1;
    *self.articles[latestArticleIndex]

  }

}
