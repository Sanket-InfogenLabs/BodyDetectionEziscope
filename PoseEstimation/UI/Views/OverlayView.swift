// Copyright 2021 The TensorFlow Authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// =============================================================================

import UIKit
import os
import simd
/// Custom view to visualize the pose estimation result on top of the input image.
class OverlayView: UIImageView {

  /// Visualization configs
  private enum Config {
    static let dot = (radius: CGFloat(5), color: UIColor.orange)
    static let line = (width: CGFloat(5.0), color: UIColor.orange)
  }
    var myArray : [BodyPart] = [.pointV1]
    var newBodyParts:[BodyPart] = [BodyPart.leftShoulder, BodyPart.rightShoulder, BodyPart.leftHip, BodyPart.rightHip]
    
    var leftShoulderPosition: CGPoint?
    var rightShoulderPosition: CGPoint?
    var leftHipPosition: CGPoint?
    var rightHipPosition: CGPoint?
    var dict : [BodyPart:CGPoint] = [.leftAnkle : CGPoint(x: 0, y: 0)]
    
    var V1 = CGPoint()
    var V2 = CGPoint()
    var V3 = CGPoint()
    var V4 = CGPoint()
    
    
    var B1 = CGPoint()
    var B2 = CGPoint()
    var B3 = CGPoint()
    var B4 = CGPoint()
    
    
    var Y1 = CGPoint()
    var Y2 = CGPoint()
    var Y3 = CGPoint()
    var Y4 = CGPoint()
    
    
    var A1 = CGPoint()
    var A2 = CGPoint()
    var A3 = CGPoint()
    var A4 = CGPoint()
    
    var arrayPoints: [CGPoint] = []

//  / List of lines connecting each part to be visualized.
  private static let lines = [
    (from: BodyPart.leftWrist, to: BodyPart.leftElbow),
    (from: BodyPart.leftElbow, to: BodyPart.leftShoulder),
    (from: BodyPart.leftShoulder, to: BodyPart.rightShoulder),
    (from: BodyPart.rightShoulder, to: BodyPart.rightElbow),
    (from: BodyPart.rightElbow, to: BodyPart.rightWrist),
    (from: BodyPart.leftShoulder, to: BodyPart.leftHip),
    (from: BodyPart.leftHip, to: BodyPart.rightHip),
    (from: BodyPart.rightHip, to: BodyPart.rightShoulder),
    (from: BodyPart.leftHip, to: BodyPart.leftKnee),
    (from: BodyPart.leftKnee, to: BodyPart.leftAnkle),
    (from: BodyPart.rightHip, to: BodyPart.rightKnee),
    (from: BodyPart.rightKnee, to: BodyPart.rightAnkle),
  ]

  /// CGContext to draw the detection result.

  var context: CGContext!

