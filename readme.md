En la funcion ofertar se agrego un require, donde el owner no puede realizar ofertas, ya que esto podria utilizarse como forma de especulacion, manipulando el precio del producto.
Inclusive la subasta podria ser utilizada solo como una forma de obtener la comision del 2% de los oferentes.

La finalizacion de la subasta se genera automaticamente cuando el tiempo_limite fue alcanzado y se interactua con estas funciones:
  ofertar()
  retirarDeposito()
  retirarComisiones()
En ese momento emite SubastaFinalizada.


