//
//  PlanetNode.swift
//  ARWorkshopDemos
//
//  Created by MBA0231P on 1/14/19.
//  Copyright © 2019 Tien Le P. All rights reserved.
//

import Foundation
import ARKit
import SceneKit

final class PlanetNode: SCNNode {
    
    let planetType: PlanetType
    var node: SCNNode!
    private var recentVirtualObjectDistances = [Float]()
    
    func reset() {
        recentVirtualObjectDistances.removeAll()
    }
    
    init(planet: PlanetType) {
        self.planetType = planet
        let planetData = planet.getPlanet()
        super.init()
        
        let geome = SCNSphere(radius: planetData.radius)
        geome.firstMaterial?.diffuse.contents = planetData.diffuse
        geome.firstMaterial?.specular.contents = planetData.specular
        geome.firstMaterial?.emission.contents = planetData.emission
        geome.firstMaterial?.normal.contents = planetData.normal
        position = SCNVector3(planetData.distance, 0, 0)
        if(planetData.hasChild!) {
            node = SCNNode()
            node.geometry = geome
            node.position = SCNVector3(0, 0, 0)
            addChildNode(node)
            if !planetData.anxisTime.isZero {
                node.runAction(getPlanetRotation(duration: planetData.anxisTime)) }
        } else {
            geometry = geome
            if !planetData.anxisTime.isZero {
                runAction(getPlanetRotation(duration: planetData.anxisTime)) }
        }
        addLight(planet: planet)
        addPlanetLoop(planet: planet)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setPosition(_ newPosition: float3, relativeTo cameraTransform: matrix_float4x4, smoothMovement: Bool) {
        let cameraWorldPosition = cameraTransform.translation
        var positionOffsetFromCamera = newPosition - cameraWorldPosition
        if simd_length(positionOffsetFromCamera) > 10 {
            positionOffsetFromCamera = simd_normalize(positionOffsetFromCamera)
            positionOffsetFromCamera *= 10
        }
        
        if smoothMovement {
            let hitTestResultDistance = simd_length(positionOffsetFromCamera)
            recentVirtualObjectDistances.append(hitTestResultDistance)
            recentVirtualObjectDistances = Array(recentVirtualObjectDistances.suffix(10))
            let averageDistance = recentVirtualObjectDistances.average!
            let averagedDistancePosition = simd_normalize(positionOffsetFromCamera) * averageDistance
            simdPosition = cameraWorldPosition + averagedDistancePosition
        } else {
            simdPosition = cameraWorldPosition + positionOffsetFromCamera
        }
    }
    
    func adjustOntoPlaneAnchor(_ anchor: ARPlaneAnchor, using node: SCNNode) {
        let planePosition = node.convertPosition(position, from: parent)
        guard planePosition.y != 0 else { return }
        let tolerance: Float = 0.1
        let minX: Float = anchor.center.x - anchor.extent.x / 2 - anchor.extent.x * tolerance
        let maxX: Float = anchor.center.x + anchor.extent.x / 2 + anchor.extent.x * tolerance
        let minZ: Float = anchor.center.z - anchor.extent.z / 2 - anchor.extent.z * tolerance
        let maxZ: Float = anchor.center.z + anchor.extent.z / 2 + anchor.extent.z * tolerance
        guard (minX...maxX).contains(planePosition.x) && (minZ...maxZ).contains(planePosition.z) else {
            return
        }
        let verticalAllowance: Float = 0.05
        let epsilon: Float = 0.001
        let distanceToPlane = abs(planePosition.y)
        if distanceToPlane > epsilon && distanceToPlane < verticalAllowance {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = CFTimeInterval(distanceToPlane * 500)
            SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            position.y = anchor.transform.columns.3.y
            SCNTransaction.commit()
        }
    }
    
    func addPlanet(planet:PlanetType) {
        let orbitNode = getPlanetOribit(planet: planet.getPlanet())
        addChildNode(orbitNode)
        let planetNode = PlanetNode(planet:planet)
        let rotateNode = SCNNode()
        rotateNode.addChildNode(planetNode)
        let planetData = planet.getPlanet()
        let action = getPlanetRotation(duration: planetData.revolutionTime!)
        rotateNode.runAction(action)
        addChildNode(rotateNode)
    }
    
    func addPlanet(planetNode: PlanetNode) {
        let planet = planetNode.planetType
        let orbitNode = getPlanetOribit(planet: planet.getPlanet())
        addChildNode(orbitNode)
        let rotateNode = SCNNode()
        rotateNode.addChildNode(planetNode)
        let action = getPlanetRotation(duration: planet.getPlanet().revolutionTime!)
        rotateNode.runAction(action)
        addChildNode(rotateNode)
    }
    
    private func getPlanetOribit(planet: Planet) -> SCNNode {
        let oribitNode = SCNNode()
        oribitNode.position = SCNVector3(0, 0, 0)
        let ringRadius = planet.distance
        oribitNode.geometry = SCNTorus(ringRadius: CGFloat(ringRadius), pipeRadius: 0.0004)
        oribitNode.geometry?.firstMaterial?.multiply.contents = UIColor(red: 255, green: 255, blue: 255, alpha: 0.3)
        return oribitNode
    }
    
    private func addPlanetLoop(planet: PlanetType) {
        if planet == .saturn {
            let loopNode = PlanetLoop(planet: planet)
            addChildNode(loopNode)
        }
    }
    
    private func addLight(planet: PlanetType) {
        if planet == .sun {
            let lightNode = SCNNode()
            lightNode.light = SCNLight()
            lightNode.light?.color = UIColor.white
            lightNode.light?.type = .omni
            node?.addChildNode(lightNode)
            let haloNode = SCNNode()
            haloNode.geometry = SCNPlane(width: 1.2, height: 1.2)
            haloNode.rotation = SCNVector4(0, 0, 1, -Float.pi/2)
            haloNode.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "saturn")
            haloNode.geometry?.firstMaterial?.lightingModel = .constant
            haloNode.geometry?.firstMaterial?.writesToDepthBuffer = false
            haloNode.opacity = 0.8
            node?.addChildNode(haloNode)
        }
    }
    
    private func getPlanetRotation(duration: Double) -> SCNAction {
        let action = SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: duration)
        let forever = SCNAction.repeatForever(action)
        return forever
    }
    
}

extension PlanetNode {
    
    static func existingObjectContainingNode(_ node: SCNNode) -> PlanetNode? {
        if let planetNodeRoot = node as? PlanetNode {
            return planetNodeRoot
        }
        guard let parent = node.parent else { return nil }
        return existingObjectContainingNode(parent)
    }
    
}
