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
        // Add manager automatically without sending any ether.
        players.push(payable(manager));
    }

    receive() external payable{
        //te manager can not participate in the lottery.
        require(msg.sender != manager, "Manager is not allowed to participate");
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
        // anyone can pick a winner if there are at least 10 players in the lottery
        // require(msg.sender == manager);  // anyone can pick the winner
        require (players.length >= 10);
        
        uint r = random();
        address payable winner;
        
        // computing a random index of the array
        uint index = r % players.length;
    
        winner = players[index]; // this is the winner

        uint managerFree = (getBalance() * 10) / 100; // manager fee is 10%
        uint winnerPrize = (getBalance() * 90) / 100; // winner prize is 90%

        
        // transferring 90% contract's balance to the winner
        winner.transfer(winnerPrize);
        
        // transferring 10% contract's balance to the winner
        payable(manager).transfer(managerFree);
        
        // resetting the lottery for the next round
        players = new address payable[](0);
    }
 
}