// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Deviner is Ownable {

    string word;
    string clue;
    address winner;

    mapping (address => bool) alreadyPlayed;
    address[] players;

    modifier isWordSet {
        // require(keccak256(abi.encodePacked((word))) != keccak256(abi.encodePacked((""))), "The word is not yet defined");
        require(bytes(word).length > 0, "The word is not yet defined");
        _;
    }

    modifier isWordNotSet {
        require(bytes(word).length == 0, "The word is already defined");
        // require(keccak256(abi.encodePacked((word))) == keccak256(abi.encodePacked((""))), "The word is already defined");        
        _;
    }

    constructor() Ownable(msg.sender){
    }
    
    function setWord(string calldata _word) external onlyOwner isWordNotSet{
        word = _word;
    }

    function setClue(string calldata _clue) external onlyOwner isWordSet {
        clue = _clue;
    }

    function getClue() external view isWordSet returns (string memory){
        require(bytes(clue).length > 0, "No clue is defined" );
        return clue;
    }

    function getWinner() external view returns (address) {
        require(winner != address(0), "No one already found the word");
        return winner;
    }

    function guessWord(string memory _guess ) external isWordSet returns (bool){
        require(!alreadyPlayed[msg.sender], "You already played once");
        players.push(msg.sender);
        alreadyPlayed[msg.sender] = true;
        if (keccak256(abi.encodePacked((_guess))) == keccak256(abi.encodePacked((word)))){
            winner = msg.sender;
            return true;
        }
        else {
            return false;
        }
    }

    function resetGame() external onlyOwner{
        for (uint i = 0; i < players.length; ++i) 
        {
            if(alreadyPlayed[players[i]]){
            alreadyPlayed[players[i]] = false;
            }
        }
        word = "";
        clue = "";
        winner = address(0);

        delete players;
    }
}