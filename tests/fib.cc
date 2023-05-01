int fib(int n){
    int n1 = 0, n2 = 1;
    for(int i = 2; i < n; ++i) {
        int tmp = n1;
        n1 = n2;
        n2 = tmp + n1;
    }
    return n1;
}

int main() {
    int n = 9;
    int res = fib(n);
    asm("ecall");    
    return res;
}