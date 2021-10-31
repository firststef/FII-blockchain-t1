// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <=0.8.7;

struct Person{
    string name;
    string pAddress;
}

struct Sponsor{
    address sAddress;
}

contract CrowdFunding{
    uint64 private fundingGoal;
    
    // maping <address, Person>
    uint64 private currentFunds;
    
    // maping <address, Sponsor>
    
    enum State{
        NotFunded,
        Funded
    }
    
    State state;
    
    constructor(uint64 fGoal){
        fundingGoal = fGoal;
    }
    
    function contribute(Person calldata p) public{
        //valoare din amount.value 
    }
    
    function retract() public {
        //retracts contribution    
    } 
    
    function status() public returns(string memory) {} // gets state
    
    function becomeSponsor() public {} // adds sponsor
}