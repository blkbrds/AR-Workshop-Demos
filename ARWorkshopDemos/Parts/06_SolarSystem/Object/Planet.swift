//
//  Planet.swift
//  ARWorkshopDemos
//
//  Created by MBA0231P on 1/14/19.
//  Copyright © 2019 Tien Le P. All rights reserved.
//

import UIKit

final class Planet: NSObject {
    
    var diffuse: UIImage
    var specular: UIImage?
    var emission: UIImage?
    var normal: UIImage?
    var radius: CGFloat
    var anxisTime: Double
    var revolutionTime: Double?
    var distance: Double
    var hasChild:Bool?
    
    init(radius: CGFloat, diffuse: UIImage, specular: UIImage? = nil, emission: UIImage? = nil, normal: UIImage? = nil, anxisTime: Double, revolTime: Double = 0, distance: Double, hasChild: Bool? = false ) {
        self.radius = radius
        self.diffuse = diffuse
        self.specular = specular
        self.emission = emission
        self.normal = normal
        self.anxisTime = anxisTime
        self.revolutionTime = revolTime
        self.distance = distance
        self.hasChild = hasChild
    }
    
}
