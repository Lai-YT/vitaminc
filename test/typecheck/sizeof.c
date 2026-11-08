int main() {
  /* sizeof expressions */
  int x = 1;
  sizeof x;
  sizeof &x;
  int a[3];
  sizeof a;
  sizeof(1 + 1);

  /* sizeof types */
  sizeof(int);
  sizeof(int*);
  sizeof(int[3]);
  return 0;
}
