int add(int a, int b);
void addSoVar(int num);
extern int soVar;
#include <stdio.h>

int count = 0;

int foo(int a, int b)
{
    return a + b;
}
int main()
{
    // foo(3, 4);

    int sum = add(1, 2);
    printf("sum: %d\n", sum);

    soVar = 5;
    addSoVar(3);
    printf("soVar: %d\n", soVar);
    return 0;
}
