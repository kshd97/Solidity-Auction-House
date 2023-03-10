pragma solidity ^0.4.22;
import "./Auction.sol";

contract EnglishAuction is Auction {

    uint public initialPrice;
    uint public biddingPeriod;
    uint public minimumPriceIncrement;

    //TODO: place your code here

    // constructor
    function EnglishAuction(address _sellerAddress,
                          address _timerAddress,
                          uint _initialPrice,
                          uint _biddingPeriod,
                          uint _minimumPriceIncrement) public
             Auction (_sellerAddress, _timerAddress) {

        initialPrice = _initialPrice;
        biddingPeriod = _biddingPeriod;
        minimumPriceIncrement = _minimumPriceIncrement;

        //TODO: place your code here
    }

    function bid() public payable{
        //TODO: place your code here
    }

    //TODO: place your code here
    //Need to override the default implementation
    function getWinner() public returns (address winner){
        return 0;
    }
}