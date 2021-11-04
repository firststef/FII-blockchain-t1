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
        uint sponsorshipPercentage;
        uint sponsorInitialBalance;
    }
    
    ScenarioParameters scenario;

    CrowdFunding cf;
    SponsorFunding sf;

    event DebugAddress(string id, address addr);
    event DebugUInt(string id, uint nr);

    function beforeAll () public {
        Assert.equal(address(cf), address(0), "invalid init");
        Assert.equal(address(sf), address(0), "invalid init");
        
        scenario.fundingGoal = 1000;
        scenario.sponsorshipPercentage = 50;
        scenario.sponsorInitialBalance = 500;
    }
    
    /// #sender: account-0
    /// #value: 10000000000000000000
    function initContracts () public payable {
        Assert.greaterThan(msg.value, uint(0), "internal error");

        cf = new CrowdFunding(scenario.fundingGoal);
        sf = new SponsorFunding{value:500}(payable(address(cf)), scenario.sponsorshipPercentage);
        
        cf.contributeFunds{value:250}("alfa");
        cf.contributeFunds{value:250}("beta");
        
        Assert.equal(cf.getStatus(), "Funded", "");
        
        // should fail, assert transaction reverted 
        //
        // contributor._name = "theta";
        // cf.contributeFunds{value:250}(contributor);
        
        cf.communicateFundingGoalReached();
        
        DistributeFunding df = DistributeFunding(cf.getDistribute());
        
        
        address account_0 = TestsAccounts.getAccount(9);
        address account_1 = TestsAccounts.getAccount(8);
        uint accountBalance_0 = account_0.balance;
        uint accountBalance_1 = account_1.balance;
        
        df.setFundee(payable(account_1), 50);
        df.setFundee(payable(account_0), 50);
        
        cf.distribute();
        
        Assert.equal(account_0.balance - accountBalance_0, 500, "");
        Assert.equal(account_1.balance - accountBalance_1, 500, "");
    }
}
