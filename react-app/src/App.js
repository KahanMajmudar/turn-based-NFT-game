import React, { useEffect, useState } from 'react'
import { ethers } from 'ethers'
import twitterLogo from './assets/twitter-logo.svg'
import './App.css'
import SelectCharacter from './Components/SelectCharacter'
import Arena from './Components/Arena'
import { CONTRACT_ADDRESS, transformCharacterData } from './constants'
import { abi as EPICGAMEABI } from './artifacts/contracts/MyEpicGame.sol/MyEpicGame.json'

// Constants
const TWITTER_HANDLE = '_buildspace'
const TWITTER_LINK = `https://twitter.com/${TWITTER_HANDLE}`

const App = () => {
	/*
	 * Just a state variable we use to store our user's public wallet. Don't forget to import useState.
	 */
	const [currentAccount, setCurrentAccount] = useState(null)

	/*
	 * Right under current account, setup this new state property
	 */
	const [characterNFT, setCharacterNFT] = useState(null)

	/*
	 * Start by creating a new action that we will run on component load
	 */
	// Actions
	const checkIfWalletIsConnected = async () => {
		try {
			/*
			 * First make sure we have access to window.ethereum
			 */
			const { ethereum } = window

			if (!ethereum) {
				console.log('Make sure you have MetaMask!')
				return
			} else {
				console.log('We have the ethereum object', ethereum)

				/*
				 * Check if we're authorized to access the user's wallet
				 */
				const accounts = await ethereum.request({
					method: 'eth_accounts',
				})

				/*
				 * User can have multiple authorized accounts, we grab the first one if its there!
				 */
				if (accounts.length !== 0) {
					const account = accounts[0]
					console.log('Found an authorized account:', account)
					setCurrentAccount(account)
				} else {
					console.log('No authorized account found')
				}
			}
		} catch (error) {
			console.log(error)
		}
	}

	/*
	 * Implement your connectWallet method here
	 */
	const connectWalletAction = async () => {
		try {
			const { ethereum } = window

			if (!ethereum) {
				alert('Get MetaMask!')
				return false
			}

			/*
			 * Fancy method to request access to account.
			 */
			const accounts = await ethereum.request({
				method: 'eth_requestAccounts',
			})

			/*
			 * Boom! This should print out public address once we authorize Metamask.
			 */
			console.log('Connected', accounts[0])
			setCurrentAccount(accounts[0])
		} catch (error) {
			console.log(error)
		}
	}

	useEffect(() => {
		/*
		 * The function we will call that interacts with out smart contract
		 */
		const fetchNFTMetadata = async () => {
			console.log(
				'Checking for Character NFT on address:',
				currentAccount
			)

			const provider = new ethers.providers.Web3Provider(window.ethereum)
			const signer = provider.getSigner()
			const gameContract = new ethers.Contract(
				CONTRACT_ADDRESS,
				EPICGAMEABI,
				signer
			)

			const txn = await gameContract.checkIfUserHasNFT()
			if (txn.name) {
				console.log('User has character NFT')
				setCharacterNFT(transformCharacterData(txn))
			} else {
				console.log('No character NFT found!')
			}
		}

		/*
		 * We only want to run this, if we have a connected wallet
		 */
		if (currentAccount) {
			console.log('CurrentAccount:', currentAccount)
			fetchNFTMetadata()
		}
	}, [currentAccount])

	// Render Methods
	const renderContent = () => {
		/*
		 * Scenario #1
		 */
		if (!currentAccount) {
			return (
				<div className="connect-wallet-container">
					<img
						src="https://64.media.tumblr.com/tumblr_mbia5vdmRd1r1mkubo1_500.gifv"
						alt="Monty Python Gif"
					/>
					<button
						className="cta-button connect-wallet-button"
						onClick={connectWalletAction}
					>
						Connect Wallet To Get Started
					</button>
				</div>
			)
			/*
			 * Scenario #2
			 */
		} else if (currentAccount && !characterNFT) {
			return <SelectCharacter setCharacterNFT={setCharacterNFT} />
		} else if (currentAccount && characterNFT) {
			return (
				<Arena
					characterNFT={characterNFT}
					setCharacterNFT={setCharacterNFT}
				/>
			)
		}
	}

	/*
	 * This runs our function when the page loads.
	 */
	useEffect(() => {
		checkIfWalletIsConnected()
	}, [])

	return (
		<div className="App">
			<div className="container">
				<div className="header-container">
					<p className="header gradient-text">
						⚔️ Metaverse Slayer ⚔️
					</p>
					<p className="sub-text">
						Team up to protect the Metaverse!
					</p>
					{/* This is where our button and image code used to be!
					 *	Remember we moved it into the render method.
					 */}
					{renderContent()}
				</div>
				<div className="footer-container">
					<img
						alt="Twitter Logo"
						className="twitter-logo"
						src={twitterLogo}
					/>
					<a
						className="footer-text"
						href={TWITTER_LINK}
						target="_blank"
						rel="noreferrer"
					>{`built with @${TWITTER_HANDLE}`}</a>
				</div>
			</div>
		</div>
	)
}

export default App
