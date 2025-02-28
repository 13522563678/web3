// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;
import "./ICallee.sol";
/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */


contract Caller{
    address calleeAddress;
    constructor(address _calleeAddress){
        calleeAddress = _calleeAddress;
    }
    function setCalleeX(uint _x)public{
        ICallee callee = ICallee(calleeAddress);
        callee.setX(_x);

    }

}
//0x9D7f74d0C41E726EC95884E0e97Fa6129e3b5E99  0xd2a5bC10698FD955D1Fe6cb468a17809A08fd005