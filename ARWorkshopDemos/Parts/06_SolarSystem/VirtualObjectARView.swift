//
//  VirtualObjectARView.swift
//  ARWorkshopDemos
//
//  Created by MBA0231P on 1/14/19.
//  Copyright © 2019 Tien Le P. All rights reserved.
//

import Foundation
import ARKit

final class VirtualObjectARView: ARSCNView {
    
    struct HitTestRay {
        var origin: float3
        var direction: float3
        
        func intersectionWithHorizontalPlane(atY planeY: Float) -> float3? {
            let normalizedDirection = simd_normalize(direction)
            if normalizedDirection.y == 0 {
                if origin.y == planeY {
                    return origin
                } else {
                    return nil
                }
            }
            let distance = (planeY - origin.y) / normalizedDirection.y
            if distance < 0 {
                return nil
            }
            return origin + (normalizedDirection * distance)
        }
        
    }
    
    struct FeatureHitTestResult {
        var position: float3
        var distanceToRayOrigin: Float
        var featureHit: float3
        var featureDistanceToHitResult: Float
    }
    
    func virtualObject(at point: CGPoint) -> PlanetNode? {
        let hitTestOptions: [SCNHitTestOption: Any] = [.boundingBoxOnly: true]
        let hitTestResults = hitTest(point, options: hitTestOptions)
        
        return hitTestResults.lazy.compactMap { result in
            return PlanetNode.existingObjectContainingNode(result.node)
            }.first
    }
    
    func worldPosition(fromScreenPosition position: CGPoint, objectPosition: float3?, infinitePlane: Bool = false) -> (position: float3, planeAnchor: ARPlaneAnchor?, isOnPlane: Bool)? {
        let planeHitTestResults = hitTest(position, types: .existingPlaneUsingExtent)
        if let result = planeHitTestResults.first {
            let planeHitTestPosition = result.worldTransform.translation
            let planeAnchor = result.anchor
            return (planeHitTestPosition, planeAnchor as? ARPlaneAnchor, true)
        }
        let featureHitTestResult = hitTestWithFeatures(position, coneOpeningAngleInDegrees: 18, minDistance: 0.2, maxDistance: 2.0).first
        let featurePosition = featureHitTestResult?.position
        if infinitePlane || featurePosition == nil {
            if let objectPosition = objectPosition,
                let pointOnInfinitePlane = hitTestWithInfiniteHorizontalPlane(position, objectPosition) {
                return (pointOnInfinitePlane, nil, true)
            }
        }
        if let featurePosition = featurePosition {
            return (featurePosition, nil, false)
        }
        let unfilteredFeatureHitTestResults = hitTestWithFeatures(position)
        if let result = unfilteredFeatureHitTestResults.first {
            return (result.position, nil, false)
        }
        return nil
    }
    
    func hitTestRayFromScreenPosition(_ point: CGPoint) -> HitTestRay? {
        guard let frame = session.currentFrame else { return nil }
        let cameraPos = frame.camera.transform.translation
        let positionVec = float3(x: Float(point.x), y: Float(point.y), z: 1.0)
        let screenPosOnFarClippingPlane = unprojectPoint(positionVec)
        let rayDirection = simd_normalize(screenPosOnFarClippingPlane - cameraPos)
        return HitTestRay(origin: cameraPos, direction: rayDirection)
    }
    
    func hitTestWithInfiniteHorizontalPlane(_ point: CGPoint, _ pointOnPlane: float3) -> float3? {
        guard let ray = hitTestRayFromScreenPosition(point) else { return nil }
        if ray.direction.y > -0.03 {
            return nil
        }
        return ray.intersectionWithHorizontalPlane(atY: pointOnPlane.y)
    }
    
    func hitTestWithFeatures(_ point: CGPoint, coneOpeningAngleInDegrees: Float, minDistance: Float = 0, maxDistance: Float = Float.greatestFiniteMagnitude, maxResults: Int = 1) -> [FeatureHitTestResult] {
        guard let features = session.currentFrame?.rawFeaturePoints, let ray = hitTestRayFromScreenPosition(point) else {
            return []
        }
        let maxAngleInDegrees = min(coneOpeningAngleInDegrees, 360) / 2
        let maxAngle = (maxAngleInDegrees / 180) * .pi
        let results = features.points.compactMap { featurePosition -> FeatureHitTestResult? in
            let originToFeature = featurePosition - ray.origin
            let crossProduct = simd_cross(originToFeature, ray.direction)
            let featureDistanceFromResult = simd_length(crossProduct)
            let hitTestResult = ray.origin + (ray.direction * simd_dot(ray.direction, originToFeature))
            let hitTestResultDistance = simd_length(hitTestResult - ray.origin)
            
            if hitTestResultDistance < minDistance || hitTestResultDistance > maxDistance {
                return nil
            }
            let originToFeatureNormalized = simd_normalize(originToFeature)
            let angleBetweenRayAndFeature = acos(simd_dot(ray.direction, originToFeatureNormalized))
            if angleBetweenRayAndFeature > maxAngle {
                return nil
            }
            return FeatureHitTestResult(position: hitTestResult,
                                        distanceToRayOrigin: hitTestResultDistance,
                                        featureHit: featurePosition,
                                        featureDistanceToHitResult: featureDistanceFromResult)
        }
        let sortedResults = results.sorted { $0.distanceToRayOrigin < $1.distanceToRayOrigin }
        let remainingResults = sortedResults.dropFirst(maxResults)
        return Array(remainingResults)
    }
    
    func hitTestWithFeatures(_ point: CGPoint) -> [FeatureHitTestResult] {
        guard let features = session.currentFrame?.rawFeaturePoints,
            let ray = hitTestRayFromScreenPosition(point) else {
                return []
        }
        let possibleResults = features.points.map { featurePosition in
            return FeatureHitTestResult(featurePoint: featurePosition, ray: ray)
        }
        let closestResult = possibleResults.min(by: { $0.featureDistanceToHitResult < $1.featureDistanceToHitResult })!
        return [closestResult]
    }
    
}

extension SCNView {
    
    func unprojectPoint(_ point: float3) -> float3 {
        return float3(unprojectPoint(SCNVector3(point)))
    }
    
}

extension VirtualObjectARView.FeatureHitTestResult {
    
    init(featurePoint: float3, ray: VirtualObjectARView.HitTestRay) {
        self.featureHit = featurePoint
        let originToFeature = featurePoint - ray.origin
        self.position = ray.origin + (ray.direction * simd_dot(ray.direction, originToFeature))
        self.distanceToRayOrigin = simd_length(self.position - ray.origin)
        self.featureDistanceToHitResult = simd_length(simd_cross(originToFeature, ray.direction))
    }
    
}
