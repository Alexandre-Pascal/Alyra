// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Epargne is Ownable{

    mapping (uint => uint) history;
    uint256 public depositCount = 0;


    uint firstTransactionTime;
    bool isFirstTransaction = true;

    constructor() Ownable(msg.sender){
    }

    function deposit() external onlyOwner payable {
        require(msg.value > 0,  "Le montant doit etre superieur a 0");

        if (isFirstTransaction){
            firstTransactionTime = block.timestamp;
            isFirstTransaction = false;
        }
            depositCount++;
            history[depositCount] = msg.value;
        }

     function withdraw()  external onlyOwner{
        require(block.timestamp >= firstTransactionTime + 90 days, "Cela fait pas trois mois");
        require(address(this).balance > 0, "Insufficient balance in contract");

        (bool sent,) = payable(msg.sender).call{value: address(this).balance}("");
        require(sent, "Echec");
    }

}