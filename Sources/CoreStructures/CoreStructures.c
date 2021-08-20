#include "CoreStructures.h"
#include <stdio.h>
#include <stdlib.h>

void printIntArrayContent(int* array, int size) {
    for (int index = 0; index <= size - 1; index += 1) {
        printf("index: %d, content: %d \n", index, array[index]);
    }
}


void initialArrayWay() {
    int array[] = {1, 3, 8, 10, 12, 5};
    void printIntArrayContent(int* array, int size);
    void printCharArrayContent(char* array, int size);
    printIntArrayContent(array, 6);
    
    int *pa = &array[0];
    putchar('\n');
    
    printIntArrayContent(pa, 6);
    
    printf("pa[2]: %d \n", pa[2]);
    
    int *pointer = array;
    
    putchar('\n');
    
    printIntArrayContent(pointer, 6);
}
