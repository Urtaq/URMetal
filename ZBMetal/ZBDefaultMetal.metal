//
//  ZBDefaultMetal.metal
//  ZBMetal
//
//  Created by DongSoo Lee on 2017. 2. 3..
//  Copyright © 2017년 zigbang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void compute(texture2d<float, access::write> output [[texture(0)]],
                    uint2 gid [[thread_position_in_grid]]) {
    int width = output.get_width();
    int height = output.get_height();
    float red = float(gid.x) / float(width);
    float green = float(gid.y) / float(height);

    output.write(float4(red, green, 0, 1), gid);
}
