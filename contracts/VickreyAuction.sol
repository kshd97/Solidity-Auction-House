pragma solidity ^0.4.22;
import "./Auction.sol";

contract VickreyAuction is Auction {

    struct input {
        bytes32 bidCommitment;
        bool isreveal;
    }
    uint public minimumPrice;
    uint public biddingDeadline;
    uint public revealDeadline;
    uint public bidDepositAmount;
    uint public startTime;
    mapping (address => input) public bids;
    uint public currentHighestBid;
    uint public secondHighestBid;

    //TODO: place your code here

    // constructor
    function VickreyAuction(address _sellerAddress,
                            address _timerAddress,
                            uint _minimumPrice,
                            uint _biddingPeriod,
                            uint _revealPeriod,
                            uint _bidDepositAmount) 
             Auction (_sellerAddress, _timerAddress) {

        minimumPrice = _minimumPrice;
        bidDepositAmount = _bidDepositAmount;
        startTime = time();
        biddingDeadline = time() + _biddingPeriod;
        revealDeadline = time() + _biddingPeriod + _revealPeriod;
        currentHighestBid = 0;
        secondHighestBid = minimumPrice;
        

        //TODO: place your code here
    }

    // Record the player's bid commitment
    // Make sure at least bidDepositAmount is provided (for new bids)
    // Bidders can update their previous bid for free if desired.
    // Only allow commitments before biddingDeadline
    function commitBid(bytes32 bidCommitment) public payable {
        // TODO: place your code here
        require (time() < biddingDeadline);
        if(bids[msg.sender].bidCommitment !=  bytes32(0x0)){
            bids[msg.sender].bidCommitment = bidCommitment;
            if (msg.value > 0){
                msg.sender.transfer(msg.value);
            }
        }
        else{
            require (msg.value >= bidDepositAmount, "Min deposit required");
            bids[msg.sender].bidCommitment = bidCommitment;
            bids[msg.sender].isreveal = false;
            if(msg.value > bidDepositAmount){
                msg.sender.transfer(msg.value - bidDepositAmount);
            }
        }
    }

    // Check that the bid (msg.value) matches the commitment
    // If the bid is below the minimum price, it is ignored but the deposit is returned.
    // If the bid is below the current highest known bid, the bid value and deposit are returned.
    // If the bid is the new highest known bid, the deposit is returned and the previous high bidder's bid is returned. 
    function revealBid(bytes32 nonce) public payable returns(bool isHighestBidder) {

        // TODO: place your code here
        require ( time() >= biddingDeadline );
        require ( time() < revealDeadline );
        require ( keccak256(msg.value, nonce) == bids[msg.sender].bidCommitment );
        require ( bids[msg.sender].isreveal == false);

        bids[msg.sender].isreveal = true;

        if(msg.value < minimumPrice)
          msg.sender.transfer(bidDepositAmount);
        
        else if(msg.value < currentHighestBid){
          msg.sender.transfer(bidDepositAmount + msg.value);
          secondHighestBid = (msg.value > secondHighestBid)? msg.value: secondHighestBid;
        }
        else if(msg.value > currentHighestBid){

          if(currentHighestBid != 0){
            secondHighestBid = currentHighestBid;
            winnerAddress.transfer(currentHighestBid);
          }
          currentHighestBid = msg.value;
          winnerAddress = msg.sender;
          msg.sender.transfer(bidDepositAmount);
        }
    }

    // finalize() must be extended here to provide a refund to the winner
    function finalize() public {
        //TODO: place your code here
        require(time() >= revealDeadline);

        if(currentHighestBid - secondHighestBid > 0)
          getWinner().transfer(currentHighestBid - secondHighestBid);

        // call the general finalize() logic
        super.finalize();
    }
}