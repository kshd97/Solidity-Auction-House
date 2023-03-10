pragma solidity ^0.4.22;

import "./TestFramework.sol";
import "./Bidders.sol";

contract EnglishAuctionTest is Assert {

    EnglishAuction testAuction;
    EnglishAuctionBidder alice;
    EnglishAuctionBidder bob;
    EnglishAuctionBidder carol;

    Timer t;

    //can receive money
    function() public payable {}
    function EnglishAuctionTest() public payable {
        require(address(this).balance >= 1000000000 wei);
    }

    function setupContracts() public {
        t = new Timer(0);
        testAuction = new EnglishAuction(this, t, 300, 10, 20);
        alice = new EnglishAuctionBidder(testAuction);
        bob = new EnglishAuctionBidder(testAuction);
        carol = new EnglishAuctionBidder(testAuction);
    }

    function makeBid(EnglishAuctionBidder bidder,
                     uint bidValue, 
                     uint bidTime,
                     bool expectedResult,
                     string message) internal {

        uint oldTime = t.getTime();
        t.setTime(bidTime);
        bidder.transfer(bidValue);
        bool result = bidder.bid(bidValue);

        if (expectedResult == false) {
            Assert_isFalse(result, message);
        }
        else {
            Assert_isTrue(result, message);
            Assert_equal(testAuction.balance, bidValue, "auction should retain bid amount");
        }
        t.setTime(oldTime);
    }

    function testCreateEnglishAuction() public {
        setupContracts();
        //do nothing, just verify that the constructor actually ran
    }

    function testLowInitialBids() public {
        setupContracts();
        makeBid(alice, 0, 0, false, "low bid should be rejected");
        makeBid(alice, 299, 9, false, "low bid should be rejected");
    }


    function testSingleValidBid() public {
        setupContracts();
        makeBid(alice, 300, 0, true, "valid bid should be accepted");
        t.setTime(10);
        Assert_equal(testAuction.getWinner(), address(alice), "single bidder should be declared the winner");
    }

    function testEarlyWinner() public {
        setupContracts();
        makeBid(alice, 300, 0, true, "valid bid should be accepted");
        t.setTime(9);
        Assert_equal(testAuction.getWinner(), 0, "no bidder should be declared before deadline");
    }

    function testLowFollowupBids() public {
        setupContracts();
        makeBid(alice, 300, 0, true, "valid bid should be accepted");
        makeBid(bob, 319, 9, false, "low bid should be rejected");
        makeBid(bob, 250, 7, false, "low bid should be rejected");
    }

    function testRefundAfterOutbid() public {
        setupContracts();
        makeBid(alice, 300, 0, true, "valid bid should be accepted");
        makeBid(bob, 320, 8, true, "valid bid should be accepted");
        Assert_equal(bob.balance, 0, "bidder should not retain funds");
        Assert_equal(testAuction.balance, 320, "auction should retain bidder's funds in escrow");
        Assert_equal(alice.balance, 300, "outbid bidder should receive refund");
    }

    function testLateBids() public {
        setupContracts();
        makeBid(alice, 300, 0, true, "valid bid should be accepted");
        makeBid(bob, 320, 10, false, "late bid should be rejected");
        makeBid(carol, 500, 12, false, "late bid should be rejected");
    }

    function testIncreaseBid() public {
        setupContracts();
        makeBid(alice, 300, 0, true, "valid bid should be accepted");
        makeBid(alice, 350, 5, true, "second valid bid should be accepted");
        t.setTime(14);
        Assert_equal(testAuction.getWinner(), 0, "no bidder should be declared before deadline");
        t.setTime(15);
        Assert_equal(testAuction.getWinner(), address(alice), "repeat bidder should be declared the winner");
        Assert_equal(alice.balance, 300, "bidder should not retain funds");
        Assert_equal(testAuction.balance, 350, "auction should retain bidder's funds in escrow");
    }

    function testExtendedBidding() public {
        setupContracts();
        makeBid(alice, 300, 0, true, "valid bid should be accepted");
        makeBid(bob, 310, 4, false, "invalid bid should be rejected");
        makeBid(carol, 400, 8, true, "valid bid should be accepted");
        makeBid(bob, 450, 12, true, "valid bid should be accepted");
        makeBid(alice, 650, 15, true, "valid bid should be accepted");
        makeBid(bob, 660, 16, false, "invalid bid should be rejected");
        makeBid(alice, 750, 20, true, "valid bid should be accepted");
        makeBid(carol, 1337, 29, true, "valid bid should be accepted");
        t.setTime(38);
        Assert_equal(testAuction.getWinner(), 0, "no bidder should be declared before deadline");
        t.setTime(39);
        Assert_equal(testAuction.getWinner(), address(carol), "final bidder should be declared the winner");
        Assert_equal(carol.balance, 400, "bidders should get valid refunds");
        Assert_equal(bob.balance, 1420, "bidders should get valid refunds");
        Assert_equal(alice.balance, 1700, "bidders should get valid refunds");
        Assert_equal(testAuction.balance, 1337, "auction should retain bidder's funds in escrow");
    }

}