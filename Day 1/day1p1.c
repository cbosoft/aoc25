#include "unistd.h"
#include "stdio.h"

void spin(int *position, int *direction, int *steps, int *pw) {
  *position = ((*position) + (*direction)*(*steps)) % 100;
  *direction = 0;
  *steps = 0;
  if (*position == 0) {
    *pw += 1;
  }
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

  printf("%d\n", pw);

}
