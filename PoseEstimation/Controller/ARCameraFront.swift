//
//  ARCamera.swift
//  PoseEstimation
//
//  Created by Sanket Lothe on 29/01/24.
//  Copyright © 2024 tensorflow. All rights reserved.
//

/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Displays the 3D face mesh geometry provided by ARKit, with a static texture.
*/

import ARKit
import SceneKit
import RealityKit
import UIKit
import os


@available(iOS 13.0, *)
class TexturedFace: UIViewController, ARSessionDelegate, ARSCNViewDelegate{

    
    var count = 0
    var contentNode: SCNNode?
    var arraypoints:[CGPoint] = []
    let generalPoints = [""]
//    var viewcontrollerObj = ViewController()
    @IBOutlet weak var sceneview: ARSCNView!
    
//    @IBOutlet weak var sceneView: ARSCNView!
    
//    @IBOutlet weak var annotationOverlayview: OverlayView!
    @IBOutlet weak var annotationOverlayview: OverlayView!
    
//    private lazy var annotationOverlayView: UIView = {
//          precondition(isViewLoaded)
//          let annotationOverlayView = UIView(frame: .zero)
//          annotationOverlayView.translatesAutoresizingMaskIntoConstraints = false
//          annotationOverlayView.clipsToBounds = true
//          return annotationOverlayView
//        }()
    
    var pixelBuffer: CMSampleBuffer??
    
    var instance: TexturedFace?
    
    private var poseEstimator: PoseEstimator?
    let queue = DispatchQueue(label: "serial_queue")
    var isRunning = false
    
    private var modelType: ModelType = Constants.defaultModelType
    private var threadCount: Int = Constants.defaultThreadCount
    private var delegate: Delegates = Constants.defaultDelegate
    
    var distance = Float()
    var PointsArray: [CGPoint] = []
    var trainingmodeObj = TrainingModeController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneview.delegate = self
        sceneview.session.delegate = self
        sceneview.automaticallyUpdatesLighting = true
       
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // AR experiences typically involve moving the device without
        // touch input for some time, so prevent auto screen dimming.
        UIApplication.shared.isIdleTimerDisabled = true
        
        // "Reset" to run the AR session for the first time.
        resetTracking()
        updateModel()
    }
    
    
    @IBAction func generalModeBtn(_ sender: Any) {
       
        
        annotationOverlayview.myArray = [.pointV1,.pointV4,.pointV2,.pointV3]
//
    }
    
    @IBAction func pulmonaryModeBtn(_ sender: Any) {
        
        annotationOverlayview.myArray = [.pointB1,.pointB2,.pointB3,.pointB4]
//
    }
    
    
    @IBAction func cardiacModeBtn(_ sender: Any) {
        
        annotationOverlayview.myArray = [.pointY1,.pointY2,.pointY3,.pointY4]
    }
    
    
    
    @IBAction func trainingModeBtn(_ sender: Any) {
        
        for subViews in view.subviews {
            
            if ((subViews as? UIButton) != nil) {
                subViews.isHidden = true
            }
            
            if ((subViews as? UIStackView) != nil) {
                subViews.isHidden = true
            }
            
        }
        let childVC = TrainingModeController.loadViewController(withStoryBoard: "Main")
            view.addSubview(childVC.view)
        
        annotationOverlayview.myArray = [.pointV1,.pointV4,.pointV2,.pointV3, .pointA1, .pointA2, .pointA3, .pointA4]
        
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        count+=1
        if count % 5 != 0
        {
            return
        }
//        if let capturedImage = frame.capturedImage
//        {
            if let uiImage = UIImage(ciImage: CIImage(cvPixelBuffer: frame.capturedImage)).rotate(radians: .pi/2),
               let pixelBuffer = uiImage.pixelBuffer()
            {
                removeDetectionpoints()
                
//                if distance > 1.2 {
                    self.runModel(pixelBuffer)
//                }
//                else {
//                    if annotationOverlayview
//                    annotationOverlayview.removeFromSuperview()
//                }
                print("pixelBuffer size",pixelBuffer.size.width,pixelBuffer.size.height)
            }
            
//        }
//        let transform = (frame.displayTransform(for: interfaceOrientation, viewportSize: sceneView.frame.size))
//        let array = getPointsArray(person: Person)
//        print("array", array)
//        print("PointsArray",PointsArray,pixelBuffer)
//        addPoints(PointsArray,transform)
   
    }
    
    func getPointsArray(person: Person) -> [CGPoint] {
        
       
        for body in person.keyPoints {
            
            print("Body", body.bodyPart)
//            if body.bodyPart == BodyPart. {
           
                let a = CGPoint(x: body.coordinate.y/1440,y: body.coordinate.x/1080)
                arraypoints.append(a)
//            }
            
        }
        
        
        
        return arraypoints
         
    }
    
    func resetTracking() {
        guard ARFaceTrackingConfiguration.isSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        if #available(iOS 13.0, *) {
            configuration.maximumNumberOfTrackedFaces = ARFaceTrackingConfiguration.supportedNumberOfTrackedFaces
        }
        configuration.isLightEstimationEnabled = true
        sceneview.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        
    }
    /// - Tag: CreateARSCNFaceGeometry
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let sceneview = renderer as? ARSCNView,
            anchor is ARFaceAnchor else { return nil }
        
