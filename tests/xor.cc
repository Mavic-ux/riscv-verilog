int main() {
  bool a = true;
  bool b = false;
  bool res = a != b;
  asm("ecall");
  return res;
}
