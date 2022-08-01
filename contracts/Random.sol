// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

/// @title Random IPFS NFT
/// @author mektigboy
/// @notice Generate NFTs with randomness, and store them in a decentralized way.
/// @dev This contract utilizes Chainlink VRF v2 for randomness.
/// URI points to IPFS.
/// Imports contracts from OpenZeppelin.
contract Random is ERC721URIStorage, VRFConsumerBaseV2 {
    VRFCoordinatorV2Interface immutable i_vrfCoordinator;
    bytes32 public immutable i_gasLane; // Should be <private>.
    uint64 public immutable i_subscriptionId; // Should be <private>.
    uint32 public immutable i_callbackGasLimit; // Should be <private>.
    uint16 public constant REQUEST_CONFIRMATIONS = 3; // Should be <private>.
    uint32 public constant NUM_WORDS = 3; // Should be <private>.
    uint256 public constant MAX_CHANCE_VALUE = 1000; // Should be <private>.

    mapping(uint256 => address) s_requestIdToSender;
    string[3] public s_tokenURIs;

    uint256 public s_tokenCounter;

    constructor(
        address vrfCoordinatorV2,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callbackGasLimit,
        string[3] memory tokenUris
    ) ERC721("Random IPFS NFT", "RIN") VRFConsumerBaseV2(vrfCoordinatorV2) {
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        s_tokenCounter = 0;
        s_tokenURIs = tokenUris;
    }

    // Mint a random object:

    // 1. Get random number.
    function requestObject() public returns (uint256 requestId) {
        requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );
        s_requestIdToSender[requestId] = msg.sender;
    }

    // 2. Mint object.
    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        override
    {
        // Owner of the object.
        address objectOwner = s_requestIdToSender[requestId];
        // Asign this NFT a <tokenId>.
        uint256 newTokenId = s_tokenCounter;
        s_tokenCounter = s_tokenCounter + 1;
        uint256 moddedRng = randomWords[0] % MAX_CHANCE_VALUE; // Random number generated.
        uint256 selection = selectionFromModdedRng(moddedRng);
        _safeMint(objectOwner, newTokenId);
        _setTokenURI(newTokenId, s_tokenURIs[selection]);
    }

    function calculateChance() public pure returns (uint256[3] memory) {
        // 0 - 10 = Epic
        // 11 - 100 = Rare
        // 101 - 1000 = Common
        return [10, 100, MAX_CHANCE_VALUE];
    }

    function selectionFromModdedRng(uint256 moddedRng)
        public
        pure
        returns (uint256)
    {
        uint256 cumulativeSum = 0;
        uint256[3] memory chanceArray = calculateChance();

        for (uint256 i = 0; i < chanceArray.length; i++) {
            if (
                moddedRng >= cumulativeSum &&
                moddedRng < cumulativeSum + chanceArray[i]
            ) return i; // Else use <revert> with custom error 'RangeOutOfScope'.
            cumulativeSum = cumulativeSum + chanceArray[i];
        }
    }
}
