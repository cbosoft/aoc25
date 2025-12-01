#include "unistd.h"
#include "stdio.h"
#include "stdlib.h"

void spin(int *position, int *direction, int *steps, int *pw) {
  int start = *position;
  if (*direction == 0) return;
  *position = *position + *direction * *steps;
  printf("pw: %d, start: %d, pos: %d, steps: %d, direction: %d\n", *pw, start, *position, *steps, *direction);
  if ((*position < 0) && (start == 0)) {
    *position += 100;
  }
  while (*position < 0) {
    *position += 100;
    *pw += 1;
    printf(" -> neg rollover\n");
  }
  while (*position >= 100) {
    *position -= 100;
    if (*position != 0) {
      *pw += 1;
      printf(" -> pos rollover\n");
    }
  }
  // *pw += *position / 100;
  *position = *position % 100;
  if (*position == 0) {
    *pw += 1;
    printf(" -> on zero\n");
  }

  *direction = 0;
  *steps = 0;
}

int main() {
  char ch = ' ';
  int direction = 0;

  int steps = 0;
  int position = 50;
  int pw = 0;

  while (read(STDIN_FILENO, &ch, 1) > 0) {
    switch (ch) {
      case 'R':
        direction = 1;
        break;
      case 'L':
        direction = -1;
        break;
      case '\n':
        spin(&position, &direction, &steps, &pw);
        break;
      default: /* 0-9 */
        steps = steps*10 + (int)ch - 48;
        break;
    }
  }
  spin(&position, &direction, &steps, &pw);

  printf("%d\n", pw);

}
