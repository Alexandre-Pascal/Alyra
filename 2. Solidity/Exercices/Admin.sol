// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;
    import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract Admin is Ownable {

    mapping (address => bool) whitelist;
    mapping (address => bool) blacklist;

    event Whitelisted(address, string);
    event Blacklisted(address, string);

    constructor() Ownable(msg.sender){
    }

    function authorize(address _address) public onlyOwner{
        require(!whitelist[_address], "Vous etes deja whitelist");
        require(!blacklist[_address], "Vous etes blacklist");
        whitelist[_address] = true;
        emit Whitelisted(_address, "Cette adresse est whitelist");
    }

    function ban(address _address) public onlyOwner{
        require(!blacklist[_address], "Vous etes deja blacklist");
        blacklist[_address] = true;
        emit Blacklisted(_address, "Cette adresse est blacklist");
    }

    function isWhitelisted(address _address) public view returns (bool) {
        return whitelist[_address];
    }

    function isBlacklisted(address _address) public view returns (bool) {
        return blacklist[_address];
    }
}