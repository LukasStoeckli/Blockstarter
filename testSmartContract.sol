pragma solidity ^0.7.0;

contract SharedStorage {
    uint public dataStorage;
    // Set dataStorage value
    function store(uint _x) public {
        dataStorage = _x;
    }
}