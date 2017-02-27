//
//  ZBDefaultMetal.metal
//  ZBMetal
//
//  Created by DongSoo Lee on 2017. 2. 3..
//  Copyright © 2017년 zigbang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

class Util {
public:
    static float distToCircle(float2 point, float2 center, float radius) {
        return length(point - center) - radius;
    }

    static float smotherstep(float e1, float e2, float x) {
        x = clamp((x - e1) / (e2 - e1), 0.0, 1.0);

        return x * x * x * (x * (x * 6 - 15) + 10);
    }
};

kernel void compute(texture2d<float, access::write> output [[texture(0)]],
                    uint2 gid [[thread_position_in_grid]]) {
    int width = output.get_width();
    int height = output.get_height();

    float2 uv = float2(gid) / float2(width, height);

    float3 color = float3(0.7);
    if (fmod(uv.x, 0.1) < 0.005 || fmod(uv.y, 0.1) < 0.005) {
        color = float3(0, 0, 1);
    }
    float2 uv_ext = uv * 2.0 - 1.0;
    if (abs(uv_ext.x) < 0.02 || abs(uv_ext.y) < 0.02) {
        color = float3(1, 0, 0);
    }
    if (abs(uv_ext.x - uv_ext.y) < 0.02 || abs(uv_ext.x + uv_ext.y) < 0.02) {
        color = float3(0, 1, 0);
    }

    output.write(float4(color, 1), gid);
}
