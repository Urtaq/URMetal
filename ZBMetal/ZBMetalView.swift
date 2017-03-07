//
//  ZBMetalView.swift
//  ZBMetal
//
//  Created by DongSoo Lee on 2017. 2. 3..
//  Copyright © 2017년 zigbang. All rights reserved.
//

import UIKit
import MetalKit

struct Matrix {
    var m: [Float]

    init() {
        m = [1, 0, 0, 0,
            0, 1, 0, 0,
            0, 0, 1, 0,
            0, 0, 0, 1
        ]
    }

    func translationMatrix(_ originMatrix: Matrix, _ position: float3) -> Matrix {
        var matrix = originMatrix
        matrix.m[12] = position.x
        matrix.m[13] = position.y
        matrix.m[14] = position.z

        return matrix
    }

    func scalingMatrix(_ originMatrix: Matrix, _ scale: Float) -> Matrix {
        var matrix = originMatrix
        matrix.m[0] = scale
        matrix.m[5] = scale
        matrix.m[10] = scale
        matrix.m[15] = 1.0

        return matrix
    }

    func rotationMatrix(_ originMatrix: Matrix, _ rot: float3) -> Matrix {
        var matrix = originMatrix
        matrix.m[0] = cos(rot.y) * cos(rot.z)
        matrix.m[4] = cos(rot.z) * sin(rot.x) * sin(rot.y) - cos(rot.x) * sin(rot.z)
        matrix.m[8] = cos(rot.x) * cos(rot.z) * sin(rot.y) + sin(rot.x) * sin(rot.z)

        matrix.m[1] = cos(rot.y) * sin(rot.z)
        matrix.m[5] = cos(rot.x) * cos(rot.z) + sin(rot.x) * sin(rot.y) * sin(rot.z)
        matrix.m[9] = -cos(rot.z) * sin(rot.x) + cos(rot.x) * sin(rot.y)
 * sin(rot.z)

        matrix.m[2] = -sin(rot.y)
        matrix.m[6] = cos(rot.y) * sin(rot.x)
        matrix.m[10] = cos(rot.x) * cos(rot.y)

        matrix.m[15] = 1.0

        return matrix
    }

    func modelMatrix(_ originMatrix: Matrix) -> Matrix {
        var matrix = originMatrix
        matrix = rotationMatrix(matrix, float3(0.0, 0.0, 0.1))
        matrix = scalingMatrix(matrix, 0.25)
        matrix = translationMatrix(matrix, float3(0.0, 0.5, 0.0))
        return matrix
    }
}

struct Vertex {
    var position: vector_float4
    var color: vector_float4
}

class ZBMetalView: MTKView {

    var vertexBuffer: MTLBuffer!
    var rps: MTLRenderPipelineState! = nil

    var uniformBuffer: MTLBuffer!

    func render() {
        self.device = MTLCreateSystemDefaultDevice()

        self.createBuffer()
        self.registerShaders()
        self.sendToGPU()
    }

    func createBuffer() {
        let vertexData = [Vertex(position: [-1.0, -1.0, 0.0, 1.0], color: [1, 0, 0, 1]),
                          Vertex(position: [1.0, -1.0, 0.0, 1.0], color: [0, 1, 0, 1]),
                          Vertex(position: [0.0, 1.0, 0.0, 1.0], color: [0, 0, 1, 1])]
        let dataSize = vertexData.count * MemoryLayout<Vertex>.size
        self.vertexBuffer = self.device?.makeBuffer(bytes: vertexData, length: dataSize, options: [])

        self.uniformBuffer = self.device?.makeBuffer(length: MemoryLayout<Float>.size * 16, options: [])
        let bufferPointer = self.uniformBuffer.contents()
        memcpy(bufferPointer, Matrix().modelMatrix(Matrix()).m, MemoryLayout<Float>.size * 16)
    }

    func registerShaders() {
        guard let library = self.device?.newDefaultLibrary() else { return }
        let vertexFunc = library.makeFunction(name: "vertex_func")
        let fragFunc = library.makeFunction(name: "fragment_func")

        let rpld = MTLRenderPipelineDescriptor()
        rpld.vertexFunction = vertexFunc
        rpld.fragmentFunction = fragFunc
        rpld.colorAttachments[0].pixelFormat = .bgra8Unorm

        do {
            self.rps = try self.device?.makeRenderPipelineState(descriptor: rpld)
        } catch let error {
            print("\(error)")
        }
    }

    func sendToGPU() {
        let rpd = MTLRenderPassDescriptor()
        guard let drawable = self.currentDrawable else { return }
        let bleen = MTLClearColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        rpd.colorAttachments[0].texture = drawable.texture
        rpd.colorAttachments[0].clearColor = bleen
        rpd.colorAttachments[0].loadAction = .clear

        let commandBuffer = self.device?.makeCommandQueue().makeCommandBuffer()
        let encoder = commandBuffer?.makeRenderCommandEncoder(descriptor: rpd)

        encoder?.setRenderPipelineState(self.rps)
        encoder?.setVertexBuffer(self.vertexBuffer, offset: 0, at: 0)
        encoder?.setVertexBuffer(self.uniformBuffer, offset: 0, at: 1)
        encoder?.setTriangleFillMode(MTLTriangleFillMode.lines)
        encoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)

        encoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        self.render()
    }
}
