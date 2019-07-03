//
//  CircleAnnotationManagement.swift
//  TheKind
//
//  Created by Tenny on 3/29/19.
//  Copyright © 2019 tenny. All rights reserved.
// https://github.com/firebase/geofire-objc

import Foundation
import MapKit
import Mapbox
import FirebaseFirestore
import Firebase
import FirebaseStorage
import GeoFire
import RxSwift
import RxCocoa

class CircleAnnotationManagement {
    static let sharedInstance = CircleAnnotationManagement()
    var plotCircleCloseToPlayerCallback: ((CircleAnnotationSet)->())?
    var unPlotCircleCloseToPlayerCallback: ((CircleAnnotationSet)->())?
    var userAddedToTemporaryCircleListCallback: ((KindUser)->())?
    var userRemovedFromTemporaryCircleListCallback: ((KindUser)->())?
    var visibleCirclesInListView: [CircleAnnotationSet] = []
    var circleSnapShotListener: ListenerRegistration?
    var setChangedOnCircleCallback: ((CircleAnnotationSet)->())?
    var reloadCircleListCallback: (()->())?
    var geoFireQuery: GFCircleQuery?
    var geoFireEnterObserver: FirebaseHandle?
    var geoFireExitObserver: FirebaseHandle?
    var circlePlotterObserver = PublishSubject<CircleAnnotationSet?>()
    private init() {}
    
    //Receive Currently Selected circle or nil. If nil, will kill the observer.
    
    var isSelectedTemporaryCircleAnnotation:Bool {
        get {
            guard let uid = KindUserSettingsManager.sharedInstance.loggedUser?.uid else {return false}
            return currentlySelectedAnnotationView != nil &&  currentlySelectedAnnotationView?.annotation?.title == uid
        }
    }
    
    var currentlySelectedAnnotationView: CircleAnnotationView? {
        didSet {
            if let annotationView = currentlySelectedAnnotationView {
                if let circleId = annotationView.circleDetails?.circleId {
                    //fire up observer only once per circleID
                    if circleId != oldValue?.circleDetails?.circleId && !isSelectedTemporaryCircleAnnotation {
                        observeCircleSetFirebase(circleId: circleId)
                    }
                }
            } else {
                // kill obbserver
                circleSnapShotListener?.remove()
            }
        }
    }
    

    
    
