/// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;


/// @title Game


contract Game {


    struct Data {
        address gamer1;         // Gamer that create teh challenge
        address gamer2;         // gamer to be challenged
        bool accepted;          // Gamer 2 accept the challenge
        bool finished;
        uint16 numberTurns;     // Number of turns to resolve the game *only until 16 bits number*
        uint256 bet;            // Valut ETH bet
        uint8[] gamer1Throws;   // Array gamer 1
        uint8[] gamer2Throws;   // Array gamer 2
        address winner;
    }
    mapping(uint => Data) internal idGameToData;         //Private Allow hide throws, intead to query info use getData
    mapping(address => uint[]) public gamesCreated;
    mapping(address => uint[]) public gamesReceived;
    mapping(address => uint) public gamesCreatedCount;
    mapping(address => uint) public gamesReceivedCount;

    uint public countIDGames;


    event WinnerEvent(
        address winner,
        uint idGame,
        uint jackpot
    );


    // 1,2 and 3 represents the three different case when you play
    modifier validThrow(uint8 _throw){
        require(_throw == 1 || _throw == 2 || _throw == 3);
        _;
    }


    constructor(){
        countIDGames = 0;
    }



    function createGame(address _gamer2, uint16 _numberTurns) external payable {
        gamesCreated[msg.sender].push(countIDGames);
        gamesReceived[_gamer2].push(countIDGames);
        gamesCreatedCount[msg.sender]++;
        gamesReceivedCount[_gamer2]++;
        idGameToData[countIDGames] = Data({
            gamer1: msg.sender,
            gamer2: _gamer2,
            accepted: false,
            finished: false,
            numberTurns: _numberTurns,
            bet: msg.value,
            gamer1Throws: new uint8[](0),
            gamer2Throws: new uint8[](0),
            winner: address(0)

        });
        countIDGames++;
    } 

    // Function to accept challenge and equal bet
    function acceptGame(uint _idGame) external payable {
        require(msg.sender == idGameToData[_idGame].gamer2, "Wrong gamer");
        require(msg.value == idGameToData[_idGame].bet, "Wrong bet");
        require(!idGameToData[_idGame].accepted, "Yet game accepted");
        
        idGameToData[_idGame].accepted = true;
    }

    //Function to reject challenge and reimbursement of bet to gamer1
    function rejectGame(uint _idGame) external {
        require(msg.sender == idGameToData[_idGame].gamer2, "Wrong gamer");
        idGameToData[_idGame].finished = true;
        idGameToData[_idGame].gamer1.call{value: idGameToData[_idGame].bet}("");
    }

    function playAsGamer1(uint _idGame, uint8 _throw) external validThrow(_throw){
        require(msg.sender == idGameToData[_idGame].gamer1, "Wrong gamer");
        require(idGameToData[_idGame].gamer1Throws.length < idGameToData[_idGame].numberTurns, "No more throws");
        idGameToData[_idGame].gamer1Throws.push(_throw);
        if(idGameToData[_idGame].gamer1Throws.length == idGameToData[_idGame].numberTurns && idGameToData[_idGame].gamer2Throws.length == idGameToData[_idGame].numberTurns){
            _resolveGame(_idGame);
        }
    }

    function playAsGamer2(uint _idGame, uint8 _throw) external validThrow(_throw){
        require(msg.sender == idGameToData[_idGame].gamer2, "Wrong gamer");
        require(idGameToData[_idGame].gamer2Throws.length < idGameToData[_idGame].numberTurns, "No more throws");
        idGameToData[_idGame].gamer2Throws.push(_throw);
        if(idGameToData[_idGame].gamer1Throws.length == idGameToData[_idGame].numberTurns && idGameToData[_idGame].gamer2Throws.length == idGameToData[_idGame].numberTurns){
            _resolveGame(_idGame);
        }
    }

    //Function to decide state of one throw in a game, 1: win1, 2: win2, 3: Draw
    function _winState(uint8 _throw1, uint8 _throw2) internal returns(uint8){
        if(_throw1 == _throw2){
            return 3;
        }
        if(_throw1==1 && _throw2 == 3){
            return 1;
        }
        if(_throw1 > _throw2){
            return 1;
        }
        return 2;
    }


    function _resolveGame(uint _idGame) internal {
        uint16 _countWinsGamer1 = 0;
        uint16 _countWinsGamer2 = 0;
        uint16 _state;
        for (uint j = 0; j < idGameToData[_idGame].numberTurns; j++) {
            _state = _winState(idGameToData[_idGame].gamer1Throws[j], idGameToData[_idGame].gamer2Throws[j]);
            if(_state == 1){
                _countWinsGamer1++;
            } else if(_state == 2){
                _countWinsGamer2++;
            }
        }
        if(_countWinsGamer1 > _countWinsGamer2){
            idGameToData[_idGame].winner = idGameToData[_idGame].gamer1;
            idGameToData[_idGame].gamer1.call{value: 2*idGameToData[_idGame].bet}("");
            emit WinnerEvent(idGameToData[_idGame].gamer1, _idGame, 2*idGameToData[_idGame].bet);
        } else if(_countWinsGamer1 < _countWinsGamer2){
            idGameToData[_idGame].winner = idGameToData[_idGame].gamer2;
            idGameToData[_idGame].gamer2.call{value: 2*idGameToData[_idGame].bet}("");
            emit WinnerEvent(idGameToData[_idGame].gamer2, _idGame, 2*idGameToData[_idGame].bet);
        } else {
            idGameToData[_idGame].gamer1.call{value: idGameToData[_idGame].bet}("");
            idGameToData[_idGame].gamer2.call{value: idGameToData[_idGame].bet}("");
        }
        idGameToData[_idGame].finished = true;
    }
    
    //Function to show data without throws, only the players of one game can see
    function getData(uint _idGame) external view returns(address, address, bool, bool, uint16, uint256, address){
        require(idGameToData[_idGame].gamer1 == msg.sender || idGameToData[_idGame].gamer2 == msg.sender, "Wrong Gamer");
        return (idGameToData[_idGame].gamer1,     
        idGameToData[_idGame].gamer2, 
        idGameToData[_idGame].accepted,
        idGameToData[_idGame].finished,
        idGameToData[_idGame].numberTurns,
        idGameToData[_idGame].bet,
        idGameToData[_idGame].winner);
    }

    function getThrows(uint _idGame) external view returns(uint8[] memory){
        require(idGameToData[_idGame].gamer1 == msg.sender || idGameToData[_idGame].gamer2 == msg.sender, "Wrong Gamer");
        if(idGameToData[_idGame].gamer1 == msg.sender){
            return idGameToData[_idGame].gamer1Throws;
        } else {
            return idGameToData[_idGame].gamer2Throws;
        }
    }
}

