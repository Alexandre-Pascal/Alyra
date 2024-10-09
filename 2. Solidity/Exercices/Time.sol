// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.27;

contract Time {
    function getTime() view public returns (uint){
        return block.timestamp;
    }
    
}