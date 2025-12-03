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
	joltage := 0
	for {
		line, err := reader.ReadString('\n')
		if (err != nil) { break }


		line = line[:len(line)-1]
		i, tens := argmax(line[:len(line)-1])
		_, units := argmax(line[i+1:])
		joltage += tens * 10 + units
		
	}
	fmt.Printf("%d\n", joltage)
}
