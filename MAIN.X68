*-----------------------------------------------------------
* Title      : PRAFIN23
* Written by : Gaizka Medina Gordo
* Date       : 19/05/2023
* Description: Emulador de la HAL9000
*-----------------------------------------------------------
    ORG $1000
EMEM: DC.W $E082,$E09B,$E0B4,$E01D,$2020,$C006,$2031,$C017,$F160
      DC.W $F170,$CE70,$3040,$EFFD,$501E,$4008,$8000,$0001
      DC.W $0001,$0001,$0001,$0001,$0001,$0000,$0000,$0000
EIR:  DC.W 0 ;eregistro de instruccion
EPC:  DC.W 0 ;econtador de programa
ET0:  DC.W 0 ;eregistro T0
ET1:  DC.W 0 ;eregistro T1
EX2:  DC.W 0 ;eregistro X2
EX3:  DC.W 0 ;eregistro X3
EX4:  DC.W 0 ;eregistro X4
EX5:  DC.W 0 ;eregistro X5
EX6:  DC.W 0 ;eregistro X6
EX7:  DC.W 0 ;eregistro X7
ESR:  DC.W 0 ;eregistro de estado (00000000 00000CNZ)    


START:
    CLR.W EPC

FETCH:
    ;--- IFETCH: INICIO FETCH
        ;*** En esta seccion debeis introducir el codigo necesario para cargar
        ;*** en el EIR la siguiente instruccion a ejecutar, indicada por el EPC,
	    ;*** y dejar listo el EPC para que apunte a la siguiente instruccion
	
	; ESCRIBID VUESTRO CODIGO AQUI
    MOVE.W (EPC),D0         
    LEA.L EMEM, A0          
    LSL.L #1,D0             ;x2 en el valor de D0
    MOVE.W (A0,D0),D1       ;Muevo el contenido de la posicion D0 de EMEM a D1
    MOVE.W D1,EIR           
    LSR.L #1,D0             ;x1/2 en el valor de D0
    ADDQ.W #1,D0            ;Actualizo EPC
    MOVE.W D0,(EPC)         ;Devuelvo el EPC actualizado        
    ;--- FFETCH: FIN FETCH
    
    
    
    ;--- IBRDECOD: INICIO SALTO A DECOD
        ;*** En esta seccion debeis preparar la pila para llamar a la subrutina
        ;*** DECOD, llamar a la subrutina, y vaciar la pila correctamente,
        ;*** almacenando el resultado de la decodificacion en D1

    ; ESCRIBID VUESTRO CODIGO AQUI                              	    
    MOVE.W #0,-(SP)          ;Espacio en la pila
    MOVE.W D1,-(SP)          ;EIR(D1) a 8(SP)  
    JSR DECOD                ;Salto a DECOD
    MOVE.W 2(SP),D1          ;Guardamos el codigo de la instr. en D1
    ADDQ.L #4,SP             ;Vaciamos la pila    
    ;--- FBRDECOD: FIN SALTO A DECOD
    
    
    
    ;--- IBREXEC: INICIO SALTO A FASE DE EJECUCION
        ;*** Esta seccion se usa para saltar a la fase de ejecucion
        ;*** NO HACE FALTA MODIFICARLA
    MULU #6,D1
    MOVEA.L D1,A1
    JMP JMPLIST(A1)
JMPLIST:
    JMP ELOA
    JMP ESTO
    JMP ELOIP
    JMP ESTIP
    JMP EGOI
    JMP EGOZ
    JMP EGON
    JMP EEXIT
    JMP ECOPY
    JMP EADD
    JMP ESUB
    JMP EAND
    JMP ESET
    JMP EADQ
    JMP ELSH
    ;--- FBREXEC: FIN SALTO A FASE DE EJECUCION
    
    
    
    ;--- IEXEC: INICIO EJECUCION
        ;*** En esta seccion debeis implementar la ejecucion de cada einstr.
	
	; ESCRIBID EN CADA ETIQUETA LA FASE DE EJECUCION DE CADA INSTRUCCION
	
ELOA:
    JSR VALOR_M_OUT          ;M en D4 (8 bits menos significativos)
    LSL.L #1,D4              ;x2 en el valor de M
    MOVE.L D4,A1            
    MOVE.W EMEM(A1),D1       ;MOVE de la dirección de M en EMEM a Ti
    
    JSR EXTRAER_I            ;Metemos D1 en el contenido de Ti
    JSR ACTU_FLAG_Z         
    JSR ACTU_FLAG_N
    JMP FETCH
    
