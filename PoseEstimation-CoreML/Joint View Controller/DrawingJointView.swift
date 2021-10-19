//
//  PoseView.swift
//  PoseEstimation-CoreML
//
//  Created by GwakDoyoung on 15/07/2018.
//  Copyright © 2018 tucan9389. All rights reserved.
//

import UIKit

class DrawingJointView: UIView {
    
    static let threshold = 0.23
    
    // the count of array may be <#14#> when use PoseEstimationForMobile's model
    private var keypointLabelBGViews: [UIView] = []
    
    //private var kneeView: [UIView?] = []

    public var bodyPoints: [PredictedPoint?] = [] {
        didSet {
            self.setNeedsDisplay()
            self.drawKeypoints(with: bodyPoints)
        }
    }
    
    //initializes old view for later usage in storing temporary views of lower limb angles
    public var oldView: UIView?
    
    //sets up labels for each specific body part
    private func setUpLabels(with keypointsCount: Int) {
        //self.subviews.forEach({ $0.removeFromSuperview() })
        for _ in self.subviews {        //for loop basically does the same thing as the above line of code, not sure which one is better at its job though
            self.removeFromSuperview()
        }
        
        let pointSize = CGSize(width: 10, height: 10)
        keypointLabelBGViews = (0..<keypointsCount).map { index in
            let color = PoseEstimationForMobileConstant.colors[index%PoseEstimationForMobileConstant.colors.count]
            let view = UIView(frame: CGRect(x: 0, y: 0, width: pointSize.width, height: pointSize.height))
            view.backgroundColor = color
            view.clipsToBounds = false
            view.layer.cornerRadius = 5
            view.layer.borderColor = UIColor.black.cgColor
            view.layer.borderWidth = 1.4
            
            let label = UILabel(frame: CGRect(x: pointSize.width * 1.4, y: 0, width: 100, height: pointSize.height))
            label.text = PoseEstimationForMobileConstant.pointLabels[index%PoseEstimationForMobileConstant.colors.count]
            label.textColor = color
            label.font = UIFont.preferredFont(forTextStyle: .caption2)
            view.addSubview(label)
            self.addSubview(view)
            return view
        }
        
        
        //var x: CGFloat = 0.0
        //let y: CGFloat = self.frame.size.height - 24
        //let _ = (0..<keypointsCount).map { index in
        //    let color = Constant.colors[index%Constant.colors.count]
        //    if index == 2 || index == 8 { x += 28 }
        //    else { x += 14 }
        //    let view = UIView(frame: CGRect(x: x, y: y + 10, width: 4, height: 4))
        //    view.backgroundColor = color
        //
        //    self.addSubview(view)
        //    return
        //}
    }
    
    override func draw(_ rect: CGRect) {
        if let ctx = UIGraphicsGetCurrentContext() {
            
            ctx.clear(rect);
            
            let size = self.bounds.size
            
            let color = PoseEstimationForMobileConstant.jointLineColor.cgColor
            if PoseEstimationForMobileConstant.pointLabels.count == bodyPoints.count {
                let _ = PoseEstimationForMobileConstant.connectedPointIndexPairs.map { pIndex1, pIndex2 in
                    if let bp1 = self.bodyPoints[pIndex1], bp1.maxConfidence > DrawingJointView.threshold,
                        let bp2 = self.bodyPoints[pIndex2], bp2.maxConfidence > DrawingJointView.threshold {
                        let p1 = bp1.maxPoint
                        let p2 = bp2.maxPoint
                        let point1 = CGPoint(x: p1.x * size.width, y: p1.y*size.height)
                        let point2 = CGPoint(x: p2.x * size.width, y: p2.y*size.height)
                        drawLine(ctx: ctx, from: point1, to: point2, color: color)
                    }
                }
            }
        }
    }
    
    
    //connects the predicted points
    private func drawLine(ctx: CGContext, from p1: CGPoint, to p2: CGPoint, color: CGColor) {
        ctx.setStrokeColor(color)
        ctx.setLineWidth(3.0)
        
        ctx.move(to: p1)
        ctx.addLine(to: p2)
        
        ctx.strokePath();
    }
    
