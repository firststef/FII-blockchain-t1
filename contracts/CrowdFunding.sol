// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <=0.8.7;

import "./SponsorFunding.sol";
import "./DistributeFunding.sol";
import "./Owned.sol";

struct ContribuitorData {
    string _name;
    // mai adaugam noi aici..
}

struct Contributor {
    ContribuitorData    _data;
    uint                _amount;
}

contract CrowdFunding is Owned {
    enum State { NotFunded, Funded }
    State public                               state;
    
    uint immutable private                      fundingGoal;
    mapping (address => Contributor) private    contributors;
    
    modifier onlyContributors {
        require(contributors[msg.sender]._amount > 0, "Only contributors allowed!");
        _;
    }
    
    modifier onlyState(State _state) {
        require(state == _state, 
                state == State.NotFunded ? "Funding in progress!" : "Funding ended!");
        _;
    }
    
    SponsorFunding sponsor;
    DistributeFunding dsFunding;
    
    constructor (uint64 _fundingGoal){ 
        fundingGoal = _fundingGoal;
        state = State.NotFunded;
        dsFunding = new DistributeFunding(address(this));
    }
    
    // get Funding status
    function getStatus() 
        public 
        view
        returns(string memory) {
        return state == State.NotFunded ? "NotFunded" : "Funded";
    }
    
    function getFundingGoal()
        public
        view
        returns(uint) {
        return fundingGoal;        
    }
     
    function getDistribute() 
        public 
        view 
        returns(address){
        return address(dsFunding);
    }
    
    // anunta SponsorFunding ca a atins goalul
    function communicateFundingGoalReached() 
        external
        onlyOwner 
        onlyState(State.Funded) {
        // announce sponsor
        // the following call will transfer the funds to this contract
        // `sponsor.finalizeSponsorship();`
        
        // sends money to distribute funding
        dsFunding.distributeFunds();
    }
    
    // Contributors
    function contributeFunds(ContribuitorData calldata _data) 
        external 
        payable 
        onlyState(State.NotFunded) {
            
        require(address(this).balance + sponsor.getSponsorshipValue() <= fundingGoal);
        
        contributors[msg.sender]._data = _data;
        contributors[msg.sender]._amount += msg.value;
        
        if(address(this).balance + sponsor.getSponsorshipValue() >= fundingGoal) {
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

    function becomeSponsor(address sfAddress) 
        external 
    {
        // the `receive` function is used as a fallback function when no calldata id provided so, I defined a 
        // separate function to receive funds from the sponse
        
        // todo: register sponsor
        // req: only one sponsor
        
    }
    
    function receiveFunds()
        public
        payable
    {
        // todo: receiveFunds 
        // todo: emit events for debug purposes
    }
    
    // Begin distribution
    function transferToDistribute() public payable {
        require(msg.sender == address(dsFunding), "Only distribute funding can access this");
        payable(address(dsFunding)).transfer(fundingGoal);
    }
}