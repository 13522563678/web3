// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract ArrayType {
    uint8[3] data;
    uint8[] ddata;
    uint16[10] data16;
    uint16[] ddata16;

    function test16() view public returns (uint16[10] memory){
        return data16;
    }


    function test16Read()  public view returns (uint16[] memory){
        return ddata16;
    }


    function test16Push(uint16 param)  public  {
        ddata16.push(param);
    }

    function test16Pop()  public  {
        ddata16.pop();
    }





    function testStaticArray() public returns (uint8[3] memory) {
        data[0] = 25;
        return data;
    }

    function testReadDynamicStorageArray()
        public
        view
        returns (uint8[] memory)
    {
        return ddata;
    }

    function testWriteDynamicStorageArray() public {
        ddata.push(12);
        ddata.pop();
        ddata.push(90);
    }

    function testMemoryDynamicArra(uint8 size)
        public
        pure
        returns (uint8[] memory)
    {
        uint8[] memory mdata = new uint8[](size);
    }

}
