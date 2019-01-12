//
//  OrientationsView.swift
//  Paragliding
//
//  Created by Stéphane Azzopardi on 23/12/2018.
//  Copyright © 2018 Stéphane Azzopardi. All rights reserved.
//

import UIKit
import SwifterSwift

final class OrientationsView: UIView {

    private var image: UIImage?
    private var orientations: [Orientation]?
    private var arcWidth: CGFloat?
    private var centerOffset: CGFloat?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    convenience init(withImage image: UIImage, orientations: [Orientation], width: CGFloat = 30.0, centerOffset: CGFloat = 10) {
        self.init(frame: CGRect.zero)

        self.image          = image
        self.orientations   = [Orientation](orientations)
        self.arcWidth       = width
        self.centerOffset   = centerOffset

        drawOrientations()
    }

    private func drawOrientations() {
        guard
            let image           = image,
            let orientations    = orientations,
            let arcWidth        = arcWidth,
            let centerOffset    = centerOffset else {
            fatalError("OrientationView has not been properly initialized")
        }

        let viewWidth = max((arcWidth + centerOffset) * 2, image.size.width)
        frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewWidth)

        let centerPoint             = CGPoint(x: bounds.midX , y: bounds.midY)
        let radius: CGFloat         = centerOffset + arcWidth
        let fractionsCount: CGFloat = CGFloat(Orientation.allCases.count)

        for orientation in orientations {
            let orientationLayer    = CAShapeLayer()
            let orientationAngle    = orientation.radians
            let startAngle          = orientationAngle - (360 / fractionsCount / 2 * CGFloat.pi / 180)
            let endAngle            = orientationAngle + (360 / fractionsCount / 2 * CGFloat.pi / 180)

            // External arc
            let path = UIBezierPath(arcCenter: centerPoint,
                                    radius: radius,
                                    startAngle: startAngle,
                                    endAngle: endAngle,
                                    clockwise: true)

            // Internal arc
            path.addArc(withCenter: centerPoint,
                        radius: centerOffset,
                        startAngle: endAngle,
                        endAngle: startAngle,
                        clockwise: false)

            path.close()

            orientationLayer.path = path.cgPath

            orientationLayer.backgroundColor   = nil
            orientationLayer.fillColor         = Color.greenishTeal.withAlphaComponent(0.75).cgColor
            orientationLayer.lineCap           = CAShapeLayerLineCap.square

            layer.addSublayer(orientationLayer)
        }
    }
}
