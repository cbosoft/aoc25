package main

import (
	"bufio"
	"fmt"
	"os"
)

// string guaranteed to be non-empty
func argmax(s string) (mxi, mxv int) {
	mxi, mxv = 0, int(s[0]);
	for i := 1; i < len(s); i++ {
		v := int(s[i])
		if v > mxv {
			mxi = i
			mxv = v
		}
	}
	mxv -= 48
	return
}

func main() {
	reader := bufio.NewReader(os.Stdin)
	line, _ := reader.ReadString('\n')

	var num_batteries, partno int
	switch line {
	case "part1\n":
		num_batteries = 2
		partno = 1
	case "part2\n":
		num_batteries = 12
		partno = 2
	default:
		panic("unexpected mode string!")
	}

	joltage := 0
	for {
		line, err := reader.ReadString('\n')
		if (err != nil) { break }

		// remove trailing newline
		line = line[:len(line)-1]
		n := len(line)
		i, j := 0, 0
		for k := range num_batteries {
			lb := i
			ub := n - num_batteries + k + 1
			di, v := argmax(line[lb:ub])
			j *= 10
			j += v
			i = lb + di + 1
		}
		joltage += j
		
	}
	fmt.Printf("part%d: %d\n", partno, joltage)
}
