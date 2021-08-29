#include <simd/simd.h>
#include "CoreStructures.h"
#include <stdio.h>
#include <stdlib.h>

struct Offset {
    simd_float2 offset;
};

struct OffsetC {
    float x;
    float y;
};

struct Offset3 {
    simd_float3 offset;
};

struct OffsetC stencilOffsetsC[] = {
    {-1, 1},
    { 0, 1},
    { 1, 1},
    {-1, 0},
    { 1, 0},
    {-1,-1},
    { 0,-1},
    { 1,-1},
};

void make3DStencil(struct Offset *memory) {
}

void makeStencil() {
    struct Offset3 stencilOffsets[STENCIL];
    for (int i = 0; i < STENCIL - 1; i++) {
        struct OffsetC element = stencilOffsetsC[i];
        stencilOffsets[i].offset = simd_make_float3(element.x, element.y, 0);
    }
    struct Offset3 stencilOffsets3D[STENCIL3D];
    int index = 0;
    for (int i = 0; i < 8; i++, index++) {
        stencilOffsets3D[index].offset.xy = stencilOffsets[i].offset.xy;
        stencilOffsets3D[index].offset.z = -1;
    }
    for (int i = 0; i < 8; i++, index++) {
        stencilOffsets3D[index].offset.xy = stencilOffsets[i].offset.xy;
        stencilOffsets3D[index].offset.z = 0;
    }
    for (int i = 0; i < 8; i++, index++) {
        stencilOffsets3D[index].offset.xy = stencilOffsets[i].offset.xy;
        stencilOffsets3D[index].offset.z = 1;
    }
    void printIntArrayContentStencil(struct Offset3* array, int size);
    printIntArrayContentStencil(stencilOffsets3D, STENCIL3D);    
}

void printIntArrayContentStencil(struct Offset3* array, int size) {
    for (int index = 0; index <= size - 1; index += 1) {
        simd_float3 cell = array[index].offset;
        printf("index: %d, content: %.1f,%.1f,%.1f \n", index, cell.x, cell.y, cell.z);
    }
}
