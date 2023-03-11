pragma solidity ^0.4.22;

import "./TestFramework.sol";
import "./Bidders.sol";

contract VickreyAuctionTestAdvanced is Assert {

    VickreyAuction testAuction;
    VickreyAuctionBidder alice;
    VickreyAuctionBidder bob;
    VickreyAuctionBidder carol;
    uint bidderCounter;

    Timer t;

    //can receive money
    function() public payable {}
    function VickreyAuctionTestAdvanced() public payable {
        require(address(this).balance >= 1000000000 wei);
    }

    function setupContracts() public {
        t = new Timer(0);
        testAuction = new VickreyAuction(this, t, 300, 10, 10, 1000);
        bidderCounter += 1;
        alice = new VickreyAuctionBidder(testAuction, bytes32(bidderCounter));
        bob = new VickreyAuctionBidder(testAuction, bytes32(bidderCounter));
        carol = new VickreyAuctionBidder(testAuction, bytes32(bidderCounter));
    }

    function commitBid(VickreyAuctionBidder bidder,
                     uint bidValue, 
                     uint bidTime,
                     bool expectedResult,
                     string message) internal {

        uint oldTime = t.getTime();
        t.setTime(bidTime);
        uint initialAuctionBalance = address(testAuction).balance;

        address(bidder).transfer(testAuction.bidDepositAmount());
        bool result = bidder.commitBid(bidValue);

        if (expectedResult == false) {
            Assert_isFalse(result, message);
        }
        else {
            Assert_isTrue(result, message);
            Assert_equal(address(testAuction).balance, initialAuctionBalance + testAuction.bidDepositAmount(), "auction should retain deposit");
        }
        t.setTime(oldTime);
    }

    function revealBid(VickreyAuctionBidder bidder,
                     uint bidValue, 
                     uint bidTime,
                     bool expectedResult,
                     string message) internal {

        uint oldTime = t.getTime();
        t.setTime(bidTime);

        address(bidder).transfer(bidValue);
        bool result = bidder.revealBid(bidValue);

        if (expectedResult == false) {
            Assert_isFalse(result, message);
        }
        else {
            Assert_isTrue(result, message);
        }
        t.setTime(oldTime);
    }

    function testMinimalBidder() public {
        setupContracts();

        commitBid(bob, 300, 9, true, "valid bid commitment should be accepted");
        revealBid(bob, 300, 19, true, "valid bid reveal should be accepted");
        t.setTime(20);
        Assert_equal(address(bob), testAuction.getWinner(), "winner should be declared after auction end");
        testAuction.finalize();
        Assert_equal(address(bob).balance, 1000, "winner should received partial refund");
    }

    function testRevealChangedBid() public {
        setupContracts();

        address(alice).transfer(2548);
        Assert_isTrue(alice.commitBid(500, 1000), "valid bid should be accepted");
        t.setTime(1);
        Assert_isTrue(alice.commitBid(550, 1097), "valid bid change should be accepted");

        revealBid(alice, 500, 14, false, "incorrect bid reveal should be rejected");
        revealBid(alice, 550, 14, true, "correct bid reveal should be accepted");
        t.setTime(20);
        Assert_equal(address(alice), testAuction.getWinner(), "winner should be declared after auction end");
        testAuction.finalize();
        Assert_equal(address(alice).balance, 3298, "winner should received partial refund");
    }

    function testMultipleBiddersOne() public {
        setupContracts();

        commitBid(alice, 500, 1, true, "correct bid should be accepted");
        commitBid(bob, 617, 2, true, "correct bid should be accepted");
        commitBid(carol, 650, 3, true, "correct bid should be accepted");

        revealBid(alice, 500, 14, true, "correct bid reveal should be accepted");
        revealBid(bob, 617, 15, true, "correct bid reveal should be accepted");
        revealBid(carol, 650, 16, true, "correct bid reveal should be accepted");

        t.setTime(20);
        Assert_equal(address(carol), testAuction.getWinner(), "winner should be declared after auction end");
        testAuction.finalize();
        Assert_equal(address(alice).balance, 1500, "loser should received full refund");
        Assert_equal(address(bob).balance, 1617, "loser should received full refund");
        Assert_equal(address(carol).balance, 1033, "winner should received partial refund");
    }

    function testMultipleBiddersTwo() public {
        setupContracts();

        commitBid(alice, 500, 1, true, "correct bid should be accepted");
        commitBid(bob, 617, 2, true, "correct bid should be accepted");
        commitBid(carol, 650, 3, true, "correct bid reveal should be accepted");

        revealBid(carol, 650, 14, true, "correct bid reveal should be accepted");
        revealBid(alice, 500, 15, true, "correct bid reveal should be accepted");
        revealBid(bob, 617, 16, true, "correct bid reveal should be accepted");

        t.setTime(20);
        Assert_equal(address(carol), testAuction.getWinner(), "winner should be declared after auction end");
        testAuction.finalize();
        Assert_equal(address(alice).balance, 1500, "loser should received full refund");
        Assert_equal(address(bob).balance, 1617, "loser should received full refund");
        Assert_equal(address(carol).balance, 1033, "winner should received partial refund");
    }
}