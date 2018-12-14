//
//  GraphicsVC.swift
//  ARWorkshopDemos
//
//  Created by Tien Le P. on 12/14/18.
//  Copyright © 2018 Tien Le P. All rights reserved.
//

import UIKit
import ARKit

class GraphicsVC: BaseViewController {
    
    @IBOutlet weak var sceneView: ARSCNView!
    var containerNode: SCNNode!
    var mario2DNode: SCNNode!
    var mario3DNode: SCNNode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadScence()
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
    
    //MARK: - Load scene
    func loadScence() {
        let gameScene = SCNScene(named: "Assets.scnassets/mariosScene.scn")!
        sceneView.scene = gameScene
        containerNode = gameScene.rootNode.childNode(withName: "container", recursively: true)!
        mario2DNode = containerNode.childNode(withName: "mario2D", recursively: true)!
        mario3DNode = containerNode.childNode(withName: "mario3D", recursively: true)!
        
        containerNode.position = SCNVector3(0, 0, -1)
        
        //add action
        let action = SCNAction.rotate(by: 360 * CGFloat((Double.pi)/180), around: SCNVector3(x:0, y:1, z:0), duration: 8)
        let repeatAction = SCNAction.repeatForever(action)
        mario2DNode.runAction(repeatAction)
        mario3DNode.runAction(repeatAction)
    }
}
