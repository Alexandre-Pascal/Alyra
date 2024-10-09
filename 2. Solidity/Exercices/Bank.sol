// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

contract Bank {
    
    mapping(address => uint) balances;

    function deposit(uint _amount) public {
        balances[msg.sender] = _amount;
    }

    function transfer(address _address, uint _amount) public {
        require (_address != address(0), "Vous ne pouvez pas envoyer a cette addresse");
        require(balanceOf(msg.sender) >= _amount, "Vous n'avez pas suffisamaent d'argent");
        balances[msg.sender] -= _amount;
        balances[_address] += _amount;
    }

    function balanceOf(address _address) public view returns (uint) {
        return balances[_address];
    }
}