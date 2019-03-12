//
//  HandleLoginWithFirestore.swift
//  TheKind
//
//  Created by Tenny on 3/3/19.
//  Copyright © 2019 tenny. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore
import GoogleSignIn


class HandleLoginWithFirestore {
    
    func loginWithEmailAndPassword(_ email: String, _ password: String, completion: @escaping (Error?)->()) {
        // Will try to sign in  user.
        Auth.auth().signIn(withEmail: email, password: password, completion: { (res, err) in
            if let err = err {
                completion(err)
                return
            }
            
            KindUserSettingsManager.sharedInstance.initializeUserFields(email: email)

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
            
            KindUserSettingsManager.sharedInstance.initializeUserFields(email: email)

            completion(nil)
            
        }
    }

    func signInWithGoogle() {
        GIDSignIn.sharedInstance().signIn()
        
    }

    func signOutWithGoogle() {
        
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            print("trying to sign out")
            GIDSignIn.sharedInstance().signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }

}