//        #if targetEnvironment(simulator)
//        #error("ARKit is not supported in iOS Simulator. Connect a physical iOS device and select it as your Xcode run destination, or select Generic iOS Device as a build-only destination.")
//        #else
        let faceGeometry = ARSCNFaceGeometry(device: sceneview.device!)!
        let material = faceGeometry.firstMaterial!
        
        material.diffuse.contents = UIColor.clear // Example texture map image.
//        material.lightingModel = .physicallyBased
        
        contentNode = SCNNode(geometry: faceGeometry)
//        #endif
        return contentNode
    }
    
    /// - Tag: ARFaceGeometryUpdate
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceGeometry = node.geometry as? ARSCNFaceGeometry,
            let faceAnchor = anchor as? ARFaceAnchor
            else { return }
        
        faceGeometry.update(from: faceAnchor.geometry)
//        var center = SCNVector3(faceAnchor.)
//        let leftEyePosition = faceAnchor.leftEyeTransform
        let leftEyePosition = SCNVector3(
            faceAnchor.leftEyeTransform.columns.3.x + faceAnchor.transform.columns.3.x,
            faceAnchor.leftEyeTransform.columns.3.y + faceAnchor.transform.columns.3.y,
            faceAnchor.leftEyeTransform.columns.3.z + faceAnchor.transform.columns.3.z)
