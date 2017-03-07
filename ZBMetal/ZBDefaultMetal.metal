//
//  ZBDefaultMetal.metal
//  ZBMetal
//
//  Created by DongSoo Lee on 2017. 2. 3..
//  Copyright © 2017년 zigbang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Ray {
    float3 origin;
    float3 direction;
    Ray(float3 o, float3 d) {
        origin = o;
        direction = d;
    }
};

struct Sphere {
    float3 center;
    float radius;
    Sphere(float3 c, float r) {
        center = c;
        radius = r;
    }
};

class Util {
public:
    static float distToSphere(Ray ray, Sphere s) {
        return length(ray.origin - s.center) - s.radius;
    }

    static float dist(float2 point, float2 center, float radius) {
        return length(point - center) - radius;
    }

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

    float distToCircle = Util::dist(uv, float2(0.), 0.5);
    bool inside = distToCircle < 0.;

    output.write(inside ? float4(1.) : float4(0.), gid);
}
