# DOCUMENTACION SUBASTA

# Componentes Clave

## Variables de Estado

```solidity
address payable public owner;       // Dueño del contrato
address payable public ganador;     // Dirección del mejor postor
uint256 public oferta_mas_alta;     // Valor de la mejor oferta
bool public finalizada;             // Estado de la subasta
```

## Estructuras de Datos

```solidity
mapping(address => uint256) public depositos_usuarios; // mapping de fondos por participante
address[] public participantes;     // Lista de todos los postores
```

## Flujo Principal

### Hacer una Oferta

```solidity
function ofertar() public payable
```

**1. Validaciones:**
- En la función ofertar se agregó un require, donde el owner no puede realizar ofertas, ya que esto podría utilizarse como forma de especulación, manipulando el precio del producto, inclusive la subasta podría ser utilizada solo como una forma de obtener la comisión del 2% de los oferentes.
- Oferta ≥ 5% mayor que oferta_mas_alta.
- Subasta activa (!finalizada y tiempo no vencido).

**2. Actualizaciones:**
- Registra el nuevo depósito.
- Si es una nueva dirección, la agrega a participantes.
- Si quedan <10 minutos, extiende el plazo (+10 min).

**3. Evento:**
```solidity
emit NuevaOferta(msg.sender, msg.value, block.timestamp);
```

### Retiro de Excedentes Durante la Subasta

```solidity
function retirarSaldoPrevio() public
```
Para el ganador actual: Retira solo el exceso sobre su última oferta válida.

### Finalización

La finalización de la subasta se genera de dos formas:
- **Automáticamente** cuando el tiempo_limite fue alcanzado y se interactúa con estas funciones:
  - `ofertar()`
  - `retirarDeposito()`
  - `retirarComisiones()`
- **Manualmente** mediante función `finalizarSubasta()` (solo si ya se cumplió la duración de la subasta)

En ese momento emite `SubastaFinalizada`.

```solidity
function finalizarSubasta() public onlyOwner
```
Marca `finalizada = true` y emite evento:
```solidity
emit SubastaFinalizada(ganador, oferta_mas_alta);
```

### Retiros Post-Subasta

```solidity
function retirarDeposito() public
```
- **Perdedores:** Reciben su depósito menos 2% de comisión.
- **Ganador:** No puede retirar (debe cumplirse su oferta).

### Retiro de Comisiones por el Owner

```solidity
function retirarComisiones() public onlyOwner
```
Transfiere al owner el 2% acumulado de las comisiones.

## Funciones de Consulta

```solidity
function obtenerGanador() public view → (address, uint256)
function obtenerOfertas() public view → (address[] memory, uint256[] memory)
function tiempoRestante() public view → uint256
```

## Eventos

Registros permanentes en la blockchain, en los logs de la tx que los emitió:

- **NuevaOferta:** Registra cada oferta.
- **SubastaFinalizada:** Indica el ganador y monto.
- **ReembolsoRealizado:** Auditabilidad de retiros.


