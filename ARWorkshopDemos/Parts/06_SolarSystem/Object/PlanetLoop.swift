//
//  PlanetLoop.swift
//  ARWorkshopDemos
//
//  Created by MBA0231P on 1/14/19.
//  Copyright © 2019 Tien Le P. All rights reserved.
//

import Foundation
import SceneKit

final class PlanetLoop: SCNNode {
    
    init(planet: PlanetType) {
        super.init()
        self.opacity = 0.4;
        self.geometry = SCNBox(width: 0.55, height: 0, length: 0.55, chamferRadius: 0)
        self.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "saturn_loop")
        self.rotation = SCNVector4Make(0, 0, 1, Float(30.degreesToRadians))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
