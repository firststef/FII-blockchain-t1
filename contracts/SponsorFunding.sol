// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <=0.8.7;

import "./CrowdFunding.sol";

struct Sponsor{
    address sAddress;
}

contract SponsorFunding{
    CrowdFunding cfContract;
    
    constructor(address cfAddress) {
        cfContract = CrowdFunding(cfAddress);
        Sponsor memory sp;
        sp.sAddress = address(this);
        cfContract.becomeSponsor(sp);
    }
    
    function finalizeSponsorship() public {
        // require sender is cfContract
        // send money to cfContract
    }
}