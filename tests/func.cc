int func(int a){
    int b = 4;
    return a + b;
}

int main() {
    int a = 3;
    int c = func(a);
    asm("ecall");
    return a;
}