//
//  MapViewModel.swift
//  TheKind
//
//  Created by Tenny on 1/23/19.
//  Copyright © 2019 tenny. All rights reserved.
//

import Foundation
import MapKit
class MapViewModel {

    //Reactive
    var annotationIndexObserver: (([CircleAnnotationSet])->())?
    
    //All you have to do is to fill in this dataset and the map will be loaded with points.
    //We should call this function from the firebase observer from time to time.
    var circleDataSet: [CircleAnnotationSet]? {
        didSet {
            if let circleDataSet = circleDataSet {
                annotationIndexObserver?(circleDataSet)
            }
        }
    }
    
}




