//
//  SolarSystemViewController.swift
//  ARWorkshopDemos
//
//  Created by MBA0231P on 1/14/19.
//  Copyright © 2019 Tien Le P. All rights reserved.
//

import UIKit
import ARKit

final class SolarSystemViewController: UIViewController {
    
    @IBOutlet weak var addObjectButton: UIButton!
    @IBOutlet weak var sceneView: VirtualObjectARView!
    @IBOutlet weak var statusView: StatusView!
    
    var focusSquare = FocusSquare()
    lazy var virtualObjectInteraction = VirtualObjectInteraction(sceneView: sceneView)
    lazy var isObjectVisible = false
    lazy var sunNode = initSunNode()
    
    var isRestartAvailable = true
    let updateQueue = DispatchQueue(label: "com.fx.ARWorkshopDemos")
    var screenCenter: CGPoint {
        let bounds = sceneView.bounds
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    var session: ARSession {
        return sceneView.session
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSceneView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func initSceneView() {
        sceneView.delegate = self
        sceneView.showsStatistics = true
        setupCamera()
        sceneView.scene.rootNode.addChildNode(focusSquare)
        sceneView.automaticallyUpdatesLighting = false
        sceneView.automaticallyUpdatesLighting = false
        if let environmentMap = UIImage(named: "Resources/environment_blur.exr") {
            sceneView.scene.lightingEnvironment.contents = environmentMap
        }
        statusView.restartExperienceHandler = { [unowned self] in
            self.restartExperience()
        }
        addObjectButton.addTarget(self, action: #selector(initPlanetNode), for: .touchUpInside)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(initPlanetNode))
        tapGesture.delegate = self
        sceneView.addGestureRecognizer(tapGesture)
    }
    
    @objc func initPlanetNode() {
        guard !isObjectVisible else { return }
        isObjectVisible = true
        addObjectButton.isHidden = true
        guard let cameraTransform = session.currentFrame?.camera.transform,
            let focusSquarePosition = focusSquare.lastPosition else {
                statusView.showMessage("CANNOT PLACE OBJECT\nTry moving left or right.")
                return
        }
        virtualObjectInteraction.selectedObject = sunNode
        sunNode.setPosition(focusSquarePosition, relativeTo: cameraTransform, smoothMovement: false)
        updateQueue.async {
            self.sceneView.scene.rootNode.addChildNode(self.sunNode)
        }
    }
    
    func initSunNode() -> PlanetNode {
        let sunNode = PlanetNode(planet: .sun)
        let earthNode = PlanetNode(planet: .earth)
        sunNode.addPlanet(planet: .mercury)
        sunNode.addPlanet(planet: .venus)
        sunNode.addPlanet(planet: .mars)
        sunNode.addPlanet(planet: .jupiter)
        sunNode.addPlanet(planet: .saturn)
        sunNode.addPlanet(planet: .uranus)
        sunNode.addPlanet(planet: .neptune)
        sunNode.addPlanet(planet: .pluto)
        earthNode.addPlanet(planet: .moon)
        sunNode.addPlanet(planetNode: earthNode)
        return sunNode
    }
    
    func setupCamera() {
        guard let camera = sceneView.pointOfView?.camera else {
            fatalError("Expected a valid `pointOfView` from the scene.")
        }
        camera.wantsHDR = true
        camera.exposureOffset = -1
        camera.minimumExposure = -1
        camera.maximumExposure = 3
    }
    
    func resetTracking() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        statusView.scheduleMessage("FIND A SURFACE TO PLACE AN OBJECT", inSeconds: 7.5, messageType: .planeEstimation)
    }
    
    func updateFocusSquare() {
        if isObjectVisible {
            focusSquare.hide()
        } else {
            focusSquare.unhide()
            statusView.scheduleMessage("TRY MOVING LEFT OR RIGHT", inSeconds: 5.0, messageType: .focusSquare)
        }
        guard let (worldPosition, planeAnchor, _) = sceneView.worldPosition(fromScreenPosition: screenCenter, objectPosition: focusSquare.lastPosition) else {
            updateQueue.async {
                self.focusSquare.state = .initializing
                self.sceneView.pointOfView?.addChildNode(self.focusSquare)
            }
            addObjectButton.isHidden = true
            return
        }
        
        updateQueue.async {
            self.sceneView.scene.rootNode.addChildNode(self.focusSquare)
            let camera = self.session.currentFrame?.camera
            
            if let planeAnchor = planeAnchor {
                self.focusSquare.state = .planeDetected(anchorPosition: worldPosition, planeAnchor: planeAnchor, camera: camera)
            } else {
                self.focusSquare.state = .featuresDetected(anchorPosition: worldPosition, camera: camera)
            }
        }
        addObjectButton.isHidden = false
        statusView.cancelScheduledMessage(for: .focusSquare)
    }
    
    func restartExperience() {
        guard isRestartAvailable else { return }
        isRestartAvailable = false
        isObjectVisible = false
        statusView.cancelAllScheduledMessages()
        self.sunNode.removeFromParentNode()
        self.sunNode.reset()
        addObjectButton.isHidden = false
        addObjectButton.setImage(#imageLiteral(resourceName: "add"), for: [])
        addObjectButton.setImage(#imageLiteral(resourceName: "addPressed"), for: [.highlighted])
        resetTracking()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.isRestartAvailable = true
        }
    }
    
    func displayErrorMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
            self.resetTracking()
        }
        alertController.addAction(restartAction)
        present(alertController, animated: true, completion: nil)
    }
    
}

extension SolarSystemViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool {
        return !self.isObjectVisible
    }
    
    func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool {
        return true
    }
    
}

extension SolarSystemViewController: ARSCNViewDelegate, ARSessionDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.virtualObjectInteraction.updateObjectToCurrentTrackingPosition()
            self.updateFocusSquare()
        }
        let baseIntensity: CGFloat = 40
        let lightingEnvironment = sceneView.scene.lightingEnvironment
        if let lightEstimate = session.currentFrame?.lightEstimate {
            lightingEnvironment.intensity = lightEstimate.ambientIntensity / baseIntensity
        } else {
            lightingEnvironment.intensity = baseIntensity
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        DispatchQueue.main.async {
            self.statusView.cancelScheduledMessage(for: .planeEstimation)
            self.statusView.showMessage("SURFACE DETECTED")
            if !self.isObjectVisible {
                self.statusView.scheduleMessage("TAP + TO PLACE AN OBJECT", inSeconds: 7.5, messageType: .contentPlacement)
            }
        }
        updateQueue.async {
            if self.isObjectVisible { self.sunNode.adjustOntoPlaneAnchor(planeAnchor, using: node) }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        updateQueue.async {
            if self.isObjectVisible { self.sunNode.adjustOntoPlaneAnchor(planeAnchor, using: node) }
        }
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        statusView.showTrackingQualityInfo(for: camera.trackingState, autoHide: true)
        switch camera.trackingState {
        case .notAvailable, .limited:
            statusView.escalateFeedback(for: camera.trackingState, inSeconds: 3.0)
        case .normal:
            statusView.cancelScheduledMessage(for: .trackingStateEscalation)
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        guard error is ARError else { return }
        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")
        DispatchQueue.main.async {
            self.displayErrorMessage(title: "The AR session failed.", message: errorMessage)
        }
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        statusView.showMessage("""
        SESSION INTERRUPTED
        The session will be reset after the interruption has ended.
        """, autoHide: false)
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        statusView.showMessage("RESETTING SESSION")
        restartExperience()
    }
    
}
