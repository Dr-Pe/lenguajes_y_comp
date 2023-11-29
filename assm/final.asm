INCLUDE number.asm
INCLUDE macros.asm

.MODEL LARGE
.386
.STACK 200h

.DATA
id_mas_largo_id_mas_id_mas_largo_id_mas_ dd ?
float_max dd ?
f dd ?
entero_max dd ?
cad_min db ?
cad_max db ?
cad_concat3 db ?
cad_concat2 db ?
cad_concat1 db ?
cad_any db ?
c dd ?
b dd ?
a dd ?
_write_not db "write not" , '$', 9 dup (?)
_write_menor_o_igual db "write menor o igual" , '$', 19 dup (?)
_write_menor db "write menor" , '$', 11 dup (?)
_write_mayor_o_igual db "write mayor o igual" , '$', 19 dup (?)
_write_mayor db "write mayor" , '$', 11 dup (?)
_write_igual db "write igual" , '$', 11 dup (?)
_write_distinto db "write distinto" , '$', 14 dup (?)
_write_a___b___b___c db "write a < b & b < c" , '$', 19 dup (?)
_write_a___b____b___c db "write a < b || b < c" , '$', 20 dup (?)
_si_esta db "si esta" , '$', 7 dup (?)
_pe1 db "pe1" , '$', 3 dup (?)
_hola__mundo db "hola, mundo" , '$', 11 dup (?)
_ciclo_a_menor_a_b db "ciclo a menor a b" , '$', 17 dup (?)
_abc db "abc" , '$', 3 dup (?)
_a db "a" , '$', 1 dup (?)
_Cualquier_c__racter_________ db "Cualquier c?racter: @!#'??" , '$', 28 dup (?)
_3 dd 3.0
_2147483648_00 dd 2147483648.
_2 dd 2.0
_10 dd 10.0
_1 dd 1.0
_0123456789012345678901234567890123456789 db "0123456789012345678901234567890123456789" , '$', 40 dup (?)
_011 db "011" , '$', 3 dup (?)
_0 dd 0.0
_ db ?
@aux0 dd ?
@aux1 dd ?
@aux2 dd ?
@aux3 dd ?

.CODE

START:
mov AX, @DATA
mov DS, AX
mov ES, AX

FLD _2147483648_00
FSTP float_max
mov dx, OFFSET _
mov di, OFFSET cad_min
STRCPY
mov dx, OFFSET _0123456789012345678901234567890123456789
mov di, OFFSET cad_max
STRCPY
mov dx, OFFSET _Cualquier_c__racter_________
mov di, OFFSET cad_any
STRCPY
displayString _hola__mundo
newLine 1
mov dx, OFFSET "11"
mov di, OFFSET cad_concat3
STRCPY
FLD _1
FCOMP _1
FSTSW AX
SAHF
JNE falso0
displayString _si_esta
newLine 1
falso0:
FLD a
FCOMP b
FSTSW AX
SAHF
JNB falso1
displayString _write_menor
newLine 1
falso1:
FLD a
FCOMP b
FSTSW AX
SAHF
JBE falso2
displayString _write_mayor
newLine 1
falso2:
FLD a
FCOMP b
FSTSW AX
SAHF
JNBE falso3
displayString _write_menor_o_igual
newLine 1
falso3:
FLD a
FCOMP b
FSTSW AX
SAHF
JNAE falso4
displayString _write_mayor_o_igual
newLine 1
falso4:
FLD a
FCOMP b
FSTSW AX
SAHF
JNE falso5
displayString _write_igual
newLine 1
falso5:
FLD a
FCOMP b
FSTSW AX
SAHF
JE falso6
displayString _write_distinto
newLine 1
falso6:
FLD a
FCOMP b
FSTSW AX
SAHF
JNAE falso7
displayString _write_not
newLine 1
falso7:
FLD a
FCOMP b
FSTSW AX
SAHF
JNB falso8
FLD b
FCOMP c
FSTSW AX
SAHF
JNB falso8
displayString _write_a___b___b___c
newLine 1
falso8:
FLD a
FCOMP b
FSTSW AX
SAHF
JNAE verdadero0
FLD b
FCOMP c
FSTSW AX
SAHF
JNB falso9
verdadero0:
displayString _write_a___b____b___c
newLine 1
falso9:
FLD _1
FRNDINT
FSTP a
FLD _10
FRNDINT
FSTP b
displayString _ciclo_a_menor_a_b
newLine 1
ciclo0:
FLD a
FCOMP b
FSTSW AX
SAHF
JNB falso10
DisplayFloat a, 0
newLine 1
FLD a
FLD _1
FADD
FSTP @aux0
FLD @aux0
FRNDINT
FSTP a
JMP ciclo0
falso10:
ciclo1:
FLD a
FCOMP _1
FSTSW AX
SAHF
JBE falso11
FLD @aux0
FLD @aux1
FADD
FSTP @aux0
FLD a
FLD _1
FSUB
FSTP @aux0
FLD @aux0
FRNDINT
FSTP a
JMP ciclo1
falso11:
FLD @aux1
FRNDINT
FSTP f
FLD _2
FLD _3
FMUL
FSTP @aux0
ciclo2:
FLD a
FCOMP _1
FSTSW AX
SAHF
JBE falso12
FLD @aux0
FLD @aux1
FADD
FSTP @aux0
FLD a
FLD _1
FSUB
FSTP @aux0
FLD @aux0
FRNDINT
FSTP a
JMP ciclo2
falso12:
FLD @aux0
FLD @aux1
FADD
FSTP @aux1
FLD @aux1
FRNDINT
FSTP f
ciclo3:
FLD a
FCOMP _1
FSTSW AX
SAHF
JBE falso13
FLD @aux0
FLD @aux1
FADD
FSTP @aux0
FLD a
FLD _1
FSUB
FSTP @aux0
FLD @aux0
FRNDINT
FSTP a
JMP ciclo3
falso13:
FLD @aux1
FLD _3
FMUL
FSTP @aux0
FLD @aux0
FRNDINT
FSTP f

MOV AX, 4C00H
INT 21h
END START
