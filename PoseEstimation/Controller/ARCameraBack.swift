//
//  ARCameraBack.swift
//  PoseEstimation
//
//  Created by Sanket Lothe on 05/02/24.
//  Copyright © 2024 tensorflow. All rights reserved.
//

import UIKit
import RealityKit
import ARKit
import Combine
class ARCameraBack: UIViewController, ARSessionDelegate {

    @IBOutlet weak var arView: ARView!
   
    @IBOutlet weak var locatePointsButton: UIButton!
    
    var lidarPresent = false
    private lazy var annotationOverlayView: UIView = {
      precondition(isViewLoaded)
      let annotationOverlayView = UIView(frame: .zero)
      annotationOverlayView.translatesAutoresizingMaskIntoConstraints = false
      annotationOverlayView.clipsToBounds = true
      return annotationOverlayView
    }()
    
    var anchorEntity = AnchorEntity()
    var frameCount = 0
    var drawPoints = false
    var exit = false
    var locatePoints:Bool = false
    var generalMode = false
    var pulmonaryMode = false
    var cardiacMode = false
    var arrayOfJoints : [simd_float2] = [[0,0]]
    var sphere1 = ModelEntity(mesh: .generateSphere(radius: 0.01))
    var sphere2 = ModelEntity(mesh: .generateSphere(radius: 0.01))
    var sphere3 = ModelEntity(mesh: .generateSphere(radius: 0.01))
    var sphere4 = ModelEntity(mesh: .generateSphere(radius: 0.01))
    var sphere5 = ModelEntity(mesh: .generateSphere(radius: 0.01))
    var sphere6 = ModelEntity(mesh: .generateSphere(radius: 0.01))
    var sphere7 = ModelEntity(mesh: .generateSphere(radius: 0.01))
    var sphere8 = ModelEntity(mesh: .generateSphere(radius: 0.01))
    var sphere9 = ModelEntity(mesh: .generateSphere(radius: 0.01))
    var sphere10 = ModelEntity(mesh: .generateSphere(radius: 0.01))
    var sphere11 = ModelEntity(mesh: .generateSphere(radius: 0.01))
    var sphere12 = ModelEntity(mesh: .generateSphere(radius: 0.01))
    var sphere13 = ModelEntity(mesh: .generateSphere(radius: 0.01))

    var dotNodes = [SCNNode]()

    var V1 = simd_float3(0,0,0)
    var V2 = simd_float3(0,0,0)
    var V3 = simd_float3(0,0,0)
    var V4 = simd_float3(0,0,0)
    
    
    @IBAction func locatePoints(_ sender: Any) {
        if locatePoints
        {
            locatePoints = false
            locatePointsButton.setTitle("Locate Points", for: .normal)
        }
        else
        {
            
            locatePoints = true
            locatePointsButton.setTitle("Detect Again", for: .normal)

        }
        
    }
    
    @IBAction func generalModeBtn(_ sender: Any) {
        generalMode = true
        cardiacMode = false
        pulmonaryMode = false
        
    }
    
    @IBAction func pulmonaryModeBtn(_ sender: Any) {
        generalMode = false
        cardiacMode = false
        pulmonaryMode = true
    }
    
    @IBAction func cardiacModeBtn(_ sender: Any) {
        generalMode = false
        cardiacMode = true
        pulmonaryMode = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        arView.session.delegate = self
        guard ARBodyTrackingConfiguration.isSupported else {
            fatalError("This feature is only supported on devices with an A12 chip")
        }
        // Run a body tracking configration.
        let configuration = ARBodyTrackingConfiguration()
//        configuration.frameSemantics = .sceneDepth
        configuration.isAutoFocusEnabled = true

        arView.session.run(configuration)
        arView.scene.addAnchor(anchorEntity)
        // Do any additional setup after loading the view.
        let supportLiDAR = ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh)
        if supportLiDAR {
            lidarPresent = true
        }

//        DispatchQueue.main.async {
//            self.hideLoader()
//        }
         
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
   
    func cropImage(image: UIImage) -> UIImage? {
        let originalSize = image.size
        let cropRect = CGRect(x: 180, y: 0, width: originalSize.width - 360, height: originalSize.height)
        guard let cgImage = image.cgImage?.cropping(to: cropRect) else {
            return image
        }
        return UIImage(cgImage: cgImage)
    }
    
    private func removeDetectionpoints() {

        annotationOverlayView.layer.sublayers = nil
    }
    
    

