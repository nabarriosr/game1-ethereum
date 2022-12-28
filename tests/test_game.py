import pytest
from brownie import Game, accounts, reverts

@pytest.fixture
def acc_deployer():
    return accounts[0]

@pytest.fixture
def acc_gamer1():
    return accounts[1]

@pytest.fixture
def acc_gamer2():
    return accounts[2]

@pytest.fixture
def acc_no_gamer():
    return accounts[3]

@pytest.fixture
def contract(acc_deployer, Game):
    return acc_deployer.deploy(Game)

def test_balance_contract(contract, acc_gamer1, acc_gamer2):
    contract.createGame(acc_gamer2, 2, {'from': acc_gamer1, 'value': "1 ether"})
    assert contract.balance() == "1 ether"

def test_restrictions_accept(contract, acc_gamer1, acc_gamer2, acc_no_gamer):
    contract.createGame(acc_gamer2, 2, {'from': acc_gamer1, 'value': "1 ether"})
    with reverts("Wrong gamer"):
        contract.acceptGame(0, {'from': acc_no_gamer})
    with reverts("Wrong bet"):
        contract.acceptGame(0, {'from': acc_gamer2, 'value': "0.5 ether"})
    with reverts("Yet game accepted"):
        contract.acceptGame(0, {'from': acc_gamer2, 'value': "1 ether"})
        contract.acceptGame(0, {'from': acc_gamer2, 'value': "1 ether"})

def test_restrictions_reject(contract, acc_gamer1, acc_gamer2, acc_no_gamer):
    contract.createGame(acc_gamer2, 2, {'from': acc_gamer1, 'value': "1 ether"})
    with reverts("Wrong gamer"):
        contract.rejectGame(0, {'from': acc_no_gamer})

def test_reject_reimbursement(contract, acc_gamer1, acc_gamer2):
    contract.createGame(acc_gamer2, 2, {'from': acc_gamer1, 'value': "1 ether"})
    prev_balance = acc_gamer1.balance()
    contract.rejectGame(0, {'from': acc_gamer2})
    assert prev_balance + "1 ether" == acc_gamer1.balance()

#Scenario including errors and win gamer1
def test_gameplay1(contract, acc_gamer1, acc_gamer2, acc_no_gamer):
    contract.createGame(acc_gamer2, 2, {'from': acc_gamer1, 'value': "1 ether"})
    with reverts("Wrong gamer"):
        contract.playAsGamer1(0,1,{'from': acc_no_gamer})
    with reverts("Wrong gamer"):
        contract.playAsGamer2(0,2,{'from': acc_no_gamer})
    contract.acceptGame(0, {'from': acc_gamer2, 'value': "1 ether"})    
    contract.playAsGamer1(0,3,{'from': acc_gamer1})
    contract.playAsGamer1(0,3,{'from': acc_gamer1})
    prev_bal_gamer1 = acc_gamer1.balance()
    with reverts("No more throws"):
        contract.playAsGamer1(0,3,{'from': acc_gamer1})
    contract.playAsGamer2(0,2,{'from': acc_gamer2})
    contract.playAsGamer2(0,2,{'from': acc_gamer2})
    with reverts("No more throws"):
        contract.playAsGamer2(0,3,{'from': acc_gamer2})
    assert prev_bal_gamer1 + "2 ether" == acc_gamer1.balance() 
    
#To verify is also possible test other scenarios where gamer 2 win, draws, and different number of turns
    
    
