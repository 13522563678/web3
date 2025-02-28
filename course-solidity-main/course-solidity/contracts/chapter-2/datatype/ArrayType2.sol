// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AddressDataType {
    // 定义一个 public 地址类型变量 wallet，值为一个非零地址
    address public wallet = 0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8;

    constructor() {}

    // 查询 wallet 地址的余额
    function checkBalance() public view returns (uint) {
        return wallet.balance; // 返回 wallet 地址的余额
    }

    // 向 wallet 地址发送 Ether
    function sendEth(uint amount) public payable {
        // 向 wallet 地址发送 Ether
        payable(wallet).transfer(amount); // 使用 transfer 发送 Ether
    }
}
