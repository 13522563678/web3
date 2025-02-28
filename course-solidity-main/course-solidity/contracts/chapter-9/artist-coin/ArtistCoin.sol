// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 引入 OpenZeppelin 的标准合约和工具
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";  // 引入 ERC-20 标准代币合约
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";  // 引入 Ownable 合约，用于管理合约所有者权限
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";  // 引入防重入攻击的工具合约
import "./dividend/DividendPayingTokenInterface.sol";  // 引入分红支付接口
import "./dividend/DividendPayingTokenOptionalInterface.sol";  // 引入分红支付可选接口

// ArtistCoin 合约继承了 ERC20, Ownable, ReentrancyGuard 和分红相关接口
contract ArtistCoin is 
    ERC20, 
    Ownable, 
    ReentrancyGuard, 
    DividendPayingTokenInterface, 
    DividendPayingTokenOptionalInterface 
{
    // 设置最大供应量常量为 100 ether
    uint256 public constant MAX_SUPPLY = 100 ether;

    // 构造函数，初始化 ERC-20 标准的名称和符号
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    // 为了精确计算分红，使用了放大的常数
    uint256 internal constant magnitude = 2**128;

    // 存储每个代币应分配的分红数量
    uint256 internal magnifiedDividendPerShare;

    // 存储合约所有者可提取的资金数量
    uint256 public ownerWithdrawable;

    // 锁定状态，控制是否允许用户提取分红
    bool public locked;

    // 存储每个用户的分红修正值，确保在转账等操作后用户的分红保持一致
    mapping(address => int256) internal magnifiedDividendCorrections;
    // 存储每个用户已提取的分红
    mapping(address => uint256) internal withdrawnDividends;

    // 限制铸币时的数量，不能超过最大供应量
    modifier mintable(uint256 amount) {
        require(amount + totalSupply() <= MAX_SUPPLY, "amount surpasses max supply");
        _;
    }

    // 只有合约未锁定时，用户才能进行分红提取
    modifier isUnlocked() {
        require(!locked, "contract is currently locked");
        _;
    }

    // 接收以太币时触发，进行分红分配
    receive() external payable {
        distributeDividends();
    }

    // 铸币功能：用户通过支付以太币来铸造新的代币
    function mint(address to_)
        public
        payable
        mintable(msg.value)  // 确保铸币后总供应量不超过最大供应量
    {
        ownerWithdrawable += msg.value;  // 增加合约所有者可提取的资金
        _mint(to_, msg.value);  // 铸造新的代币并转给用户
    }

    // 合约所有者提取以太币
    function collect()
        public
        onlyOwner  // 只有所有者可以提取
        nonReentrant  // 防止重入攻击
    {
        require(ownerWithdrawable > 0);  // 确保合约所有者有可提取的资金
        uint _with = ownerWithdrawable;
        ownerWithdrawable = 0;  // 重置所有者可提取金额
        payable(msg.sender).transfer(_with);  // 将资金转到所有者
    }

    // 切换合约的锁定状态，防止用户提取分红
    function toggleLock() external onlyOwner {
        locked = !locked;
    }

    // 分配收到的以太币给代币持有者，作为分红
    function distributeDividends() public payable {
        require(totalSupply() > 0);  // 确保有代币存在，才能分配分红

        if (msg.value > 0) {
            // 根据总供应量计算每个代币应分得的分红，并更新 magnifiedDividendPerShare
            magnifiedDividendPerShare += (msg.value * magnitude) / totalSupply();
            emit DividendsDistributed(msg.sender, msg.value);  // 触发分红分配事件
        }
    }

    // 用户提取他们应得的分红
    function withdrawDividend() public nonReentrant isUnlocked {
        uint256 _withdrawableDividend = withdrawableDividendOf(msg.sender);  // 获取可提取的分红
        if (_withdrawableDividend > 0) {
            withdrawnDividends[msg.sender] += _withdrawableDividend;  // 更新已提取的分红
            emit DividendWithdrawn(msg.sender, _withdrawableDividend);  // 触发分红提取事件
            (payable(msg.sender)).transfer(_withdrawableDividend);  // 转账给用户
        }
    }

    // 查看某个地址可以提取的分红数量
    function dividendOf(address _owner) public view returns (uint256) {
        return withdrawableDividendOf(_owner);
    }

    // 查看某个地址可提取的分红数量
    function withdrawableDividendOf(address _owner)
        public
        view
        returns (uint256)
    {
        return accumulativeDividendOf(_owner) - (withdrawnDividends[_owner]);
    }

    // 查看某个地址已经提取的分红数量
    function withdrawnDividendOf(address _owner) public view returns (uint256) {
        return withdrawnDividends[_owner];
    }

    // 查看某个地址总共赚得的分红数量（已提取和未提取的分红总和）
    function accumulativeDividendOf(address _owner)
        public
        view
        returns (uint256)
    {
        int256 x = int256(magnifiedDividendPerShare * balanceOf(_owner));  // 计算应得分红

        x += magnifiedDividendCorrections[_owner];  // 加上修正值
        return uint256(x) / magnitude;  // 返回总分红金额（去掉修正和放大的影响）
    }

    // 重写 _transfer 方法，确保转账时分红修正值正确更新
    function _transfer(
        address from,
        address to,
        uint256 value
    ) internal override {
        super._transfer(from, to, value);  // 调用父类的转账方法

        int256 _magCorrection = int256(magnifiedDividendPerShare * (value));  // 计算修正值

        magnifiedDividendCorrections[from] += _magCorrection;  // 更新转出账户的修正值
        magnifiedDividendCorrections[to] -= _magCorrection;  // 更新转入账户的修正值
    }

    // 重写 _mint 方法，确保铸币时分红修正值正确更新
    function _mint(address account, uint256 value) internal override {
        super._mint(account, value);  // 调用父类的铸币方法

        magnifiedDividendCorrections[account] -= int256(magnifiedDividendPerShare * value);  // 更新铸币账户的修正值
    }

    // 重写 _burn 方法，确保燃烧时分红修正值正确更新
    function _burn(address account, uint256 value) internal override {
        super._burn(account, value);  // 调用父类的燃烧方法

        magnifiedDividendCorrections[account] += int256(magnifiedDividendPerShare * value);  // 更新燃烧账户的修正值
    }
}