    func updateCircleSettings(completion: @escaping (CircleAnnotationSet?, Bool)->()) {
        let db = Firestore.firestore()
        guard let set = currentlySelectedAnnotationView?.circleDetails else { return}
        guard let circleDict = set.asDictionary() else {return}
        db.collection("kindcircles").document(set.circleId).updateData(circleDict) { (err) in
            if let err = err {
                //SAVE CAUSE NO CIRCLE EXIST
                if err.localizedDescription.contains("No document to update") {
                    //Create circle from scratch
                    self.saveNewCircleSet(completion: { (set,completed)  in
                        if completed == false {
                            completion(nil,false)
                            return
                        }
                        
                        guard let set = set else {
                            completion(nil,false)
                            return
                        }
                        
                        completion(set,true)
                        return
                        
                    })
                }
            } else {
                //UPDATE CAUSE IT EXISTS
                completion(set,true)
            }

        }
    }
 
    
    //REFACTOR THIS LATER
    private func saveNewCircleSet(completion: @escaping (CircleAnnotationSet?, Bool)->()) {
        let db = Firestore.firestore()
        guard let set = currentlySelectedAnnotationView?.circleDetails else { return}
        var documentRef: DocumentReference? = nil
        guard let circleDict = set.asDictionary() else {return}
        var resultingSet: CircleAnnotationSet!
        let group = DispatchGroup()
        
        group.enter() // ==== ENTER (+ 1)  = 1
        documentRef = db.collection("kindcircles").addDocument(data: circleDict) { err in
            if let err = err {
                print(err)
                //completion(nil, err)
                group.leave() // OR LEAVE (- 1) = 0
                return
            }
            
            guard let circleid = documentRef?.documentID else {
                group.leave() // OR LEAVE (- 1) = 0
                return
            }
            

            documentRef?.setData(["circleid":circleid], merge: true, completion: { (err) in
                if let err = err {
                    print(err)
                    group.leave() // OR LEAVE (- 1) = 0
                    return
                }
                
            })

        
            documentRef?.getDocument(completion: { (document,error) in
                if let error = error {
                    print(error)
                    group.leave()
                    return
                }
                
                // SET SAVED SUCCESSFULLY - NOW GET SET AND SAVE IT FOR GEOFIRE
                group.enter() // === ENTER (+ 1) = 2
                let fireBaseRef = Database.database().reference()
                
                guard let document = document, document.exists else {return}
                let circleAnnotationSet = CircleAnnotationSet(document: document)
                resultingSet = circleAnnotationSet
                
                // FIRST half completed
                group.leave() // === LEAVE (- 1) = 1 // Still on task to go

                
                let geoFire = GeoFire(firebaseRef: fireBaseRef)
                geoFire.setLocation(CLLocation(latitude: resultingSet.location.latitude, longitude: resultingSet.location.longitude), forKey: resultingSet.circleId) { (error) in
                    if (error != nil) {
                        print("An error occured: \(String(describing: error))")
                        db.collection("kindcircles").document(resultingSet.circleId).delete()
                        resultingSet = nil
                        group.leave()  // === LEAVE (- 1) = 0 <- back to
                        return
                    }

                    // ALL SUCCESS
                    group.leave()  // === LEAVE (- 1) = 0 <- back to
                }
                
            })
        }

    
        group.notify(queue: .main) {
            if resultingSet != nil {
                completion(resultingSet, true)
            } else {
                completion(nil, false)
            }
        }
    }
    
    
    //DEPRECARED FIX IT
    func retrieveCirclesCloseToPlayerDeprecated(completion: @escaping (([CircleAnnotationSet])->()))  {
        let db = Firestore.firestore()
        guard let uid = KindUserSettingsManager.sharedInstance.loggedUser?.uid else {return}
        db.collection("kindcircles").getDocuments { (snapshot, err) in
            if let err = err {
                print(err)
                return
            }
            self.visibleCirclesInListView = []
            snapshot?.documents.forEach({ (document) in
                let set = CircleAnnotationSet(document: document)
                
                //TODO: FILTER THIS IN THE QUERY NOT HERE MAYBE.
                // Show only not private or private with user in.
                if !set.isPrivate || set.users.contains(uid) {
                    if !set.deleted {
                        self.visibleCirclesInListView.append(set)
                    }
                }
            })
            
            completion(self.visibleCirclesInListView)
        }
        
    }
    


    func getCirclesWithinRadiusObserver(latitude: CLLocationDegrees, longitude: CLLocationDegrees,radius: Double, completion: @escaping (()->()))  {
        let fireBaseRef = Database.database().reference()
        let geoFire = GeoFire(firebaseRef: fireBaseRef)
        let center = CLLocation(latitude: latitude, longitude: longitude)
        geoFireQuery = geoFire.query(at: center, withRadius: radius)
        
        //Entered region - Show
        geoFireEnterObserver = geoFireQuery?.observe(.keyEntered, with: { (key: String!, location: CLLocation!) in
            //print("Key '\(String(describing: key))' entered the search area and is at location '\(String(describing: location))'")
            
            self.retrieveCircleById(circleId: key, completion: { (set) in
                guard let set = set else {
                    completion()
                    return
                }
                self.visibleCirclesInListView.append(set)
              //  self.plotCircleCloseToPlayerCallback?(set) //deprecated
                self.reloadCircleListCallback?() // uses visibleCircles
                self.circlePlotterObserver.onNext(set)
            })
            
        })
        
        //Leave region - Hide
        geoFireExitObserver = geoFireQuery?.observe(.keyExited, with: { (key: String!, location: CLLocation!) in
            print("Key '\(String(describing: key))' exited the search area and is at location '\(String(describing: location))'")
            
            self.retrieveCircleById(circleId: key, completion: { (set) in
                guard let set = set else {
                    completion()
                    return
                }
                
                self.visibleCirclesInListView.removeAll(where: { (setToRemove) -> Bool in
                    if setToRemove.circleId == set.circleId {
                        return true
                    }
                    return false
                })
                self.reloadCircleListCallback?() // uses visibleCircles
              //  self.unPlotCircleCloseToPlayerCallback?(set) deprecated
                self.circlePlotterObserver.onNext(set)
            })
            
        })
    }
    
    func removeAllGeoFireObservers() {
        geoFireQuery?.removeAllObservers()
    }
    
    func retrieveCircleById(circleId: String, completion: ((CircleAnnotationSet?)->())?) {
        let db = Firestore.firestore()
        db.collection("kindcircles").document(circleId).getDocument {  (document,err) in
            if let err = err {
                print(err)
                completion?(nil)
                return
            }
            if document?.data() == nil
            {
                print("no data")
                completion?(nil)
                return
            }
            
            let set:CircleAnnotationSet = CircleAnnotationSet(document: document!)
            completion?(set)
        }
    }
    
