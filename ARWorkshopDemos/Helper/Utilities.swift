//
//  Utilities.swift
//  ARWorkshopDemos
//
//  Created by MBA0231P on 1/14/19.
//  Copyright © 2019 Tien Le P. All rights reserved.
//

import Foundation
import ARKit

extension float4x4 {
    
    var translation: float3 {
        let translation = columns.3
        return float3(translation.x, translation.y, translation.z)
    }
    
}

extension CGPoint {
    
    init(_ vector: SCNVector3) {
        self.init()
        x = CGFloat(vector.x)
        y = CGFloat(vector.y)
    }
    
    var length: CGFloat {
        return sqrt(x * x + y * y)
    }
    
}

extension Collection where Iterator.Element == Float {
    
    var average: Float? {
        guard !isEmpty else {
            return nil
        }
        let sum = reduce(Float(0)) { current, next -> Float in
            return current + next
        }
        return sum / Float(count)
    }
}

extension Int {
    
    var degreesToRadians: Double { return Double(self) * .pi / 180 }
    
}
