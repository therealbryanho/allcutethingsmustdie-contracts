// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Worm.sol";
import "hardhat/console.sol";

contract AllCuteThingsMustDie is Ownable, ReentrancyGuard {

Worm public payToken;
address public payTokenAddress;
address public gameowner;
uint256 public minScore = 500;
bool public beatMinScoreRequirement = false;
uint256 public contractMinimum = 10000000000000000000000; // 10000 tokens

    constructor(address _worm) {
        setPayToken(_worm);    
        gameowner = msg.sender;
    }

    function setContractMinimum(uint256 _contractMinimum) public onlyOwner {
        contractMinimum = _contractMinimum;
    }

    function setPayToken(address _payTokenAddress) public onlyOwner {
        payTokenAddress = _payTokenAddress;
        payToken = Worm(_payTokenAddress);
        payToken.approve(address(this),10000000000000000000000);
    }

    event CollectTokens(address _player, uint256 _score);

    function submitScore(uint256 _score) external nonReentrant returns (bool success) {
        if(beatMinScoreRequirement){
            require(_score > minScore, "You did not reach the minimum score to get worms");
        }

        uint256 _tokensEarned = _score * 10 ** 18;
        payToken.mint(address(this), _tokensEarned);

        payToken.approve(address(this), _tokensEarned);
        //payToken.transferFrom(address(this), msg.sender, _tokensEarned);
        (bool callsuccess, ) = payTokenAddress.call(
            abi.encodeWithSignature(
                "transfer(address,uint256)",
                msg.sender,
                _tokensEarned
            )
        );
        require(callsuccess, "Transfer fail");

        emit CollectTokens(msg.sender, _tokensEarned);
        return true;
    }

}