module NewsMoves {
  // Struct representing a news article entry
  struct Article {
    timestamp: u64,
    title: vector<u8>,
    content: vector<u8>,
  }

  // NewsMoves struct representing the contract state
  resource struct NewsMoves {
    articles: vector<Article>,
  }

  // Initialization function for the NewsMoves contract
  public fun init(): NewsMoves {
    NewsMoves {
      articles: Vector::create(),
    }
  }

  // Function to add a news article to the contract (can only be called by the trusted signer)
  public fun addArticle(timestamp: u64, title: vector<u8>, content: vector<u8>, signer: address) {
    assert(Signer::is_valid(signer), 99); // Ensure that the signer is valid and trusted
    let self = &mut NewsMoves::borrow_global_mut();
    self.articles.push(Article {
      timestamp: timestamp,
      title: title,
      content: content,
    });
  }

  // Function to get the latest news article from the contract
  public fun getLatestArticle(): Article {
    let self = &NewsMoves::borrow_global();
    assert(self.articles.len() > 0, 98); // Ensure there is at least one article
    let latestArticleIndex = self.articles.len() - 1;
    self.articles[latestArticleIndex]
  }
}
