// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <=0.8.7;

import "./SponsorFunding.sol";
import "./DistributeFunding.sol";
import "./Owned.sol";

struct SponsorData {
    SponsorFunding sponsor;
    bool sponsorshipReceived;
}

struct Contributor {
    string              _name;
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
        sponsorData.sponsor.finalizeSponsorship();
    }
    
    // Contributors
    function contributeFunds(string memory _name) 
        external 
        payable
        onlyState(State.NotFunded) 
    {
        require(msg.value > 0, "You cannot contribute with none value");
        
        uint sponsorshipAmount = 0;
        if(address(sponsorData.sponsor) != address(0)){
            sponsorshipAmount = sponsorData.sponsor.getSponsorshipValue();
        }
        
        require(address(this).balance + sponsorshipAmount <= fundingGoal, "Invalid ammount!");
        
        contributors[msg.sender]._name = _name;
        contributors[msg.sender]._amount += msg.value;
        
        if(address(this).balance + sponsorshipAmount >= fundingGoal) {
            state = State.Funded;
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
    }
    
    // Sponsors

    function becomeSponsor(address _address) 
        external
        onlyState(State.NotFunded)
        haveSponsor(false)
    {
        // this method is called inside SponsorFunding constructor
        // which means that the contract abi is unavailable 
        sponsorData.sponsor = SponsorFunding(_address);
        sponsorData.sponsorshipReceived = false;
        
        // todo: check if sponsorship value is not 0
    }
    
    function receiveSponsorshipFunds()
        public
        payable
        onlyState(State.Funded) 
        haveSponsor(true)
    {
        require(msg.sender == address(sponsorData.sponsor), "Only sponsor allowed");
        require(msg.value == sponsorData.sponsor.getSponsorshipValue());
        
        assert(address(this).balance >= fundingGoal);
        
        emit SponsorshipReceived(msg.sender, msg.value);
    }
    
    receive() external payable { revert("Invalid operation!"); }
    fallback() external payable { revert("Invalid operation!"); }
    
    // Begin distribution
    function distribute() 
        external
        onlyState(State.Funded)
        onlyOwner
        payable 
    {
        require(address(this).balance >= fundingGoal); //make sure SponsorshipReceived
        dsFunding.distributeFunds{value:address(this).balance}();
    }
}