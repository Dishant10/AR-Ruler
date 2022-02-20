//
//  ViewController.swift
//  AR Ruler
//
//  Created by Dishant Nagpal on 18/02/22.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate { 
    
    @IBOutlet var sceneView: ARSCNView!
    
    var dotNodes=[SCNNode]()
    var textNode=SCNNode()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
//        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if dotNodes.count>=2{
            for dot in dotNodes{
                dot.removeFromParentNode()
            }
            dotNodes=[SCNNode]()
        }
        textNode.removeFromParentNode()
        if let touch = touches.first{
            let touchLocation = touch.location(in: sceneView)
            guard let query = sceneView.raycastQuery(from: touchLocation, allowing: .estimatedPlane, alignment: .any)else {
                print("Error quering.")
                return
            }
            let result=sceneView.session.raycast(query)
            if let hitResult=result.first{
                addDot(at:hitResult)
            }
        }
    }
    
    func addDot(at location:ARRaycastResult){
        let dot = SCNSphere(radius: 0.003)
        let dotMaterials=SCNMaterial()
        dotMaterials.diffuse.contents=UIColor.red
        dot.materials=[dotMaterials]
        let dotNode = SCNNode()
        dotNode.geometry = dot
        dotNode.position=SCNVector3(location.worldTransform.columns.3.x, location.worldTransform.columns.3.y, location.worldTransform.columns.3.z)
        sceneView.scene.rootNode.addChildNode(dotNode)
        
        dotNodes.append(dotNode)
        
        if dotNodes.count>=2{
            calculate()
        }
    }
    
    
    func calculate(){
        let start=dotNodes[0]
        let end=dotNodes[1]
        
        let distance = sqrt(pow(end.position.x-start.position.x, 2) +
                            pow(end.position.y-start.position.y, 2) +
                            pow(end.position.z-start.position.z, 2)
        )
        updateText("\(String(format: "%.2f", distance * 100)) cm",atPosition: end.position)
        
    }
    
    func updateText(_ distance:String,atPosition position:SCNVector3){
        
        let textGeometry=SCNText(string: distance, extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents=UIColor.white
        textNode=SCNNode(geometry: textGeometry)
        textNode.position=SCNVector3((position.x)/2.5,(position.y)/2,(position.z)/2)
        textNode.scale=SCNVector3(0.001, 0.001, 0.001)
        sceneView.scene.rootNode.addChildNode(textNode)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
}
