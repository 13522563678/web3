// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title 分红支付代币接口
/// @author Roger Wu (https://github.com/roger-wu)
/// @dev 分红支付代币合约的接口
interface DividendPayingTokenInterface {
    /// @notice 查看某个地址可以提取的分红数量（以 wei 为单位）
    /// @param _owner 代币持有者的地址
    /// @return 返回 `_owner` 地址可以提取的分红数量（以 wei 为单位）
    function dividendOf(address _owner) external view returns (uint256);

    /// @notice 将以太币作为分红分发给代币持有者
    /// @dev 应该将支付的以太币按比例分发给代币持有者作为分红。
    /// 不应在此函数中直接将以太币转移给代币持有者。
    /// 当分发的以太币数量大于0时，必须触发 `DividendsDistributed` 事件。
    function distributeDividends() external payable;

    /// @notice 提取分发给发送者的以太币作为分红
    /// @dev 应该将 `dividendOf(msg.sender)` wei 转移到 `msg.sender`，并且在转账后 `dividendOf(msg.sender)` 应该为 0。
    /// 当转账的以太币数量大于0时，必须触发 `DividendWithdrawn` 事件。
    function withdrawDividend() external;

    /// @dev 当以太币分发给代币持有者时必须触发此事件
    /// @param from 向该合约发送以太币的地址
    /// @param weiAmount 分发的以太币数量（以 wei 为单位）
    event DividendsDistributed(
        address indexed from, // 发送方地址
        uint256 weiAmount // 分发的以太币数量
    );

    /// @dev 当某个地址提取分红时必须触发此事件
    /// @param to 提取以太币的地址
    /// @param weiAmount 提取的以太币数量（以 wei 为单位）
    event DividendWithdrawn(
        address indexed to, // 提取者地址
        uint256 weiAmount // 提取的以太币数量
    );
}
