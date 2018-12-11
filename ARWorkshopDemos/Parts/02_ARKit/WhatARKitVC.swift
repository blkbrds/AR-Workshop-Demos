//
//  WhatARKitVC.swift
//  ARWorkshopDemos
//
//  Created by Tien Le P. on 12/10/18.
//  Copyright © 2018 Tien Le P. All rights reserved.
//

import UIKit
import ARKit

class WhatARKitVC: BaseViewController {
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    var cameraNode: SCNNode!
    var chipComputerNode: SCNNode!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCamera()
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
    
    //MARK: - Load camera 3D
    func loadCamera() {
        let gameScene = SCNScene(named: "Assets.scnassets/cameraScene.scn")!
        sceneView.scene = gameScene
        let container = gameScene.rootNode.childNode(withName: "container", recursively: false)!
        cameraNode = container.childNode(withName: "camera", recursively: true)!
        chipComputerNode = container.childNode(withName: "chipComputer", recursively: true)!

        container.position = SCNVector3(0, 0, -0.5)
        
        //add action
        let action = SCNAction.rotate(by: 360 * CGFloat((Double.pi)/180), around: SCNVector3(x:0, y:1, z:0), duration: 8)
        let repeatAction = SCNAction.repeatForever(action)
        cameraNode.runAction(repeatAction)
        chipComputerNode.runAction(repeatAction)
    }


}
