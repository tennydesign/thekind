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

enum UserFields: String {
    case name = "name",
    year = "year",
    email = "email",
    photoURL = "photoURL",
    driver = "driver",
    kind = "kind"
}

public class KindUserManager {
    static var loggedUserEmail: String? {
        get {
            return Auth.auth().currentUser?.email
        }
        set {
            
        }
    }
    static var loggedUserName: String!
    static var isUserOnboarding: Bool = true
    
    var userFields: [String: Any] = [:]
    
    func updateUserSettings() {
        let db = Firestore.firestore()
        db.collection("usersettings").document((Auth.auth().currentUser?.uid)!).updateData(userFields) { (err) in
        //print("ERROR SAVING: \(err?.localizedDescription)")
        if let err = err {
            if err.localizedDescription.contains("No document to update") {
                //Create user from scratch
                self.createNewUserSettings(completion: { (err) in
                    if let err = err {
                        fatalError(err.localizedDescription)
                    }
                    
                    
                })
                
            }
        }
            
            
        }
        
    }
    
    //Called by updateUserSettings()
    private func createNewUserSettings(completion: @escaping (Error?)->()) {
        let db = Firestore.firestore()
        db.collection("usersettings").document((Auth.auth().currentUser?.uid)!).setData(userFields, completion: { (err) in
            if let err = err {
                completion(err)
                return
            }
            completion(nil)
        })
    }
    
    func loginWithEmailAndPassword(_ email: String, _ password: String, completion: @escaping (Error?)->()) {
        // Will try to sign in  user.
        Auth.auth().signIn(withEmail: email, password: password, completion: { (res, err) in
            if let err = err {
                completion(err)
                return
            }
            
            //KindUserManager.loggedUserEmail = email
            KindUserManager.loggedUserName = String(email.split(separator: "@").first ?? "")
            
            completion(nil)
            
        })
    }
    
    func createNewUser(_ email: String, _ password: String, completion:  @escaping (Error?)->()) {
        Auth.auth().createUser(withEmail: email, password: password) { (res, err) in
            if let err = err {
                print(err)
                completion(err)
                return
            }
            
            //KindUserManager.loggedUserEmail = email
            KindUserManager.loggedUserName = String(email.split(separator: "@").first ?? "")
            self.userFields[UserFields.name.rawValue] = KindUserManager.loggedUserName!
            self.userFields[UserFields.email.rawValue] = email
            self.updateUserSettings()
            completion(nil)
            
            // ADD CODE TO SETUP NEW USER IN THE DATABASE HERE.
            
            
        }
    }
    
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
                self.userFields[UserFields.photoURL.rawValue] = url?.absoluteString
                self.updateUserSettings()
                
            })
            
            
        })
    }
}