ESTO:
    JSR VALOR_M_OUT
    LSL.L #1,D4              ;x2 en el valor de M
    MOVE.W D4,A1
    
    JSR INSERTAR_I           ;T0/T1 en D1
    MOVE.W D1,EMEM(A1)       ;MOVE de Ti a la dirección de M en EMEM
    JMP FETCH
    
ELOIP:                      
    JSR INSERTAR_B           ;B en D5  
    MOVE.W D5,D2             ;Salvaguardamos valor de B 
    
    LSL.L #1,D5              ;x2 en el valor de Xb
    ADD.W #$1000,D5
    MOVE.W D5,A1
    MOVE.W (A1),D1           ;MOVE del contenido de A1 a D1
 
    JSR EXTRAER_I            ;D1 a T0/T1
    JSR ACTU_FLAG_Z          
    JSR ACTU_FLAG_N
                             ;Post-Incremento       
    ADD.L #1,D2             
    MOVE.W D2,D1             ;[B]+1 en D1
    JSR EXTRAER_B            ;D1 a Xb
    JMP FETCH
    
ESTIP:                      
    JSR INSERTAR_B           ;B en D5
    MOVE.W D5,D2             ;Salvaguardamos valor de B
    JSR INSERTAR_I           ;T0/T1 en D1
    
    LSL.L #1,D5              ;x2 en el valor de Xb
    ADD.W #$1000,D5
    MOVE.W D5,A1
    MOVE.W D1,(A1)           ;MOVE del contenido de T0/T1 al contenido de Xb
                             ;Post-Incremento
    ADD.L #1,D2             
    MOVE.W D2,D1             ;[B]+1 en D1
    JSR EXTRAER_B            ;D1 a Xb
    JMP FETCH
    
EGOI:
    JSR VALOR_M_OUT          ;M en D4
    MOVE.W D4,(EPC)
    JMP FETCH
    
EGOZ:
    MOVE.W (ESR),D7          
    BTST.L #0,D7             ;COMPROBAR FLAG Z
    BEQ ETZES0
    JSR VALOR_M_OUT          ;M en D4
    MOVE.W D4,(EPC)
ETZES0:
    JMP FETCH
    
EGON:
    MOVE.W (ESR),D7           
    BTST.L #1,D7             ;COMPROBAR FLAG N
    BEQ ETFLAGNES0
    JSR VALOR_M_OUT          ;M en D4
    MOVE.W D4,(EPC)
ETFLAGNES0:
    JMP FETCH    
    
EEXIT:
    SIMHALT
    
ECOPY:
    JSR INSERTAR_B           ;B en D5
    
    MOVE.W D5,D1             ;COPY B a D1
    MOVE.W SR,D0             ;Guardo flags
    JSR ACTU_FLAG_Z
    JSR ACTU_FLAG_N
   
    JSR EXTRAER_C            ;D1 a Rc
    JMP FETCH
    
EADD:
    JSR INSERTAR_A           ;A en D4
    JSR INSERTAR_B           ;B en D5
    
    ADD.W D4,D5              ;ADD Rb,Rc
    MOVE.W SR,D0             ;Guardo flags
    JSR ACTU_FLAG_C
    JSR ACTU_FLAG_Z
    JSR ACTU_FLAG_N
    
    MOVE.W D5,D1             ;Preparo subrutina
    JSR EXTRAER_C            ;D1 a Rc
    JMP FETCH
    
