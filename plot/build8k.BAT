ca65.exe --cpu 6502 -t vic20 -l basic.lst basic.s
ca65.exe --cpu 6502 -t vic20 -l %1.lst %1.s
ld65.exe -C basic+8k.cfg -Ln %1.sym -m %1.map -o %1.prg %1.o basic.o
