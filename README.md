# Turn Based NFT Game

## To run the blockchain project

1. Clone the repo
2. `cd hardhat`
3. `npm i`
4. `npx hardhat run scripts/run.js` to test locally
5. create a .env file and add the following values

```
   ALCHEMY_API_KEY
   ACCOUNT_PRIVATE_KEY
```

6. `npx hardhat run scripts/deploy.js --network rinkeby` to deploy on the testnet

## To run the react app

1. `cd react-app`
2. copy the artifacts from hardhat/artifacts to react-app/src/artifacts
3. `npm i`
4. Replace the contract address in `constants.js`
5. `npm run start`

### Enjoy Playing 🔥


[Click](https://opensea.io/assets/matic/0x3CD266509D127d0Eac42f4474F57D0526804b44e/1846) to view project completion NFT
