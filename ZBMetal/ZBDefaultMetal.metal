//
//  ZBDefaultMetal.metal
//  ZBMetal
//
//  Created by DongSoo Lee on 2017. 2. 3..
//  Copyright © 2017년 zigbang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Uniforms {
    float4x4 modelMatrix;
};

struct Vertex {
    float4 position [[position]];
    float4 color;
};

vertex Vertex vertex_func(constant Vertex *vertices [[buffer(0)]],
                          constant Uniforms &uniforms [[buffer(1)]],
                          uint vid [[vertex_id]]) {
    float4x4 matrix = uniforms.modelMatrix;
    Vertex in = vertices[vid];
    Vertex out;
    out.position = matrix * float4(in.position);
    out.color = in.color;
    return out;
}

fragment half4 fragment_func(Vertex vert [[stage_in]]) {
    return half4(0.0, 1.0, 0.0, 1.0);
}
