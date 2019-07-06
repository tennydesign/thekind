//
//  KindUser.swift
//  TheKind
//
//  Created by Tenny on 1/7/19.
//  Copyright © 2019 tenny. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore
import RxSwift
import RxCocoa

enum UserFieldTitle: String {
    case name = "name",
    year = "year",
    email = "email",
    photoURL = "photoURL",
    driver = "driver",
    kind = "kind",
    currentLandingView = "currentLandingView",
    circles = "circles",
    uid = "uid",
    ref = "ref"
}

struct KindUser {
    var uid: String?
    var circles: [String]?
    var currentLandingView: Int?
    var driver: String?
    var email: String?
    var kind: Int?
    var name: String?
    var photoURL: String?
    var year: Int?

    var ref: DocumentReference?
    
    init(document: DocumentSnapshot) {
        name = document.data()?[UserFieldTitle.name.rawValue] as? String
        photoURL = document.data()?[UserFieldTitle.photoURL.rawValue] as? String
        kind = document.data()?[UserFieldTitle.kind.rawValue] as? Int
        email = document.data()?[UserFieldTitle.email.rawValue] as? String
        photoURL = document.data()?[UserFieldTitle.photoURL.rawValue] as? String
        year = document.data()?[UserFieldTitle.year.rawValue] as? Int
        driver = document.data()?[UserFieldTitle.driver.rawValue] as? String
        currentLandingView = document.data()?[UserFieldTitle.currentLandingView.rawValue] as? Int
        circles = document.data()?[UserFieldTitle.circles.rawValue] as? [String]
        uid = document.documentID
        ref = document.reference
    }
    
}

public class KindUserSettingsManager {
    
    var loggedUserName: String?
    
    var updateHUDWithUserSettings: (()->())?
    var userSignedIn: (()->())?
    var userFields: [String: Any] = [:]
    var loggedUser: KindUser?
    var currentUserImageURL: String = ""
    private var userSettingsRxBehaviorRelayPublisher = BehaviorRelay<KindUser?>(value: nil)
    var userSettingsRxObserver:Observable<KindUser?> {
        return userSettingsRxBehaviorRelayPublisher.asObservable()
    }
    static let sharedInstance = KindUserSettingsManager()
    
    private init() {}
    
    
    // Initialize userFields
    //Called by AppDelegate on google login
    //Called by HandleLoginWithFirestore on email login
    //TODO: Should also be called on silent login
    func initializeUserFields(email: String) {
        //try to retrieve settings
        attemptToRetrieveLoggedUserSettings { (success) in
            //if fails, create first settings (name and email)
            if !success {
                let suggestedUsername = String(email.split(separator: "@").first ?? "")
                self.loggedUserName = suggestedUsername
                self.userFields[UserFieldTitle.name.rawValue] = suggestedUsername
                self.userFields[UserFieldTitle.email.rawValue] = email
                self.updateUserSettings() { (err) in
                    if let err = err {
                        print(err)
                        return
                    }
                }
            } else {
                // Update all interface controls with retrieved data.
                self.loggedUserName = self.loggedUser?.name ?? ""
                self.updateHUDWithUserSettings?()

            }

            // let the client know user signed in
            self.userSignedIn?()
            // turn observer ON.
            //self.observeUserSettings() - old
            //Rx version.
            self.userSettingsObserver()
        }

    }
    
    
    // OBSERVE!
    // Use a real observer here, just so all screens can  subscribe.
    
    func userSettingsObserver() {
        let db = Firestore.firestore()
        db.collection("usersettings").document((Auth.auth().currentUser?.uid)!).addSnapshotListener { (document, err) in
            if let err = err {
                print(err)
                return
            }
            guard let data = document?.data() else {
                print("no snapshot data on observerUserSettings")
                return
            }
            self.userFields = data
            
            //save user also as KindUser object. Always updating when it changes.
            let kindUser = KindUser(document: document!)
            self.loggedUser = kindUser
            
            // Let the client know there was data retrieval
            self.userSettingsRxBehaviorRelayPublisher.accept(kindUser)
        }

    }
    
//    func observeUserSettings() {
//        let db = Firestore.firestore()
//        db.collection("usersettings").document((Auth.auth().currentUser?.uid)!).addSnapshotListener { (document, err) in
//            if let err = err {
//                print(err)
//                return
//            }
//            guard let data = document?.data() else {
//                print("no snapshot data on observerUserSettings")
//                return
//            }
//            self.userFields = data
//
//            //save user also as KindUser object. Always updating when it changes.
//            let kindUser = KindUser(document: document!)
//            self.loggedUser = kindUser
//
//            // Let the client know there were data retrieval
//            self.updateHUDWithUserSettings?()
//         }
//    }
    
