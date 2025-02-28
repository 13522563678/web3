// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title 分红支付代币可选接口
/// @author Roger Wu (https://github.com/roger-wu)
/// @dev 提供给分红支付代币合约的可选函数接口
interface DividendPayingTokenOptionalInterface {
    /// @notice 查看某个地址可以提取的分红数量（以 wei 为单位）
    /// @param _owner 代币持有者的地址
    /// @return 返回 `_owner` 地址可以提取的分红数量（以 wei 为单位）
    function withdrawableDividendOf(
        address _owner
    ) external view returns (uint256);

    /// @notice 查看某个地址已经提取的分红数量（以 wei 为单位）
    /// @param _owner 代币持有者的地址
    /// @return 返回 `_owner` 地址已经提取的分红数量（以 wei 为单位）
    function withdrawnDividendOf(
        address _owner
    ) external view returns (uint256);

    /// @notice 查看某个地址总共赚得的分红数量（以 wei 为单位）
    /// @dev accumulativeDividendOf(_owner) = withdrawableDividendOf(_owner) + withdrawnDividendOf(_owner)
    /// @param _owner 代币持有者的地址
    /// @return 返回 `_owner` 地址总共赚得的分红数量（以 wei 为单位）
    function accumulativeDividendOf(
        address _owner
    ) external view returns (uint256);
}
