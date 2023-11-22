::PATH=D:\Users\pablo\Documents\Estudio\2023-Leng-y-Compiladores\lenguajes_y_comp\assm;

tasm numbers.asm
tasm final.asm
tlink final.obj numbers.obj
final.exe
del final.obj 
del numbers.obj 
del final.exe
del final.map


