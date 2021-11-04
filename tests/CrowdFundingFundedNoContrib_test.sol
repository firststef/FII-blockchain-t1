// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "remix_tests.sol";
import "remix_accounts.sol";

import "../contracts/CrowdFunding.sol";
import "../contracts/SponsorFunding.sol";
import "../contracts/DistributeFunding.sol";

contract CrowdFundingSimpleTestScenario {
   
    struct ScenarioParameters {
        uint64 fundingGoal;
    }
    
    ScenarioParameters scenario;

    CrowdFunding cf;
    SponsorFunding sf;

    event DebugAddress(string id, address addr);
    event DebugUInt(string id, uint nr);

    function beforeAll () public {
        Assert.equal(address(cf), address(0), "invalid init");
        Assert.equal(address(sf), address(0), "invalid init");
        
        scenario.fundingGoal = 500;
    }
    
    /// #sender: account-0
    /// #value: 10000000000000000000
    function initContracts () public payable {
        Assert.greaterThan(msg.value, uint(0), "internal error");

        cf = new CrowdFunding(scenario.fundingGoal);
        
        cf.contributeFunds{value:250}("alfa");
        cf.contributeFunds{value:250}("beta");
        
        Assert.equal(cf.getStatus(), "Funded", "");
        
        try cf.contributeFunds{value:250}("theta") 
        {
            Assert.ok(false, "Test did not fail on contribute after fully funded");
        }
        catch Error(string memory reason){
            return;
        }
        
        Assert.ok(false, "Test did not fail on contribute after fully funded");
    }
}