    func retrieveAllCirclesUserIsAdmin(completion: (([CircleAnnotationSet]?)->())?) {
        let db = Firestore.firestore()
        var circleSets:[CircleAnnotationSet] = []
        let ref = db.collection("kindcircles")
        guard let uid = KindUserSettingsManager.sharedInstance.loggedUser?.uid else {return}
        let query = ref.whereField("admin", isEqualTo: uid)
        query.getDocuments {  (document,err) in
            if let err = err {
                print(err)
                completion?(nil)
                return
            }
            
            document?.documents.forEach({ (document) in
                let set: CircleAnnotationSet = CircleAnnotationSet(document: document)
                circleSets.append(set)
            })
            
            completion?(circleSets)
        }
    }
    
    func checkIfUserBelongsToCircle(userId: String, completion: ((Bool?)->())?) {
        guard let set = currentlySelectedAnnotationView?.circleDetails else {return}
        loadUserIDsInCircle(set: set) { (users) in
            if let users = users {
                completion?(users.contains(userId))
            } else {
                completion?(nil)
            }
        }
    }
    
    func checkIfUserBelongsToTemporaryCircle(userId: String, completion: ((Bool?)->())?) {
        guard let set = currentlySelectedAnnotationView?.circleDetails else {return}
        completion?(set.users.contains(userId))
    }
    
    func addUserToCircle(userId: String, completion: (()->())?) {
        let db = Firestore.firestore()
        guard let circleId = currentlySelectedAnnotationView?.circleDetails?.circleId else {return}

        let circlesRef = db.collection("kindcircles").document(circleId)
        //ArrayUnion() adds elements to an array but only elements not already present.
        circlesRef.updateData(["users" : FieldValue.arrayUnion([userId])]) { (err) in
            if let err = err {
                print(err)
                return
            }
            completion?()
        }

    }
    
    func addUsersToCircle(userIds: [String], completion: (()->())?) {
        let db = Firestore.firestore()
        guard let circleId = currentlySelectedAnnotationView?.circleDetails?.circleId else {return}
        let circlesRef = db.collection("kindcircles").document(circleId)
        //ArrayUnion() adds elements to an array but only elements not already present.
        circlesRef.updateData(["users" : FieldValue.arrayUnion([userIds])]) { (err) in
            if let err = err {
                print(err)
                return
            }
            completion?()
        }
        
    }
    
    
    func removeUserFromCircle(userId: String, completion: (()->())?) {
        let db = Firestore.firestore()
        guard let circleId = currentlySelectedAnnotationView?.circleDetails?.circleId else {return}
        let circlesRef = db.collection("kindcircles").document(circleId)
        circlesRef.updateData(["users" : FieldValue.arrayRemove([userId])]) { (err) in
            if let err = err {
                print(err)
                return
            }
            completion?()
        }
    }
    
    func addUserToTemporaryCircle(userId: String, completion: ((KindUser?)->())?) {
      KindUserSettingsManager.sharedInstance.retrieveAnyUserSettings(userId: userId, completion: { (kindUser) in
            if let kindUser = kindUser {
                CircleAnnotationManagement.sharedInstance.currentlySelectedAnnotationView?.circleDetails?.users.append(userId)
                completion?(kindUser)
            }
        })
    }
    
    func removeUserFromTemporaryCircle(userId: String, completion: (((KindUser?))->())?) {
        KindUserSettingsManager.sharedInstance.retrieveAnyUserSettings(userId: userId, completion: { (kindUser) in
            if let kindUser = kindUser {
                CircleAnnotationManagement.sharedInstance.currentlySelectedAnnotationView?.circleDetails?.users.removeAll {$0 == userId}
                completion?(kindUser)
            }
        })
        
    }
    
