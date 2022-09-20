// SPDX-License-Identifier: MIT
 
pragma solidity >=0.7.0 <0.9.0;
 
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
 
contract AllCuteThingsMustDieGamePass is ERC721, Ownable {
  using Strings for uint256;
  using Counters for Counters.Counter;
 
  Counters.Counter private supply;
 
  string public uriPrefix = "ipfs://QmfZS8T9vExvyxgqgCHSqRcnwJbemNvyuf5AvgwgVVKEoJ/";
  string public uriSuffix = ".json";
 
  uint256 public cost = 1 ether;
  uint256 public maxFreeMints = 200;
  uint256 public maxMintAmountPerTx = 1;
 
  bool public paused = false;
  bool public revealed = false;
 
  constructor() ERC721("All Cute Things Must Die Game Pass", "ACTGP") {
    mint(8);
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
    if (msg.sender != owner()) {
        if (totalSupply() > maxFreeMints) {
            require(msg.value >= cost * _mintAmount, "Insufficient funds!");
        }
    }
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
 
  function tokenURI(uint256 _tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(_tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );
    return uriPrefix;
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
 
  function withdraw() public onlyOwner {
    (bool os, ) = payable(owner()).call{value: address(this).balance}("");
    require(os);
  }
 
  function _mintLoop(address _receiver, uint256 _mintAmount) internal {
    for (uint256 i = 0; i < _mintAmount; i++) {
      supply.increment();
      _safeMint(_receiver, supply.current());
    }
  }
 
  function _baseURI() internal view virtual override returns (string memory) {
    return uriPrefix;
  }
}

