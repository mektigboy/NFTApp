// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

/// @title Random IPFS NFT
/// @author mektigboy
/// @notice Generate NFTs with randomness, and store them in a decentralized way.
/// @dev This contract utilizes Chainlink VRF v2 for randomness.
/// URI points to IPFS.
/// Imports contracts from OpenZeppelin.
contract Random is ERC721URIStorage {
    constructor() ERC721("Random IPFS NFT", "RIN") {}
}
