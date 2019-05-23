
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
    
//    static func == (lhs: CircleAnnotationSet, rhs: CircleAnnotationSet) -> Bool {
//        return (lhs.circleId == rhs.circleId)
//    }
//
////    static func == (lhs: CircleAnnotationSet, rhs: CircleAnnotationSet) -> Bool {
////        return (lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude &&
////        lhs.circlePlotName == rhs.circlePlotName && lhs.isPrivate == rhs.isPrivate &&
////        lhs.circleId == rhs.circleId && lhs.admin == rhs.admin && lhs.users == rhs.users &&
////        lhs.dateCreated == rhs.dateCreated)
////    }
//
//    static func != (lhs: CircleAnnotationSet, rhs: CircleAnnotationSet) -> Bool {
//        return !(lhs.circleId == rhs.circleId)
//    }

    //somethings off here. 
    var location: CLLocationCoordinate2D! {
        didSet {
            latitude = location.latitude
            longitude = location.longitude
        }
    }
    
    // For equatability.
    var latitude: CLLocationDegrees!
    var longitude: CLLocationDegrees!
    var deleted: Bool!
    var circlePlotName: String!
    var isPrivate: Bool!
    var circleId: String!
    var admin: String!
    var users: [String]!
    var stealthMode: Bool!
    var dateCreated: String!
    var locationSnapShot: String!
    var ref: DocumentReference!
    
    init(document: DocumentSnapshot) {
        location = geoPointToCLLocationCoordinate2d(document.data()?["location"] as? GeoPoint)
        circlePlotName = document.data()?["name"] as? String
        isPrivate = document.data()?["isprivate"] as? Bool
        circleId = document.reference.documentID
        admin = document.data()?["admin"] as? String
        users = document.data()?["users"] as? [String]
        dateCreated = document.data()?["created"] as? String
        deleted = document.data()?["deleted"] as? Bool
        stealthMode = document.data()?["stealthmode"] as? Bool
        locationSnapShot = document.data()?["locationsnapshot"] as? String
        ref = document.reference
     }
    
    init(location: CLLocationCoordinate2D, circlePlotName: String, isPrivate: Bool, circleId: String?,
         admin: String, users: [String], dateCreated: String, stealthMode: Bool,mapSnapShot: String? ) {
        self.location = location
        self.circlePlotName = circlePlotName
        self.isPrivate = isPrivate
        self.circleId = circleId ?? "temporary"
        self.admin = admin
        self.users = users
        self.deleted = false
        self.stealthMode = stealthMode
        self.locationSnapShot = mapSnapShot ?? ""
        self.dateCreated = dateCreated
    }

    func asDictionary() -> [String:Any]? {
        guard let locationGeoPoint = cLLocationCoordinate2dToGeoPoint(location) else {return nil}
        let circleDict: [String:Any] = ["name": circlePlotName as String, "location": locationGeoPoint as GeoPoint,
                                        "isprivate": isPrivate as Bool, "circleid": circleId as String, "admin": admin as String, "users": users as [String], "created": dateCreated as String, "deleted": deleted as Bool, "stealthmode": stealthMode as Bool, "locationsnapshot": locationSnapShot as String]
        return circleDict
    }
    
    //Somethings off here.
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




