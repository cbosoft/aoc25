.SUFFIXES:

%.o: %.asm
	nasm -g -f elf32 -o $@ $<

%: %.o
	ld -m elf_i386 -o $@ $<

test: day4 test.txt
	@echo
	@echo "Part 1"
	@echo "1" | cat - test.txt | ./day4
	#@echo "2" | cat - test.txt | ./day4
	@echo

run: day4 input.txt
	@echo
	@echo "Part 1"
	@echo "1" | cat - input.txt | ./day4
	#@echo "2" | cat - input.txt | ./day4
	@echo
