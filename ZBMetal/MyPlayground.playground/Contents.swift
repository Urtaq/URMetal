//: Playground - noun: a place where people can play

import MetalKit
import PlaygroundSupport

var weights = [Float](repeating: 0.0, count: 9)
weights[8] = 0

let frame = NSRect(x: 0, y: 0, width: 400, height: 400)
let delegate = MetalView()
let view = MTKView(frame: frame, device: delegate.device)
view.delegate = delegate
PlaygroundPage.current.liveView = view