    func addNewPoint(point:CGPoint,node:inout ModelEntity) {
        
        if lidarPresent == false {
            return
        }
        
        let avPoint = CGPoint(x: CGFloat(point.x), y: CGFloat(point.y)).convertVisionToAVFoundation()

        let screenSpacePoint = arView?.convertAVFoundationToScreenSpace(avPoint) ?? .zero
        let locationsInSpace = arView.hitTest(screenSpacePoint, types: .featurePoint)
        
        if let locationInSpace = locationsInSpace.first {
//            print("point1 is",CGPoint(x: CGFloat(point1.y)*1440, y: CGFloat(point1.x)*1920),locationInSpace.localTransform)
//            addDot(at: locationInSpace)
            print("locationInSpace.worldTransform.columns.3",locationInSpace.worldTransform.columns.3)
            if abs(locationInSpace.worldTransform.columns.3.z) <= 0.30
            {
                return
            }
            node.position = simd_float3(
                locationInSpace.worldTransform.columns.3.x,
                locationInSpace.worldTransform.columns.3.y,
                locationInSpace.worldTransform.columns.3.z
            )
//
            anchorEntity.addChild(node)
        }
    }
    
    func getCmSampleBufferFromCvPixelBuffer(cvPixelBuffer: CVPixelBuffer) -> CMSampleBuffer? {
        var sampleBuffer: CMSampleBuffer?

        let scale = CMTimeScale(1_000_000_000)
        let time = CMTime(value: CMTimeValue(2 * Double(scale)), timescale: scale)

        var timingInfo = CMSampleTimingInfo(duration: CMTime.invalid, presentationTimeStamp: time, decodeTimeStamp: CMTime.invalid)

        var _videoInfo: CMVideoFormatDescription?

        CMVideoFormatDescriptionCreateForImageBuffer(allocator: nil, imageBuffer: cvPixelBuffer, formatDescriptionOut: &_videoInfo)

        guard let videoInfo = _videoInfo else {
//            Logger.shared().log(message: "videoInfo is nil")
            return nil
        }

        CMSampleBufferCreateForImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: cvPixelBuffer, dataReady: true, makeDataReadyCallback: nil, refcon: nil, formatDescription: videoInfo, sampleTiming: &timingInfo, sampleBufferOut: &sampleBuffer)

