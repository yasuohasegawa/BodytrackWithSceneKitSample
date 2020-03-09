//
//  ViewController.swift
//  MotionCaptureTest
//
//  Created by Yasuo Hasegawa on 2020/03/09.
//  Copyright © 2020 Yasuo Hasegawa. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet var sceneView: ARSCNView!
    private var sphereNodes:[SCNNode] = []
    private var jointNames:[ARSkeleton.JointName] = [ARSkeleton.JointName.head,ARSkeleton.JointName.leftFoot,ARSkeleton.JointName.rightFoot,ARSkeleton.JointName.rightHand,ARSkeleton.JointName.leftHand,ARSkeleton.JointName.leftShoulder,ARSkeleton.JointName.rightShoulder]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARBodyTrackingConfiguration()
        configuration.environmentTexturing = .automatic

        guard ARBodyTrackingConfiguration.isSupported else {
            fatalError("This feature is only supported on devices with an A12 chip")
        }
        
        print("supported")
        
        // Run the view's session
        sceneView.session.run(configuration)
        sceneView.session.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        // Present an error message to the user

        for anchor in anchors {
            guard let bodyAnchor = anchor as? ARBodyAnchor else { continue }
             
            let bodyPosition = simd_make_float3(bodyAnchor.transform.columns.3)
            if(sphereNodes.count != 0){
                for  i in 0..<jointNames.count {
                    if let transform = bodyAnchor.skeleton.modelTransform(for: jointNames[i]) {
                        let position = bodyPosition + simd_make_float3(transform.columns.3)
                        sphereNodes[i].position = SCNVector3(position.x, position.y, position.z)
                    }
                }
            } else {
                //joints
                for  i in 0..<jointNames.count {
                    if let transform = bodyAnchor.skeleton.modelTransform(for: jointNames[i]) {
                        let position = bodyPosition + simd_make_float3(transform.columns.3)
                        let sphereNode = SCNNode(geometry: SCNSphere(radius: 0.1))
                        sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
                        sphereNode.geometry?.firstMaterial?.metalness.intensity = 1.0
                        sphereNode.position = SCNVector3(position.x, position.y, position.z)
                        self.sceneView.scene.rootNode.addChildNode(sphereNode)
                        sphereNodes.append(sphereNode)
                    }
                }
            
            }
        }
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
