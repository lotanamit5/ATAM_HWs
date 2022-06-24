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
    for (size_t i = 0; i < 10; i++)
    {
        printf("add returns %d\n", add(i, i+1));
    }
    
    // int sum = add(1, 2);
    // printf("sum: %d\n", sum);

    soVar = 5;
    addSoVar(3);
    // printf("soVar: %d\n", soVar);
    return 0;
}
