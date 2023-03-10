pragma solidity ^0.4.22;
import "./Auction.sol";

contract DutchAuction is Auction {

    uint public initialPrice;
    uint public biddingPeriod;
    uint public offerPriceDecrement;
    uint public startTime;
    //TODO: place your code here

    // constructor
    function DutchAuction(address _sellerAddress,
                          address _timerAddress,
                          uint _initialPrice,
                          uint _biddingPeriod,
                          uint _offerPriceDecrement) public
             Auction (_sellerAddress, _timerAddress) {

        initialPrice = _initialPrice;
        biddingPeriod = _biddingPeriod;
        offerPriceDecrement = _offerPriceDecrement;
        startTime = time();

        //TODO: place your code here
    }


    function bid() public payable{
        //TODO: place your code here
        uint currentPrice = initialPrice - (time() - startTime) * offerPriceDecrement;
        require (  msg.value >= currentPrice, "bid value has to be greater than current price");
        require (  time() < startTime + biddingPeriod, "time completed" );
        require (  getWinner() == 0, "Winner already decided");

        winnerAddress = msg.sender;
        uint refund = this.balance - currentPrice;
        getWinner().transfer(refund);
        // sellerAddress.transfer(currentPrice);

    }

}