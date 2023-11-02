// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

interface IMiPrimerTKN {
    function mint(address to, uint256 amount) external;
    function burn(address from, uint256 amount) external;
    function balanceOf(address account) external view returns (uint256);
    function addToWhiteList(address _account) external;
    function removeFromWhitelist(address _account) external;
}

contract AirdropOne is Pausable, AccessControl {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");


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
        _setupRole(MINTER_ROLE, msg.sender);
        _setupRole(BURNER_ROLE, msg.sender);

    }

    function min() external view {
        require(hasRole(MINTER_ROLE, msg.sender), "MINTER_ROLE");
    }

     function bur() external view {
        require(hasRole(BURNER_ROLE, msg.sender), "BURNER_ROLE");
    }

    
   

    function addToWhiteList(address _account) external onlyRole(MINTER_ROLE) {
    require(!whiteList[_account], "Address is already in the whitelist");
    whiteList[_account] = true;
   
}

function removeFromWhitelist(address _account) external onlyRole(MINTER_ROLE) {
    require(whiteList[_account], "Address is not in the whitelist");
    whiteList[_account] = false;
   
}

 

    function participateInAirdrop() public whenNotPaused {
    require(whiteList[msg.sender], "No esta en lista blanca");
    require(!haSolicitado[msg.sender], "Ya ha participado");
    
    // Generar un número aleatorio de tokens (simplificado aquí)
    uint256 tokensToReceive = _getRandomNumberBelow1000();

    // Actualizar el recuento de distribución de tokens
    require(airdropGivenSoFar + tokensToReceive <= totalAirdropMax, "Airdrop limit reached");
    airdropGivenSoFar += tokensToReceive;

    // Marcar que el usuario ha participado
    haSolicitado[msg.sender] = true;

    // Transferir los tokens
    IMiPrimerTKN(miPrimerTokenAdd).mint(msg.sender, tokensToReceive);
    }




   function quemarMisTokensParaParticipar() public whenNotPaused {
    require(haSolicitado[msg.sender], "Usted aun no ha participado");
    require(IMiPrimerTKN(miPrimerTokenAdd).balanceOf(msg.sender) >= quemaTokensParticipar, "No tiene suficientes tokens para quemar");

    // Quemar los tokens requeridos
    IMiPrimerTKN(miPrimerTokenAdd).burn(msg.sender, quemaTokensParticipar);

    // Marcar que el usuario ha participado
    haSolicitado[msg.sender] = false;
}



    // Función auxiliar para pausar el contrato
    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    // Función auxiliar para reanudar el contrato
    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function _getRandomNumberBelow1000() internal view returns (uint256) {
        uint256 random = (uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % 1000) + 1;
        return random * 10**18;
    }

    // Función para establecer la dirección del token
    function setTokenAddress(address _tokenAddress) external {
        miPrimerTokenAdd = _tokenAddress;
    }
}
