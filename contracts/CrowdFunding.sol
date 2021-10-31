// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <=0.8.7;

import "./SponsorFunding.sol";
import "./DistributeFunding.sol";

struct Person{
    string name;
    string pAddress;
}

contract CrowdFunding{
    address private owner;
    
    uint64 private fundingGoal;
    
    enum State{
        NotFunded,
        Funded
    }
    
    State state;
    
    mapping (address=> Person) contributors;
    uint64 private currentFunds;
    
    Sponsor sponsor;
    
    DistributeFunding dsFunding;
    
    constructor(uint64 fGoal){
        owner = msg.sender;
        fundingGoal = fGoal;
        dsFunding = new DistributeFunding(address(this));
    }
    
    // State
    function status() public returns(string memory) {} // gets state
    
    function finishFunding() private {
        // announces sponsor
        // sends money to distribute funding
    }
    
    // Contributors
    function contribute(Person calldata p) public{
        //valoare din amount.value 
    }
    
    function retract() public {
        //retracts contribution    
    } 
    
    // Sponsors
    function becomeSponsor(Sponsor calldata s) public {} // adds sponsor
}