  /// Draw the detected keypoints on top of the input image.
  ///
  /// - Parameters:
  ///     - image: The input image.
  ///     - person: Keypoints of the person detected (i.e. output of a pose estimation model)
  func draw(at image: UIImage, person: Person) {
    if context == nil {
      UIGraphicsBeginImageContext(image.size)
      guard let context = UIGraphicsGetCurrentContext() else {
        fatalError("set current context faild")
      }
      self.context = context
    }
    
      for body in person.keyPoints {
          if body.bodyPart == BodyPart.leftShoulder {
              
              leftShoulderPosition = body.coordinate
          }
          
          if body.bodyPart == BodyPart.rightShoulder {
              
              rightShoulderPosition = body.coordinate
          }
          
          if body.bodyPart == BodyPart.rightHip {
              
              rightHipPosition = body.coordinate
          }
          
          if body.bodyPart == BodyPart.leftHip {
              
              leftHipPosition = body.coordinate
          }

      }
      
      
      if let rightSholder = leftShoulderPosition, let leftSholder = rightShoulderPosition, let rightHip = leftHipPosition, let leftHip = rightHipPosition {
          
          let A = CGPoint(x: (rightSholder.x+leftSholder.x)/2,y: rightSholder.y)
          let B = CGPoint(x: A.x+0.3*abs(leftSholder.x-A.x), y: rightSholder.y)
          let C = CGPoint(x: (A.x+B.x)/2, y: rightSholder.y)
          let F = CGPoint(x: (rightHip.x+leftHip.x)/2, y: rightHip.y)
          let G = CGPoint(x: B.x, y: rightHip.y)
          let H = CGPoint(x: (F.x+G.x)/2, y: rightHip.y)
          let E = CGPoint(x: A.x, y: A.y+0.3*abs(A.y-F.y))
//          let X = CGPoint(x: A.x, y: A.y+0.4*abs(A.y-F.y))
          
          let shdwidth = abs(leftSholder.x-rightSholder.x)
          let hipheight = abs(leftSholder.y-leftHip.y)
          
          var X = rightSholder.x-abs(rightSholder.x-leftSholder.x)*0.33
          var Y = leftSholder.y+CGFloat(hipheight)*0.13
          
          V1 = CGPoint(x:X, y: Y)
          dict[.pointV1] = V1
          
          let tempV1 = V1.x
          
          X=rightSholder.x-shdwidth*0.62
          Y=leftSholder.y+hipheight*0.11
          V2 = CGPoint(x:X, y: Y)
          dict[.pointV2] = V2
          
          let refDistance = V1.x - V2.x
          
          
          X=rightSholder.x-shdwidth*0.79
          Y=leftSholder.y+hipheight*0.24
          V4 = CGPoint(x:X, y: Y)
          dict[.pointV4] = V4
          
          A1 = CGPoint(x:V4.x, y: V4.y + refDistance*0.6)
          dict[.pointA1] = A1
          
          A2 = CGPoint(x:V4.x, y: V4.y - refDistance*0.6)
          dict[.pointA2] = A2
          
          A3 = CGPoint(x:V4.x - refDistance*0.6 , y: V4.y)
          dict[.pointA3] = A3
          
          A4 = CGPoint(x:V4.x + refDistance*0.6 , y: V4.y)
          dict[.pointA4] = A4
          
          X=rightSholder.x-shdwidth*0.68
          Y=leftSholder.y+hipheight*0.18
          V3 = CGPoint(x:X, y: Y)
          dict[.pointV3] = V3
          
          
          X = leftSholder.x+shdwidth*0.15
          Y = rightSholder.y+hipheight*0.073
          B1 = CGPoint(x:X, y: Y)
          dict[.pointB1] = B1
          
          X = leftSholder.x+shdwidth*0.809
          Y = rightSholder.y+hipheight*0.073
          B2 = CGPoint(x:X, y: Y)
          dict[.pointB2] = B2
          
          X = leftSholder.x+shdwidth*0.12
          Y = rightSholder.y+hipheight*0.40
          B3 = CGPoint(x:X, y: Y)
          dict[.pointB3] = B3
          
          X = leftSholder.x+shdwidth*0.92
          Y = rightSholder.y+hipheight*0.40
          B4 = CGPoint(x:X, y: Y)
          dict[.pointB4] = B4
          
          X = leftSholder.x+shdwidth*0.287
          Y = rightSholder.y+hipheight*0.632
          Y1 = CGPoint(x:X, y: Y)
          dict[.pointY1] = Y1
          
          X = rightSholder.x-shdwidth*0.287
          Y = rightSholder.y+hipheight*0.632
          Y2 = CGPoint(x:X, y: Y)
          dict[.pointY2] = Y2
          
          X = leftSholder.x+shdwidth*0.22
          Y = rightSholder.y+hipheight*0.74 
          Y3 = CGPoint(x:X, y: Y)
          dict[.pointY3] = Y3
          
          X = rightSholder.x-shdwidth*0.22
          Y = rightSholder.y+hipheight*0.74
          Y4 = CGPoint(x:X, y: Y)
          dict[.pointY4] = Y4
          
          X = rightSholder.x-shdwidth*0.22
          Y = rightSholder.y+hipheight*0.74
          Y4 = CGPoint(x:X, y: Y)
          dict[.pointY4] = Y4
          
          
          
          print("V4",V4)
          print("B1",B1,B2,B3,B4)
          arrayPoints += [V1,V2,V3,V4,B1,B2,B3,B4,Y1,Y2,Y3,Y4]
          
      }
      
    guard let strokes = strokes(from: person) else { return }
    image.draw(at: .zero)
    context.setLineWidth(Config.dot.radius)
    
      drawDots(at: context, dots: strokes.dots)
//    drawLines(at: context, lines: strokes.lines)
    context.setStrokeColor(UIColor.green.cgColor)
    context.strokePath()
    guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { fatalError() }
    self.image = newImage
  }
    
  /// Draw the dots (i.e. keypoints).
  ///
  /// - Parameters:
  ///     - context: The context to be drawn on.
  ///     - dots: The list of dots to be drawn.
  private func drawDots(at context: CGContext, dots: [CGPoint]) {
    for dot in dots {
     
      let dotRect = CGRect(
        x: dot.x - Config.dot.radius / 2, y: dot.y - Config.dot.radius / 2,
        width: Config.dot.radius, height: Config.dot.radius)
      let path = CGPath(
        roundedRect: dotRect, cornerWidth: Config.dot.radius, cornerHeight: Config.dot.radius,
        transform: nil)
      context.addPath(path)
    }
  }

  /// Draw the lines (i.e. conneting the keypoints).
  ///
  /// - Parameters:
  ///     - context: The context to be drawn on.
  ///     - lines: The list of lines to be drawn.
  private func drawLines(at context: CGContext, lines: [Line]) {
    for line in lines {
      context.move(to: CGPoint(x: line.from.x, y: line.from.y))
      context.addLine(to: CGPoint(x: line.to.x, y: line.to.y))
    }
  }