    //utilizes previous functions to draw points from prediction model
    private func drawKeypoints(with n_kpoints: [PredictedPoint?]) {
        let imageFrame = keypointLabelBGViews.first?.superview?.frame ?? .zero
        
        let pointSize = CGSize(width: 10, height: 10)
        let myView = UIView(frame: CGRect(x: 0, y: 0, width: pointSize.width, height: pointSize.height))
        if oldView != nil {
            oldView!.removeFromSuperview()
        }
        
        let minAlpha: CGFloat = 0.4
        let maxAlpha: CGFloat = 1.0
        let maxC: Double = 0.6
        let minC: Double = 0.1
        var x8: CGFloat = 0.0
        var y8: CGFloat = 0.0
        var x9: CGFloat = 0.0
        var y9: CGFloat = 0.0
        var x10: CGFloat = 0.0
        var y10: CGFloat = 0.0
        var x11: CGFloat = 0.0
        var y11: CGFloat = 0.0
        var x12: CGFloat = 0.0
        var y12: CGFloat = 0.0
        var x13: CGFloat = 0.0
        var y13: CGFloat = 0.0
        
        
        if n_kpoints.count != keypointLabelBGViews.count {
            setUpLabels(with: n_kpoints.count)
        }
        
        for (index, kp) in n_kpoints.enumerated() {
            if let n_kp = kp {
                let x = n_kp.maxPoint.x * imageFrame.width
                let y = n_kp.maxPoint.y * imageFrame.height
                keypointLabelBGViews[index].center = CGPoint(x: x, y: y)
                let cRate = (n_kp.maxConfidence - minC)/(maxC - minC)
                keypointLabelBGViews[index].alpha = (maxAlpha - minAlpha) * CGFloat(cRate) + minAlpha
                switch index { //saves the values of the lower limb joints for later access
                case 8:
                    x8 = x
                    y8 = y
                case 9:
                    x9 = x
                    y9 = y
                case 10:
                    x10 = x
                    y10 = y
                case 11:
                    x11 = x
                    y11 = y
                case 12:
                    x12 = x
                    y12 = y
                case 13:
                    x13 = x
                    y13 = y
                default:
                    continue
                }
            } else {
                keypointLabelBGViews[index].center = CGPoint(x: -4000, y: -4000)
                keypointLabelBGViews[index].alpha = minAlpha
            }
            
            
            
        }
        
        //recombine CGFloats as coordinate values for the bodypoints
        let bodyPoint8 = CGPoint(x: x8, y: y8)
        let bodyPoint9 = CGPoint(x: x9, y: y9)
        let bodyPoint10 = CGPoint(x: x10, y: y10)
        let bodyPoint11 = CGPoint(x: x11, y: y11)
        let bodyPoint12 = CGPoint(x: x12, y: y12)
        let bodyPoint13 = CGPoint(x: x13, y: y13)
        
        //if 1, then function will test for right knee, 2 for left knee
        let rKneeAngle = round(angleBetweenPoints(knee: 1, midPoint: bodyPoint9, firstPoint: bodyPoint8, secondPoint: bodyPoint10))
        let lKneeAngle = round(angleBetweenPoints(knee: 2, midPoint: bodyPoint12, firstPoint: bodyPoint11, secondPoint: bodyPoint13))
        
        //create labels for right and left knee
        
        let label9 = UILabel()
        label9.frame = CGRect(x: x9 + 5, y: y9 + 5, width: 200, height: 50)
        label9.text = "\(rKneeAngle)"
        if rKneeAngle < 0 {                 //detects when right knee collapses inwardy
            label9.textColor = .red
        } else {
            label9.textColor = .green
        }

        
        let label12 = UILabel()
        label12.frame = CGRect(x: x12 + 5, y: y12 + 5, width: 200, height: 50)
        label12.text = "\(lKneeAngle)"
        if lKneeAngle < 0 {                 //detects when left knee collapses inwardly
            label12.textColor = .red
        } else {
            label12.textColor = .green
        }
        
        
        myView.addSubview(label9)
        myView.addSubview(label12)
        
        oldView = myView    //store current view as old view to be removed on next iteration
        self.addSubview(myView)
        
        
    }
    
    //calculate angle of knee joint, and identify knee valgus
    func angleBetweenPoints(knee: Int, midPoint: CGPoint,  firstPoint: CGPoint, secondPoint: CGPoint) -> CGFloat {
        let firstAngle = atan2(firstPoint.y - midPoint.y, firstPoint.x - midPoint.x)
        let secondAngle = atan2(secondPoint.y - midPoint.y, secondPoint.x - midPoint.x)
        var angleDiff = (firstAngle - secondAngle) * 180 / 3.14
        
        if knee == 1 && firstPoint.x > midPoint.x  {
            angleDiff *= -1
        } else if knee == 2 && firstPoint.x < midPoint.x {
            angleDiff *= -1
        }

        return angleDiff
    }
    
}

// MARK: - Constant for edvardHua/PoseEstimationForMobile
struct PoseEstimationForMobileConstant {
    static let pointLabels = [
        "top",          //0
        "neck",         //1
        
        "R shoulder",   //2
        "R elbow",      //3
        "R wrist",      //4
        "L shoulder",   //5
        "L elbow",      //6
        "L wrist",      //7
        
        "R hip",        //8
        "R knee",       //9
        "R ankle",      //10
        "L hip",        //11
        "L knee",       //12
        "L ankle",      //13
    ]
    
    static let connectedPointIndexPairs: [(Int, Int)] = [
        (0, 1),     // top-neck
        
        (1, 2),     // neck-rshoulder
        (2, 3),     // rshoulder-relbow
        (3, 4),     // relbow-rwrist
        (1, 8),     // neck-rhip
        (8, 9),     // rhip-rknee
        (9, 10),    // rknee-rankle
        
        (1, 5),     // neck-lshoulder
        (5, 6),     // lshoulder-lelbow
        (6, 7),     // lelbow-lwrist
        (1, 11),    // neck-lhip
        (11, 12),   // lhip-lknee
        (12, 13),   // lknee-lankle
    ]
    static let jointLineColor: UIColor = UIColor(red: 26.0/255.0, green: 187.0/255.0, blue: 229.0/255.0, alpha: 0.8)
    
    static var colors: [UIColor] = [
        .red,
        .green,
        .blue,
        .cyan,
        .yellow,
        .magenta,
        .orange,
        .purple,
        .brown,
        .black,
        .darkGray,
        .lightGray,
        .white,
        .gray,
    ]

        
}
