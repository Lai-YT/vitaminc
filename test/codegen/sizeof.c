int main() {
  /* sizeof expressions */
  int x = 1;
  __builtin_print(sizeof x);
  __builtin_print(sizeof &x);
  int a[3];
  __builtin_print(sizeof a);
  __builtin_print(sizeof(1 + 1));
  __builtin_print(sizeof sizeof a);

  /* sizeof types */
  __builtin_print(sizeof(int));
  __builtin_print(sizeof(int*));
  __builtin_print(sizeof(int[3]));
  return 0;
}
