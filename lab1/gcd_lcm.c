#include <stdio.h>

int gcd(int a, int b) {
    // TODO
    // euclidean algorithm
    if(b > a){
        int temp = a;
        a = b;
        b = temp;
    }
    do{
        int temp_b = b;
        b = a % b;
        a = temp_b;

        // printf("a: %d, b: %d\n", a, b);
    } while(b != 0);

    return a;
}

int lcm(int a, int b) {
    // TODO
    int res = (a * b) / gcd(a, b);
    return res;
}

int main() {
    // DO NOT modify this section
    int n1, n2;
    printf("Please enter the first number: ");
    scanf("%d", &n1);
    printf("Please enter the second number: ");
    scanf("%d", &n2);

    printf("%d %d\n", gcd(n1, n2), lcm(n1, n2));

    return 0;
}
