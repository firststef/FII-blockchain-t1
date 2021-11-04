// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <=0.8.7;

import "./SponsorFunding.sol";
import "./DistributeFunding.sol";
import "./Owned.sol";

struct SponsorData {
    SponsorFunding sponsor;
    uint sponsorshipAmount;
    bool sponsorshipReceived;
}

struct Contributor {
    string              _name;
    uint                _amount;
}

contract CrowdFunding is Owned {
    enum State { NotFunded, Funded }
    
    event SponsorshipReceived(address _address, uint _value);
    event FundingGoalReached(uint _amount);
    event ContributionReceived(string _name, uint _amount);
    event ContributionWithdrawn(string _name, uint _amount);
    
    State public                                state;
    
    uint immutable private                      fundingGoal;
    mapping (address => Contributor) private    contributors;
    
    SponsorData         sponsorData;
    DistributeFunding   dsFunding;
    
    modifier onlyContributors 
    {
        require(contributors[msg.sender]._amount > 0, "Only contributors allowed!");
        _;
    }
    
    modifier onlyState(State _state) 
    {
        require(state == _state, 
                state == State.NotFunded ? "Funding in progress!" : "Funding ended!");
        _;
    }
    
    modifier haveSponsor(bool expected)
    {
        require((address(sponsorData.sponsor) == address(0)) == !expected, "Sponsor unexpected!");
        _;
    }
    
    constructor (uint64 _fundingGoal)
    { 
        fundingGoal         = _fundingGoal;
        state               = State.NotFunded;
        dsFunding           = new DistributeFunding(payable(address(this)));
    }
    
    // get Funding status
    function getStatus() 
        public 
        view
        returns(string memory)
    {
        return state == State.NotFunded ? "NotFunded" : "Funded";
    }
    
    function getFundingGoal()
        public
        view
        returns(uint) 
    {
        return fundingGoal;        
    }
    
    function getBalance()
        public
        view
        returns(uint) 
    {
            return address(this).balance;
        }
     
    function getDistribute() 
        public 
        view 
        returns(address)
    {
        return address(dsFunding);
    }
    
    // anunta SponsorFunding ca a atins goalul
    function communicateFundingGoalReached() 
        external
        onlyOwner 
        onlyState(State.Funded)
        haveSponsor(true) 
    {
        require(sponsorData.sponsorshipReceived == false, "Already received sponsorship!");
        sponsorData.sponsor.finalizeSponsorship();
    }
    
    // Contributors
    function contributeFunds(string memory _name) 
        external 
        payable
        onlyState(State.NotFunded) 
    {
        require(msg.value > 0, "You cannot contribute with none value");
        
        require(address(this).balance + sponsorData.sponsorshipAmount <= fundingGoal, "Invalid amount! Exceeds funding goal!");
        
        contributors[msg.sender]._name = _name;
        contributors[msg.sender]._amount += msg.value;
        
        emit ContributionReceived(_name, msg.value);
        
        if(address(this).balance + sponsorData.sponsorshipAmount >= fundingGoal) {
            state = State.Funded;
            emit FundingGoalReached(fundingGoal);
        }
    }
    
    function withdrawFunds(uint amount) 
        external
        onlyContributors
        onlyState(State.NotFunded) 
    {
        require((amount != 0) && (contributors[msg.sender]._amount >= amount),
            "Invalid amount!");
        
        payable(msg.sender).transfer(amount);
        contributors[msg.sender]._amount -= amount;
        
        emit ContributionWithdrawn(contributors[msg.sender]._name, amount);
    }
    
    // Sponsors

    function becomeSponsor(address _address, uint _amount) 
        external
        onlyState(State.NotFunded)
        haveSponsor(false)
    {
        // this method is called inside SponsorFunding constructor
        // which means that the contract abi is unavailable 
        require(_amount != 0, "Sponsorship Amount cannot be zero!");
        require(_amount + address(this).balance <= fundingGoal, "Invalid sponsorship amount! (Exceeds fundingGoal)");
        
        sponsorData.sponsor = SponsorFunding(_address);
        sponsorData.sponsorshipReceived = false;
        sponsorData.sponsorshipAmount = _amount;
        
        if((sponsorData.sponsorshipAmount + address(this).balance) >= fundingGoal){
            state = State.Funded;
            emit FundingGoalReached(fundingGoal);
        }
        
    }
    
    function receiveSponsorshipFunds()
        public
        payable
        onlyState(State.Funded) 
        haveSponsor(true)
    {
        require(msg.sender == address(sponsorData.sponsor), "Only sponsor allowed");
        require(sponsorData.sponsorshipReceived == false, "Already received sponsorship!");
        require(msg.value == sponsorData.sponsor.getSponsorshipValue());
        
        assert(address(this).balance >= fundingGoal);
        
        sponsorData.sponsorshipReceived = true;
        
        emit SponsorshipReceived(msg.sender, msg.value);
    }
    
    receive() external payable { revert("Invalid operation!"); }
    fallback() external payable { revert("Invalid operation!"); }
    
    // Begin distribution
    function distribute() 
        external
        onlyState(State.Funded)
        onlyOwner
    {
        require(address(this).balance >= fundingGoal); //make sure SponsorshipReceived
        dsFunding.distributeFunds{value:address(this).balance}();
    }
}