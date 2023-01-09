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


## Comments
- The smart contarct has all the permission system neccesary to can challenge other players (identified by account address)
- Hide own decissions on game (or throws)
- One account can play with itself
- Option to reject or accept challenge and pay teh bet
- Reimbursement in case of reject
