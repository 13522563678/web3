// contracts/GameItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 导入 OpenZeppelin 的 ERC721 扩展和其他辅助库
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol"; // ERC721 合约，支持 URI 存储
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol"; // ERC721 合约，支持枚举（枚举 tokenIDs）
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol"; // 支持版税的 ERC721 扩展
import "@openzeppelin/contracts/access/Ownable.sol"; // 继承 Ownable 合约，实现合约所有者权限控制
import "@openzeppelin/contracts/utils/Counters.sol"; // 计数器库，用于跟踪 token ID

// 定义 ArtistNFT 合约，继承自 ERC721URIStorage, ERC721Enumerable, ERC721Royalty 和 Ownable
contract ArtistNFT is
    ERC721URIStorage,
    ERC721Enumerable,
    ERC721Royalty,
    Ownable
{
    using Counters for Counters.Counter; // 使用计数器库来处理 token ID
    Counters.Counter private _tokenIds; // 用于生成新的 tokenId

    uint96 royaltyFraction = 200; // 版税比例，200 表示 2%
    uint public feeRate = 1 gwei; // 每个铸造 NFT 的费用
    address public feeCollector; // 费用收集者地址

    // 设置版税比例，只有合约所有者才能调用
    function setFeeRoyaltyFraction(uint96 rf) external onlyOwner {
        royaltyFraction = rf;
    }

    // 设置铸造费用率，只有合约所有者才能调用
    function setFeeRate(uint fr) external onlyOwner {
        feeRate = fr;
    }

    // 设置费用收集者地址，只有合约所有者才能调用
    function setFeeCollector(address fc) external onlyOwner {
        feeCollector = fc;
    }

    // 构造函数，初始化合约名称和符号，并设置费用收集者为合约所有者
    constructor() ERC721("ArtistNFT", "AN") {
        feeCollector = owner(); // 设置合约所有者为费用收集者
    }

    // 提现函数，只有费用收集者可以提取合约中的余额
    function withdraw() external {
        require(msg.sender == feeCollector, "only fee collector can withdraw"); // 验证调用者是费用收集者
        (bool suc, bytes memory data) = feeCollector.call{
            value: address(this).balance
        }(""); // 提取合约余额
        require(suc, "withdraw failed!"); // 提取失败则抛出异常
    }

    // 铸造函数，用于铸造新的 NFT，接收艺术家的地址和 tokenURI
    function mint(
        address artist,
        string memory tokenURI
    ) public payable returns (uint256) {
        // 必须支付大于铸造费用的金额
        require(msg.value > feeRate, "please provide 1g wei for your minting!");

        uint256 newItemId = _tokenIds.current(); // 获取当前 tokenId
        _mint(artist, newItemId); // 铸造新 token
        _setTokenURI(newItemId, tokenURI); // 设置该 token 的 URI

        _tokenIds.increment(); // 增加 tokenId
        _setTokenRoyalty(newItemId, artist, royaltyFraction); // 设置该 token 的版税

        return newItemId; // 返回新铸造的 tokenId
    }

    // 重写 ERC721 的 _beforeTokenTransfer 函数，处理 token 转移前的逻辑
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize); // 调用父类的 _beforeTokenTransfer
    }

    // 重写 ERC721 的 _burn 函数，处理 token 销毁时的逻辑
    function _burn(
        uint256 tokenId
    ) internal override(ERC721, ERC721URIStorage, ERC721Royalty) {
        super._burn(tokenId); // 调用父类的 _burn
    }

    // 重写 ERC721 的 supportsInterface 函数，检查是否支持某个接口
    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC721, ERC721Enumerable, ERC721Royalty)
        returns (bool)
    {
        return super.supportsInterface(interfaceId); // 调用父类的 supportsInterface
    }

    // 重写 ERC721 的 tokenURI 函数，返回 token 的 URI
    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return ERC721URIStorage.tokenURI(tokenId); // 调用父类的 tokenURI
    }
}
