// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

contract Random {
    uint nonce;

    function random() public returns (uint){
        nonce++;
        return uint(keccak256(abi.encodePacked(block.timestamp ,msg.sender, nonce))) % 100;
    }
    
}