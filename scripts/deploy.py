from brownie import Game, accounts

def main():
    contract= Game.deploy({'from': accounts[0]})
    return contract

    
