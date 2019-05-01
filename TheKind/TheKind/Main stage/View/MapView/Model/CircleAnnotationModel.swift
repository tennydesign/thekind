
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
import Firebase
import FirebaseFirestore

struct CircleAnnotationSet {
    var location: CLLocationCoordinate2D!
    var circlePlotName: String!
    var isPrivate: Bool!
    var circleId: String!
    var admin: String!
    var users: [String]!
    var dateCreated: String!
    var ref: DocumentReference!
    
    init(document: DocumentSnapshot) {
        location = geoPointToCLLocationCoordinate2d(document.data()?["location"] as? GeoPoint)
        circlePlotName = document.data()?["name"] as? String
        isPrivate = document.data()?["isprivate"] as? Bool
        circleId = document.reference.documentID
        admin = document.data()?["admin"] as? String
        users = document.data()?["users"] as? [String]
        dateCreated = document.data()?["created"] as? String
        ref = document.reference
     }
    
    init(location: CLLocationCoordinate2D, circlePlotName: String, isPrivate: Bool, circleId: String?,
         admin: String, users: [String], dateCreated: String) {
        self.location = location
        self.circlePlotName = circlePlotName
        self.isPrivate = isPrivate
        self.circleId = circleId ?? "0"
        self.admin = admin
        self.users = users
        self.dateCreated = dateCreated
    }

    func asDictionary() -> [String:Any]? {
        guard let locationGeoPoint = cLLocationCoordinate2dToGeoPoint(location) else {return nil}
        let circleDict: [String:Any] = ["name": circlePlotName as String, "location": locationGeoPoint as GeoPoint,
                "isprivate": isPrivate as Bool, "circleid": circleId as String, "admin": admin as String, "users": users as [String], "created": dateCreated as String]
        return circleDict
    }
    
    func geoPointToCLLocationCoordinate2d(_ geoPoint: GeoPoint?) -> CLLocationCoordinate2D? {
        if let geoPointFB = geoPoint {
            return  CLLocationCoordinate2D(latitude: geoPointFB.latitude, longitude: geoPointFB.longitude)
        } else {
            return nil
        }
    }
    
    func cLLocationCoordinate2dToGeoPoint(_ location: CLLocationCoordinate2D?) -> GeoPoint? {
        if let location = location {
            return GeoPoint(latitude: location.latitude, longitude: location.longitude)
        } else {
            return nil
        }
    }
}



class KindPointAnnotation: MGLPointAnnotation {
    var circleDetails: CircleAnnotationSet? {
        didSet {
            
        }
    }
    
    init(circleAnnotationSet: CircleAnnotationSet) {
        super.init()
        guard let location = circleAnnotationSet.location else {fatalError("circle can't have nil coordinates:  init(circleAnnotationSet: CircleAnnotationSet")}
        coordinate = location
        title = circleAnnotationSet.circlePlotName
        circleDetails = circleAnnotationSet
        
    }
    
    
    override init() {
        super.init()
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
