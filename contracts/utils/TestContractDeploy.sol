// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <=0.8.7;

contract TestContractDeploy{
    constructor() payable {}
    
    function get() public view returns(uint256){
        return address(this).balance;
    }
}