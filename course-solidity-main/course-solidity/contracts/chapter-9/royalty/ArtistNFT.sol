// contracts/GameItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 引入 OpenZeppelin 库中的 ERC721 标准接口及其扩展功能
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol"; // 支持 URI 存储
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol"; // 支持枚举功能
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol"; // 支持版税功能
import "@openzeppelin/contracts/utils/Counters.sol"; // 计数器，生成新的 Token ID

// 定义 ArtistNFT 合约，继承 ERC721 的功能
contract ArtistNFT is ERC721URIStorage, ERC721Enumerable, ERC721Royalty {
    // 使用 Counters 库来处理 Token ID 的生成
    using Counters for Counters.Counter;

    // 声明一个计数器，用于生成新的 Token ID
    Counters.Counter private _tokenIds;

    // 构造函数，初始化合约时设置 Token 的名字和符号
    constructor() ERC721("ArtistNFT", "AN") {
        // 这里可以进行额外的初始化操作（暂时为空）
    }

    // Mint 函数，铸造新的 NFT
    // artist: 接收 NFT 的艺术家地址
    // tokenURI: 该 NFT 的元数据 URI
    function mint(
        address artist,
        string memory tokenURI
    ) public returns (uint256) {
        // 获取下一个新的 Token ID
        uint256 newItemId = _tokenIds.current();

        // 铸造新的 Token，并将其分配给指定艺术家
        _mint(artist, newItemId);

        // 设置该 Token 的元数据 URI
        _setTokenURI(newItemId, tokenURI);

        // 增加计数器，为下一个 Token 分配新的 ID
        _tokenIds.increment();

        // 设置该 Token 的版税，艺术家地址和版税比例（200表示2%）
        _setTokenRoyalty(newItemId, artist, 200);

        // 返回新铸造的 Token ID
        return newItemId;
    }

    // 覆盖 _beforeTokenTransfer 函数，确保 ERC721 和 ERC721Enumerable 的转移逻辑被调用
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
    }

    // 覆盖 _burn 函数，确保在销毁 Token 时调用 ERC721 和 ERC721URIStorage 的销毁逻辑
    function _burn(
        uint256 tokenId
    ) internal override(ERC721, ERC721URIStorage, ERC721Royalty) {
        super._burn(tokenId);
    }

    // 支持的接口检查，确保合约实现了 ERC721, ERC721Enumerable 和 ERC721Royalty 的接口
    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC721, ERC721Enumerable, ERC721Royalty)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    // 覆盖 tokenURI 函数，获取指定 Token 的元数据 URI
    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return ERC721URIStorage.tokenURI(tokenId);
    }
}
