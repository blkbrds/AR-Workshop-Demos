//
//  SampleShape.swift
//  ARWorkshopDemos
//
//  Created by Tien Le P. on 12/7/18.
//  Copyright © 2018 Tien Le P. All rights reserved.
//

import Foundation
import ARKit

enum ShapeType:Int {
    
    case box = 0
    case sphere
    case pyramid
    case torus
    case capsule
    case cylinder
    case cone
    case tube
    
    // 2
    static func random() -> ShapeType {
        let maxValue = tube.rawValue
        let rand = arc4random_uniform(UInt32(maxValue+1))
        return ShapeType(rawValue: Int(rand))!
    }
}

class SampleShape {
    
    /// A simple box With hard code for vector or size
    ///
    /// - Returns: ScreenKit Node
    class func simpleBox() -> SCNNode {
        let box = SCNBox(width: 0.05, height: 0.05, length: 0.05, chamferRadius: 0)
        
        let boxNode = SCNNode()
        boxNode.geometry = box
        boxNode.position = SCNVector3(0, 0, -0.2)
        
        return boxNode
    }
    
    
    /// Random a shape
    ///
    /// - Parameters:
    ///   - x: x
    ///   - y: y
    ///   - z: z
    /// - Returns: ScreenKit Node
    class func spawnShape(x: Float = 0, y: Float = 0, z: Float = -0.2) -> SCNNode {
        
        var geometry:SCNGeometry
        
        switch ShapeType.random() {
        case  .box:
            geometry = SCNBox(width: 0.05, height: 0.05, length: 0.05, chamferRadius: 0)
        case .sphere:
            geometry = SCNSphere(radius: 0.05)
        case .pyramid:
            geometry = SCNPyramid(width: 0.05, height: 0.05, length: 0.05)
        case .torus:
            geometry = SCNTorus(ringRadius: 0.1, pipeRadius: 0.02)
        case .capsule:
            geometry = SCNCapsule(capRadius: 0.05, height: 0.2)
        case .cylinder:
            geometry = SCNCylinder(radius: 0.1, height: 0.15)
        case .cone:
            geometry = SCNCone(topRadius: 0.05, bottomRadius: 0.1, height: 0.15)
        case .tube:
            geometry = SCNTube(innerRadius: 0.05, outerRadius: 0.1, height: 0.15)
        }
        
        let geometryNode = SCNNode(geometry: geometry)
        geometryNode.position = SCNVector3(x, y, z)
        
        return geometryNode
    }
}