    func loadUserIDsInCircle(set: CircleAnnotationSet, completion: (([String]?)->())?) {
        let db = Firestore.firestore()
        guard let circleId = set.circleId else {fatalError("no circleID: func loadUserIDsInCircle")}
        db.collection("kindcircles").document(circleId).getDocument {  (document,err) in
            if let err = err {
                print(err)
                return
            }
            guard let data = document?.data() else
            {
                print("no data")
                return
            }
            let circleData:[String:Any] = data
            
            guard let users = circleData["users"] as? [String], !users.isEmpty else {
                completion?(nil)
                return
            }
            
            completion?(users)
        }
    }

 
    func loadCircleUsersProfile(completion: (([KindUser]?)->())?) {
        guard let set = currentlySelectedAnnotationView?.circleDetails else {return}
        var userProfiles:[KindUser] = []
        let group = DispatchGroup()
        self.loadUserIDsInCircle(set: set) { (userIds) in
            guard let userIds = userIds else {return}
            userIds.forEach({ (id) in
                group.enter()
                KindUserSettingsManager.sharedInstance.retrieveAnyUserSettings(userId: id, completion: { (kindUser) in
                    if let kindUser = kindUser {
                        userProfiles.append(kindUser)
                    }
                    group.leave()
                })
            })
            group.notify(queue: .main) {
                completion?(userProfiles)
            }
        }
    }
    
    //SAVE MAP SNAP
    func uploadMapSnap(mapImageData: Data, completion: ((String?)->())?) {
        let imageName = NSUUID().uuidString
        let storageRef = Storage.storage().reference(withPath: "map_images").child("\(imageName).jpg")
        
        storageRef.putData(mapImageData, metadata: nil, completion: { (metadata, error) in
            if error != nil {
                print(error!)
                return
            }
            
            storageRef.downloadURL(completion: { (url, error) in
                if error != nil {
                    print(error!)
                    return
                }
                
                if let urlstring = url?.absoluteString {
                    completion?(urlstring)
                } else {
                    completion?(nil)
                }
 
            })
            
            
        })
    }

    
    func observeCircleSetFirebase(circleId: String) {
        let db = Firestore.firestore()
        circleSnapShotListener = db.collection("kindcircles").document(circleId).addSnapshotListener { (document, err) in
            if let err = err {
                print(err)
                return
            }
            guard (document?.data()) != nil else {
                print("no snapshot data on observeCircleSetFirebase")
                return
            }
            print("circle changed")
            let set:CircleAnnotationSet = CircleAnnotationSet(document: document!)
            // reload SET with new info.
            self.currentlySelectedAnnotationView?.circleDetails = set
            // let client now there is a new loaded set.
            self.setChangedOnCircleCallback?(set)
            
        }
    }
    
    
}


//========
// Old - before refactoring

//    func changeCircleAdminTo(userId: String, completion: (()->())?) {
//        let db = Firestore.firestore()
//        guard let circleId = currentlySelectedAnnotationView?.circleDetails?.circleId else {return}
//
//        let circlesRef = db.collection("kindcircles").document(circleId)
//        //ArrayUnion() adds elements to an array but only elements not already present.
//        circlesRef.updateData(["admin" : userId]) { (err) in
//            if let err = err {
//                print(err)
//                return
//            }
//            completion?()
//        }
//
//    }

//    func flagCircleAsDeleted(completion: (()->())?) {
//        let db = Firestore.firestore()
//        guard let circleId = currentlySelectedAnnotationView?.circleDetails?.circleId else {return}
//
//        let circlesRef = db.collection("kindcircles").document(circleId)
//        //ArrayUnion() adds elements to an array but only elements not already present.
//        circlesRef.updateData(["deleted" : true]) { (err) in
//            if let err = err {
//                print(err)
//                return
//            }
//            completion?()
//        }
//
//    }

//    func togglePublicOrPrivate(isPrivate: Bool, completion: (()->())?) {
//        let db = Firestore.firestore()
//        guard let circleId = currentlySelectedAnnotationView?.circleDetails?.circleId else {return}
//
//        let circlesRef = db.collection("kindcircles").document(circleId)
//        //ArrayUnion() adds elements to an array but only elements not already present.
//        circlesRef.updateData(["isprivate" : isPrivate]) { (err) in
//            if let err = err {
//                print(err)
//                return
//            }
//            completion?()
//        }
//
//    }

//    func removeCurrentlySelectedCircle(completion: @escaping ((Bool)->())) {
//        let db = Firestore.firestore()
//        if !isSelectedTemporaryCircleAnnotation {
//            guard let set = currentlySelectedAnnotationView?.circleDetails else { return}
//            db.collection("kindcircles").document(set.circleId).delete() { err in
//                if let err = err {
//                    print("Error removing document: \(err)")
//                    completion(false)
//                } else {
//                    print("Document successfully removed!")
//                    completion(true)
//                    self.currentlySelectedAnnotationView = nil
//                    //self.setDeletedCircleObserver?(set)
//                }
//            }
//        }
//
//    }
