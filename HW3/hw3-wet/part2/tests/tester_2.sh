echo running[...]
as ../../part2/hw3_hook.asm -o ../hw3_hook.o
ld a_2.o ../../part2/a.o ../hw3_hook.o ../../part2/b.o -o ../hw3.out -T ../../part2/hw3.ld
../hw3.out > output/a_2_out.txt
ld b_2.o ../../part2/a.o ../hw3_hook.o ../../part2/b.o  -o ../hw3.out -T ../../part2/hw3.ld
../hw3.out > output/b_2_out.txt

diff -q expected.txt output/a_2_out.txt
diff -q expected.txt output/b_2_out.txt
echo done!
