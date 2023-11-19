PATH=D:\Users\pablo\Documents\Estudio\2023-Leng-y-Compiladores\lenguajes_y_comp\assm;

tasm number.asm
tasm final.asm
tlink final.obj number.obj
final.exe
del final.obj 
del number.obj 
del final.exe
del final.map


