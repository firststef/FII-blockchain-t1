// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <=0.8.7;

import "./SponsorFunding.sol";
import "./DistributeFunding.sol";
import "./Owned.sol";

struct ContribuitorData {
    string _name;
    // mai adaugam noi aici..
}

struct SponsorData {
    SponsorFunding sponsor;
    uint sponsorshipValue;
    bool haveSponsor;
    bool sponsorshipReceived;
}

struct Contributor {
    ContribuitorData    _data;
    uint                _amount;
}

contract CrowdFunding is Owned {
    enum State { NotFunded, Funded }
    
    event SponsorshipReceived(address _address, uint _value);
    
    State public                                state;
    
    uint immutable private                      fundingGoal;
    mapping (address => Contributor) private    contributors;
    
    SponsorData         sponsorData;
    DistributeFunding   dsFunding;
    
    modifier onlyContributors {
        require(contributors[msg.sender]._amount > 0, "Only contributors allowed!");
        _;
    }
    
    modifier onlyState(State _state) {
        require(state == _state, 
                state == State.NotFunded ? "Funding in progress!" : "Funding ended!");
        _;
    }
    
    constructor (uint64 _fundingGoal){ 
        fundingGoal = _fundingGoal;
        state       = State.NotFunded;
        dsFunding   = new DistributeFunding(address(this));
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
    
    function getBalance()
        public
        view
        returns(uint) {
            return address(this).balance;
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
        
        
        require(sponsorData.haveSponsor, "No sponsor!");
        sponsorData.sponsor.finalizeSponsorship();
        // announce sponsor
        // the following call will transfer the funds to this contract
        // `sponsor.finalizeSponsorship();`
        
        // sends money to distribute funding
        //dsFunding.distributeFunds();
    }
    
    // Contributors
    function contributeFunds(ContribuitorData calldata _data) 
        external 
        payable 
        onlyState(State.NotFunded) {
            
        require(address(this).balance + sponsorData.sponsorshipValue <= fundingGoal);
        
        contributors[msg.sender]._data = _data;
        contributors[msg.sender]._amount += msg.value;
        
        if(address(this).balance + sponsorData.sponsorshipValue >= fundingGoal) {
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

    function becomeSponsor(address _address) 
        external
        onlyState(State.NotFunded)
    {
        require(sponsorData.haveSponsor == false, "Already has a sponsor");
        sponsorData.sponsor = SponsorFunding(_address);
        sponsorData.sponsorshipValue = sponsorData.sponsor.getSponsorshipValue();
        sponsorData.haveSponsor = true;
        // the `receive` function is used as a fallback function when no calldata id provided so, I defined a 
        // separate function to receive funds from the sponse
        
        // todo: register sponsor
        // req: only one sponsor
        
    }
    
    function receiveSponsorshipFunds()
        public
        payable
        onlyState(State.Funded)
    {
        require(sponsorData.haveSponsor, "No sponsor!");
        require(msg.sender == address(sponsorData.sponsor), "Only sponsor allowed");
        require(msg.value == sponsorData.sponsorshipValue);
        
        assert(address(this).balance >= fundingGoal);
        
        emit SponsorshipReceived(msg.sender, msg.value);
    }
    
    //receive() external payable { revert("Invalid operation!"); }
    //fallback() external payable { revert("Invalid operation!"); }
    
    // Begin distribution
    function transferToDistribute() 
    external
    onlyState(State.Funded)
    payable 
    {
        // only owner of CrowdFunding should send funds to ds;
        require(address(this).balance >= fundingGoal); //make sure SponsorshipReceived
        require(msg.sender == address(dsFunding), "Only distribute funding can access this");
        payable(address(dsFunding)).transfer(fundingGoal);
    }
}