#import <simd/simd.h>
#include <stdint.h>

struct SnakeCellC {
    simd_float2 position;
    simd_float2 velocity;
    simd_float3 info;
    float density;
    char cell; // 0 field, 1 body, 2 head, 3 target
    char velocityAllow; // 0 disallow, 1 allow
};

struct SnakeCell3D {
    simd_float3 position;
    simd_float3 velocity;
    simd_float3 info;
    float density;
    char cell; // 0 field, 1 body, 2 head, 3 target
    uint32_t rem;
    char velocityAllow;
};

void printIntArrayContent(int* array, int size);
void initialArrayWay();

struct IOVertex {
    simd_float3 position;
    simd_float3 normal;
    simd_float2 textureCoordinate;
};

struct IOVertex2 {
    simd_float3 position;
    simd_float3 normal;
};

struct RazewareUniforms {
    simd_float4x4 modelMatrix;
    simd_float4x4 viewMatrix;
    simd_float4x4 projectionMatrix;
    simd_float3x3 normalMatrix;
};

struct FragmentUniforms {
    char lightCount;
    simd_float3 cameraPosition;
};

struct CoubeTransform {
    simd_float4x4 modelMatrix;
    simd_float3x3 normalMatrix;
};

struct SnakeFridgeUniforms {
    simd_float3x3 fridgeNormalMatrix;
    simd_float4x4 fridgeModelMatrix;
    simd_float4x4 cameraModelMatrix;
    simd_float4x4 cameraProjectionMatrix;
};

#define STENCIL 8
#define STENCIL3D (STENCIL * 3 + 2)
struct Stencil3x3 {
    simd_float3 offsets[STENCIL3D];
};

void makeStencil(void);
