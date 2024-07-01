// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract Lottery{
    address payable[] public players;
    address public manager;

    constructor(){
        manager = msg.sender;
    }

    receive() external payable{
        require(msg.value == 0.1 ether, "not correct amunt, should be '0.1 Ether"); // 0.1 ether is equal to 100000000000000000 wei
        players.push(payable(msg.sender)); // We convert a plain address to a payable one.
    }

    function getBalance() public view returns(uint){
        require(msg.sender == manager, "you are not the owenr");
        return address(this).balance;
    }

    function random() public view returns(uint){ // This is not safe as a miner can manipulate and make himself a winner. Use chainlink instead.
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));
    }

    function pickWinner() public payable {
        require(msg.sender == manager);
        require(players.length >= 3);

        uint r  = random();
        address payable  winner;

        uint index = r % players.length;
        winner = players[index];
        
        winner.transfer(getBalance());
        players = new address payable[](0); //resetting the lottery
    }

}