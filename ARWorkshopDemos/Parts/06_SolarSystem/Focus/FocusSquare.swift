//
//  FocusSquare.swift
//  ARWorkshopDemos
//
//  Created by MBA0231P on 1/14/19.
//  Copyright © 2019 Tien Le P. All rights reserved.
//

import Foundation
import ARKit

class FocusSquare: SCNNode {
    
    enum State {
        case initializing
        case featuresDetected(anchorPosition: float3, camera: ARCamera?)
        case planeDetected(anchorPosition: float3, planeAnchor: ARPlaneAnchor, camera: ARCamera?)
    }
    
    static let size: Float = 0.17
    static let thickness: Float = 0.018
    static let scaleForClosedSquare: Float = 0.97
    static let sideLengthForOpenSegments: CGFloat = 0.2
    static let animationDuration = 0.7
    static let primaryColor = #colorLiteral(red: 1, green: 0.8, blue: 0, alpha: 1)
    static let fillColor = #colorLiteral(red: 1, green: 0.9254901961, blue: 0.4117647059, alpha: 1)
    
    var lastPosition: float3? {
        switch state {
        case .initializing: return nil
        case .featuresDetected(let anchorPosition, _): return anchorPosition
        case .planeDetected(let anchorPosition, _, _): return anchorPosition
        }
    }
    
    var state: State = .initializing {
        didSet {
            guard state != oldValue else { return }
            
            switch state {
            case .initializing:
                displayAsBillboard()
                
            case .featuresDetected(let anchorPosition, let camera):
                displayAsOpen(at: anchorPosition, camera: camera)
                
            case .planeDetected(let anchorPosition, let planeAnchor, let camera):
                displayAsClosed(at: anchorPosition, planeAnchor: planeAnchor, camera: camera)
            }
        }
    }
    
    private var isOpen = false
    private var isAnimating = false
    private var recentFocusSquarePositions: [float3] = []
    private var anchorsOfVisitedPlanes: Set<ARAnchor> = []
    private var segments: [FocusSquare.Segment] = []
    private let positioningNode = SCNNode()
    
    override init() {
        super.init()
        opacity = 0.0
        let s1 = Segment(name: "s1", corner: .topLeft, alignment: .horizontal)
        let s2 = Segment(name: "s2", corner: .topRight, alignment: .horizontal)
        let s3 = Segment(name: "s3", corner: .topLeft, alignment: .vertical)
        let s4 = Segment(name: "s4", corner: .topRight, alignment: .vertical)
        let s5 = Segment(name: "s5", corner: .bottomLeft, alignment: .vertical)
        let s6 = Segment(name: "s6", corner: .bottomRight, alignment: .vertical)
        let s7 = Segment(name: "s7", corner: .bottomLeft, alignment: .horizontal)
        let s8 = Segment(name: "s8", corner: .bottomRight, alignment: .horizontal)
        segments = [s1, s2, s3, s4, s5, s6, s7, s8]
        
        let sl: Float = 0.5
        let c: Float = FocusSquare.thickness / 2
        s1.simdPosition += float3(-(sl / 2 - c), -(sl - c), 0)
        s2.simdPosition += float3(sl / 2 - c, -(sl - c), 0)
        s3.simdPosition += float3(-sl, -sl / 2, 0)
        s4.simdPosition += float3(sl, -sl / 2, 0)
        s5.simdPosition += float3(-sl, sl / 2, 0)
        s6.simdPosition += float3(sl, sl / 2, 0)
        s7.simdPosition += float3(-(sl / 2 - c), sl - c, 0)
        s8.simdPosition += float3(sl / 2 - c, sl - c, 0)
        positioningNode.eulerAngles.x = .pi / 2
        positioningNode.simdScale = float3(FocusSquare.size * FocusSquare.scaleForClosedSquare)
        for segment in segments {
            positioningNode.addChildNode(segment)
        }
        positioningNode.addChildNode(fillPlane)
        displayNodeHierarchyOnTop(true)
        addChildNode(positioningNode)
        displayAsBillboard()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }
    
    func hide() {
        guard action(forKey: "hide") == nil else { return }
        displayNodeHierarchyOnTop(false)
        runAction(.fadeOut(duration: 0.5), forKey: "hide")
    }
    
