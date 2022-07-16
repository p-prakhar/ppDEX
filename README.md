![Project Image](assets/logo.jpg)

# ppDEX
> Decentralised Exchange Based on Ethereum Blockchain

---

### Table of Contents

- [ppDEX](#ppdex)
    - [Table of Contents](#table-of-contents)
  - [Introduction](#introduction)
      - [Basic Terminology and Definitions](#basic-terminology-and-definitions)
      - [Technologies](#technologies)
  - [How It Works](#how-it-works)
      - [Creating Exchanges](#creating-exchanges)
      - [Setting Prices](#setting-prices)
      - [ETH &#8652; ERC20 Tokens](#eth--erc20-tokens)
      - [Providing Liquidity](#providing-liquidity)
  - [Future Additions](#future-additions)
  - [Installation](#installation)
  - [References](#references)
  - [Author Info](#author-info)
      - [Prakhar Pandey](#prakhar-pandey)
      - [Pratham Pekamwar](#pratham-pekamwar)
  - [License](#license)

---

## Introduction

ppDEX is a protocol for automated token exchange on Ethereum. It is designed around
ease-of-use, gas efficiency, censorship resistance, and zero rent extraction. It is useful for
traders and functions particularily well as a component of other smart contracts which
require guaranteed on-chain liquidity.

#### Basic Terminology and Definitions

- Ethereum - The blockchain platform used by ppDEX. Read [here](https://ethereum.org/).
- ERC20 - [Ethereum Standard Token](https://ethereum.org/en/developers/docs/standards/tokens/erc-20/)
- ETH - [Ether](https://ethereum.org/en/eth/)
- Smart Contract - A computer program written in Solidity, for Ethereum, that ensures credibility of the decentralized exchange. Read [Wiki](https://en.wikipedia.org/wiki/Smart_contract).
- Liquidity - Measure of how fluidly the token can be exchanged.
- Liquidity Pool - Pool of tokens locked in a smart contract.


#### Technologies

- Front End: HTML, CSS (+ BootStrap) , JavaScript (+ Jquery)
- Browser-Block Chain Connectivity: MetaMask, Web3.js
- Back End: Solidity, Ganache + Truffle (Local Network) (current), Rinkeby (to be deployed)

[Back To The Top](#ppdex)

---

## How It Works

Visit site [here](https://ppdex.herokuapp.com). (Note that the website may not be updated to the latest version yet.)
or build a local instance of the website using the instructions given [here](#installation). (Recommended for the most recent version)


#### Creating Exchanges
 [ppSwapExchangeCreator](contracts/ppdex.sol) deploys a separate exchange contract for each ERC20 token. These exchange contracts each hold a reserve of ETH and their associated ERC20. This allows trades between the two based on relative supply. This is achieved using the launchExhange() function.
 Following is the implementation of the same

``` solidity
function launchExchange(address _token) public returns (address exchange) {
    require(tokenToExchange[_token] == address(0));             //There can only be one exchange per token
    require(_token != address(0) && _token != address(this));
    ppSwap newExchange = new ppSwap(_token);
    tokenList.push(_token);
    tokenToExchange[_token] = address(newExchange);
    exchangeToToken[address(newExchange)] = _token;
    emit ExchangeLaunch(address(newExchange), _token);
    return address(newExchange);
}

```

#### Setting Prices

Prices are set automatically using the constant product
[`x*y=k`](https://ethresear.ch/t/improving-front-running-resistance-of-x-y-k-market-makers/1281) market maker mechanism, which keeps overall reserves in relative equilibrium. Reserves are
pooled between a network of liquidity providers who supply the system with tokens in exchange for a proportional share of transaction (provided through liquidity tokens) .
Following is the implementation for the same

``` solidity
uint256 TokenPool = invariant.div(EthPool);
```

Note: Here `div` is just a function that divides two numbers but in a safe manner, i.e. it does not divide by zero. Invariant is the k value in the above equation. EthPool is the amount of ETH in the pool. TokeinPool is the amount of tokens in the pool.





#### ETH &#8652; ERC20 Tokens







#### Providing Liquidity






[Back To The Top](#ppdex)


---
## Future Additions
- Support for ERC20 &#8652; ERC20 exchange

---

## Installation

- Step 1: Clone this repository into your local machine. (See [here](https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository))
- Step 2: Install Node.js and npm. (See [here](https://nodejs.org/en/download/))
- Step 3: Install Truffle. (See [here](https://truffleframework.com/docs/getting_started/installation))
- Step 4: Install Ganache. (See [here](https://ethereum.org/developers/testing/ganache-cli))
- Step 5: Install Metamask extension. (See [here](https://metamask.io/))
- Step 6: Run Ganache and Configure Metamask for the local network. (See [here](https://metamask.io/docs/guide/ethereum-setup.html))
- Step 7: Run the following command in the project directory:
    ```
    npm install
    ```
- Step 8: Run the following command in the project directory:
    ```
    npm run dev
    ```
- Step 9: Open the browser and navigate to the localhost:3000

[Back To The Top](#ppdex)

---

## References

- Ethereum - [Ethereum](https://ethereum.org/en/eth/)
- Solidity - [Solidity](https://solidity.readthedocs.io/en/latest/)
- Truffle - [Truffle](https://truffleframework.com/)
- ERC20 - [Ethereum Standard Token](https://ethereum.org/en/developers/docs/standards/tokens/erc-20/)
- Decentralized Applications - [Whiteboard Crypto](https://youtu.be/oPIupbsVimc) (YouTube), [Wiki](https://en.wikipedia.org/wiki/Decentralized_application) (Wikipedia)
- Smart Contracts - [Whiteboard Crypto](https://youtu.be/pyaIppMhuic) (YouTube), [Wiki](https://en.wikipedia.org/wiki/Smart_contract) (Wikipedia)

[Back To The Top](#ppdex)

---

## Author Info

#### Prakhar Pandey

- Email - [prakhar.pandey@iitg.ac.in](mailto:prakhar.pandey@iitg.ac.in)
- Github - [p-prakhar](https://github.com/p-prakhar)

#### Pratham Pekamwar

- Email - [p.pratham@iitg.ac.in](mailto:p.pratham@iitg.ac.in)
- Github - [PrathamPekamwar](https://github.com/PrathamPekamwar)
  
  [Back To The Top](#ppdex)

---

## License

- MIT License (MIT) (Truffle) - [MIT License](LICENSE)

    [Back To The Top](#ppdex)
---
