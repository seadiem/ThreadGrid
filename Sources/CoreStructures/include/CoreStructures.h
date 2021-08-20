#import <simd/simd.h>
struct SnakeCellC {
    simd_float2 velocity;
    simd_float2 info;
    float density;
    char cell; // 0 field, 1 body, 2 head, 3 target
    char velocityAllow; // 0 disallow, 1 allow
};
void printIntArrayContent(int* array, int size);
void initialArrayWay();
