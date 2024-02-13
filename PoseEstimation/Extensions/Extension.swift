//
//  Extension.swift
//  BodyDetection
//
//  Created by Apple on 09/11/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation
import RealityKit
import UIKit
import ARKit
public extension CVPixelBuffer {
    
    ///The input point must be in normalized AVFoundation coordinates. i.e. (0,0) is in the Top-Left, (1,1,) in the Bottom-Right.
    func value(from point: CGPoint) -> Float? {
        
        let width = CVPixelBufferGetWidth(self)
        let height = CVPixelBufferGetHeight(self)
        
        let colPosition = Int(point.x * CGFloat(width))
        
        let rowPosition = Int(point.y * CGFloat(height))
        
        return value(column: colPosition, row: rowPosition)
    }
    
    func value(column: Int, row: Int) -> Float? {
        guard CVPixelBufferGetPixelFormatType(self) == kCVPixelFormatType_DepthFloat32 else { return nil }
        CVPixelBufferLockBaseAddress(self, .readOnly)
        if let baseAddress = CVPixelBufferGetBaseAddress(self) {
            let width = CVPixelBufferGetWidth(self)
            let index = column + (row * width)
            let offset = index * MemoryLayout<Float>.stride
            let value = baseAddress.load(fromByteOffset: offset, as: Float.self)
                CVPixelBufferUnlockBaseAddress(self, .readOnly)
            return value
        }
        CVPixelBufferUnlockBaseAddress(self, .readOnly)
        return nil
    }
}

extension CVPixelBuffer {
    func getCmSampleBuffer1() -> CMSampleBuffer? {
        var sampleBuffer: CMSampleBuffer?
        
        let scale = CMTimeScale(1_000_000_000)
        let time = CMTime(value: CMTimeValue(2 * Double(scale)), timescale: scale)
        
        var timingInfo = CMSampleTimingInfo(duration: CMTime.invalid, presentationTimeStamp: time, decodeTimeStamp: CMTime.invalid)
        
        var _videoInfo: CMVideoFormatDescription?
        
        CMVideoFormatDescriptionCreateForImageBuffer(allocator: nil, imageBuffer: self, formatDescriptionOut: &_videoInfo)
        
        guard let videoInfo = _videoInfo else {
#if DEBUG
#endif
            return nil
        }
        
        CMSampleBufferCreateForImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: self, dataReady: true, makeDataReadyCallback: nil, refcon: nil, formatDescription: videoInfo, sampleTiming: &timingInfo, sampleBufferOut: &sampleBuffer)
        
        return sampleBuffer
    }
}
extension CMSampleBuffer {
    func getCiImage1() -> CIImage? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(self) else {
            return nil
        }
        
        // var tempPixelBuffer: CVPixelBuffer?
        // let error = CVPixelBufferCreate(kCFAllocatorDefault, CVPixelBufferGetHeight(pixelBuffer), CVPixelBufferGetWidth(pixelBuffer), kCVPixelFormatType_420YpCbCr8PlanarFullRange, nil, &tempPixelBuffer)
        
        // guard error == kCVReturnSuccess, let newPixelBuffer = tempPixelBuffer else {
        //    return
        // }
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        return ciImage
        
    
    }
}
extension UIImage{

