int sum(int a, int b, int c) {
  return a + b + c;
}

int add_five(int d) {
  return d + 5;
}

int variadic(int a, int b, ...) {
  return a + b;
}

int main() {
  int a = sum(1, 2, 3);
  int b = variadic(a, 4, 5);
  return add_five(b);
}
