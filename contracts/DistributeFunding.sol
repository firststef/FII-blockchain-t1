// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <=0.8.7;

import "./CrowdFunding.sol";

struct Fundee{
    address payable fAddress;
    uint32 share;
}

contract DistributeFunding{
    enum State {NotInitialized, Initialized, Finished}
    State private state;
    
    CrowdFunding cfContract;
    
    Fundee[] fundees;
    uint32 progressShare;
        
    constructor(address cfAddress) {
        cfContract = CrowdFunding(cfAddress);
    }
    
    function setFundee(address payable add, uint32 share) public {
        require(cfContract.checkOwner(msg.sender), "Only owner can set fundees");
        require(state == State.NotInitialized, "DistributeFunding has to be not initialized");
        fundees.push(Fundee(add, share));
        progressShare += share;
        if (progressShare == 100){
            state = State.Initialized;
        }
    }
    
    function distributeFunds() public payable {
        require(msg.sender == address(cfContract), "Only CrowdFunding can init distribution");
        require(state == State.Initialized, "DistributeFunding has not been fully initialized");
        state = State.Finished;
        cfContract.transferToDistribute();
        for (uint32 i = 0; i < fundees.length; i++){
            uint256 money = cfContract.getFundingGoal() * fundees[i].share / 100; 
            fundees[i].fAddress.transfer(money);
        }
    }
}