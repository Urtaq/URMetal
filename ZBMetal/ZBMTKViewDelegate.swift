//
//  ZBMTKViewDelegate.swift
//  ZBMetal
//
//  Created by DongSoo Lee on 2017. 2. 28..
//  Copyright © 2017년 zigbang. All rights reserved.
//

import MetalKit

public class ZBMTKViewDelegate: NSObject, MTKViewDelegate {

    var device: MTLDevice!
    var queue: MTLCommandQueue!
    var cps: MTLComputePipelineState!

    public override init() {
        super.init()

        self.device = MTLCreateSystemDefaultDevice()
        self.registerShaders()
    }

    func registerShaders() {
        self.queue = self.device.makeCommandQueue()

        guard let library = self.device.newDefaultLibrary() else { return }
        let kernel = library.makeFunction(name: "compute")

        do {
            self.cps = try self.device?.makeComputePipelineState(function: kernel!)
        } catch let error {
            print("\(error)")
        }
    }

    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        //
    }

    public func draw(in view: MTKView) {
        view.framebufferOnly = false
        guard let drawable = view.currentDrawable else { return }

        let commandBuffer = self.queue.makeCommandBuffer()
        let encoder = commandBuffer.makeComputeCommandEncoder()

        encoder.setComputePipelineState(self.cps)
        encoder.setTexture(drawable.texture, at: 0)

        let threadGroupCount = MTLSizeMake(8, 8, 1)
        let threadGroups = MTLSizeMake(drawable.texture.width / threadGroupCount.width, drawable.texture.height / threadGroupCount.height, 1)
        encoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupCount)

        encoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
