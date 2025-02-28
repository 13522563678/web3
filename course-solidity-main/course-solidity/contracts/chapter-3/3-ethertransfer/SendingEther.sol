// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract ReceiveEther {
    string public caller;
 
    receive() external payable {
//        caller = "receive";
    }

    fallback() external  {
        caller = "fallback";
    }
    function deposit()public {

    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}

contract SendEther {

    //send和transfer不建议使用
    function sendViaTransfer(address payable _to) public payable {
        _to.transfer(msg.value);
    }

    function sendViaSend(address payable _to) public payable {

        bool sent = _to.send(msg.value);
        require(sent, "Failed to send Ether");
    }

    function sendViaCall(address  _to) public payable {
        //calldata为空，空字符串也可以转为字节数组
        (bool sent, bytes memory data) = _to.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
    }
    uint public received;
    function deposit()public payable{
        received += msg.value;
     
    }
     function sendTo(address payable _to,uint amount) public  {
        
        (bool sent, bytes memory data) = _to.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    //2300是开发者在send和transfer中封装好的，限制被调用者做一些额外的消耗gas的操作
    //如果出现了 就会报错
    function mysend(address to, uint amount)public returns(bool){
        (bool sent, bytes memory data) = to.call{gas: 2300, value: amount}("");
        return  sent;
    }
  function mytransfer(address to, uint amount)public returns(bool){
        (bool sent, bytes memory data) = to.call{gas: 2300, value: amount}("");
        require(sent, "Failed to send Ether");
    }




}

contract TestSender{

    string public  caller;
    receive() external payable { 
        caller = "1";
    }
    fallback() external payable{
        caller= "2";
    }

    function deposit() public {

    }

    function getBalance() public view  returns (uint){
        return address(this).balance;
    }


}