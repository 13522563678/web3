// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract MappingType {
    //改成public...
    mapping(string => uint8) public ages;
    //public 读操作 array
    uint[] public arr;
    mapping(string => mapping(string => uint8)) public ages1;

    constructor(string memory key,address  ads) {
        addresses[key]=ads;
    }
    function getAge(string memory name) public view returns (uint8) {
         mapping(string => uint8) storage _ages = ages;
        return ages[name];
    }
    function getAddress(string memory key) public returns(address) {
       return addresses[key] ;
    }
    function setAge(string memory name, uint8 age) public {
        // mapping(string => uint8) storage myages = ages;
        ages[name] = age;
    }
    //一般规则：public menory calldata internal private可以是 storage 
    // mappping：只能是storage
    //=》public函数参数或者返回值不可能出现mapping类型 
    
    //写一个internal或private函数，传递storage的mapping
     mapping (string=>address) addresses;
    function _setMapping(mapping(string=>address) storage map2) internal {

    }
  function _setMapping2(mapping(string=>address) storage map2) private {
   
    }

}
