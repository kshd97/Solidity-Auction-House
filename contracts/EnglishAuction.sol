pragma solidity ^0.4.22;
import "./Auction.sol";

contract EnglishAuction is Auction {

    uint public initialPrice;
    uint public biddingPeriod;
    uint public minimumPriceIncrement;
    uint public currentHighestBid;
    uint public currentBiddingPeriod;
    address public currentHighestBidderAddress;
    uint public startTime;
    uint public endTime;

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
        currentHighestBid = 0;
        currentBiddingPeriod = 0;
        currentHighestBidderAddress = 0;
        startTime = time();
        winnerAddress = 0;
        endTime = time() + _biddingPeriod;
        //TODO: place your code here
    }

    function bid() public payable{
        require (msg.value >= initialPrice);
        require ( msg.value >= currentHighestBid + minimumPriceIncrement, "bid too low" );
        require ( getWinner() == 0, "Winner already confirmed" );
        currentHighestBidderAddress.transfer(currentHighestBid);
        currentHighestBid = msg.value;
        currentHighestBidderAddress = msg.sender;
        currentBiddingPeriod = 0;
        endTime = time() + biddingPeriod;


        //TODO: place your code here
    }

    // function incrementbidPeriod() public ownerOnly{
    //     require (getWinner() == 0 && currentBiddingPeriod < biddingPeriod, "error");
    //     currentBiddingPeriod += 1;
    //     if (currentBiddingPeriod == biddingPeriod){
    //         winnerAddress = currentHighestBidderAddress;
    //     }
    // }

    //TODO: place your code here
    //Need to override the default implementation
    function getWinner() public returns (address winner){
        if (time() < endTime){
            return 0;
        }
        if (winnerAddress != 0){
            return winnerAddress;
        }
        else{
            winnerAddress = currentHighestBidderAddress;
            // sellerAddress.transfer(currentHighestBid);
            return winnerAddress;
        }
    }
}