//        ViewController.instance?.addAnchor(position: leftEyePosition)
//        faceAnchor.geometry.vertices
      
       distance = abs(leftEyePosition.z)
        print("leftEyePosition",distance)
    }
    
    private func updateModel() {
      // Update the model in the same serial queue with the inference logic to avoid race condition
      queue.async {
        do {
          switch self.modelType {
          case .posenet: break
  //          self.poseEstimator = try PoseNet(
  //            threadCount: self.threadCount,
  //            delegate: self.delegate)
          case .movenetLighting, .movenetThunder:
            self.poseEstimator = try MoveNet(
              threadCount: self.threadCount,
              delegate: self.delegate,
              modelType: self.modelType)
          }
        } catch let error {
          os_log("Error: %@", log: .default, type: .error, String(describing: error))
        }
      }
    }
    func addPoints(_ arrayOfJoints:[CGPoint],_ transform:CGAffineTransform)
        {
            let pointsPath = UIBezierPath()
            guard let interfaceOrientation = sceneview.window?.windowScene?.interfaceOrientation else { return }
            for i in 0..<arrayOfJoints.count
            {
                
                var normalizedCenter = CGPoint(x: CGFloat(arrayOfJoints[i].x), y: CGFloat(CGFloat(arrayOfJoints[i].y))).applying(transform)
                //                let normalizedCenter2 = CGPoint(x: CGFloat(arrayOfJoints[i-1][0]), y: CGFloat(arrayOfJoints[i-1][1])).applying(transform)
                let center = normalizedCenter.applying(CGAffineTransform.identity.scaledBy(x: sceneview.frame.width, y: sceneview.frame.height))
                
                let circleWidth: CGFloat = 10
                let circleHeight: CGFloat = 10
                let rect = CGRect(origin: CGPoint(x: center.x - circleWidth/2, y: center.y - circleHeight/2), size: CGSize(width: circleWidth, height: circleHeight))
                
                
                var circleLayer = CAShapeLayer()
                
                if (i>=arrayOfJoints.count-4){
                    //                    print("")
                    print("arrayOfJoint",i,arrayOfJoints[i])
                    circleLayer.fillColor = .init(srgbRed: 255, green: 255, blue: 0, alpha: 1.0)
                }else if i >= (arrayOfJoints.count-8) {
                    circleLayer.fillColor = .init(srgbRed: 0, green: 0, blue: 255, alpha: 1.0)
                }
                else if  i >= (arrayOfJoints.count-12)
                {
                    circleLayer.fillColor = .init(srgbRed: 255, green: 0, blue: 0, alpha: 1.0)
                    
                }
                circleLayer.path = UIBezierPath(ovalIn: rect).cgPath
                
                pointsPath.move(to: normalizedCenter)
                normalizedCenter.x+=0.5
                normalizedCenter.y+=0.5
                
                pointsPath.addArc(withCenter: normalizedCenter, radius: 5, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
                //                pointsPath.addLine(to: normalizedCenter2)
                //                circleLayer.path = pointsPath.cgPath
                annotationOverlayview.layer.addSublayer(circleLayer)
                
               
     
            }
            sceneview.addSubview(annotationOverlayview)
            
            NSLayoutConstraint.activate([
                annotationOverlayview.topAnchor.constraint(equalTo: sceneview.topAnchor),
                annotationOverlayview.leadingAnchor.constraint(equalTo: sceneview.leadingAnchor),
                annotationOverlayview.trailingAnchor.constraint(equalTo: sceneview.trailingAnchor),
                annotationOverlayview.bottomAnchor.constraint(equalTo: sceneview.bottomAnchor),
            ])
        }
    
    private func removeDetectionpoints() {
        
//            annotationOverlayview.layer.sublayers = nil
        }
    
    private func runModel(_ pixelBuffer: CVPixelBuffer) -> [CGPoint] {
        
        var arrOfPoints:[CGPoint] = []
    
            
           
            // Guard to make sure that there's only 1 frame process at each moment.
            guard !isRunning else { return [] }
        
        // Guard to make sure that the pose estimator is already initialized.
        guard let estimator = poseEstimator else {
            return [] }
        
        // Run inference on a serial queue to avoid race condition.
        queue.async { [self] in
            self.isRunning = true
            defer { self.isRunning = false }
            
            // Run pose estimation
            do {
                let (result, times) = try estimator.estimateSinglePose(
                    on: pixelBuffer)
                
                arrOfPoints = getPointsArray(person: result)
                PointsArray = arrOfPoints
                print("result is",PointsArray)
                // Return to main thread to show detection results on the app UI.
                DispatchQueue.main.async { [self] in
                    //            self.totalTimeLabel.text = String(format: "%.2fms",
                    //                                              times.total * 1000)
                    //            self.scoreLabel.text = String(format: "%.3f", result.score)
                    
                    // Allowed to set image and overlay
                    let image = UIImage(ciImage: CIImage(cvPixelBuffer: pixelBuffer))
                    
                    // If score is too low, clear result remaining in the overlayView.
                    if result.score < 0.2 {
                        //              self.overlayView.image = image
                        //              return
                    }
                    
                    // Visualize the pose estimation result.
                    //                if distance > 0.5 {
                    if distance > 0.2 {
                        self.annotationOverlayview.draw(at: image, person: result)
                    }
                    else {
                        annotationOverlayview.image = image
                    }
                }
            } catch {
                os_log("Error running pose estimation.", type: .error)
                return
            }
        }
        return arrOfPoints
    }

    
}

    



