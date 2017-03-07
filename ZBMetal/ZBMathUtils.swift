//
//  ZBMathUtils.swift
//  ZBMetal
//
//  Created by DongSoo Lee on 2017. 2. 6..
//  Copyright © 2017년 zigbang. All rights reserved.
//

import simd

struct Vertex {
    var position: vector_float4
    var color: vector_float4
}

struct Uniforms {
    var modelViewProjectionMatrix: matrix_float4x4
}

func modelMatrix() -> matrix_float4x4 {
    let scaled = scalingMatrix(scale: 0.5)
    let rotatedY = rotationMatrix(angle: Float.pi / 4, axis: float3(0, 1, 0))
    let rotatedX = rotationMatrix(angle: Float.pi / 4, axis: float3(1, 0, 0))
    return matrix_multiply(matrix_multiply(rotatedX, rotatedY), scaled)
}

// MARK: from object space to world space
func translationMatrix(position: float3) -> matrix_float4x4 {
    let X = vector_float4(1, 0, 0, 0)
    let Y = vector_float4(0, 1, 0, 0)
    let Z = vector_float4(0, 0, 1, 0)
    let W = vector_float4(position.x, position.y, position.z, 1)
    return matrix_float4x4(columns:(X, Y, Z, W))
}

func scalingMatrix(scale: Float) -> matrix_float4x4 {
    let X = vector_float4(scale, 0, 0, 0)
    let Y = vector_float4(0, scale, 0, 0)
    let Z = vector_float4(0, 0, scale, 0)
    let W = vector_float4(0, 0, 0, 1)
    return matrix_float4x4(columns:(X, Y, Z, W))
}

func rotationMatrix(angle: Float, axis: vector_float3) -> matrix_float4x4 {
    var X = vector_float4(0, 0, 0, 0)
    X.x = axis.x * axis.x + (1 - axis.x * axis.x) * cos(angle)
    X.y = axis.x * axis.y * (1 - cos(angle)) - axis.z * sin(angle)
    X.z = axis.x * axis.z * (1 - cos(angle)) + axis.y * sin(angle)
    X.w = 0.0
    var Y = vector_float4(0, 0, 0, 0)
    Y.x = axis.x * axis.y * (1 - cos(angle)) + axis.z * sin(angle)
    Y.y = axis.y * axis.y + (1 - axis.y * axis.y) * cos(angle)
    Y.z = axis.y * axis.z * (1 - cos(angle)) - axis.x * sin(angle)
    Y.w = 0.0
    var Z = vector_float4(0, 0, 0, 0)
    Z.x = axis.x * axis.z * (1 - cos(angle)) - axis.y * sin(angle)
    Z.y = axis.y * axis.z * (1 - cos(angle)) + axis.x * sin(angle)
    Z.z = axis.z * axis.z + (1 - axis.z * axis.z) * cos(angle)
    Z.w = 0.0
    let W = vector_float4(0, 0, 0, 1)
    return matrix_float4x4(columns:(X, Y, Z, W))
}

// MARK: from world space to camera space
func viewMatrix() -> matrix_float4x4 {
    let cameraPosition = vector_float3(0, 0, -3)
    return translationMatrix(position: cameraPosition)
}

// MARK: from camera space to clip space
func projectionMatrix(near: Float, far: Float, aspect: Float, fovy: Float) -> matrix_float4x4 {
    let scaleY = 1 / tan(fovy * 0.5)
    let scaleX = scaleY / aspect
    let scaleZ = -(far + near) / (far - near)
    let scaleW = -2 * far * near / (far - near)
    let X = vector_float4(scaleX, 0, 0, 0)
    let Y = vector_float4(0, scaleY, 0, 0)
    let Z = vector_float4(0, 0, scaleZ, -1)
    let W = vector_float4(0, 0, scaleW, 0)
    return matrix_float4x4(columns: (X, Y, Z, W))
}

// MARK: from clip space to normalized device coordinates(NDC) => through Metal framework
// MARK: from normalized device coordinates(NDC) to screen space => through Metal framework
