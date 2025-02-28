pragma solidity ^0.8.0;

contract IntegerDataType {
    uint public a = 10;
    uint public b = 1;
    int public c = -1;
    function arithmetic() public view returns (uint, uint, uint, uint) {
        return (a + b, a - b, a * b, a / b);
    }
}
