//
//  MapViewModel.swift
//  TheKind
//
//  Created by Tenny on 1/23/19.
//  Copyright © 2019 tenny. All rights reserved.
//

import Foundation
import MapKit
class MapViewViewModel {

    //Reactive
    var annotationIndexObserver: (([CircleAnnotationSet])->())?
    
    func retrieveCirclesCloseToPlayer(completion: (()->()))  {
        let circleAnnotationModel = CircleAnnotationModel()
        circleAnnotationModel.retrieveCirclesCloseToPlayer { (annotations) in
            self.circleDataSet = annotations
            completion()
        }
    }

    
    private var circleDataSet: [CircleAnnotationSet]? {
        didSet {
            if let circleDataSet = circleDataSet {
                annotationIndexObserver?(circleDataSet)
            }
        }
    }
    
}




