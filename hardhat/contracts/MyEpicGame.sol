// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./libraries/Base64.sol";
import "hardhat/console.sol";

contract MyEpicGame is ERC721, ERC721Enumerable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    event CharacterNFTMinted(
        address sender,
        uint256 tokenId,
        uint256 characterIndex
    );
    event AttackComplete(uint256 newBossHp, uint256 newPlayerHp);

    struct CharacterAttributes {
        string name;
        string imageURI;
        uint256 id;
        uint256 hp;
        uint256 maxHp;
        uint256 attackDamage;
    }

    struct BigScaryBoss {
        string name;
        string imageURI;
        uint256 hp;
        uint256 maxHp;
        uint256 attackDamage;
    }

    BigScaryBoss public bigScaryBoss;

    CharacterAttributes[] characterAttributes;

    mapping(uint256 => CharacterAttributes) public nftHolderAttributes;
    mapping(address => uint256) public ownerOfTokenId;

    constructor(
        string[] memory charNames,
        string[] memory charImageURIs,
        uint256[] memory charMaxHps,
        uint256[] memory charAttackDamages,
        string memory bossName,
        string memory bossImageURI,
        uint256 bossHp,
        uint256 bossAttackDamage
    ) ERC721("Pocket Monsters", "Pokemon") {
        for (uint256 i = 0; i < charNames.length; i++) {
            characterAttributes.push(
                CharacterAttributes({
                    name: charNames[i],
                    imageURI: charImageURIs[i],
                    id: i,
                    hp: charMaxHps[i],
                    maxHp: charMaxHps[i],
                    attackDamage: charAttackDamages[i]
                })
            );

            CharacterAttributes memory charAttrs = characterAttributes[i];

            console.log(
                "Done initializing %s w/ HP %s, img %s",
                charAttrs.name,
                charAttrs.hp,
                charAttrs.imageURI
            );
        }

        bigScaryBoss = BigScaryBoss({
            name: bossName,
            imageURI: bossImageURI,
            hp: bossHp,
            maxHp: bossHp,
            attackDamage: bossAttackDamage
        });

        console.log(
            "Done initializing boss %s w/ HP %s, img %s",
            bigScaryBoss.name,
            bigScaryBoss.hp,
            bigScaryBoss.imageURI
        );
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        CharacterAttributes memory charAttributes = nftHolderAttributes[
            _tokenId
        ];

        string memory strHp = Strings.toString(charAttributes.hp);
        string memory strMaxHp = Strings.toString(charAttributes.maxHp);
        string memory strAttackDamage = Strings.toString(
            charAttributes.attackDamage
        );

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        charAttributes.name,
                        " -- NFT #: ",
                        Strings.toString(_tokenId),
                        '", "description": "This is an NFT that lets people play in the game Metaverse Slayer!", "image": "ipfs://',
                        charAttributes.imageURI,
                        '", "attributes": [ { "trait_type": "Health Points", "value": ',
                        strHp,
                        ', "max_value":',
                        strMaxHp,
                        '}, { "trait_type": "Attack Damage", "value": ',
                        strAttackDamage,
                        "} ]}"
                    )
                )
            )
        );

        string memory output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        return output;
    }

    function fetchAllMintableNFTs()
        external
        view
        returns (CharacterAttributes[] memory)
    {
        return characterAttributes;
    }

    function mintCharacterNFT(uint256 _characterIndex) external {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();

        _safeMint(msg.sender, newItemId);

        nftHolderAttributes[newItemId] = CharacterAttributes({
            name: characterAttributes[_characterIndex].name,
            imageURI: characterAttributes[_characterIndex].imageURI,
            id: _characterIndex,
            hp: characterAttributes[_characterIndex].hp,
            maxHp: characterAttributes[_characterIndex].hp,
            attackDamage: characterAttributes[_characterIndex].attackDamage
        });

        ownerOfTokenId[msg.sender] = newItemId;

        console.log(
            "Minted NFT w/ tokenId %s and characterIndex %s",
            newItemId,
            _characterIndex
        );

        emit CharacterNFTMinted(msg.sender, newItemId, _characterIndex);
    }

    function checkIfUserHasNFT()
        public
        view
        returns (CharacterAttributes memory)
    {
        uint256 ownerTokenId = ownerOfTokenId[msg.sender];

        if (ownerTokenId > 0) {
            return nftHolderAttributes[ownerTokenId];
        }
        CharacterAttributes memory emptyData;
        return emptyData;
    }

    function attackBoss() public {
        // Get the state of the player's NFT.
        uint256 ownerTokenId = ownerOfTokenId[msg.sender];
        CharacterAttributes storage playerNFTData = nftHolderAttributes[
            ownerTokenId
        ];
        console.log(
            "\nPlayer w/ character %s about to attack. Has %s HP and %s AD",
            playerNFTData.name,
            playerNFTData.hp,
            playerNFTData.attackDamage
        );
        console.log(
            "Boss %s has %s HP and %s AD\n",
            bigScaryBoss.name,
            bigScaryBoss.hp,
            bigScaryBoss.attackDamage
        );

        require(playerNFTData.hp > 0, "RIP, your NFT is dead!");
        require(bigScaryBoss.hp > 0, "Success, you defeated the boss!!");

        if (playerNFTData.attackDamage > bigScaryBoss.hp) {
            bigScaryBoss.hp = 0;
        } else {
            bigScaryBoss.hp -= playerNFTData.attackDamage;
        }

        if (bigScaryBoss.attackDamage > playerNFTData.hp) {
            playerNFTData.hp = 0;
        } else {
            playerNFTData.hp -= bigScaryBoss.attackDamage;
        }

        console.log("Player attacked boss. New boss hp: %s", bigScaryBoss.hp);
        console.log(
            "Boss attacked player. New player hp: %s\n",
            playerNFTData.hp
        );

        emit AttackComplete(bigScaryBoss.hp, playerNFTData.hp);
    }
}
