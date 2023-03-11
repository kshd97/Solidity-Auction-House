pragma solidity ^0.4.22;
import "./Auction.sol";

contract DutchAuction is Auction {

    uint public initialPrice;
    uint public biddingPeriod;
    uint public offerPriceDecrement;

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

        //TODO: place your code here
    }


    function bid() public payable{
        //TODO: place your code here
    }

}