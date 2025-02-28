// contracts/GameItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 导入 OpenZeppelin 的 ERC721 扩展功能和其他所需合约
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/// @title ArtistNFT 合约
/// @dev 该合约实现了一个 ERC721 NFT，其中包含 URI 存储、枚举、版税功能以及收费功能
// 支持 URI 存储的 ERC721 扩展
contract ArtistNFT is
    ERC721URIStorage,
    ERC721Enumerable, // 支持枚举功能的 ERC721 扩展
    ERC721Royalty, // 支持版税的 ERC721 扩展
    Ownable // 支持所有者权限管理的合约
{
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds; // 用于生成新的 tokenId 的计数器

    uint96 royaltyFraction = 200; // 默认版税分成比例（基于 10000 分母）
    uint256 public feeRate = 1 gwei; // 每次铸造的费用（1 gwei）
    address public feeCollector; // 收费方地址

    // 更新 token 时的内部函数
    function _update(
        address to, // 目标地址
        uint256 tokenId, // tokenId
        address auth // 授权地址
    ) internal virtual override returns (address) {
        address previousOwner = super._update(to, tokenId, auth);

        // 如果之前没有拥有者，添加到所有代币的枚举中
        if (previousOwner == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        }
        // 如果之前的拥有者不是目标地址，则从之前拥有者的枚举中移除
        else if (previousOwner != to) {
            _removeTokenFromOwnerEnumeration(previousOwner, tokenId);
        }

        // 如果目标地址是零地址（销毁代币），则从所有代币的枚举中移除
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        }
        // 如果之前的拥有者和目标地址不同，则将 token 添加到目标地址的枚举中
        else if (previousOwner != to) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }

        return previousOwner;
    }

    // 增加账户余额时的内部函数
    function _increaseBalance(
        address account,
        uint128 amount
    ) internal override(ERC721, ERC721Enumerable) {
        super._increaseBalance(account, amount);
    }

    // 设置版税分成比例
    function setFeeRoyaltyFraction(uint96 rf) external onlyOwner {
        royaltyFraction = rf;
    }

    // 设置铸造费用
    function setFeeRate(uint256 fr) external onlyOwner {
        feeRate = fr;
    }

    // 设置收费方地址
    function setFeeCollector(address fc) external onlyOwner {
        feeCollector = fc;
    }

    // 构造函数，初始化 ERC721，并设置初始收费方为合约的拥有者
    constructor() ERC721("ArtistNFT", "AN") {
        feeCollector = owner(); // 初始收费方为合约拥有者
    }

    // 提现函数，允许收费方提取合约中的余额
    function withdraw() external {
        require(msg.sender == feeCollector, "only fee collector can withdraw");
        (bool suc, bytes memory data) = feeCollector.call{
            value: address(this).balance
        }(""); // 提取合约中的所有余额
        require(suc, "withdraw failed!"); // 提现失败时抛出异常
    }

    // 铸造 NFT 的函数，只有支付费用的用户可以铸造
    function mint(
        address artist,
        string memory tokenURI
    ) public payable returns (uint256) {
        require(msg.value > feeRate, "please provide 1g wei for your minting!"); // 确保用户支付足够的费用

        uint256 newItemId = _tokenIds.current(); // 获取新的 tokenId
        _mint(artist, newItemId); // 铸造 NFT 给指定的 artist
        _setTokenURI(newItemId, tokenURI); // 设置 NFT 的 URI

        _tokenIds.increment(); // 增加 tokenId
        _setTokenRoyalty(newItemId, artist, royaltyFraction); // 设置 NFT 的版税
        return newItemId; // 返回新铸造的 tokenId
    }

    // 在转移 token 之前执行的钩子函数
    function _beforeTokenTransfer(
        address from, // 来源地址
        address to, // 目标地址
        uint256 firstTokenId, // 第一个 tokenId
        uint256 batchSize // 批量转移的 token 数量
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize); // 调用父类的 `_beforeTokenTransfer` 函数
    }

    // 销毁 NFT 的函数
    function _burn(
        uint256 tokenId
    ) internal override(ERC721, ERC721URIStorage, ERC721Royalty) {
        super._burn(tokenId); // 调用父类的 `_burn` 函数
    }

    // 支持的接口函数，用于检查合约是否实现某个接口
    function supportsInterface(
        bytes4 interfaceId
    )

    
        public
        view
        override(ERC721, ERC721Enumerable, ERC721Royalty)
        returns (bool)
    {
        return super.supportsInterface(interfaceId); // 调用父类的 `supportsInterface` 函数
    }

    // 获取指定 tokenId 对应的 URI
    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return ERC721URIStorage.tokenURI(tokenId); // 调用父类的 `tokenURI` 函数
    }
}
