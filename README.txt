Para probar el contrato en Remix es conveniente tener una plantilla donde apuntar las direcciones.
Este es un ejemplo donde se pueden introducir direcciones de los roles indicados abajo para hacer pruebas:

----------------------------------------------------------------------------------------------------------

UNI: <dirección que lanza el contrato>

----------------------------------------------------------------------------------------------------------

CAR 1: <dirección carrera 1>

    STU 1: <dirección estdiante 1>

    STU 2:  <dirección estdiante 2>

----------------------------------------------------------------------------------------------------------

CAR 2: <dirección carrera 2>

    STU 3:  <dirección estdiante 3>

----------------------------------------------------------------------------------------------------------

CAR 3: <dirección carrera 3>

----------------------------------------------------------------------------------------------------------

Roles:

    - NONE = 0
    - STU = 1
    - CAR = 2
    - UNI = 3

----------------------------------------------------------------------------------------------------------

-  ¡IMPORTANTE!

Antes de revocar una carrera se debe estar seguro de que la misma no tiene ningún estudiante asociado (se debe revocar a todos los estudiantes de dicha carrera)

-

- Para asignar estudiantes debe existir al menos una universidad
- Los estudiantes siguen teniendo saldo a pesar de ser revocados. Este saldo lo podran volver a gastar si se les vuelve a asignar como estudiante de una carrera (no necesariamente la misma)
- Orden de ejecución recomendado:

    1- Lanzar con Tokens iniciales
    2- setCareer (al menos 1)
    3- setStudent (obligatorio si se quieren probar los métodos spend, reward y removeStu, al menos 1)
    4- uniTransfer (obligatorio con destinatario de rol STU si se quiere probar el método spend, obligatorio con destinatario de rol CAR si se quiere probar el método reward)
    5- spend y/o reward, según los saldos especificados anteriormente y según se desee transferir Tokens
    6- removeStu con graduated en true o en false, según se desee (al menos todos los estudiantes de una carrera antes del siguiente paso)
    7- removeCar

- Getters --> totalSupply (de ERC20) | balanceOf (de ERC20) | studentRef | careerOfStudent | careerRef | universityOfCareer | Owner
- setters --> setStudent | setCareer
- transfers --> uniTransfer | reward | spend
- removers --> removeStu | removeStu