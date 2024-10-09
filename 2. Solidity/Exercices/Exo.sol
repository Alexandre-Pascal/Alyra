// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

contract Exo {
    address  myAddr;

    function setAddr(address _addr) external {
        myAddr = _addr;
    }

    function getMyBalance() external view returns (uint){
        return myAddr.balance;
    }

    function getBalance(address _addr) external view returns (uint){
        return _addr.balance;
    }
    
    function transfertEth(address payable _to) external payable {
        _to.transfer(msg.value);
    }

    function sendEth(address payable _to) external payable {
        bool sent = _to.send(msg.value);
        require(sent, "qsqs");
    }
    function callEth(address payable _to) external payable {
        (bool sent,) = _to.call{value:msg.value}("");
        require(sent, "zezeez");
    }


    function transfert(uint _minBalance) external payable {
        require(myAddr.balance > _minBalance* 1 ether, "La quantite d'ether est trop faible");
        (bool sent,) = myAddr.call{value:msg.value}("");
        require(sent, "L'argent n'as pas pu etre envoye");
    }

}
