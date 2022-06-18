echo running symbol table tests...
../../../binutils-2.36.1/binutils/readelf -s e.o > output/e_symbolTable_out.txt
../../../binutils-2.36.1/binutils/readelf -s ../../part2/a.o > output/a_symbolTable_out.txt
../../../binutils-2.36.1/binutils/readelf -s ../../part2/b.o > output/b_symbolTable_out.txt
../../../binutils-2.36.1/binutils/readelf -s c.o > output/c_symbolTable_out.txt
../../../binutils-2.36.1/binutils/readelf -s d.o > output/d_symbolTable_out.txt
diff expected/a_symbolTable_expected.txt output/a_symbolTable_out.txt
diff expected/b_symbolTable_expected.txt output/b_symbolTable_out.txt
diff expected/e_symbolTable_expected.txt output/e_symbolTable_out.txt
diff expected/c_symbolTable_expected.txt output/c_symbolTable_out.txt
diff expected/d_symbolTable_expected.txt output/d_symbolTable_out.txt
echo running section table tests...
../../../binutils-2.36.1/binutils/readelf -S e.o > output/e_sectionTable_out.txt
../../../binutils-2.36.1/binutils/readelf -S prog > output/prog_sectionTable_out.txt
../../../binutils-2.36.1/binutils/readelf -S ../../part2/a.o > output/a_sectionTable_out.txt
../../../binutils-2.36.1/binutils/readelf -S ../../part2/b.o > output/b_sectionTable_out.txt
../../../binutils-2.36.1/binutils/readelf -S c.o > output/c_sectionTable_out.txt
../../../binutils-2.36.1/binutils/readelf -S d.o > output/d_sectionTable_out.txt
diff expected/a_sectionTable_expected.txt output/a_sectionTable_out.txt
diff expected/b_sectionTable_expected.txt output/b_sectionTable_out.txt
diff expected/e_sectionTable_expected.txt output/e_sectionTable_out.txt
diff expected/c_sectionTable_expected.txt output/c_sectionTable_out.txt
diff expected/d_sectionTable_expected.txt output/d_sectionTable_out.txt
diff expected/prog_sectionTable_expected.txt output/prog_sectionTable_out.txt
echo done!
