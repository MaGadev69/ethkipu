# Sintaxis en Solidity

# address(this) dirección del contrato actual
# ----------------------------------------------------------------
# require(finalizada, "La subasta no ha finalizado oficialmente");
Verifica que la subasta esté finalizada.
Si finalizada es falso, la función termina inmediatamente y muestra el mensaje "La subasta no ha finalizado oficialmente".
require, efectivamente tiene dos partes:
La condición a evaluar (comisiones > 0)
El mensaje a mostrar si la condición no se cumple ("No hay comisiones acumuladas")
# ----------------------------------------------------------------
mapping(address => uint256) public depositos_usuarios;
Diccionario o mapa:
Columna 1: la clave es una dirección (address), que representa a cada usuario.
Columna 2: el valor es un número (uint256), que representa el monto depositado por ese usuario.
Mapping solo asocia una clave con un valor
# ----------------------------------------------------------------
address[] public participantes;
array dinamico
Cada elemento es una dirección (address)
# ----------------------------------------------------------------
event NuevaOferta(address indexed oferente, uint256 monto, uint256 timestamp);
evento llamado NuevaOferta que registra información en la blockchain cada vez que se emite (usando emit). 
Los parámetros son: 
address indexed oferente: la dirección de quien hace la oferta (marcada como indexed, lo que facilita buscar eventos por ese campo).
uint256 monto: el monto ofertado.
uint256 timestamp: la marca de tiempo del evento.
Los eventos se usan para dejar un registro accesible y eficiente de acciones importantes dentro del contrato, 
como nuevas ofertas, depósitos, retiros, etc. Puedes ver esos eventos fuera del contrato usando herramientas como Etherscan o desde aplicaciones web conectadas a la blockchain.
# ----------------------------------------------------------------
Modificadores como checkDead actualizan estados, pero no rechazan transacciones a menos que incluyan un require.
# ----------------------------------------------------------------


## Visibilidad de Funciones
| Keyword    | Acceso permitido                          | Ejemplo                     |
|------------|------------------------------------------|-----------------------------|
| `public`   | Todos los usuarios                       | `function foo() public`     |
| `private`  | Solo el contrato actual                  | `function _bar() private`   |
| `external` | Solo desde fuera del contrato            | `function baz() external`   |
| `internal` | Contrato actual y heredados              | `function qux() internal`   |

## 💰 Funciones Pagables
- `payable`: Permite recibir ETH
```solidity
function deposit() public payable {
    // Puede recibir ETH con la transacción
}
