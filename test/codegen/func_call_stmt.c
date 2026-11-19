/* Function definitions are tested together since one cannot test function calls
 * without function definitions. */

int five(/* no parameter */) {
  return 5;
}

int sum(int a, int b, int c) {
  return a + b + c;
}

int add_five(int d) {
  return d + five();
}

int unreachable_after_return1() {
  return 1;
  2;
  3;
}

int unreachable_after_return2() {
  return 2;
  return 1;
}

int main() {
  __builtin_print(add_five(sum(1, 2, 3) + 4));
  __builtin_print(unreachable_after_return1());
  __builtin_print(unreachable_after_return2());
  return 0;
}
