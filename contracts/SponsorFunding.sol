// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <=0.8.7;

import "./CrowdFunding.sol";

contract SponsorFunding{
    CrowdFunding internal cfContract;
    uint internal sponsorshipValue;
    
    event sponsor_joined(address, uint value, uint percentage, uint minimum);
    
    constructor(address cfAddress, uint percentageValue) 
        payable 
    {
        CrowdFunding cf = CrowdFunding(cfAddress);
        uint minimum = cf.getFundingGoal() * percentageValue / 100;
        
        require(percentageValue < 100, "Invalid percentage value, maximum 100!");
        require(msg.value >= minimum, "false");
        
        sponsorshipValue = msg.value;
        cfContract = cf;
        cfContract.becomeSponsor(address(this));
        
        emit sponsor_joined(cfAddress, msg.value, percentageValue, minimum);
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
        require(str_equal(cfContract.getStatus(), "Founded"), "CrowdFunding goal not reached");
        
        address payable destination_address = payable(address(cfContract));
        bool sent = destination_address.send(sponsorshipValue);
        require(sent, "Something went wrong! Failed to send sponsorship value!");
    }
    
    function getSponsorshipValue() 
        public
        view
        returns(uint)
    {  
        return sponsorshipValue;
    }
}