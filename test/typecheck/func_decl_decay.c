int foo(int arr[2], int func(int, int));

int add(int a, int b) {
  return a + b;
}

int main() {
  int arr[4] = {1, 2, 3, 4};
  foo(arr, add);
  return 0;
}

int foo(int* arr, int (*func)(int, int)) {
  return func(func(func(arr[0], arr[1]), arr[2]), arr[3]);
}
