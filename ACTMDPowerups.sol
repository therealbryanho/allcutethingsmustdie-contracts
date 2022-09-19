// SPDX-License-Identifier: MIT
 
pragma solidity >=0.7.0 <0.9.0;
 
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Worm.sol";
 
contract ACTMDPowerups is ERC721, Ownable {
  using Strings for uint256;
  using Counters for Counters.Counter;
 
  Counters.Counter private supply;
 
  string public uriPrefix = "";
  string public uriSuffix = ".json";
 
  uint256 public cost = 1000 ether;
  uint256 public maxMintAmountPerTx = 1;
 
  bool public paused = false;

   string[] private percent = [
        "+50",
        "+40",
        "+30",
        "+20",
        "+10",
        "-10",
        "-20",
        "-30",
        "-40",
        "-10"
    ];

  struct Powerup {
      string healthPowerup;
      string attackPowerup;
      string defensePowerup;
  }

  Powerup[] powerups;

  mapping(uint256 => address) public powerupOwner;

  Worm public payToken;
  address public payTokenAddress;
 
  constructor() ERC721("ACTMD Powerups", "ACTP") {
  }

  function setPayToken(address _payTokenAddress) public onlyOwner {
      payTokenAddress = _payTokenAddress;
      payToken = Worm(_payTokenAddress);
  }

  function random() private view returns(uint){
      return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, totalSupply())));
  }
 
  modifier mintCompliance(uint256 _mintAmount) {
      if (msg.sender != owner()) {
        require(_mintAmount > 0 && _mintAmount <= maxMintAmountPerTx, "Invalid mint amount!");
      }
    _;
  }
 
  function totalSupply() public view returns (uint256) {
    return supply.current();
  }
 
  function mint(uint256 _mintAmount) public payable mintCompliance(_mintAmount) {
    require(!paused, "The contract is paused!");
    _mintLoop(msg.sender, _mintAmount);
  }
 
  function mintForAddress(uint256 _mintAmount, address _receiver) public mintCompliance(_mintAmount) onlyOwner {
    _mintLoop(_receiver, _mintAmount);
  }
 
  function walletOfOwner(address _owner)
    public
    view
    returns (uint256[] memory)
  {
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory ownedTokenIds = new uint256[](ownerTokenCount);
    uint256 currentTokenId = 1;
    uint256 ownedTokenIndex = 0;
 
    while (ownedTokenIndex < ownerTokenCount) {
      address currentTokenOwner = ownerOf(currentTokenId);
 
      if (currentTokenOwner == _owner) {
        ownedTokenIds[ownedTokenIndex] = currentTokenId;
        ownedTokenIndex++;
      }
 
      currentTokenId++;
    }
 
    return ownedTokenIds;
  }
 
  function setCost(uint256 _cost) public onlyOwner {
    cost = _cost;
  }
 
  function setMaxMintAmountPerTx(uint256 _maxMintAmountPerTx) public onlyOwner {
    maxMintAmountPerTx = _maxMintAmountPerTx;
  }
 
  function setUriPrefix(string memory _uriPrefix) public onlyOwner {
    uriPrefix = _uriPrefix;
  }
 
  function setUriSuffix(string memory _uriSuffix) public onlyOwner {
    uriSuffix = _uriSuffix;
  }
 
  function setPaused(bool _state) public onlyOwner {
    paused = _state;
  }
 
  function _mintLoop(address _receiver, uint256 _mintAmount) internal {
    for (uint256 i = 0; i < _mintAmount; i++) {

      (bool success, ) = payTokenAddress.call(
            abi.encodeWithSignature(
                "transferFrom(address,address,uint256)",
                msg.sender,
                address(this),
                cost
            )
        );
        require(success, "Mint powerup fail");

      supply.increment();
      uint newPowerupId = supply.current();

      uint indexhealth = random() % 10;
      string memory _healthPowerup = percent[indexhealth];

      uint indexattack = random() % 10;
      string memory _attackPowerup = percent[indexattack];

      uint indexdefense = random() % 10;
      string memory _defensePowerup = percent[indexdefense];

      Powerup memory _powerup = Powerup({
          healthPowerup: _healthPowerup,
          attackPowerup: _attackPowerup,
          defensePowerup: _defensePowerup
      });
      powerups.push(_powerup);
      _transfer(address(0), _receiver, newPowerupId);//transfer from nowhere. Creation event.
    }
  }
 
  function _baseURI() internal view virtual override returns (string memory) {
    return uriPrefix;
  }

  function withdraw() public onlyOwner {
        (, bytes memory result) = payTokenAddress.staticcall(
            abi.encodeWithSignature("balanceOf(address)", address(this))
        );
        uint256 balance = abi.decode(result, (uint256));
        (bool success, ) = payTokenAddress.call(
            abi.encodeWithSignature(
                "transfer(address,uint256)",
                msg.sender,
                balance
            )
        );
        require(success, "Transfer fail");
    }
}