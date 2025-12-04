const readline = require('readline');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
  terminal: false
});

var mode = undefined;
const input = [];

rl.on('line', (line) => {
  if (mode === undefined) {
    mode = line;
  }
  else {
    input.push(line);
  }
});

rl.once('close', () => {
  switch (mode) {
    case "part1":
      part1(input);
      break;
    case "part2":
      part2(input);
      break;
  }
});


function part1(input) {
  const r = input.length;
  const c = input[0].length;
  var accessible = 0;

  for (var i = 0; i < r; i++) {
    for (var j = 0; j < c; j++) {
      if (input[i][j] !== "@") continue;
      var this_count = 0;
      for (const di of [-1, 0, 1]) {
        const ii = i + di;
        if ((ii < 0) || (ii >= r)) continue;
        for (const dj of [-1, 0, 1]) {
          const jj = j + dj;
          if ((jj < 0) || (jj >= c)) continue;
          if ((ii === i) && (jj === j)) continue;
          if (input[ii][jj] === "@") this_count += 1;
        }
      }

      console.log(`${i},${j}: ${this_count}`);

      if (this_count < 4) accessible += 1;
    }
  }

  console.log(`Part 1: ${accessible}`)
}

function part2(input) {
}
