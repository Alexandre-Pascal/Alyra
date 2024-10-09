// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.27;

contract People {

    struct Person {
        string name;
        uint age;
    }

    Person public moi;

    function modifyPerson(string memory _name, uint _age) public  {
        moi.age = _age;
        moi.name = _name;
        // moi = Person(_name, _age);
    }


    Person[] public persons;

    function add(string memory _name, uint _age) public  {
        //persons.push(Person(_name, _age));
        Person memory person = Person(_name,_age);
        persons.push(person);
    }

    function remove() public {
        persons.pop();
    }
}