    //SAVE
    func updateUserSettings(completion: ((Error?)->())?) {
        let db = Firestore.firestore()
        db.collection("usersettings").document((Auth.auth().currentUser?.uid)!).updateData(userFields) { (err) in
            if let err = err {
                if err.localizedDescription.contains("No document to update") {
                    //Create user from scratch
                    self.createUserSettingsDocument(completion: { (err) in
                        if let err = err {
                            completion?(err)
                        }
                        //print("New UserSettingd Document created successfully")
                        //print("Fields updated successfully")
                        completion?(nil)
                        return
                        
                    })
                    
                }
            } else {
                completion?(nil)
            }
            
        }
        
    }
    
    func updateUserCircleArray(newElement: String) {
        let db = Firestore.firestore()
        let circlesRef = db.collection("usersettings").document((Auth.auth().currentUser?.uid)!)
        //updates array by keeping it unique
        circlesRef.updateData(["circles" : FieldValue.arrayUnion([newElement])])
    }
    
    func removeFromUserCircleArray(removingElement: String) {
        let db = Firestore.firestore()
        let circlesRef = db.collection("usersettings").document((Auth.auth().currentUser?.uid)!)
        circlesRef.updateData(["circles" : FieldValue.arrayRemove([removingElement])
            ])
    }
    
    //SAVE
    private func createUserSettingsDocument(completion: @escaping (Error?)->()) {
        let db = Firestore.firestore()
        db.collection("usersettings").document((Auth.auth().currentUser?.uid)!).setData(userFields, completion: { (err) in
            if let err = err {
                completion(err)
                return
            }
            completion(nil)
        })
    }
    
    //SAVE
    func uploadUserPicture(profileImageData: Data) {
        let imageName = NSUUID().uuidString
        let storageRef = Storage.storage().reference(withPath: "profile_images").child("\(imageName).jpg")
        
        storageRef.putData(profileImageData, metadata: nil, completion: { (metadata, error) in
            if error != nil {
                print(error!)
                return
            }
            
            storageRef.downloadURL(completion: { (url, error) in
                if error != nil {
                    print(error!)
                    return
                }

                self.userFields[UserFieldTitle.photoURL.rawValue] = url?.absoluteString
        
                self.updateUserSettings(completion: nil)
            })
            
            
        })
    }
    
    // RETRIEVE
    
    func retrieveAnyUserSettings(userId: String, completion: ((KindUser?)->())?) {
        let db = Firestore.firestore()
        db.collection("usersettings").document(userId).getDocument {  (document,err) in
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
            
            let user:KindUser = KindUser(document: document!)
            completion?(user)
        }
    }
    
    //Login purposes only
    private func attemptToRetrieveLoggedUserSettings(completion:@escaping (Bool)->()) {
        let db = Firestore.firestore()
        guard let uid = Auth.auth().currentUser?.uid else {return}
        db.collection("usersettings").document(uid).getDocument {  (document,err) in
            if let err = err {
                print(err)
                completion(false)
                return
            }
            guard let data = document?.data() else
            {
                print("no data")
                completion(false)
                return
            }
            
            let kindUser = KindUser(document: document!)
            self.loggedUser = kindUser
            self.userFields = data
            completion(true)
        }
    }
    
    func retrieveAllUsers(completion:@escaping ([KindUser]?)->()) {
        let db = Firestore.firestore()
        var kindUsers: [KindUser]?
        db.collection("usersettings").getDocuments {  (document,err) in
            if let err = err {
                print(err)
                completion(nil)
                return
            }
            document?.documents.forEach({ (document) in
                let user: KindUser = KindUser(document: document)
                kindUsers?.append(user)
            })
            completion(kindUsers)
            
        }
    }
    
    func retrieveUserByKeyword(keyword: String, completion:@escaping ((KindUser?)->())) {
        let db = Firestore.firestore()
        let ref = db.collection("usersettings")
        let keyword = keyword.lowercased()
        let query = ref.whereField("email", isEqualTo: keyword)
        query.getDocuments {  (document,err) in
            if let err = err {
                print(err)
                completion(nil)
                return
            }

            if let document = document?.documents.first {
                let user: KindUser = KindUser(document: document)
                completion(user)
                return
            }
            //otherwise
            completion(nil)


        }
    }

}



//    func retrieveUserPhoto(userId: String, completion: @escaping ((URL?)->())) {
//        let db = Firestore.firestore()
//        db.collection("usersettings").document(userId).getDocument {  (document,err) in
//            if let err = err {
//                print(err)
//                completion(nil)
//                return
//            }
//            guard let data = document?.data() else
//            {
//                print("no data")
//                completion(nil)
//                return
//            }
//            guard let photoURL = data[UserFieldTitle.photoURL.rawValue] as? String else {
//                completion(nil)
//                return
//            }
//
//            let url = URL(string: photoURL)
//
//            completion(url)
//        }
//    }
