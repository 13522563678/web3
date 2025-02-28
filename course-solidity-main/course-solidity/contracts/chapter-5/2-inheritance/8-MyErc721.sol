import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract MyErc721Erc721 is ERC721Enumerable{
    constructor()ERC721("myNFT", "MYNFT"){

    }
     function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal {
    }

 
    // 只使用 ERC721 中的实现
    function _increaseBalance(address account, uint128 value) internal override(ERC721Enumerable) {
        super._increaseBalance(account, value);  // 调用 ERC721 的实现
    }

}