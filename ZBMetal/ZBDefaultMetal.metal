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

    static float random(float2 p) {
        return fract(sin(dot(p, float2(15.79, 81.93)) * 45678.9123));
    }

    static float noise(float2 p) {
        float2 i = floor(p);
        float2 f = fract(p);
        f = f * f * (3.0 - 2.0 * f);
        float bottom = mix(random(i + float2(0)), random(i + float2(1.0, 0.0)), f.x);
        float top = mix(random(i + float2(0.0, 1.0)), random(i + float2(1)), f.x);
        float t = mix(bottom, top, f.y);

        return t;
    }

    static float fbm(float2 uv) {
        float sum = 0;
        float amp = 0.7;
        for (int i = 0; i < 4; ++i) {
            sum += noise(uv) * amp;
            uv += uv * 1.2;
            amp *= 0.4;
        }

        return sum;
    }
};

kernel void compute(texture2d<float, access::write> output [[texture(0)]],
                    texture2d<float, access::sample> input [[texture(1)]],
                    constant float &timer [[buffer(0)]],
                    constant float2 &gesture [[buffer(1)]],
                    uint2 gid [[thread_position_in_grid]]) {
    int width = output.get_width();
    int height = output.get_height();

    float2 uv = float2(gid) / float2(width, height);

    uv = uv * 2.0 - 1.0;
    float radius = 0.5;
    float distance = length(uv) - radius;

    float4 color = input.read(gid);

//    uv = fmod(float2(gid) + float2(timer * 100, 0), float2(width, height));
//    color = input.read(uint2(uv));

    uv = uv * 2;
    radius = 1;
    constexpr sampler textureSampler(coord::normalized,
                                     address::repeat,
                                     min_filter::linear,
                                     mag_filter::linear,
                                     mip_filter::linear);
    float3 norm = float3(uv, sqrt(1.0 - dot(uv, uv)));
    float pi = 3.14;
    float s = atan2(norm.z, norm.x) / (2 * pi);
    float t = asin(norm.y) / (2 * pi);
    t += 0.5;
    color = input.sample(textureSampler, float2(s + timer * 0.1 + gesture.x, t));
    output.write(distance < 0 ? color : float4(0), gid);
}


kernel void computeMin(texture2d<float, access::write> output [[texture(0)]],
                    constant float &timer [[buffer(1)]],
                    constant float2 &mouse [[buffer(2)]],
                    uint2 gid [[thread_position_in_grid]]) {
    int width = output.get_width();
    int height = output.get_height();

    float2 uv = float2(gid) / float2(width, height);

    float2 cc = 1.1 * float2(0.5 * cos(0.1 * timer) - 0.25 * cos(0.2 * timer), 0.5 * sin(0.1 * timer) - 0.25 * sin(0.2 * timer) );
    float4 dmin = float4(1000.0);
    float2 z = (-1.0 + 2.0 * uv) * float2(1.7, 1.0);
    for (int i = 0; i < 8; i++) {
        z = cc + float2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y);
        dmin = min(dmin, float4(abs(0.0 + z.y + 0.5 * sin(z.x)), abs(1.0 + z.x + 0.5 * sin(z.y)), dot(z, z), length(fract(z) - 0.5)));
    }

    float3 color = float3( mouse.x - mouse.y );
    color = mix(color, float3(1.00, 0.80, 0.60), min(1.0, pow(dmin.x * 0.25, 0.20)));
    color = mix(color, float3(0.72, 0.70, 0.60), min(1.0, pow(dmin.y * 0.50, 0.50)));
    color = mix(color, float3(1.00, 1.00, 1.00), 1.0 - min(1.0, pow(dmin.z * 1.00, 0.15)));
    color = 1.25 * color * color;
    color *= 0.5 + 0.5 * pow(16.0 * uv.x * (1.0 - uv.x) * uv.y * (1.0 - uv.y), 0.15);

    output.write(float4(color, 1), gid);
}
