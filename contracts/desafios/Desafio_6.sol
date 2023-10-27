// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

interface IMiPrimerTKN {
    function mint(address to, uint256 amount) external;
    function burn(address from, uint256 amount) external;
    function balanceOf(address account) external view returns (uint256);
}

contract AirdropOne is Pausable, AccessControl {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    uint256 public constant totalAirdropMax = 10_000_000 * 10**18;
    uint256 public constant quemaTokensParticipar = 10 * 10**18;

    uint256 public airdropGivenSoFar;
    address public miPrimerTokenAdd;

    mapping(address => bool) public whiteList;
    mapping(address => bool) public haSolicitado;

    constructor(address _tokenAddress) {
        miPrimerTokenAdd = _tokenAddress;

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(PAUSER_ROLE, msg.sender);
    }

    function participateInAirdrop() public whenNotPaused {
        require(whiteList[msg.sender], "Not in whitelist");
        require(!haSolicitado[msg.sender], "Already participated");
        require(airdropGivenSoFar + quemaTokensParticipar <= totalAirdropMax, "Airdrop limit reached");

        // Generate a random number of tokens (simplified here)
        uint256 tokensToReceive = _getRandomNumberBelow1000();

        // Update the token distribution count
        airdropGivenSoFar += tokensToReceive;

        // Mark that the user has participated
        haSolicitado[msg.sender] = true;

        // Transfer the tokens
        IMiPrimerTKN(miPrimerTokenAdd).mint(msg.sender, tokensToReceive);
    }

    function burnMyTokensToParticipate() public whenNotPaused {
        require(!haSolicitado[msg.sender], "Already participated");
        require(IMiPrimerTKN(miPrimerTokenAdd).balanceOf(msg.sender) >= quemaTokensParticipar, "Insufficient tokens");

        // Burn the required tokens
        IMiPrimerTKN(miPrimerTokenAdd).burn(msg.sender, quemaTokensParticipar);

        // Mark that the user has participated
        haSolicitado[msg.sender] = true;
    }

    // Helper function to add an address to the whitelist
    function addToWhiteList(address _account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        whiteList[_account] = true;
    }

    // Helper function to remove an address from the whitelist
    function removeFromWhitelist(address _account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        whiteList[_account] = false;
    }

    // Helper function to pause the contract
    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    // Helper function to unpause the contract
    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function _getRandomNumberBelow1000() internal view returns (uint256) {
        uint256 random = (uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % 1000) + 1;
        return random * 10**18;
    }

    // Function to set the token address
    function setTokenAddress(address _tokenAddress) external {
        miPrimerTokenAdd = _tokenAddress;
    }
}
