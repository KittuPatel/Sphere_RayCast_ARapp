//
//  ViewController.swift
//  RealityKitApp
//
//  Created by Krishna Mangalarapu on 7/22/23.
//

import UIKit
import RealityKit
import ARKit

class ViewController: UIViewController {
    
    // ARView is the view that renders the AR Scene.
    @IBOutlet var arView: ARView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Fire off plane detection
        startPlaneDetection()
        
        // 2. Get 2d point when tapped.
        arView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:))))
        
        
        
    }
    
    func startPlaneDetection() {
        
        arView.automaticallyConfigureSession = true
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        configuration.environmentTexturing = .automatic
        
        arView.session.run(configuration)
    }
    
    @objc
    func handleTap(recognizer: UITapGestureRecognizer) {
        // this function gets triggered when ever user taps on the screen.
        
        // 1. get the touch location.
        let tapLocation = recognizer.location(in: arView)
        
        // 2. a way to convert 2d point to 3d point in real world - raycasting
        let results = arView.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .horizontal)
        
        if let firstResult = results.first {
            
            // 3d point (x, y, z) coordinates
            let worldPosition = (firstResult.worldTransform.columns.3)
            let position3D = SIMD3<Float>(worldPosition.x, worldPosition.y, worldPosition.z)

            // createSphere
            let sphere = createSphere()
            
            // place sphere in world
             placeObject(object: sphere, at: position3D)
            
        }
        
    }
    
    func createSphere() -> ModelEntity {
        // Sphere ModelEntity
        let sphereMesh = MeshResource.generateSphere(radius: 0.05)
        let sphereMaterial = SimpleMaterial(color: .red, roughness: 0, isMetallic: true)
        
        
        let sphereEntity = ModelEntity(mesh: sphereMesh, materials: [sphereMaterial])
        return sphereEntity
    }
    
    func placeObject(object: ModelEntity, at location: SIMD3<Float>) {
        
        // create anchor entity = a hook in the real world.
        let objectAnchor = AnchorEntity(world: location)
        
        // tie model to anchor
        objectAnchor.addChild(object)
        
        // add anchor to scene
        arView.scene.addAnchor(objectAnchor)
    }
}