    func unhide() {
        guard action(forKey: "unhide") == nil else { return }
        displayNodeHierarchyOnTop(true)
        runAction(.fadeIn(duration: 0.5), forKey: "unhide")
    }
    
    private func displayAsBillboard() {
        eulerAngles.x = -.pi / 2
        simdPosition = float3(0, 0, -0.8)
        unhide()
        performOpenAnimation()
    }
    
    private func displayAsOpen(at position: float3, camera: ARCamera?) {
        performOpenAnimation()
        recentFocusSquarePositions.append(position)
        updateTransform(for: position, camera: camera)
    }
    
    private func displayAsClosed(at position: float3, planeAnchor: ARPlaneAnchor, camera: ARCamera?) {
        performCloseAnimation(flash: !anchorsOfVisitedPlanes.contains(planeAnchor))
        anchorsOfVisitedPlanes.insert(planeAnchor)
        recentFocusSquarePositions.append(position)
        updateTransform(for: position, camera: camera)
    }
    
    private func updateTransform(for position: float3, camera: ARCamera?) {
        simdTransform = matrix_identity_float4x4
        recentFocusSquarePositions = Array(recentFocusSquarePositions.suffix(10))
        let average = recentFocusSquarePositions.reduce(float3(0), { $0 + $1 }) / Float(recentFocusSquarePositions.count)
        self.simdPosition = average
        self.simdScale = float3(scaleBasedOnDistance(camera: camera))
        guard let camera = camera else { return }
        let tilt = abs(camera.eulerAngles.x)
        let threshold1: Float = .pi / 2 * 0.65
        let threshold2: Float = .pi / 2 * 0.75
        let yaw = atan2f(camera.transform.columns.0.x, camera.transform.columns.1.x)
        var angle: Float = 0
        switch tilt {
        case 0..<threshold1:
            angle = camera.eulerAngles.y
        case threshold1..<threshold2:
            let relativeInRange = abs((tilt - threshold1) / (threshold2 - threshold1))
            let normalizedY = normalize(camera.eulerAngles.y, forMinimalRotationTo: yaw)
            angle = normalizedY * (1 - relativeInRange) + yaw * relativeInRange
        default:
            angle = yaw
        }
        eulerAngles.y = angle
    }
    
    private func normalize(_ angle: Float, forMinimalRotationTo ref: Float) -> Float {
        var normalized = angle
        while abs(normalized - ref) > .pi / 4 {
            if angle > ref {
                normalized -= .pi / 2
            } else {
                normalized += .pi / 2
            }
        }
        return normalized
    }
    
    private func scaleBasedOnDistance(camera: ARCamera?) -> Float {
        guard let camera = camera else { return 1.0 }
        let distanceFromCamera = simd_length(simdWorldPosition - camera.transform.translation)
        if distanceFromCamera < 0.7 {
            return distanceFromCamera / 0.7
        } else {
            return 0.25 * distanceFromCamera + 0.825
        }
    }
    
