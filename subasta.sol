// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

contract Subasta {
    
    address payable public owner;
    address payable public ganador;
    uint256 public profit;

    string public articulo;
    uint256 public tiempo_limite;
    uint256 public oferta_mas_alta;
    bool public finalizada;
    
    mapping(address => uint256) public depositos_usuarios;
    
    address[] public participantes;

    event NuevaOferta(address indexed oferente, uint256 monto, uint256 timestamp);
    event SubastaFinalizada(address ganador, uint256 montoGanador);  
    event ReembolsoRealizado(address indexed usuario, uint256 monto);

    modifier onlyOwner() {
        require(msg.sender == owner, "Solo el owner puede hacer esto");
        _;
    }
    modifier checkDead() {
        if (block.timestamp >= tiempo_limite && !finalizada) {
            finalizada = true;
            emit SubastaFinalizada(ganador, oferta_mas_alta);
        }
        _;
    }
    
    constructor(string memory _articulo, uint256 _duracion_minutos) {
        owner = payable(msg.sender);
        articulo = _articulo;
        tiempo_limite = block.timestamp + (_duracion_minutos * 1 minutes);
        finalizada = false;
        oferta_mas_alta = 0;
        profit = 0;
    }
    
    function ofertar() public payable checkDead{
        require(msg.sender != owner, "El owner no puede ofertar");

        uint256 oferta_minima;
        if (oferta_mas_alta == 0) {
            oferta_minima = 0;
        } else {
            oferta_minima = oferta_mas_alta + (oferta_mas_alta * 5 / 100);
        }
        
        require(msg.value >= oferta_minima, "Tu oferta tiene que ser 5% mas alta");
        
        // Actualizo quien va ganando
        ganador = payable(msg.sender);
        oferta_mas_alta = msg.value;
        
        // Deposito principal
        depositos_usuarios[msg.sender] = depositos_usuarios[msg.sender] + msg.value;
        
        // Agrego a la lista si no estaba
        bool esta_en_lista = false;
        for (uint256 i = 0; i < participantes.length; i++) {
            if (participantes[i] == msg.sender) {
                esta_en_lista = true;
                break;
            }
        }
        if (!esta_en_lista) {
            participantes.push(msg.sender);
        }
        
        // Si faltan menos de 10 minutos, extiendo el tiempo
        if (tiempo_limite - block.timestamp < 10 minutes) {
            tiempo_limite = block.timestamp + 10 minutes;
        }
        
        // Emito el evento
        emit NuevaOferta(msg.sender, msg.value, block.timestamp);
    }
    
    // Funcion para ver quien va ganando
    function obtenerGanador() public view returns (address, uint256) {
        return (ganador, oferta_mas_alta);
    }
    
    // Funcion para ver todas las ofertas
    function obtenerOfertas() public view returns (address[] memory, uint256[] memory) {
        uint256[] memory montos = new uint256[](participantes.length);
        for (uint256 i = 0; i < participantes.length; i++) {
            montos[i] = depositos_usuarios[participantes[i]];
        }
        return (participantes, montos);
    }
    
    // Funcion para retirar eth de saldo previo durante la subasta 
    function retirarSaldoPrevio() public checkDead {
        require(!finalizada, "La subasta ya finalizo");
        uint256 mi_deposito = depositos_usuarios[msg.sender];
        require(mi_deposito > oferta_mas_alta, "No tienes excedente");
        
        uint256 exceso = mi_deposito - oferta_mas_alta;
        depositos_usuarios[msg.sender] = oferta_mas_alta;
        payable(msg.sender).transfer(exceso);
        emit ReembolsoRealizado(msg.sender, exceso);
    }
    
    // Post-Subasta
    function retirarDeposito() public checkDead{
        require(finalizada, "La subasta no finalizo");
        require(msg.sender != ganador, "Felicidades, ganaste la subasta!");
        
        uint256 mi_deposito = depositos_usuarios[msg.sender];
        require(mi_deposito > 0, "No tenes eth para retirar");
        
        uint256 comision = mi_deposito * 2 / 100;
        uint256 reembolso = mi_deposito - comision;
        profit += comision;

        depositos_usuarios[msg.sender] = 0;
        
        payable(msg.sender).transfer(reembolso);
        emit ReembolsoRealizado(msg.sender, reembolso);
    }
    
    function retirarComisiones() public onlyOwner checkDead {
        require(finalizada, "La subasta no ha finalizado oficialmente");
        
        uint256 monto = profit;
        require(profit > 0, "No hay comisiones acumuladas");
        profit = 0;
        
        payable(owner).transfer(monto);
    }
    
    function tiempoRestante() public view returns (uint256) {
        if (block.timestamp >= tiempo_limite) {
            return 0;
        }
        return tiempo_limite - block.timestamp;
    }
    
    function verBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function finalizarSubasta() public onlyOwner checkDead {
        require(block.timestamp >= tiempo_limite, "El tiempo no ha terminado");
        require(!finalizada, "Ya finalizo");
        finalizada = true;
        emit SubastaFinalizada(ganador, oferta_mas_alta);
    }
}
