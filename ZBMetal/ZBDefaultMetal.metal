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
    static float dist(float2 point, float2 center, float radius) {
        return length(point - center) - radius;
    }

};

kernel void compute(texture2d<float, access::write> output [[texture(0)]],
                    uint2 gid [[thread_position_in_grid]]) {
    int width = output.get_width();
    int height = output.get_height();
    float red = float(gid.x) / float(width);
    float green = float(gid.y) / float(height);

    float2 uv = float2(gid) / float2(width, height);
    uv = uv * 2.0 - 1.0;
    float distToCircle = Util::dist(uv, float2(-0.1, 0.1), 0.5);
    bool inside = distToCircle < 0;

    output.write(inside ? float(0) : float4(red, green, 0, 1) * (1 - distToCircle), gid);
}
