const CONTRACT_ADDRESS = '0xB1199F8008E27C2AC382E7EB7416cf21CF3d2945'

/*
 * Add this method and make sure to export it on the bottom!
 */
const transformCharacterData = (characterData) => {
	return {
		name: characterData.name,
		imageURI: `https://cloudflare-ipfs.com/ipfs/${characterData.imageURI}`,
		hp: characterData.hp.toNumber(),
		maxHp: characterData.maxHp.toNumber(),
		attackDamage: characterData.attackDamage.toNumber(),
	}
}

export { CONTRACT_ADDRESS, transformCharacterData }
