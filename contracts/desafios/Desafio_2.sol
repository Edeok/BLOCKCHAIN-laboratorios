// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/**
 * Desafío 2
 *
 * Vamos a crear una serie de modifiers que nos ayudarán añadir validaciones
 * y protecciones a nuestros contratos.
 *
 * Escenarios a validar/proteger:
 *so
 *
 * 2
 * - permiso: que personas de una lista puedan llamar a un método
 *   nombre modifer: soloListaBlanca
 *   aplicar al método: metodoPermisoProtegido
 *   Adicional:
 *   - definir un setter para incluir addresses en la lista blanca protegido por soloAdmin
 *   - nombre del método: incluirEnListaBlanca
 *
 * 3
 * - tiempo: que un método sea llamado dentro de un rango de tiempo
 *   nombre modifer: soloEnTiempo
 *   aplicar al método: metodoTiempoProtegido
 *
 * 4
 * - pausa: que un método pueda ser pausado y reanudado
 *   nombre modifer: pausa
 *   aplicar al método: metodoPausaProtegido
 *   Adicional:
 *   - definir un método para cambiar ese booleano que tenga el modifier de soloAdmin
 *   - nombre del metodo: cambiarPausa
 *
 *
 * Notas:
 *  - para el modifier de tiempo, se puede usar block.timestamp
 *  - para el modifier de pausa, se puede usar un booleano
 *  - dejar los cuerpos de todos los métodos en blanco
 *
 * Testing: Ejecutar el siguiente comando:
 * - npx hardhat test test/DesafioTesting_2.js
 */

contract Desafio_2 {
    
    address public admin = 0x08Fb288FcC281969A0BBE6773857F99360f2Ca06;
    bool public funcionEjecutada = false; // Bandera para verificar si se ejecutó la función

    modifier soloAdmin() {
       require(msg.sender == admin, "No eres el admin");
        _;
    }

     function metodoAccesoProtegido() public soloAdmin {
       
       require(!funcionEjecutada, "No eres el admin" );

       funcionEjecutada = true;
     }

    // 2
   

     mapping(address => bool) public listaBlanca;
     modifier soloListaBlanca() {
     require(listaBlanca[msg.sender], "Fuera de la lista blanca");
    _;
}

     function metodoPermisoProtegido() public soloListaBlanca {

      

    }

     function incluirEnListaBlanca(address cuenta) public soloAdmin {
         listaBlanca[cuenta] = true;

    }

    // 3
    // definir un rango de tiempo cualquiera (e.g. hoy + 30 days)
    // En solidity se cumple que: 1 days = 86400 seconds
    uint256 public tiempoLimite = block.timestamp + 30 days;

     modifier soloEnTiempo() {
      
         require(block.timestamp <= tiempoLimite, "Fuera de tiempo");
    _;

     }

    function metodoTiempoProtegido() public soloEnTiempo {

    }

   
   
// 4

 bool public pausado;

modifier pausa() {
    require(!pausado, "El metodo esta pausado");
    _;
}



function metodoPausaProtegido() public pausa {

}

function cambiarPausa() public soloAdmin {
    pausado = !pausado;
}
}
