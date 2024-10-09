// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.27;

contract Whitelist {
    mapping (address => bool) whitelist;

    event Authorized(address _address);
    event ethReceive(address _addres, uint amount);

    // function authorize(address _address) public{
    //     require(check(), "Vous n'etes pas autorise");
    //         whitelist[_address] = true;
    //         emit Authorized(_address);
    // }

    // function check() view private returns (bool) {
    //     bool isChecked = false;
    //     if (whitelist[msg.sender] == true){
    //         isChecked = true;
    //     }
    //     return isChecked;
    // }

    constructor(){
        whitelist[msg.sender] = true;
    }

    function authorize(address _address) public check{
            whitelist[_address] = true;
            emit Authorized(_address);
    }

    modifier  check()   {
        require(whitelist[msg.sender] == true, "You are not authorized");
        _;
    }



    // receive() external payable { 
    //     emit ethReceive(msg.sender, msg.value);
    // }

    // fallback() external payable { 
    //     emit ethReceive(msg.sender, msg.value);
    // }
}