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

    struct CharacterAttributes {
        string name;
        string imageURI;
        uint256 id;
        uint256 hp;
        uint256 maxHp;
        uint256 attackDamage;
    }

    CharacterAttributes[] characterAttributes;

    mapping(uint256 => CharacterAttributes) public nftHolderAttributes;

    constructor(
        string[] memory charNames,
        string[] memory charImageURIs,
        uint256[] memory charMaxHps,
        uint256[] memory charAttackDamages
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
                        '", "description": "This is an NFT that lets people play in the game Metaverse Slayer!", "image": "',
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

        console.log(
            "Minted NFT w/ tokenId %s and characterIndex %s",
            newItemId,
            _characterIndex
        );
    }
}
