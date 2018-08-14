pragma solidity ^0.4.18;

import "./Ownable.sol";

contract ChainList is Ownable {
  // custom types
  struct Article {
    uint id;
    address seller;
    address buyer;
    string name;
    string description;
    uint256 price;    
  }

  // state variable
  mapping (uint => Article) public articles;
  uint articleCounter;

  // constructor
  // function ChainList() public {
  //   //sellArticle("Default article", "This is default set", 1000000000000000000);
  // }

  // events
  event LogSellArticle(
    uint indexed _id,
    address indexed _seller,
    string _name,
    uint256 _price
  );
  event LogBuyArticle(
    uint indexed _id,
    address indexed _seller,
    address indexed _buyer,
    string _name,
    uint256 _price
  );

  // deactive the contract
  function kill() public onlyOwner {
    selfdestruct(owner);
  }

  // sell an article
  function sellArticle(string _name, string _description, uint256 _price) public {
    articleCounter++;

    articles[articleCounter] = Article(
      articleCounter,
      msg.sender,
      0x0,
      _name,
      _description,
      _price
    );

    emit LogSellArticle(articleCounter, msg.sender, _name, _price);
  }

  function getNumberOfArticles() public view returns (uint) {
    return articleCounter;
  }

  function getArticlesForSale() public view returns (uint[]) {
    uint[] memory articleIds = new uint[](articleCounter);
    uint numberOfArticlesForSale = 0;
    for (uint i = 1; i <= articleCounter; i++) {
      if (articles[i].buyer == 0x0) {
        articleIds[numberOfArticlesForSale] = articles[i].id;
        numberOfArticlesForSale ++;
      }
    }

    uint[] memory forSale = new uint[](numberOfArticlesForSale);
    for (uint j = 0; j < numberOfArticlesForSale; j++) {
      forSale[j] = articleIds[j];
    }
    return forSale;
  }


  function buyArticle(uint _id) payable public {
    require(articleCounter > 0);

    require(_id > 0 && _id <= articleCounter);

    Article storage article = articles[_id];

    // check that the article has not been sold yet
    require(article.buyer == 0x0);

    // don't allow the seller to buy his own
    require(msg.sender != article.seller);

    // check that value sent corresponds to the article price
    require(msg.value == article.price);

    // keep buyer information
    article.buyer = msg.sender;

    // the buyer can pay the seller
    article.seller.transfer(msg.value);

    emit LogBuyArticle(_id, article.seller, article.buyer, article.name, article.price);
  }
}