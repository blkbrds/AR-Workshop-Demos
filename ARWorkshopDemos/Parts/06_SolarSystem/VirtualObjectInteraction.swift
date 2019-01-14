//
//  VirtualObjectInteraction.swift
//  ARWorkshopDemos
//
//  Created by MBA0231P on 1/14/19.
//  Copyright © 2019 Tien Le P. All rights reserved.
//

import Foundation
import ARKit

final class VirtualObjectInteraction: NSObject, UIGestureRecognizerDelegate {
    
    let translateAssumingInfinitePlane = true
    let sceneView: VirtualObjectARView
    var selectedObject: PlanetNode?
    private var trackedObject: PlanetNode? {
        didSet {
            guard trackedObject != nil else { return }
            selectedObject = trackedObject
        }
    }
    private var currentTrackingPosition: CGPoint?
    
    init(sceneView: VirtualObjectARView) {
        self.sceneView = sceneView
        super.init()
        let panGesture = ThresholdPanGesture(target: self, action: #selector(didPan(_:)))
        panGesture.delegate = self
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(didRotate(_:)))
        rotationGesture.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        sceneView.addGestureRecognizer(panGesture)
        sceneView.addGestureRecognizer(rotationGesture)
        sceneView.addGestureRecognizer(tapGesture)
    }
    
    @objc func didPan(_ gesture: ThresholdPanGesture) {
        switch gesture.state {
        case .began:
            if let object = objectInteracting(with: gesture, in: sceneView) {
                trackedObject = object
            }
        case .changed where gesture.isThresholdExceeded:
            guard let object = trackedObject else { return }
            let translation = gesture.translation(in: sceneView)
            let currentPosition = currentTrackingPosition ?? CGPoint(sceneView.projectPoint(object.position))
            currentTrackingPosition = CGPoint(x: currentPosition.x + translation.x, y: currentPosition.y + translation.y)
            gesture.setTranslation(.zero, in: sceneView)
        case .changed:
            break
        default:
            currentTrackingPosition = nil
            trackedObject = nil
        }
    }
    
    @objc func updateObjectToCurrentTrackingPosition() {
        guard let object = trackedObject, let position = currentTrackingPosition else { return }
        translate(object, basedOn: position, infinitePlane: translateAssumingInfinitePlane)
    }
    
    @objc func didRotate(_ gesture: UIRotationGestureRecognizer) {
        guard gesture.state == .changed else { return }
        trackedObject?.eulerAngles.y -= Float(gesture.rotation)
        gesture.rotation = 0
    }
    
    @objc func didTap(_ gesture: UITapGestureRecognizer) {
        let touchLocation = gesture.location(in: sceneView)
        if let tappedObject = sceneView.virtualObject(at: touchLocation) {
            selectedObject = tappedObject
        } else if let object = selectedObject {
            translate(object, basedOn: touchLocation, infinitePlane: false)
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    private func objectInteracting(with gesture: UIGestureRecognizer, in view: ARSCNView) -> PlanetNode? {
        for index in 0..<gesture.numberOfTouches {
            let touchLocation = gesture.location(ofTouch: index, in: view)
            if let object = sceneView.virtualObject(at: touchLocation) {
                return object
            }
        }
        return sceneView.virtualObject(at: gesture.center(in: view))
    }
    
    private func translate(_ object: PlanetNode, basedOn screenPos: CGPoint, infinitePlane: Bool) {
        guard let cameraTransform = sceneView.session.currentFrame?.camera.transform,
            let (position, _, isOnPlane) = sceneView.worldPosition(fromScreenPosition: screenPos,
                                                                   objectPosition: object.simdPosition,
                                                                   infinitePlane: infinitePlane) else { return }
        object.setPosition(position, relativeTo: cameraTransform, smoothMovement: !isOnPlane)
    }
    
}

extension UIGestureRecognizer {
    
    func center(in view: UIView) -> CGPoint {
        let first = CGRect(origin: location(ofTouch: 0, in: view), size: .zero)
        let touchBounds = (1..<numberOfTouches).reduce(first) { touchBounds, index in
            return touchBounds.union(CGRect(origin: location(ofTouch: index, in: view), size: .zero))
        }
        return CGPoint(x: touchBounds.midX, y: touchBounds.midY)
    }
    
}
