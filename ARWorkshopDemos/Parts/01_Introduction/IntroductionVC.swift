//
//  IntroductionVC.swift
//  ARWorkshopDemos
//
//  Created by Tien Le P. on 12/7/18.
//  Copyright © 2018 Tien Le P. All rights reserved.
//

import UIKit
import ARKit
import WebKit

class IntroductionVC: BaseViewController {
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    var stepDemo = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Introduction"
        addText()
        addTapGestureToSceneView()
    }
    
    //MARK: - Setup ARKit Screen
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    //MARK: - Add box play
    func addPlayBox() {
        let box = SCNBox(width: 0.1, height: 0.05, length: 0.02, chamferRadius: 0.2)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "img_play_button")
        let material2 = SCNMaterial()
        material2.diffuse.contents = UIColor.red
        //add to box
        box.materials = [material,material2,material,material2,material2,material2]
        
        let boxNode = SCNNode()
        boxNode.geometry = box
        boxNode.position = SCNVector3(0, 0, -0.2)
        boxNode.name = "Step2"
        
        sceneView.scene.rootNode.addChildNode(boxNode)
    }
    
    //MARK: - Add Text on screen
    func addText() {
        let textNode = self.createTextNode(string: "Hello ARkit")
        textNode.name = "Step1"
        textNode.position = SCNVector3(-0.1, 0, -0.3)
        sceneView.scene.rootNode.addChildNode(textNode)
    }
    
    func createTextNode(string: String) -> SCNNode {
        let text = SCNText(string: string, extrusionDepth: 0.1)
        text.font = UIFont.systemFont(ofSize: 1.0)
        text.flatness = 0.01
        text.firstMaterial?.diffuse.contents = UIColor.cyan
        
        let textNode = SCNNode(geometry: text)
        
        let fontSize = Float(0.04)
        textNode.scale = SCNVector3(fontSize, fontSize, fontSize)
        
        return textNode
    }
    
    //MARK: - Add Video Node
    func addVideoNode() {
        guard let currentFrame = self.sceneView.session.currentFrame else {
            return
        }
        
        let videoNode = SKVideoNode(fileNamed: "vr_and_ar_tinhte.mp4")
        videoNode.play()
        
        let skScene = SKScene(size: CGSize(width: 640, height: 480))
        skScene.addChild(videoNode)
        
        videoNode.position = CGPoint(x: skScene.size.width/2, y: skScene.size.height/2)
        videoNode.size = skScene.size
        
        let tvPlane = SCNPlane(width: 1.0, height: 0.75)
        tvPlane.firstMaterial?.diffuse.contents = skScene
        tvPlane.firstMaterial?.isDoubleSided = true
        
        let tvPlaneNode = SCNNode(geometry: tvPlane)
        
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -1.0
        
        tvPlaneNode.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
        tvPlaneNode.eulerAngles = SCNVector3(Double.pi,0,0)
        
        tvPlaneNode.name = "Step3"
        self.sceneView.scene.rootNode.addChildNode(tvPlaneNode)
    }
    
    //MAKR: - gesture
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(IntroductionVC.didTap(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    
    @objc func didTap(withGestureRecognizer recognizer: UIGestureRecognizer) {
        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation)
        guard let node = hitTestResults.first?.node else {
            return
        }

        print(node.name ?? "No value")
        node.removeFromParentNode()
        
        if stepDemo == 1 {
            addPlayBox()
            stepDemo += 1
        } else if stepDemo == 2 {
            addVideoNode()
            stepDemo += 1
        }
       
    }
    
}
