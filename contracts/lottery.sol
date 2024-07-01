// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract Lottery{
    
    // declaring the state variables
    address payable[] public players; //dynamic array of type address payable
    address public manager; 
    
    
    // declaring the constructor
    constructor(){
        // initializing the owner to the address that deploys the contract
        manager = msg.sender; 
    }

    receive() external payable{
         // each player sends exactly 0.1 ETH 
        require(msg.value == 0.1 ether, "not correct amunt, should be '0.1 Ether"); // 0.1 ether is equal to 100000000000000000 wei
        // appending the player to the players array
        players.push(payable(msg.sender)); // We convert a plain address to a payable one.
    }

     // returning the contract's balance in wei
    function getBalance() public view returns(uint){
        // only the manager is allowed to call it
        require(msg.sender == manager);
        return address(this).balance;
    }

    // helper function that returns a big random integer
    function random() public view returns(uint){ // This is not safe as a miner can manipulate and make himself a winner. Use chainlink instead.
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));
    }

    // selecting the winner
    function pickWinner() public{
        // only the manager can pick a winner if there are at least 3 players in the lottery
        require(msg.sender == manager);
        require (players.length >= 3);
        
        uint r = random();
        address payable winner;
        
        // computing a random index of the array
        uint index = r % players.length;
    
        winner = players[index]; // this is the winner
        
        // transferring the entire contract's balance to the winner
        winner.transfer(getBalance());
        
        // resetting the lottery for the next round
        players = new address payable[](0);
    }
 
}