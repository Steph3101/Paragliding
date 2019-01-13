//
//  SiteAnnotationView.swift
//  Paragliding
//
//  Created by Stéphane Azzopardi on 15/12/2018.
//  Copyright © 2018 Stéphane Azzopardi. All rights reserved.
//

import UIKit
import Mapbox

final class SiteAnnotationView: MGLAnnotationView {
    var viewModel: SiteAnnotationViewModel

    init(annotation: MGLAnnotation?, reuseIdentifier: String?, viewModel: SiteAnnotationViewModel) {
        self.viewModel = viewModel
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

        let imageView = UIImageView(image: viewModel.image)
        addSubview(imageView)

        frame = imageView.frame

        isDraggable = true

        if let orientations = viewModel.orientations, orientations.count > 0 {
            let orientationsView = OrientationsView(withImage: viewModel.image,
                                                    orientations: orientations,
                                                    width: 10,
                                                    centerOffset: 11)
            frame = orientationsView.frame

            imageView.center = orientationsView.center

            addSubview(orientationsView)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }

    override func setDragState(_ dragState: MGLAnnotationViewDragState, animated: Bool) {
        super.setDragState(dragState, animated: animated)

        switch dragState {
        case .starting:
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.5, options: [.curveLinear], animations: {
                self.transform = self.transform.scaledBy(x: 2, y: 2)
            })
        case .ending:
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.5, options: [.curveLinear], animations: {
                self.transform = CGAffineTransform.identity
            })
        default:
            break
        }
    }
}
