//: Playground - noun: a place where people can play

import QuartzCore
import MetalKit
import PlaygroundSupport

let device = MTLCreateSystemDefaultDevice()
let frame = CGRect(x: 0, y: 0, width: 300, height: 300)
let view = ZBMetalView(frame: frame, device: device)
PlaygroundPage.current.liveView = view
