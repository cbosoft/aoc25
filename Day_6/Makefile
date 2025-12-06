%.o: %.cbl
	cobc -c $^

day6p1: day6p1.cbl parse-input-row.o
	cobc -x $^

test: day6p1
	@cat test.txt | ./day6p1
	@#cat test.txt | ./day6p2

run: day6p1
	@cat input.txt | ./day6p1
	@#cat input.txt | ./day6p2