    private func performOpenAnimation() {
        guard !isOpen, !isAnimating else { return }
        isOpen = true
        isAnimating = true
        SCNTransaction.begin()
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeOut)
        SCNTransaction.animationDuration = FocusSquare.animationDuration / 4
        positioningNode.opacity = 1.0
        for segment in segments {
            segment.open()
        }
        SCNTransaction.completionBlock = {
            self.positioningNode.runAction(pulseAction(), forKey: "pulse")
            self.isAnimating = false
        }
        SCNTransaction.commit()
        SCNTransaction.begin()
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeOut)
        SCNTransaction.animationDuration = FocusSquare.animationDuration / 4
        positioningNode.simdScale = float3(FocusSquare.size)
        SCNTransaction.commit()
    }
    
    private func performCloseAnimation(flash: Bool = false) {
        guard isOpen, !isAnimating else { return }
        isOpen = false
        isAnimating = true
        positioningNode.removeAction(forKey: "pulse")
        positioningNode.opacity = 1.0
        SCNTransaction.begin()
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeOut)
        SCNTransaction.animationDuration = FocusSquare.animationDuration / 2
        positioningNode.opacity = 0.99
        SCNTransaction.completionBlock = {
            SCNTransaction.begin()
            SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeOut)
            SCNTransaction.animationDuration = FocusSquare.animationDuration / 4
            for segment in self.segments {
                segment.close()
            }
            SCNTransaction.completionBlock = { self.isAnimating = false }
            SCNTransaction.commit()
        }
        SCNTransaction.commit()
        positioningNode.addAnimation(scaleAnimation(for: "transform.scale.x"), forKey: "transform.scale.x")
        positioningNode.addAnimation(scaleAnimation(for: "transform.scale.y"), forKey: "transform.scale.y")
        positioningNode.addAnimation(scaleAnimation(for: "transform.scale.z"), forKey: "transform.scale.z")
        if flash {
            let waitAction = SCNAction.wait(duration: FocusSquare.animationDuration * 0.75)
            let fadeInAction = SCNAction.fadeOpacity(to: 0.25, duration: FocusSquare.animationDuration * 0.125)
            let fadeOutAction = SCNAction.fadeOpacity(to: 0.0, duration: FocusSquare.animationDuration * 0.125)
            fillPlane.runAction(SCNAction.sequence([waitAction, fadeInAction, fadeOutAction]))
            
            let flashSquareAction = flashAnimation(duration: FocusSquare.animationDuration * 0.25)
            for segment in segments {
                segment.runAction(.sequence([waitAction, flashSquareAction]))
            }
        }
    }
    
    private func scaleAnimation(for keyPath: String) -> CAKeyframeAnimation {
        let scaleAnimation = CAKeyframeAnimation(keyPath: keyPath)
        let easeOut = CAMediaTimingFunction(name: .easeOut)
        let easeInOut = CAMediaTimingFunction(name: .easeInEaseOut)
        let linear = CAMediaTimingFunction(name: .linear)
        let size = FocusSquare.size
        let ts = FocusSquare.size * FocusSquare.scaleForClosedSquare
        let values = [size, size * 1.15, size * 1.15, ts * 0.97, ts]
        let keyTimes: [NSNumber] = [0.00, 0.25, 0.50, 0.75, 1.00]
        let timingFunctions = [easeOut, linear, easeOut, easeInOut]
        scaleAnimation.values = values
        scaleAnimation.keyTimes = keyTimes
        scaleAnimation.timingFunctions = timingFunctions
        scaleAnimation.duration = FocusSquare.animationDuration
        return scaleAnimation
    }
    
    func displayNodeHierarchyOnTop(_ isOnTop: Bool) {
        func updateRenderOrder(for node: SCNNode) {
            node.renderingOrder = isOnTop ? 2 : 0
            for material in node.geometry?.materials ?? [] {
                material.readsFromDepthBuffer = !isOnTop
            }
            for child in node.childNodes {
                updateRenderOrder(for: child)
            }
        }
        updateRenderOrder(for: positioningNode)
    }
    
    private lazy var fillPlane: SCNNode = {
        let correctionFactor = FocusSquare.thickness / 2 // correction to align lines perfectly
        let length = CGFloat(1.0 - FocusSquare.thickness * 2 + correctionFactor)
        let plane = SCNPlane(width: length, height: length)
        let node = SCNNode(geometry: plane)
        node.name = "fillPlane"
        node.opacity = 0.0
        let material = plane.firstMaterial!
        material.diffuse.contents = FocusSquare.fillColor
        material.isDoubleSided = true
        material.ambient.contents = UIColor.black
        material.lightingModel = .constant
        material.emission.contents = FocusSquare.fillColor
        return node
    }()
}

private func pulseAction() -> SCNAction {
    let pulseOutAction = SCNAction.fadeOpacity(to: 0.4, duration: 0.5)
    let pulseInAction = SCNAction.fadeOpacity(to: 1.0, duration: 0.5)
    pulseOutAction.timingMode = .easeInEaseOut
    pulseInAction.timingMode = .easeInEaseOut
    return SCNAction.repeatForever(SCNAction.sequence([pulseOutAction, pulseInAction]))
}

