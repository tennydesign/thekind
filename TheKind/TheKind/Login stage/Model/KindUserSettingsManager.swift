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

enum UserFieldTitle: String {
    case name = "name",
    year = "year",
    email = "email",
    photoURL = "photoURL",
    driver = "driver",
    kind = "kind",
    currentLandingView = "currentLandingView",
    circles = "circles"
}

public class KindUserSettingsManager {
    
    var loggedUserName: String?
    
    var updateHUDWithUserSettings: (()->())?
    var userSignedIn: (()->())?
    
    var userFields: [String: Any] = [:]
    var currentUserImageURL: String = ""
    static let sharedInstance = KindUserSettingsManager()
    
    private init() {}
    
    
     // Initialize userFields
    func initializeUserFields(email: String) {
        let suggestedUsername = String(email.split(separator: "@").first ?? "")
        loggedUserName = suggestedUsername
        userFields[UserFieldTitle.name.rawValue] = suggestedUsername
        userFields[UserFieldTitle.email.rawValue] = email
        updateUserSettings() { (err) in
            if let err = err {
                print(err)
                return
            }
            // let the client know user signed in and update was successful.
            //TODO: check if MAINCONTROL IS LOADED!!
            self.userSignedIn?()
            // turn observer ON.
            self.observeUserSettings()
        }
        

    }
    
    
    // OBSERVE!
    func observeUserSettings() {
        let db = Firestore.firestore()
        db.collection("usersettings").document((Auth.auth().currentUser?.uid)!).addSnapshotListener { (snapshot, err) in
            if let err = err {
                print(err)
                return
            }
            guard let data = snapshot?.data() else {
                print("no snapshot data on observerUserSettings")
                return
            }
            self.userFields = data
            
            // Let the client know there were data retrieval
            self.updateHUDWithUserSettings?()
         }
    }
    
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
    func retrieveUserSettings(completion:@escaping (Bool?)->()) {
        let db = Firestore.firestore()
        db.collection("usersettings").document((Auth.auth().currentUser?.uid)!).getDocument {  (document,err) in
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
            
            self.userFields = data
            completion(true)
            // let the client know there was data retrieval.
            self.updateHUDWithUserSettings?()
        }
    }

}










// RETRIEVE
//    func checkUserOnboardingView(completion:@escaping ((Int)?)->()) {
//        let db = Firestore.firestore()
//        db.collection("usersettings").document((Auth.auth().currentUser?.uid)!).getDocument { (document, err) in
//            if let err = err {
//                print("error \(err)")
//                completion(nil)
//            } else {
//                if let document = document, document.exists{
//                    if let result = document.data() {
//                        if let onboardingView = result[UserFieldTitle.currentLandingView.rawValue] as? Int {
//                            completion(onboardingView)
//                        } else {
//                            self.userFields[UserFieldTitle.currentLandingView.rawValue] = ActionViewName.UserNameView.rawValue
//                            completion(nil)
//                        }
//                    }
//                }  else {
//                    self.userFields[UserFieldTitle.currentLandingView.rawValue] = ActionViewName.UserNameView.rawValue
//                    completion(nil)
//                }
//
//            }
//        }
//    }