    func resizedImage(to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let resizedImage = renderer.image { (context) in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
        
        return resizedImage
    }
    
    func pixelData() -> [UInt8]? {
         let size = self.size
         let dataSize = size.width * size.height * 4
//         print("datasize",dataSize,size.width,size.height)
         var pixelData = [UInt8](repeating: 0, count: Int(dataSize))
         let colorSpace = CGColorSpaceCreateDeviceRGB()
         let context = CGContext(data: &pixelData,
                                 width: Int(size.width),
                                 height: Int(size.height),
                                 bitsPerComponent: 8,
                                 bytesPerRow: 4 * Int(size.width),
                                 space: colorSpace,
                                 bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
         guard let cgImage = self.cgImage else { return nil }
         context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
          
         return pixelData
     }
    
    func rotate1(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        // Move origin to middle
        context.translateBy(x: newSize.width / 2, y: newSize.height / 2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        draw(in: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    func pixelBuffer1() -> CVPixelBuffer? {
        let width = size.width
        let height = size.height
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                     kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         Int(width),
                                         Int(height),
                                         kCVPixelFormatType_32ARGB,
                                         attrs,
                                         &pixelBuffer)

        guard status == kCVReturnSuccess else {
            return nil
        }

        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)

        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData,
                                width: Int(width),
                                height: Int(height),
                                bitsPerComponent: 8,
                                bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!),
                                space: rgbColorSpace,
                                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

        context?.translateBy(x: 0, y: height)
        context?.scaleBy(x: 1.0, y: -1.0)

        UIGraphicsPushContext(context!)
        draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

        return pixelBuffer
    }
}
extension ARView {
   func convertAVFoundationToScreenSpace(_ point: CGPoint) -> CGPoint {
       //Convert from normalized AVFoundation coordinates (0,0 top-left, 1,1 bottom-right)
       //to screen-space coordinates.
       if
           let arFrame = session.currentFrame,
           let interfaceOrientation = window?.windowScene?.interfaceOrientation{
           let transform = arFrame.displayTransform(for: interfaceOrientation, viewportSize: frame.size)
           let normalizedCenter = point.applying(transform)
           let center = normalizedCenter.applying(CGAffineTransform.identity.scaledBy(x: frame.width, y: frame.height))
           return center
       } else {
           return CGPoint()
       }
   }
   
   func convertScreenSpaceToAVFoundation(_ point: CGPoint) -> CGPoint? {
       //Convert to normalized pixel coordinates (0,0 top-left, 1,1 bottom-right)
       //from screen-space coordinates.
       guard
         let arFrame = session.currentFrame,
         let interfaceOrientation = window?.windowScene?.interfaceOrientation
       else {return nil}
          
         let inverseScaleTransform = CGAffineTransform.identity.scaledBy(x: frame.width, y: frame.height).inverted()
         let invertedDisplayTransform = arFrame.displayTransform(for: interfaceOrientation, viewportSize: frame.size).inverted()
         let unScaledPoint = point.applying(inverseScaleTransform)
         let normalizedCenter = unScaledPoint.applying(invertedDisplayTransform)
         return normalizedCenter
   }
}
extension CGPoint{
    func convertVisionToAVFoundation() -> CGPoint {
        return CGPoint(x:self.x, y: self.y)
    }
}


extension UIViewController{
    
    class func loadViewController(withStoryBoard storyBoardName: String = "Main") -> Self {
            return instantiateViewController(withStoryBoard: storyBoardName)
        }

        class func instantiateViewController<T>(withStoryBoard storyBoardName: String) -> T {
            let sb = UIStoryboard(name: storyBoardName, bundle: nil)
            let controller = sb.instantiateViewController(withIdentifier: String(describing: self)) as! T
            return controller
        }
    

    class LoadingViewController: UIViewController {
        private let loadingIndicator = UIActivityIndicatorView(style: .large)

        override func viewDidLoad() {
            super.viewDidLoad()

            view.backgroundColor = UIColor(white: 0, alpha: 0.5)

            loadingIndicator.color = UIColor(white: 1, alpha: 0.5)
            loadingIndicator.center = view.center
            loadingIndicator.startAnimating()
            loadingIndicator.backgroundColor = UIColor(white: 0.2, alpha: 1)
            loadingIndicator.layer.cornerRadius = 8.0
            loadingIndicator.frame = CGRect(x: UIScreen.main.bounds.width * 0.5 - 30, y: UIScreen.main.bounds.height * 0.5 - 30, width: 60, height: 60)
            navigationController?.interactivePopGestureRecognizer?.isEnabled = false

            view.addSubview(loadingIndicator)
        }
    }
  
    func hideLoader() {
            if let loadingViewController = presentedViewController as? LoadingViewController {
                loadingViewController.view.isHidden = true
                loadingViewController.dismiss(animated: true, completion: nil)
            }
            view.isUserInteractionEnabled = true
        }


    func showLoader() {
            if let existingLoader = presentedViewController as? LoadingViewController {
                existingLoader.view.isHidden = false
            }
            else {
                let loadingViewController = LoadingViewController()
                loadingViewController.modalPresentationStyle = .overFullScreen
                loadingViewController.modalTransitionStyle = .crossDissolve
                present(loadingViewController, animated: true, completion: nil)
            }
            view.isUserInteractionEnabled = false
        }
    
}


extension UIImage {
    
    
    func rotate(radians: Float) -> UIImage? {
        
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        
        newSize.width = floor(newSize.width)
        
        newSize.height = floor(newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        
        let context = UIGraphicsGetCurrentContext()!
        
        // Move origin to middle
        
        
        
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        
        // Rotate around middle
        
        context.rotate(by: CGFloat(radians))
        
        
        
        // Draw the image at its center
        
        
        
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        
        return newImage
        
        
        
    }
    
}
   
extension String {
    
    var isValidEmail: Bool {
            return NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z]+([._%+-]{1}[A-Z0-9a-z]+)*@[A-Za-z0-9-]+((\\.[A-Za-z][A-Za-z0-9]{1,3})+)*\\.([A-Za-z]{2,4})").evaluate(with: self)
        }

        var isValidPassword: Bool {
            return NSPredicate(format: "SELF MATCHES %@", "^(?=.*?[A-Z])(?=(.*[a-z]){1,})(?=(.*[\\d]){1,})(?=(.*[\\W]){1,})(?!.*\\s).{8,}$").evaluate(with: self)
        }
}
