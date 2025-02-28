// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

 contract Base {
    
    constructor(string memory  _name) {}

}

contract ContractA is Base {
    string name;

    constructor() Base(name) {}

}
contract ContracB is Base("") {


    constructor() {}

}