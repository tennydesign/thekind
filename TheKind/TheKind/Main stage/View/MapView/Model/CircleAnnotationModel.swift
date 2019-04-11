
//
//  CircleModel.swift
//  TheKind
//
//  Created by Tenny on 1/25/19.
//  Copyright © 2019 tenny. All rights reserved.
//

import Foundation
import MapKit
import Mapbox

struct CircleAnnotationSet {
    var location: CLLocationCoordinate2D
    var circlePlotName: String
    var isPrivate: Bool
    var circleId: String
    var admin: String
    var users: [String]
}


