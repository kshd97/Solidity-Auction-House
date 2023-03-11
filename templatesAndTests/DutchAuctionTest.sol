pragma solidity ^0.4.22;

import "./TestFramework.sol";
import "./Bidders.sol";

contract DutchAuctionTest is Assert {

    DutchAuction testAuction;
    Timer t;

    //can receive money
    function() public payable {}
    function DutchAuctionTest() public payable {
        require(address(this).balance >= 1000000000 wei);
    }
    function setupContracts() public {
        t = new Timer(0);
        testAuction = new DutchAuction(this, t, 300, 10, 20);
    }

    function makeBid(uint bidValue, 
                     uint bidTime,
                     uint expectedPrice,
                     bool expectedResult,
                     string message) internal {
        DutchAuctionBidder bidder = new DutchAuctionBidder(testAuction);
        address(bidder).transfer(bidValue);
        uint oldTime = t.getTime();
        t.setTime(bidTime);
        uint initialAuctionBalance = address(testAuction).balance;
        address currentWinner = testAuction.getWinner();
        bool result = bidder.bid(bidValue);
        if (expectedResult == false) {
          Assert_isFalse(result, message);
          Assert_equal(currentWinner, testAuction.getWinner(), "no winner should be declared after invalid bid");
        }
        else{
          Assert_isTrue(result, message);
          Assert_equal(address(testAuction).balance, initialAuctionBalance + expectedPrice, "auction should retain final price");
          Assert_equal(address(bidder).balance, bidValue - expectedPrice, "bidder should be refunded excess bid amount");
          Assert_equal(testAuction.getWinner(), bidder, "bidder should be declared the winner");
        }
        t.setTime(oldTime);
    }

    function testCreateDutchAuction() public {
        setupContracts();
        //do nothing, just verify that the constructor actually ran
    }

    function testLowBids() public {
        setupContracts();
        makeBid(299, 0, 0, false, "low bid should be rejected");
        makeBid(240, 2, 0, false, "low bid should be rejected");
        makeBid(100, 5, 0, false, "low bid should be rejected");
    }

    function testExactBid() public {
        setupContracts();
        makeBid(300, 0, 300, true, "exact bid should be accepted");
        setupContracts();
        makeBid(280, 1, 280, true, "exact bid should be accepted");
        setupContracts();
        makeBid(120, 9, 120, true, "exact bid should be accepted");
    }

    function testValidBidAfterInvalid() public {
        setupContracts();
        makeBid(299, 0, 0, false, "low bid should be rejected");
        makeBid(300, 0, 300, true, "valid bid after failed bid should succeed");
    }

    function testLateBid() public {
        setupContracts();
        makeBid(300, 10, 0, false, "late bid should be rejected");
    }

    function testSecondValidBid() public {
        setupContracts();
        makeBid(280, 1, 280, true, "exact bid should be accepted");
        makeBid(300, 0, 0, false, "second bid should be rejected");
    }

    function testRefundHighBid() public {
        setupContracts();
        makeBid(300, 2, 260, true, "high bid should be accepted");
    }

}