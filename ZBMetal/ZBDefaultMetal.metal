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

    static float distToScene(Ray r) {
        Sphere s = Sphere(float3(1.0), 0.5);
        Ray repeatRay = r;
        repeatRay.origin = fmod(r.origin, 2.0);
        return distToSphere(repeatRay, s);
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
    uv = uv * 2.0 - 1.0;
    Ray ray = Ray(float3(1000.), normalize(float3(uv, 1.0)));
    float3 col = float3(0.);
    for (int i = 0; i < 100; i++) {
        float dist = Util::distToScene(ray);
        if (dist < 0.001) {
            col = float3(1.);
            break;
        }
        ray.origin += ray.direction * dist;
    }

    output.write(float4(col * abs((ray.origin - 1000.) / 10.0), 1.), gid);
}
