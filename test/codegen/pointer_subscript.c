int* global_ptr;

int main() {
  int values[2] = {7, 8};
  global_ptr = &values[0];

  __builtin_print(global_ptr[1]);
  global_ptr[1] = 9;
  __builtin_print(values[1]);

  int* local_ptr = &values[0];
  __builtin_print(local_ptr[0]);
  local_ptr[0] = 11;
  __builtin_print(values[0]);

  return 0;
}
