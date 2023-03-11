pragma solidity ^0.4.22;

import "./Timer.sol";
import "/Auction.sol";
import "/DutchAuction.sol";
import "/EnglishAuction.sol";
import "/VickreyAuction.sol";

contract Assert {
    
    function Assert_isFalse(bool value, string message) public {
        if (value)
           revert();
    }
    
    function Assert_isTrue(bool value, string message) public {
         if (!value) 
            revert();
    }
    
    function Assert_equal(uint value1, uint value2, string message) public {
        if (value1 != value2)
            revert();
    }
    
    function Assert_equal(bytes32 value1, bytes32 value2, string message) public {
        if (value1 != value2)
           revert();
    }
    
    function Assert_equal(address value1, address value2, string message) public {
        if (value1 != value2)
           revert();
    }
    
    
}