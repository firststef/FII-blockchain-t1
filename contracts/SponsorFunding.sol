// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <=0.8.7;

import "./CrowdFunding.sol";

contract SponsorFunding{
    CrowdFunding internal cfContract;
    uint internal sponsorshipValue;
    
    constructor(address payable cfAddress, uint percentageValue) 
        payable 
    {
        CrowdFunding cf = CrowdFunding(cfAddress);
        uint minimum = cf.getFundingGoal() * percentageValue / 100;
        
        require(percentageValue < 100, "Invalid percentage value, maximum 100!");
        require(msg.value >= minimum, "false");
        
        sponsorshipValue = msg.value;
        cfContract = cf;
        cfContract.becomeSponsor(address(this));
    }
    
    function mem_equal(bytes memory a, bytes memory b) 
        internal
        pure
        returns(bool)
    {
        return (a.length == b.length) && (keccak256(a) == keccak256(b));
    }
    
    function str_equal(string memory a, string memory b) 
        internal
        pure
        returns(bool)
    {
        return mem_equal(bytes(a), bytes(b));
    }
    
    function finalizeSponsorship() 
        public 
    {
        require(msg.sender == address(cfContract), "Caller is not the CrowdFunding contract!");
        require(str_equal(cfContract.getStatus(), "Funded"), "CrowdFunding goal not reached");
        require((address(cfContract).balance + sponsorshipValue) >= cfContract.getFundingGoal());
        
        cfContract.receiveSponsorshipFunds{value:sponsorshipValue}();
    }
    
    function getSponsorshipValue() 
        public
        view
        returns(uint)
    {  
        return sponsorshipValue;
    }
}