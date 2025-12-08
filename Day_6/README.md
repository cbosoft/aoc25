# Day 6
Time to [`COBOL`](https://cmjb.tech/blog/2025/06/22/modern-cobol/) together a solution.

Bless [IBM](https://www.ibm.com/docs/en/cobol-zos/6.5.0) and [GNU](https://gnucobol.sourceforge.io/guides.html) for the docs but the good folks at [mainframestechhelp](https://www.mainframestechhelp.com/tutorials/cobol/) came in clutch.

Running requires [GNU Cobol](https://gnucobol.sourceforge.io/) and [make](https://www.gnu.org/software/make/#download).

```bash
make run
```

# Part 1
read in operands over 3-4 rows with postfix operators on final line (4th or 5th). Return sum of computed values.

# Part 2
Transpose the numbers, then apply the operation.

# Thoughts
There's a lot to love about `COBOL`s type system. It's all strings: strings of characters or strings of digits. This makes it super easy to build up base-10 numbers. However I miss scopes, I miss easy function declarations. I miss nice iteration. I miss zero-based indexing! (So many off-by-one errors...)
