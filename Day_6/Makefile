%.o: %.cbl
	cobc -c $^

day6: day6.cbl parse-input-row.o
	cobc -x $^

test: day6
	@echo part1 | cat - test.txt | ./day6
	@#echo part2 | cat - test.txt | ./day6

run: day6
	@echo part1 | cat - input.txt | ./day6
	@#echo part2 | cat - input.txt | ./day6
