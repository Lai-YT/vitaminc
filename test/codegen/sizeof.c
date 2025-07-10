int main() {
  int x = 1;
  __builtin_print(sizeof x);
  __builtin_print(sizeof &x);
  int a[3];
  __builtin_print(sizeof a);
  __builtin_print(sizeof(1 + 1));
  return 0;
}
