//
//  ClusterAnnotationView.swift
//  Paragliding
//
//  Created by Stéphane Azzopardi on 15/12/2018.
//  Copyright © 2018 Stéphane Azzopardi. All rights reserved.
//

import UIKit
import Mapbox
import SwifterSwift

final class ClusterAnnotationView: MGLAnnotationView {
    var imageView: UIImageView!
    var countLabel: UILabel!

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }

    init(annotation: MGLAnnotation?, reuseIdentifier: String?, count: UInt = 0) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

        imageView = UIImageView(image: Asset.mapCluster.image)
        addSubview(imageView)

        frame = imageView.frame

        switch Int(count) {
        case 0...9:
            frame = imageView.frame.insetBy(dx: 10, dy: 10)
        case 10...99:
            frame = imageView.frame.insetBy(dx: 5, dy: 5)
        case 100...999:
            frame = imageView.frame.insetBy(dx: 3, dy: 3)
        default:
            break
        }

        imageView.frame = bounds

        countLabel              = UILabel()
        countLabel.textColor    = Color.white
        countLabel.font         = UIFont.textStyle
        countLabel.text = String(count)
        countLabel.sizeToFit()
        countLabel.center = imageView.center
        addSubview(countLabel)

        centerOffset = CGVector(dx: 0.5, dy: 1)
    }

    func setup(withCount count: UInt) {
        countLabel.text = String(count)
        countLabel.sizeToFit()
        countLabel.center = imageView.center
    }
}
