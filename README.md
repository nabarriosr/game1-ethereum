# ROCK PAPER SCISSORS GAME

## Getting Started

- Install NodeJS https://nodejs.org/en/download/
- Install python 3 https://www.python.org/downloads/
- Install brownie     ```pipx install eth-brownie ```
- Run from the root ``` brownie compile ```


## Scripts

- Run ``` brownie run deploy ``` to deploy the smart contract *also possible include network but that require infura node.

## Tests

- Run ``` brownie test``` to test, the most scenarios scenarios were worked

## Integration with ERC20

This game works with the native token of the network, but tpo implement some ERC20 its neccesary insert the interface (for ERC20 one interface standardized) and itside the smart contract just called and execute the transfer operation when its neccesary.

``` IERC20 public token;```

``` token.transfer([arguments])```

https://docs.openzeppelin.com/contracts/4.x/erc20


## Comments
- The smart contarct has all the permission system neccesary to can challenge other players (identified by account address)
- Hide own decissions on game (or throws)
- Getters to can access data
- One account can play with itself
- Option to reject or accept challenge and pay teh bet
- Reimbursement in case of reject
- Frontend is being coded on react but still is not ready
- 
