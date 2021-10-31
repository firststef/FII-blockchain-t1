// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <=0.8.7;

import "./CrowdFunding.sol";

contract DistributeFunding{
    CrowdFunding cfContract;
    
    mapping(address => uint64) fundees;
        
    constructor(address cfAddress) {
        cfContract = CrowdFunding(cfAddress);
    }
    
    function setFundees(address add, uint64 share) public {
        // addsa a fundee
        // probably must require sender.address to be the one that created CrowdFunding
    } 
}