private func flashAnimation(duration: TimeInterval) -> SCNAction {
    let action = SCNAction.customAction(duration: duration) { (node, elapsedTime) -> Void in
        let elapsedTimePercentage = elapsedTime / CGFloat(duration)
        let saturation = 2.8 * (elapsedTimePercentage - 0.5) * (elapsedTimePercentage - 0.5) + 0.3
        if let material = node.geometry?.firstMaterial {
            material.diffuse.contents = UIColor(hue: 0.1333, saturation: saturation, brightness: 1.0, alpha: 1.0)
        }
    }
    return action
}

extension FocusSquare.State: Equatable {
    static func ==(lhs: FocusSquare.State, rhs: FocusSquare.State) -> Bool {
        switch (lhs, rhs) {
        case (.initializing, .initializing):
            return true
        case (.featuresDetected(let lhsPosition, let lhsCamera),
              .featuresDetected(let rhsPosition, let rhsCamera)):
            return lhsPosition == rhsPosition && lhsCamera == rhsCamera
        case (.planeDetected(let lhsPosition, let lhsPlaneAnchor, let lhsCamera),
              .planeDetected(let rhsPosition, let rhsPlaneAnchor, let rhsCamera)):
            return lhsPosition == rhsPosition
                && lhsPlaneAnchor == rhsPlaneAnchor
                && lhsCamera == rhsCamera
        default:
            return false
        }
    }
}

extension FocusSquare {
    
    enum Corner {
        case topLeft
        case topRight
        case bottomRight
        case bottomLeft
    }
    
    enum Alignment {
        case horizontal
        case vertical
    }
    
    enum Direction {
        case up, down, left, right
        var reversed: Direction {
            switch self {
            case .up:   return .down
            case .down: return .up
            case .left:  return .right
            case .right: return .left
            }
        }
    }
    
    class Segment: SCNNode {
        static let thickness: CGFloat = 0.018
        static let length: CGFloat = 0.5
        static let openLength: CGFloat = 0.2
        let corner: Corner
        let alignment: Alignment
        let plane: SCNPlane
        
        init(name: String, corner: Corner, alignment: Alignment) {
            self.corner = corner
            self.alignment = alignment
            switch alignment {
            case .vertical:
                plane = SCNPlane(width: Segment.thickness, height: Segment.length)
            case .horizontal:
                plane = SCNPlane(width: Segment.length, height: Segment.thickness)
            }
            super.init()
            self.name = name
            let material = plane.firstMaterial!
            material.diffuse.contents = FocusSquare.primaryColor
            material.isDoubleSided = true
            material.ambient.contents = UIColor.black
            material.lightingModel = .constant
            material.emission.contents = FocusSquare.primaryColor
            geometry = plane
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("\(#function) has not been implemented")
        }
        
        var openDirection: Direction {
            switch (corner, alignment) {
            case (.topLeft,     .horizontal):   return .left
            case (.topLeft,     .vertical):     return .up
            case (.topRight,    .horizontal):   return .right
            case (.topRight,    .vertical):     return .up
            case (.bottomLeft,  .horizontal):   return .left
            case (.bottomLeft,  .vertical):     return .down
            case (.bottomRight, .horizontal):   return .right
            case (.bottomRight, .vertical):     return .down
            }
        }
        
        func open() {
            if alignment == .horizontal {
                plane.width = Segment.openLength
            } else {
                plane.height = Segment.openLength
            }
            
            let offset = Segment.length / 2 - Segment.openLength / 2
            updatePosition(withOffset: Float(offset), for: openDirection)
        }
        
        func close() {
            let oldLength: CGFloat
            if alignment == .horizontal {
                oldLength = plane.width
                plane.width = Segment.length
            } else {
                oldLength = plane.height
                plane.height = Segment.length
            }
            
            let offset = Segment.length / 2 - oldLength / 2
            updatePosition(withOffset: Float(offset), for: openDirection.reversed)
        }
        
        private func updatePosition(withOffset offset: Float, for direction: Direction) {
            switch direction {
            case .left:     position.x -= offset
            case .right:    position.x += offset
            case .up:       position.y -= offset
            case .down:     position.y += offset
            }
        }
    }
    
}
