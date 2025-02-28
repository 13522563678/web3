// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract ComplexValueType{
    function testAddress()public view  returns(address){
        address addr = msg.sender;
        return addr;

    }
    function testMyAddress()public view  returns(address){
        address addr = address(this);
        return addr;

    }

    //Contract Type
    function testContract()public view {
     
        ComplexValueType mycontract = this;
        
    }
    function testFixedByteArray()public pure returns(bytes3){
        bytes3 data = 0x111111;

        return data;
    }
      function testFixedByteArray1()public pure returns(uint){
        bytes3 data = 0x111111;
        bytes1 first = data[0];
        uint256 l =  data.length;
        return l;
    }
    function testMsg() public view returns(bytes4){
        uint b = gasleft();
        bytes4 u = msg.sig;
        return u;
    }
}
//0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
//0x5B38Da6a701c568545dCfcB03FcB875f56beddC4

//0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8
//0x9D7f74d0C41E726EC95884E0e97Fa6129e3b5E99
//0x9D7f74d0C41E726EC95884E0e97Fa6129e3b5E99