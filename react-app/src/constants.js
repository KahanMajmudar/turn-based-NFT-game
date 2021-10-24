const CONTRACT_ADDRESS = '0xBCA88811B32D5947A3F8a04cc0Fc1c1ADb46f6E7'

/*
 * Add this method and make sure to export it on the bottom!
 */
const transformCharacterData = (characterData) => {
	return {
		name: characterData.name,
		imageURI: characterData.imageURI,
		hp: characterData.hp.toNumber(),
		maxHp: characterData.maxHp.toNumber(),
		attackDamage: characterData.attackDamage.toNumber(),
	}
}

export { CONTRACT_ADDRESS, transformCharacterData }
