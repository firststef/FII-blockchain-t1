// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <=0.8.7;

import "./SponsorFunding.sol";
import "./DistributeFunding.sol";

struct ContribuitorData {
    string _name;
    // mai adaugam noi aici..
}

struct Contributor {
    ContribuitorData    _data;
    uint                _amount;
}

contract CrowdFunding {
    enum State{
        NotFunded,
        Funded
    }
    
    address immutable private                   owner;
    uint immutable private                      fundingGoal;
    State private                               state;
    mapping (address => Contributor) private    contributors;
    
    
    modifier onlyOwner {
        require(msg.sender == owner, "Only owner!");
        _;
    }
    
    modifier onlyContributors {
        require(contributors[msg.sender]._amount > 0, "Only contributors allowed!");
        _;
    }
    
    modifier onlyState(State _state) {
        require(state == _state, 
                state == State.NotFunded ? "Funding in progress!" : "Funding ended!");
        _;
    }
    
    //Sponsor sponsor;
    //DistributeFunding dsFunding;
    
    constructor (uint64 _fundingGoal){
        owner = msg.sender;
        fundingGoal = _fundingGoal;
        state = State.NotFunded;
        //dsFunding = new DistributeFunding(address(this));
    }
    
    // get Funding status
    function getStatus() 
        public 
        view
        returns(string memory) {
        return state == State.NotFunded ? "NotFunded" : "Funded";
    }
    
    // anunta SponsorFunding ca a atins goalul
    function communicateFundingGoalReached() 
        external
        onlyOwner 
        onlyState(State.Funded) {
        // announce sponsor
        // sends money to distribute funding
    }
    
    // Contributors
    function contributeFunds(ContribuitorData calldata _data) 
        external 
        payable 
        onlyState(State.NotFunded) {
            
        require(address(this).balance /*+ get sponsorship money*/ <= fundingGoal);
        
        contributors[msg.sender]._data = _data;
        contributors[msg.sender]._amount += msg.value;
        
        if(address(this).balance /*get sponsorship money*/ >= fundingGoal) {
            state = State.Funded;
        }
    }
    
    function withdrawFunds(uint amount) 
        external
        onlyContributors
        onlyState(State.NotFunded) {
            
        require((amount != 0) && (contributors[msg.sender]._amount >= amount),
                "Invalid amount!");
        
        payable(msg.sender).transfer(amount);
        contributors[msg.sender]._amount -= amount;
        
    }
    
    // Sponsors
    function becomeSponsor(Sponsor calldata s) external {} // adds sponsor
    
}