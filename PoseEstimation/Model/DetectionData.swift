//
//  OverlayModel.swift
//  PoseEstimation
//
//  Created by Sanket Lothe on 09/02/24.
//  Copyright © 2024 tensorflow. All rights reserved.
//

import Foundation
import UIKit


// MARK: Detection result
/// Time required to run pose estimation on one frame.
struct Times {
  var preprocessing: TimeInterval
  var inference: TimeInterval
  var postprocessing: TimeInterval
  var total: TimeInterval { preprocessing + inference + postprocessing }
}

/// An enum describing a body part (e.g. nose, left eye etc.).
enum BodyPart: String, CaseIterable {
  
  case nose = "nose"
  case leftEye = "left eye"
  case rightEye = "right eye"
  case leftEar = "left ear"
  case rightEar = "right ear"
  case leftShoulder = "left shoulder"
  case rightShoulder = "right shoulder"
  case leftElbow = "left elbow"
  case rightElbow = "right elbow"
  case leftWrist = "left wrist"
  case rightWrist = "right wrist"
  case leftHip = "left hip"
  case rightHip = "right hip"
  case leftKnee = "left knee"
  case rightKnee = "right knee"
  case leftAnkle = "left ankle"
  case rightAnkle = "right ankle"


  case pointV1 = "pointV1"
  case pointV2 = "pointV2"
  case pointV3 = "pointV3"
  case pointV4 = "pointV4"
    

  case pointB1 = "pointB1"
  case pointB2 = "pointB2"
  case pointB3 = "pointB3"
  case pointB4 = "pointB4"
    
  
  case pointY1 = "pointY1"
  case pointY2 = "pointY2"
  case pointY3 = "pointY3"
  case pointY4 = "pointY4"
    
    
   case pointA1 = "pointA1"
   case pointA2 = "pointA2"
   case pointA3 = "pointA3"
   case pointA4 = "pointA4"
      
    
    
  /// Get the index of the body part in the array returned by pose estimation models.

  var position: Int {
    return BodyPart.allCases.firstIndex(of: self) ?? 0
  }
}

/// A body keypoint (e.g. nose) 's detection result.
struct KeyPoint {
  var bodyPart: BodyPart = .leftHip
  var coordinate: CGPoint = .zero
  var score: Float32 = 0.0
}

/// A person detected by a pose estimation model.
struct Person {
  var keyPoints: [KeyPoint]
  var score: Float32
}




struct Strokes {
  var dots: [CGPoint]
  var lines: [Line]
}

/// A straight line.
struct Line {
  let from: CGPoint
  let to: CGPoint
}

enum VisualizationError: Error {
  case missingBodyPart(of: BodyPart)
}

enum Constants {
  // Configs for the TFLite interpreter.
  static let defaultThreadCount = 4
  static let defaultDelegate: Delegates = .gpu
  static let defaultModelType: ModelType = .movenetThunder

  // Minimum score to render the result.
  static let minimumScore: Float32 = 0.2
}