ESUB:
    JSR INSERTAR_A           ;A en D4
    JSR INSERTAR_B           ;B en D5
    
    NOT D4                   ;A'
    ADD.W #1,D4              ;(A'+1)
    ADD.W D4,D5              ;B+(A'+1)=B-A
    
    MOVE.W SR,D0             ;Guardo flags
    JSR ACTU_FLAG_C
    JSR ACTU_FLAG_Z
    JSR ACTU_FLAG_N
    
    MOVE.W D5,D1             ;Preparo subrutina
    JSR EXTRAER_C            ;D1 a Rc
    JMP FETCH
    

EAND:
    JSR INSERTAR_A           ;A en D4
    JSR INSERTAR_B           ;B en D5
    
    AND.W D4,D5              ;AND Rb,Rc
    MOVE.W SR,D0             ;Guardo flags
    JSR ACTU_FLAG_Z
    JSR ACTU_FLAG_N
    
    MOVE.W D5,D1             ;Preparo subrutina
    JSR EXTRAER_C            ;D1 a Rc
    JMP FETCH
    
ESET:
    JSR VALOR_K_OUT          ;K en D4 (ya extendido)

    MOVE.W D4,D1
    MOVE.W SR,D0             ;Guardo flags
    JSR ACTU_FLAG_Z
    JSR ACTU_FLAG_N

    JSR EXTRAER_C            ;D1 a Rc
    JMP FETCH
    
EADQ:
    JSR INSERTAR_C           ;C en D6
    JSR VALOR_K_OUT          ;K en D4 (ya extendido)

    ADD.W D4,D6
    MOVE.W SR,D0             ;Guardo flags
    JSR ACTU_FLAG_C
    JSR ACTU_FLAG_Z
    JSR ACTU_FLAG_N
    
    MOVE.W D6,D1             ;Preparo subrutina
    JSR EXTRAER_C            ;D1 a Rc
    JMP FETCH    
    
ELSH:
    MOVE.W (EIR),D2
    JSR INSERTAR_B           ;B en D5
    JSR VALOR_P_OUT          ;P en D4 (8 bits -significativos)
    BTST.L #0,D2
    BEQ ETNES0
    BNE ETNES1
ETNES0:
    LSL.L D4,D5              ;LSL de B p posiciones
    MOVE.W SR,D0             ;Guardo flags
    JMP ETFINELSH
ETNES1:
    LSR.L D4,D5              ;LSR de B p posiciones
    MOVE.W SR,D0             ;Guardo flags
    JMP ETFINELSH
ETFINELSH:                   ;Actualización flags y retorno a Fetch
    JSR ACTU_FLAG_C
    JSR ACTU_FLAG_N
    JSR ACTU_FLAG_Z
    
    MOVE.W D5,D1             ;Preparo subrutina
    JSR EXTRAER_B            ;D1 a Rb
    JMP FETCH   
    
    ;--- FEXEC: FIN EJECUCION
    
    

    ;--- ISUBR: INICIO SUBRUTINAS
        ;*** Aqui debeis incluir las subrutinas que necesite vuestra solucion
        ;*** SALVO DECOD, que va en la siguiente seccion

    ; ESCRIBID VUESTRO CODIGO AQUI
    
INSERTAR_I:                  ;INSERTAMOS VALOR DE i EN D1
    MOVE.W (EIR),D4          
    BTST.L #0,D4             ;Miramos el bit de i       
    BEQ ETI0OUT
    BNE ETI1OUT 
ETI0OUT:
    MOVE.W (ET0),D1          ;i=0,Ti=ET0
    MOVE.W SR,D0
    RTS
ETI1OUT:
    MOVE.W (ET1),D1          ;i=1,Ti=ET1
    MOVE.W SR,D0
    RTS
     
EXTRAER_I:                   ;EXTRAEMOS VALOR DE D1 A Ti
    MOVE.W (EIR),D4         
    BTST.L #0,D4             ;Miramos el bit de i       
    BEQ ETI0IN
    BNE ETI1IN 
ETI0IN:
    MOVE.W D1,(ET0)          ;i=0,Ti=ET0
    MOVE.W SR,D0
    RTS
ETI1IN:
    MOVE.W D1,(ET1)          ;i=1,Ti=ET1
    MOVE.W SR,D0
    RTS
    
VALOR_M_OUT:                 ;VALOR M (8 bits) A D4
    MOVE.W (EIR),D4         
    AND #$01FE,D4            ;Máscara
    LSR.L #1,D4              ;8 bits - significativos
    RTS

VALOR_K_OUT:                 ;VALOR K (8 bits) A D4
    MOVE.W (EIR),D4
    AND #$07F8,D4
    LSR.L #3,D4              ;8 bits - significativos
    EXT.W D4                 ;Ext. de signo
    RTS
    
VALOR_P_OUT:                 ;VALOR P (3 bits) A D4
    MOVE.W (EIR),D4         
    AND #$0700,D4            ;Extraemos los bits de P
    LSR.L #8,D4              ;3 bits - significativos
    RTS
    
INSERTAR_A:                  ;INSERTAMOS CONTENIDO DE Xa en D4
    MOVE.W (EIR),D4
    AND #$0700,D4            ;Máscara
    LSR.L #8,D4              ;3 bits - significativos
    BTST #2,D4               ;DECOD de Ra
    BEQ ETA0
    BNE ETA1
ETA0:
    BTST #1,D4
    BEQ ETA00
    BNE ETA01
ETA1:
    BTST #1,D4
    BEQ ETA10
    BNE ETA11
ETA00:
    BTST #0,D4
    BEQ ETA000
    BNE ETA001
ETA01:
    BTST #0,D4
    BEQ ETA010
    BNE ETA011
ETA10:
    BTST #0,D4
    BEQ ETA100
    BNE ETA101
ETA11:
    BTST #0,D4
    BEQ ETA110
    BNE ETA111
ETA000:
    MOVE.W (ET0),D4
    RTS
ETA001:
    MOVE.W (ET1),D4
    RTS
ETA010:
    MOVE.W (EX2),D4
    RTS
ETA011:
    MOVE.W (EX3),D4
    RTS
ETA100:
    MOVE.W (EX4),D4
    RTS
ETA101:
    MOVE.W (EX5),D4
    RTS
ETA110:
    MOVE.W (EX6),D4
    RTS
ETA111:
    MOVE.W (EX7),D4
    RTS

INSERTAR_B:                  ;INSERTAMOS CONTENIDO DE Xb/Rb en D5
    MOVE.W (EIR),D5
    AND #$0070,D5            ;Máscara
    LSR.L #4,D5              ;3 bits - significativos
    BTST #2,D5               ;DECOD de Rb
    BEQ ETBIN0
    BNE ETBIN1
ETBIN0:
    BTST #1,D5
    BEQ ETBIN00
    BNE ETBIN01
ETBIN1:
    BTST #1,D5
    BEQ ETBIN10
    BNE ETBIN11
ETBIN00:
    BTST #0,D5
    BEQ ETBIN000
    BNE ETBIN001
ETBIN01:
    BTST #0,D5
    BEQ ETBIN010
    BNE ETBIN011
ETBIN10:
    BTST #0,D5
    BEQ ETBIN100
    BNE ETBIN101
ETBIN11:
    BTST #0,D5
    BEQ ETBIN110
    BNE ETBIN111
ETBIN000:
    MOVE.W (ET0),D5
    RTS
ETBIN001:
    MOVE.W (ET1),D5
    RTS
ETBIN010:
    MOVE.W (EX2),D5
    RTS
ETBIN011:
    MOVE.W (EX3),D5
    RTS
ETBIN100:
    MOVE.W (EX4),D5
    RTS
ETBIN101:
    MOVE.W (EX5),D5
    RTS
ETBIN110:
    MOVE.W (EX6),D5
    RTS
ETBIN111:
    MOVE.W (EX7),D5
    RTS
    
EXTRAER_B:                   ;EXTRAEMOS EL CONTENIDO DE D1 EN Xb/Rb
    MOVE.W (EIR),D5
    AND #$0070,D5            ;Máscara
    LSR.L #4,D5              ;3 bits - significativos
    BTST #2,D5               ;DECOD de Rb
    BEQ ETBOUT0
    BNE ETBOUT1
ETBOUT0:
    BTST #1,D5
    BEQ ETBOUT00
    BNE ETBOUT01
ETBOUT1:
    BTST #1,D5
    BEQ ETBOUT10
    BNE ETBOUT11
ETBOUT00:
    BTST #0,D5
    BEQ ETBOUT000
    BNE ETBOUT001
ETBOUT01:
    BTST #0,D5
    BEQ ETBOUT010
    BNE ETBOUT011
ETBOUT10:
    BTST #0,D5
    BEQ ETBOUT100
    BNE ETBOUT101
ETBOUT11:
    BTST #0,D5
    BEQ ETBOUT110
    BNE ETBOUT111
ETBOUT000:
    MOVE.W D1,(ET0)
    RTS
ETBOUT001:
    MOVE.W D1,(ET1)
    RTS
ETBOUT010:
    MOVE.W D1,(EX2)
    RTS
ETBOUT011:
    MOVE.W D1,(EX3)
    RTS
ETBOUT100:
    MOVE.W D1,(EX4)
    RTS
ETBOUT101:
    MOVE.W D1,(EX5)
    RTS
ETBOUT110:
    MOVE.W D1,(EX6)
    RTS
ETBOUT111:
    MOVE.W D1,(EX7)
    RTS
    
INSERTAR_C:                  ;INSERTAMOS EL CONTENIDO DE Rc en D6
    MOVE.W (EIR),D6             
    AND #$0007,D6            ;Máscara
    BTST #2,D6               ;DECOD de Rc
    BEQ ETCIN0
    BNE ETCIN1
ETCIN0:
    BTST #1,D6
    BEQ ETCIN00
    BNE ETCIN01
ETCIN1:
    BTST #1,D6
    BEQ ETCIN10
    BNE ETCIN11
ETCIN00:
    BTST #0,D6
    BEQ ETCIN000
    BNE ETCIN001
ETCIN01:
    BTST #0,D6
    BEQ ETCIN010
    BNE ETCIN011
ETCIN10:
    BTST #0,D6
    BEQ ETCIN100
    BNE ETCIN101
ETCIN11:
    BTST #0,D6
    BEQ ETCIN110
    BNE ETCIN111
ETCIN000:
    MOVE.W (ET0),D6
    RTS
ETCIN001:
    MOVE.W (ET1),D6
    RTS
ETCIN010:
    MOVE.W (EX2),D6
    RTS
ETCIN011:
    MOVE.W (EX3),D6
    RTS
ETCIN100:
    MOVE.W (EX4),D6
    RTS
ETCIN101:
    MOVE.W (EX5),D6
    RTS
ETCIN110:
    MOVE.W (EX6),D6
    RTS
ETCIN111:
    MOVE.W (EX7),D6
    RTS

EXTRAER_C:                   ;EXTRAEMOS EL CONTENIDO DE D1 A Rc
    MOVE.W (EIR),D6
    AND #$0007,D6            ;Máscara
    BTST #2,D6               ;DECOD de Rc
    BEQ ETCOUT0
    BNE ETCOUT1
ETCOUT0:
    BTST #1,D6
    BEQ ETCOUT00
    BNE ETCOUT01
ETCOUT1:
    BTST #1,D6
    BEQ ETCOUT10
    BNE ETCOUT11
ETCOUT00:
    BTST #0,D6
    BEQ ETCOUT000
    BNE ETCOUT001
ETCOUT01:
    BTST #0,D6
    BEQ ETCOUT010
    BNE ETCOUT011
ETCOUT10:
    BTST #0,D6
    BEQ ETCOUT100
    BNE ETCOUT101
ETCOUT11:
    BTST #0,D6
    BEQ ETCOUT110
    BNE ETCOUT111
ETCOUT000:
    MOVE.W D1,(ET0)
    RTS
ETCOUT001:
    MOVE.W D1,(ET1)
    RTS
ETCOUT010:
    MOVE.W D1,(EX2)
    RTS
ETCOUT011:
    MOVE.W D1,(EX3)
    RTS
ETCOUT100:
    MOVE.W D1,(EX4)
    RTS
ETCOUT101:
    MOVE.W D1,(EX5)
    RTS
ETCOUT110:
    MOVE.W D1,(EX6)
    RTS
ETCOUT111:
    MOVE.W D1,(EX7)
    RTS
    
ACTU_FLAG_Z:                 ;ACTUALIZA FLAG Z DE ESR 
    MOVE.W (ESR),D7
    BTST.L #2,D0             ;Compruebo bit Z de la última operación guardada
    BEQ ETFLAGZ0
    BNE ETFLAGZ1
ETFLAGZ0:
    BCLR.L #0,D7             ;Bit Z a 0
    MOVE.W D7,(ESR)
    RTS
ETFLAGZ1:
    BSET.L #0,D7             ;Bit Z a 1
    MOVE.W D7,(ESR)    
    RTS
    
ACTU_FLAG_N:                 ;ACTUALIZA FLAG N DE ESR
    MOVE.W (ESR),D7
    BTST.L #3,D0             ;Compruebo bit N de la última operación guardada
    BEQ ETFLAGN0
    BNE ETFLAGN1
ETFLAGN0:
    BCLR.L #1,D7             ;Bit N a 0
    MOVE.W D7,(ESR)
    RTS
ETFLAGN1:
    BSET.L #1,D7             ;Bit N a 1
    MOVE.W D7,(ESR)    
    RTS
    
ACTU_FLAG_C:                 ;ACTUALIZA FLAG C DE ESR
    MOVE.W (ESR),D7
    BTST.L #0,D0             ;Compruebo bit C de la última operación guardada
    BEQ ETFLAGC0
    BNE ETFLAGC1
ETFLAGC0:
    BCLR.L #2,D7             ;Bit C a 0
    MOVE.W D7,(ESR)
    RTS
ETFLAGC1:
    BSET.L #2,D7             ;Bit C a 1
    MOVE.W D7,(ESR)    
    RTS      
    ;--- FSUBR: FIN SUBRUTINAS
    
    

    ;--- IDECOD: INICIO DECOD
        ;*** Tras la etiqueta DECOD, debeis implementar la subrutina de 
        ;*** decodificacion, que debera ser de libreria, siguiendo la interfaz
        ;*** especificada en el enunciado
DECOD:
	        ; ESCRIBID VUESTRO CODIGO AQUI
	        
	MOVE.L D0,-(SP)          ;Salvaguardamos D0
	MOVE.W 8(SP),D0          ;EIR a D0
	
    BTST.L #15,D0
    BEQ ET_0
    BNE ET_1
ET_0:
    BTST.L #14,D0
    BEQ ET00
    BNE ET01
ET_1:
    BTST.L #14,D0
    BEQ ET10
    BNE ET11
ET00:
    BTST.L #13,D0
    BEQ ET000
    BNE ET001
ET01:
    BTST.L #13,D0
    BEQ ET010
    BNE ET011
ET10:
    MOVE.W #7,10(SP)         ;EINSTRUCCIÓN EEXIT
    MOVE.L (SP)+,D0
    RTS
ET11:
    BTST.L #13,D0
    BEQ ET110
    BNE ET111
ET000:
    BTST.L #12,D0
    BEQ ET0000 
    BNE ET0001 
ET001:
    BTST.L #12,D0
    BEQ ET0010 
    BNE ET0011 
ET010:
    BTST.L #12,D0
    BEQ ET0100 
    BNE ET0101 
ET011:
    BTST.L #12,D0
    BEQ ET0110 
ET110:
    BTST.L #12,D0
    BEQ ET1100 
    BNE ET1101   
ET111:
    BTST.L #12,D0
    BEQ ET1110 
    BNE ET1111 
ET0000:
    MOVE.W #0,10(SP)         ;EINSTRUCCIÓN ELOA
    MOVE.L (SP)+,D0
    RTS
ET0001:
    MOVE.W #1,10(SP)         ;EINSTRUCCIÓN ESTO
    MOVE.L (SP)+,D0
    RTS
ET0010:
    MOVE.W #2,10(SP)         ;EINSTRUCCIÓN ELOIP
    MOVE.L (SP)+,D0
    RTS
ET0011:
    MOVE.W #3,10(SP)         ;EINSTRUCCIÓN ESTIP
    MOVE.L (SP)+,D0
    RTS
ET0100:
    MOVE.W #4,10(SP)         ;EINSTRUCCIÓN EGOI
    MOVE.L (SP)+,D0
    RTS
ET0101:
    MOVE.W #5,10(SP)         ;EINSTRUCCIÓN EGOZ
    MOVE.L (SP)+,D0
    RTS
ET0110:
    MOVE.W #6,10(SP)         ;EINSTRUCCIÓN EGON
    MOVE.L (SP)+,D0
    RTS
ET1100:
    BTST.L #11,D0
    BEQ ET11000 
    BNE ET11001  
ET1101:
    BTST.L #11,D0
    BEQ ET11010 
    BNE ET11011  
ET1110:
    BTST.L #11,D0
    BEQ ET11100 
    BNE ET11101  
ET1111:
    BTST.L #11,D0
    BEQ ET11110 
ET11000: 
    MOVE.W #8,10(SP)         ;EINSTRUCCIÓN ECOPY
    MOVE.L (SP)+,D0
    RTS
ET11001:
    MOVE.W #9,10(SP)         ;EINSTRUCCIÓN EADD
    MOVE.L (SP)+,D0
    RTS
ET11010:    
    MOVE.W #10,10(SP)        ;EINSTRUCCIÓN ESUB
    MOVE.L (SP)+,D0
    RTS
ET11011:   
    MOVE.W #11,10(SP)        ;EINSTRUCCIÓN EAND
    MOVE.L (SP)+,D0
    RTS
ET11100:  
    MOVE.W #12,10(SP)        ;EINSTRUCCIÓN ESET
    MOVE.L (SP)+,D0
    RTS
ET11101:    
    MOVE.W #13,10(SP)        ;EINSTRUCCIÓN EADQ
    MOVE.L (SP)+,D0
    RTS
ET11110:   
    MOVE.W #14,10(SP)        ;EINSTRUCCIÓN ELSH
    MOVE.L (SP)+,D0
    RTS

    ;--- FDECOD: FIN DECOD
    END    START


*~Font name~Courier New~
*~Font size~11~
*~Tab type~1~
*~Tab size~4~
