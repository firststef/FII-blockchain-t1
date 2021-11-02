// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <=0.8.7;

contract Owned {
    address internal immutable owner;
    constructor() {owner = msg.sender;}
    
    modifier onlyOwner {
        require(checkOwner(msg.sender), "Only owner allowed!");
        _;
    }
    
    function checkOwner(address addr) public view returns(bool) {
        return addr == owner;
    }
}