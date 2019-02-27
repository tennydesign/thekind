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
    currentLandingView = "currentLandingView"
}

public class KindUserSettingsManager {
    static var loggedUserEmail: String? {
        get {
            return Auth.auth().currentUser?.email
        }
    }
    
    static var loggedUserName: String?
    
    
    var userFields: [String: Any] = [:] {
        didSet {
            updateUserSettings()
        }
    }
    
    private func updateUserSettings() {
        let db = Firestore.firestore()
        db.collection("usersettings").document((Auth.auth().currentUser?.uid)!).updateData(userFields) { (err) in
            if let err = err {
                if err.localizedDescription.contains("No document to update") {
                    //Create user from scratch
                    self.createUserSettingsDocument(completion: { (err) in
                        if let err = err {
                            fatalError(err.localizedDescription)
                        }
                        print("New UserSettingd Document created successfully")
                        print("Fields updated successfully")
                        
                    })
                    
                }
            }
            
            print("Fields updated successfully")
            
        }
        
    }
    
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
    
    func loginWithEmailAndPassword(_ email: String, _ password: String, completion: @escaping (Error?)->()) {
        // Will try to sign in  user.
        Auth.auth().signIn(withEmail: email, password: password, completion: { (res, err) in
            if let err = err {
                completion(err)
                return
            }
            
            //KindUserManager.loggedUserEmail = email
            KindUserSettingsManager.loggedUserName = String(email.split(separator: "@").first ?? "")
            
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
            
            KindUserSettingsManager.loggedUserName = String(email.split(separator: "@").first ?? "")
            self.userFields[UserFieldTitle.name.rawValue] = KindUserSettingsManager.loggedUserName!
            self.userFields[UserFieldTitle.email.rawValue] = email
            self.userFields[UserFieldTitle.currentLandingView.rawValue] = ActionViewName.UserNameView
            completion(nil)
            
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
                self.userFields[UserFieldTitle.photoURL.rawValue] = url?.absoluteString

            })
            
            
        })
    }

    //HERE (finished)
    func checkUserOnboardingView(completion:@escaping ((Int)?)->()) {
        let db = Firestore.firestore()
        db.collection("usersettings").document((Auth.auth().currentUser?.uid)!).getDocument { (document, err) in
            if let err = err {
                print("error \(err)")
                completion(nil)
            } else {
                if let document = document, document.exists{
                    if let result = document.data() {
                        if let onboardingView = result[UserFieldTitle.currentLandingView.rawValue] as? Int {
                            completion(onboardingView)
                        } else {
                            self.userFields[UserFieldTitle.currentLandingView.rawValue] = ActionViewName.UserNameView.rawValue
                            completion(ActionViewName.UserNameView.rawValue)
                        }
                    }
                }

            }
        }
    }
}
