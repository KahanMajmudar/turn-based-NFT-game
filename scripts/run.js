// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require('hardhat')

async function main() {
	// Hardhat always runs the compile task when running scripts with its command
	// line interface.
	//
	// If this script is run directly using `node` you may want to call compile
	// manually to make sure everything is compiled
	// await hre.run('compile');
	;[owner, addr1, _] = await ethers.getSigners()

	// We get the contract to deploy
	const GameContract = await hre.ethers.getContractFactory('MyEpicGame')
	const gameContract = await GameContract.deploy(
		['Charizard', 'Mewtwo', 'Pikachu', 'Eevee', 'Gyarados'],
		[
			'https://comicvine.gamespot.com/a/uploads/scale_medium/11/114183/5198637-006charizard.png',
			'https://comicvine.gamespot.com/a/uploads/original/11/114183/5200790-150mewtwo.png',
			'https://comicvine.gamespot.com/a/uploads/original/11/114183/5198796-025pikachu.png',
			'https://comicvine.gamespot.com/a/uploads/original/11/114183/5198663-133eevee.png',
			'https://comicvine.gamespot.com/a/uploads/original/11/114183/5198702-130gyarados.png',
		],
		[360, 416, 430, 435, 640],
		[215, 254, 135, 150, 200]
	)

	await gameContract.deployed()

	console.log('Game Contract deployed to:', gameContract.address)
	// 0x4e3fab0dad77db15657a77268aaf1f94e4457490

	await gameContract.mintCharacterNFT(0)
	await gameContract.mintCharacterNFT(1)
	await gameContract.mintCharacterNFT(2)
	await gameContract.mintCharacterNFT(3)
	await gameContract.mintCharacterNFT(4)

	let returnedTokenUri = await gameContract.tokenURI(1)
	let tokenOwneData = await gameContract.balanceOf(owner.address)
	console.log('Token URI:', returnedTokenUri)
	console.log('Token Data:', tokenOwneData)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error)
		process.exit(1)
	})
