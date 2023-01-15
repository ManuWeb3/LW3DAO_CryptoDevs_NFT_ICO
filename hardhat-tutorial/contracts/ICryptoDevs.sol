// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// single interface being created for 2 below f()
// 1. in ERC721 (balanceOf)
// 2. in ERC721Enum (tokenOfOwnerByIndex)
// Our contract inherits ERC721Enum that already inherits ERC721 (extension)
// Hence, single interface works fine
// CryptoDevsNFT.balanceOf(sender); and CryptoDevsNFT.tokenOfOwnerByIndex(sender, i); work well
interface ICryptoDevs {
    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index)
        external
        view
        returns (uint256 tokenId);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);
}