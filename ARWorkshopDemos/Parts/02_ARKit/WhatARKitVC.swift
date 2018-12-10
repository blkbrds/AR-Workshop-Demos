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
        //let camera = container.childNode(withName: "camera", recursively: true)!
        container.position = SCNVector3(0, 0, -0.5)
    }


}
