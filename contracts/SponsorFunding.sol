// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <=0.8.7;

import "./CrowdFunding.sol";

contract SponsorFunding{
    CrowdFunding cfContract;
    
    constructor(address cfAddress) {
        cfContract = CrowdFunding(cfAddress);
    }
    
    function finalizeSponsorship() public {
        // require sender is cfContract
        // send money to cfContract
    }
}