  /// Generate a list of strokes to draw in order to visualize the pose estimation result.
  ///
  /// - Parameters:
  ///     - person: The detected person (i.e. output of a pose estimation model).
  private func strokes(from person: Person) -> Strokes? {
    var strokes = Strokes(dots: [], lines: [])
    // MARK: Visualization of detection result
      let newCases = [BodyPart.leftShoulder, BodyPart.rightShoulder]
    var bodyPartToDotMap: [BodyPart: CGPoint] = [:]
      for (index, part) in BodyPart.allCases.enumerated() {
    
//          if newBodyParts.contains(part) {
//              let position = CGPoint(
//                x: person.keyPoints[index].coordinate.x,
//                y: person.keyPoints[index].coordinate.y)
//              bodyPartToDotMap[part] = position
////              strokes.dots.append(position)
//              print("partsss", part)
//          }
         ////
          for part in myArray{
//              a(position: CGPoint(x: V1.x,y: V1.y), part: part)
              appendPoint(position: dict[part]!, part: part)
//              bodyPartToDotMap[part] = dict[part]!
          }
          
     
//              if part == BodyPart.pointV1 {
//                  a(position: CGPoint(x: V1.x,y: V1.y), part: part)
//              }
              
//              if part == BodyPart.pointV2 {
//                  
//                  let position = CGPoint(
//                    x: V2.x,
//                    y: V2.y)
//                bodyPartToDotMap[part] = position
//                strokes.dots.append(position)
//  
//              }
//              
//              if part == BodyPart.pointV3 {
//                  
//                  let position = CGPoint(
//                    x: V3.x,
//                    y: V3.y)
//                bodyPartToDotMap[part] = position
//                strokes.dots.append(position)
//  
//              }
//              
//              if part == BodyPart.pointV4 {
//                  
//                  let position = CGPoint(
//                    x: V4.x,
//                    y: V4.y)
//                bodyPartToDotMap[part] = position
//                strokes.dots.append(position)
//  
//              }
//          
//          if part == BodyPart.pointB1 {
//              
//              let position = CGPoint(
//                x: B1.x,
//                y: B1.y)
//            bodyPartToDotMap[part] = position
//            strokes.dots.append(position)
//
//          }
//          
//          if part == BodyPart.pointB2 {
//              
//              let position = CGPoint(
//                x: B2.x,
//                y: B2.y)
//            bodyPartToDotMap[part] = position
//            strokes.dots.append(position)
//
//          }
//          
//          if part == BodyPart.pointB4 {
//              
//              let position = CGPoint(
//                x: B3.x,
//                y: B3.y)
//            bodyPartToDotMap[part] = position
//            strokes.dots.append(position)
//
//          }
//          
//          if part == BodyPart.pointB4 {
//              
//              let position = CGPoint(
//                x: B4.x,
//                y: B4.y)
//            bodyPartToDotMap[part] = position
//            strokes.dots.append(position)
//
//          }
//          
//          
//          if part == BodyPart.pointY1 {
//              
//              let position = CGPoint(
//                x: Y1.x,
//                y: Y1.y)
//            bodyPartToDotMap[part] = position
//            strokes.dots.append(position)
//
//          }
//          
//          if part == BodyPart.pointY2 {
//              
//              let position = CGPoint(
//                x: Y2.x,
//                y: Y2.y)
//            bodyPartToDotMap[part] = position
//            strokes.dots.append(position)
//
//          }
//          
//          if part == BodyPart.pointY3 {
//              
//              let position = CGPoint(
//                x: Y3.x,
//                y: Y3.y)
//            bodyPartToDotMap[part] = position
//            strokes.dots.append(position)
//
//          }
//          
//          if part == BodyPart.pointY4 {
//              
//              let position = CGPoint(
//                x: Y4.x,
//                y: Y4.y)
//            bodyPartToDotMap[part] = position
//            strokes.dots.append(position)
////
//          }

          
    }
      
      func appendPoint(position: CGPoint,part: BodyPart){
          print("appended")
//          dict[part] = position
        strokes.dots.append(position)
      }

//    do {
//      try strokes.lines = OverlayView.lines.map { map throws -> Line in
//        guard let from = bodyPartToDotMap[map.from] else {
//          throw VisualizationError.missingBodyPart(of: map.from)
//        }
//        guard let to = bodyPartToDotMap[map.to] else {
//          throw VisualizationError.missingBodyPart(of: map.to)
//        }
//        return Line(from: from, to: to)
//      }
//    } catch VisualizationError.missingBodyPart(let missingPart) {
//      os_log("Visualization error: %s is missing.", type: .error, missingPart.rawValue)
//      return nil
//    } catch {
//      os_log("Visualization error: %s", type: .error, error.localizedDescription)
//      return nil
//    }
    return strokes
  }
}

/// The strokes to be drawn in order to visualize a pose estimation result.
fileprivate struct Strokes {
  var dots: [CGPoint]
  var lines: [Line]
}

/// A straight line.
fileprivate struct Line {
  let from: CGPoint
  let to: CGPoint
}

fileprivate enum VisualizationError: Error {
  case missingBodyPart(of: BodyPart)
}


