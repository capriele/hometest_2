#include <stdio.h>
#include <unistd.h>

int main(int argc, char** argv) {
  printf("hello world\r\n");
  while (1) sleep(10);
  return 0;
}