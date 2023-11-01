// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
REPETIBLE CON LÍMITE, PREMIO POR REFERIDO

* El usuario puede participar en el airdrop una vez por día hasta un límite de 10 veces
* Si un usuario participa del airdrop a raíz de haber sido referido, el que refirió gana 3 días adicionales para poder participar
* El contrato Airdrop mantiene los tokens para repartir (no llama al mint )
* El contrato Airdrop tiene que verificar que el totalSupply  del token no sobrepase el millón
* El método participateInAirdrop le permite participar por un número random de tokens de 1000 - 5000 tokens
*/

interface IMiPrimerTKN {
    function transfer(address to, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

contract AirdropTwo is Pausable, AccessControl {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    struct Participant {
        address participantAddress;
        uint256 participations;
        uint256 limiteParticipaciones;
        uint256 lastTimeParticipated;
    }

    mapping(address => Participant) public participantes;

    // instanciamos el token en el contrato
    IMiPrimerTKN miPrimerToken;

    constructor(address _tokenAddress) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);

        miPrimerToken = IMiPrimerTKN(_tokenAddress);
    }

    function participateInAirdrop() public {
        _participateInAirdrop(address(0));
    }

    function participateInAirdrop(address _elQueRefirio) public {
        _participateInAirdrop(_elQueRefirio);
    }

    function _participateInAirdrop(address _elQueRefirio) private {
        if (participantes[msg.sender].participantAddress == address(0)) {
            Participant memory newParticipant = Participant({
                participantAddress: msg.sender,
                participations: 1,
                lastTimeParticipated: block.timestamp,
                limiteParticipaciones: 10
            });

            participantes[msg.sender] = newParticipant;
        } else {
            Participant memory participant = participantes[msg.sender];

            // 1 days = 86400 seconds
            require(
                participant.lastTimeParticipated + 86400 < block.timestamp,
                "Ya participaste en el ultimo dia"
            );

            require(
                participant.participations < participant.limiteParticipaciones,
                "Llegaste limite de participaciones"
            );

            participantes[msg.sender].participations++;
            participantes[msg.sender].lastTimeParticipated = block.timestamp;
        }

        uint256 semiRandomTokens = _getRadomNumber10005000();
        uint256 balanceTokensAirdrop = miPrimerToken.balanceOf(address(this));

        // Verifica que el contrato tenga suficientes tokens
        require(
            balanceTokensAirdrop >= semiRandomTokens,
            "El contrato Airdrop no tiene tokens suficientes"
        );

        // Verifica que el balance del token no sobrepase el millón
        require(
            balanceTokensAirdrop + semiRandomTokens <= 1e6 ether,
            "Total supply exceeds one million"
        );

        miPrimerToken.transfer(msg.sender, semiRandomTokens);
        require(msg.sender != _elQueRefirio, "No puede autoreferirse");
        if (_elQueRefirio != address(0)) _operateReferred(_elQueRefirio);
    }

    ///////////////////////////////////////////////////////////////
    ////                     HELPER FUNCTIONS                  ////
    ///////////////////////////////////////////////////////////////

    function _getRadomNumber10005000() internal view returns (uint256) {
        return
            (uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender))) %
                4000) +
            1000 +
            1;
    }

    function setTokenAddress(address _tokenAddress) external {
        miPrimerToken = IMiPrimerTKN(_tokenAddress);
    }

    function transferTokensFromSmartContract()
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        miPrimerToken.transfer(
            msg.sender,
            miPrimerToken.balanceOf(address(this))
        );
    }

    function _operateReferred(address _elQueRefirio) internal {
        Participant storage referredParticipant = participantes[_elQueRefirio];

        if (referredParticipant.participantAddress != address(0)) {
            referredParticipant.limiteParticipaciones += 3;
            referredParticipant.lastTimeParticipated = block.timestamp;
        } else {
            Participant memory newParticipant = Participant({
                participantAddress: _elQueRefirio,
                participations: 0,
                lastTimeParticipated: block.timestamp,
                limiteParticipaciones: 13
            });

            // guardar el registro del participante
            participantes[_elQueRefirio] = newParticipant;
 }
}
}