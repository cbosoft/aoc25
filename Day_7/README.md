# Day 6
`SQL` for me today.

Using [sqscript](https://github.com/cbosoft/sqscript) to run SQL script, pass input, and return results. A small bit of python doesn't count if it just passes the input in, right?

Using a run script to facilitate preprocessor for part 2 (and timing for debugging).
```bash
bash run.sh p1.sql input.txt
bash run.sh p2.sql input.txt

# check runtime
# time bash run.sh p1.sql input.txt
```

# Part 1
Run "tachyon beam" state machine, count splits.

# Part 2
Count all combinations of timelines in the tachyon beam.

# Thoughts on failure and SQL
I got stuck in an expensive recursive solution which would work, but consumes more RAM than I have in my laptop and is slower than frozen treacle. It would've been nice if the SQL I chose had more looping constructs... but really I wish I'd gone with a more efficient solution sooner.