        return sampleBuffer
    }
    
    
    func session(_ session: ARSession, didUpdate frame: ARFrame){
        
        let frame = session.currentFrame
                
        frameCount+=1
        if frameCount % 16 != 0
        {
            return
        }
        frameCount=0
        removeDetectionpoints()
        

        guard let imageCmSampleBuffer = frame?.capturedImage.getCmSampleBuffer(),
              let image = imageCmSampleBuffer.getCiImage(),
              let uiImage = UIImage(ciImage: image).rotate(radians: .pi/2)
        else {

            return
        }
        if exit{
            return
        }
        let pointsPath = UIBezierPath()
        if locatePoints {
            return
        }
        if let detectedBody = frame?.detectedBody{
            //This array contains only the lower body joints
            for i in detectedBody.skeleton.jointLandmarks {
                if !(i.x.isNaN) &&  !(i.y.isNaN)  {
//
                    arrayOfJoints.append(i)
                }
            }
//
            guard let interfaceOrientation = arView.window?.windowScene?.interfaceOrientation else { return }
            let transform = (frame?.displayTransform(for: interfaceOrientation, viewportSize: arView.frame.size))!
            
            
           let righthip = detectedBody.skeleton.landmark(for: ARSkeleton.JointName(rawValue: "right_upLeg_joint"))
           let lefthip = detectedBody.skeleton.landmark(for: ARSkeleton.JointName(rawValue: "left_upLeg_joint"))
           let rightshoulder =  detectedBody.skeleton.landmark(for: ARSkeleton.JointName(rawValue:"right_shoulder_1_joint"))
           let leftshoulder =  detectedBody.skeleton.landmark(for: ARSkeleton.JointName(rawValue:"left_shoulder_1_joint"))
           let rightelbow = detectedBody.skeleton.landmark(for: ARSkeleton.JointName(rawValue:"right_forearm_joint"))
           let leftelbow = detectedBody.skeleton.landmark(for: ARSkeleton.JointName(rawValue:"left_forearm_joint"))
           let newpoint = simd_float2(leftshoulder!.x+distance(leftshoulder!,leftelbow!),leftshoulder!.y)
//           var arrayOfJoints:[simd_float2] = [righthip!,lefthip!,rightshoulder!,leftshoulder!,newpoint,rightelbow!,leftelbow!]
           var arrayOfJoints:[simd_float2] = []
//
            let point1=simd_float2(detectedBody.skeleton.landmark(for: ARSkeleton.JointName(rawValue:"right_shoulder_1_joint"))!.y,detectedBody.skeleton.landmark(for: ARSkeleton.JointName(rawValue:"right_shoulder_1_joint"))!.x)
            let point2=simd_float2(detectedBody.skeleton.landmark(for: ARSkeleton.JointName(rawValue:"left_shoulder_1_joint"))!.y,detectedBody.skeleton.landmark(for: ARSkeleton.JointName(rawValue:"left_shoulder_1_joint"))!.x)
            let point3=simd_float2(detectedBody.skeleton.landmark(for: ARSkeleton.JointName(rawValue:"right_upLeg_joint"))!.y,detectedBody.skeleton.landmark(for: ARSkeleton.JointName(rawValue:"right_upLeg_joint"))!.x)
            let point4=simd_float2(detectedBody.skeleton.landmark(for: ARSkeleton.JointName(rawValue:"left_upLeg_joint"))!.y,detectedBody.skeleton.landmark(for: ARSkeleton.JointName(rawValue:"left_upLeg_joint"))!.x)
            

            addNewPoint(point: CGPoint(x: CGFloat(rightshoulder!.x), y: CGFloat(rightshoulder!.y)), node: &sphere1)
            addNewPoint(point: CGPoint(x: CGFloat(leftshoulder!.x), y: CGFloat(leftshoulder!.y)), node: &sphere2)
            addNewPoint(point: CGPoint(x: CGFloat(lefthip!.x), y: CGFloat(lefthip!.y)), node: &sphere3)
            addNewPoint(point: CGPoint(x: CGFloat(righthip!.x), y: CGFloat(righthip!.y)), node: &sphere4)
            

           print("point1",point1,point2,point3,point4,newpoint)

            let A = simd_float2((point1.x+point2.x)/2,point1.y)
            let B = simd_float2(A.x-0.3*abs(point2.x-A.x),point1.y)
            let C =  simd_float2((A.x+B.x)/2,point1.y)
            let F = simd_float2((point3.x+point4.x)/2,point3.y)
            let G = simd_float2(B.x,point3.y)
            let H = simd_float2((F.x+G.x)/2,point3.y)
            let E = simd_float2(A.x,A.y+0.3*abs(A.y-F.y))
            let X = simd_float2(A.x,A.y+0.4*abs(A.y-F.y))
            var V1 = simd_float2(point1.x-abs(point1.x-point2.x)*0.33,point1.y+abs(point1.y-point4.y)*0.13)//simd_float2(A.x+0.5*abs(B.x-A.x),E.y)
            var V2 = simd_float2(point1.x-abs(point1.x-point2.x)*0.62,point1.y+abs(point1.y-point4.y)*0.11)//simd_float2(C.x,E.y)
            var V4 = simd_float2(point1.x-abs(point1.x-point2.x)*0.79,point1.y+abs(point1.y-point4.y)*0.24)//simd_float2(B.x,X.y)
            var V3 =  simd_float2(point1.x-abs(point1.x-point2.x)*0.68,point1.y+abs(point1.y-point4.y)*0.18)//simd_float2((V2.x+V4.x)/2,(V2.y+V4.y)/2)
            let v1 = simd_float2(self.V1.y,self.V1.x)
            let v2 = simd_float2(self.V2.y,self.V2.x)
            let v3 = simd_float2(self.V3.y,self.V3.x)
            let v4 = simd_float2(self.V4.y,self.V4.x)
            
            var B1 = simd_float2(point1.x-abs(point1.x-point2.x)*0.16,point1.y+abs(point1.y-point4.y)*0.059)
            var B2 = simd_float2(point2.x+abs(point1.x-point2.x)*0.21,point1.y+abs(point1.y-point4.y)*0.059)
            var B3 = simd_float2(point1.x-abs(point1.x-point2.x)*0.16,point1.y+abs(point1.y-point4.y)*0.39)
            var B4 = simd_float2(point2.x+abs(point1.x-point2.x)*0.12,point1.y+abs(point1.y-point4.y)*0.39)
            print("B1 and B2",B1,B2)

            
            var Y1 = simd_float2(point1.x-abs(point1.x-point2.x)*0.30,point1.y+abs(point1.y-point4.y)*0.60)
            var Y2 = simd_float2(point1.x-abs(point1.x-point2.x)*0.67,point1.y+abs(point1.y-point4.y)*0.60)
            var Y3 = simd_float2(point1.x-abs(point1.x-point2.x)*0.24,point1.y+abs(point1.y-point4.y)*0.716)
            var Y4 = simd_float2(point1.x-abs(point1.x-point2.x)*0.75,point1.y+abs(point1.y-point4.y)*0.716)
            
           

            if generalMode {
               
                for entity in arView.scene.anchors {
                    entity.children.removeAll()
                        }
                
                V1 = simd_float2(V1.y,V1.x)
                V2 = simd_float2(V2.y,V2.x)
                V3 = simd_float2(V3.y,V3.x)
                V4 = simd_float2(V4.y,V4.x)
                
                
                addNewPoint(point: CGPoint(x: CGFloat(V1.x), y: CGFloat(V1.y)), node: &sphere5)
                addNewPoint(point: CGPoint(x: CGFloat(V2.x), y: CGFloat(V2.y)), node: &sphere6)
                addNewPoint(point: CGPoint(x: CGFloat(V3.x), y: CGFloat(V3.y)), node: &sphere7)
                addNewPoint(point: CGPoint(x: CGFloat(V4.x), y: CGFloat(V4.y)), node: &sphere8)
                
                arrayOfJoints += [V1,V2,V3,V4]
            }
            
            else if cardiacMode {
               
                for entity in arView.scene.anchors {
                    entity.children.removeAll()
                        }
                
                B1 = simd_float2(B1.y,B1.x)
                B2 = simd_float2(B2.y,B2.x)
                B3 = simd_float2(B3.y,B3.x)
                B4 = simd_float2(B4.y,B4.x)
                
                addNewPoint(point: CGPoint(x: CGFloat(B1.x), y: CGFloat(B1.y)), node: &sphere1)
                addNewPoint(point: CGPoint(x: CGFloat(B2.x), y: CGFloat(B2.y)), node: &sphere2)
                addNewPoint(point: CGPoint(x: CGFloat(B3.x), y: CGFloat(B3.y)), node: &sphere3)
                addNewPoint(point: CGPoint(x: CGFloat(B4.x), y: CGFloat(B4.y)), node: &sphere4)
                
                arrayOfJoints += [B1,B2,B3,B4]
                
            }
            
            else if pulmonaryMode {
                
                for entity in arView.scene.anchors {
                    entity.children.removeAll()
                        }
                
                Y1 = simd_float2(Y1.y,Y1.x)
                Y2 = simd_float2(Y2.y,Y2.x)
                Y3 = simd_float2(Y3.y,Y3.x)
                Y4 = simd_float2(Y4.y,Y4.x)
                
                addNewPoint(point: CGPoint(x: CGFloat(Y1.x), y: CGFloat(Y1.y)), node: &sphere9)
                addNewPoint(point: CGPoint(x: CGFloat(Y2.x), y: CGFloat(Y2.y)), node: &sphere10)
                addNewPoint(point: CGPoint(x: CGFloat(Y3.x), y: CGFloat(Y3.y)), node: &sphere11)
                addNewPoint(point: CGPoint(x: CGFloat(Y4.x), y: CGFloat(Y4.y)), node: &sphere12)
                arrayOfJoints += [Y1,Y2,Y3,Y4]
            }
               
            
          
            
            
            print("V1 and V2",V1,V2)

//
            
          for i in 0..<arrayOfJoints.count {

                var normalizedCenter = CGPoint(x: CGFloat(arrayOfJoints[i].x), y: CGFloat(CGFloat(arrayOfJoints[i].y))).applying(transform)
//
                      let center = normalizedCenter.applying(CGAffineTransform.identity.scaledBy(x: arView.frame.width, y: arView.frame.height))

                      let circleWidth: CGFloat = 10
                      let circleHeight: CGFloat = 10
                      let rect = CGRect(origin: CGPoint(x: center.x - circleWidth/2, y: center.y - circleHeight/2), size: CGSize(width: circleWidth, height: circleHeight))


                var circleLayer = CAShapeLayer()
                
               
                print("distance", detectedBody.skeleton.landmark(for: ARSkeleton.JointName(rawValue: "right_upLeg_joint"))?.x ?? 0 - (detectedBody.skeleton.landmark(for: ARSkeleton.JointName(rawValue: "right_foot_joint"))?.x ?? 0))
              if  drawPoints || (i>=arrayOfJoints.count-4){
//
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
//
              if lidarPresent == false {
                  annotationOverlayView.layer.addSublayer(circleLayer)
              }

                  }
            arView.addSubview(annotationOverlayView)
            NSLayoutConstraint.activate([
              annotationOverlayView.topAnchor.constraint(equalTo: arView.topAnchor),
              annotationOverlayView.leadingAnchor.constraint(equalTo: arView.leadingAnchor),
              annotationOverlayView.trailingAnchor.constraint(equalTo: arView.trailingAnchor),
              annotationOverlayView.bottomAnchor.constraint(equalTo: arView.bottomAnchor),
            ])
            arrayOfJoints = [[0,0]]
            arView.bringSubviewToFront(locatePointsButton)

        }else {
            print("arbody2d not detected")
        }
    }
    
    public func worldPosition(screenPosition: CGPoint,
                              depth: Float) -> simd_float3? {
        guard
            let rayResult = arView.ray(through: screenPosition)
        else {return nil}
        
        var depth = depth
//
        
        let worldOffset = rayResult.direction * depth
        print("worldOffset", worldOffset)
         var  worldPosition = rayResult.origin + worldOffset
         print("worldPosition",worldPosition)
         return worldPosition
    }
    
}

