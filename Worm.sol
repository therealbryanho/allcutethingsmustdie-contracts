// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import from node_modules @openzeppelin/contracts v4.0
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "hardhat/console.sol";

contract Worm is ERC20, Ownable, ReentrancyGuard {

  address public gameContractAddress;

    constructor() ERC20("Worm", "WORM") {
    }

    function mint(address account, uint256 amount) external returns (bool sucess) {
      require(account != address(0) && amount != uint256(0), "ERC20: function mint invalid input");
      require(_msgSender() == gameContractAddress, "ERC20: function only accessible by game contract");
      _mint(account, amount);
      return true;
    }

    function setGameContractAddress(address _gameContractAddress) external onlyOwner {
        gameContractAddress = _gameContractAddress;
        _mint(gameContractAddress, 10000000000000000000000);
    }

    function withdraw(uint256 amount) external onlyOwner returns (bool success) {
      require(amount <= address(this).balance, "ERC20: function withdraw invalid input");
      payable(_msgSender()).transfer(amount);
      return true;
    }
}