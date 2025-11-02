//
//  AuthViewModel.swift
//  testProject
//
//  Created by orino on 2/11/2025.
//

import Foundation
import FirebaseAuth
import Combine
import SwiftUI
import FirebaseAuth
import FirebaseMessaging

@MainActor
final class AuthViewModel: ObservableObject {
    // this is new and will be used in our app delegate -> when we init an instance of this class ( that we inject into our sub views ) we will store the refrence for it in a static var as a singlton so we can access it from with in the app delegate as when sending the FCM we need the token of the user + to keep logic of creating ano user if logged out
    static var shared: AuthViewModel?

    // we need a loading published var here -> however due to teh simplicity of ui as of now its not important
    @Published var isLoggedIn: Bool = false
    @Published var email: String? = nil

    enum LoginResult {
        case success
        case wrongData
        case emailNotVerified
    }

    init() {
        Task { @MainActor in
            // here we hold refrence for initiated instance as a shared singlton
            AuthViewModel.shared = self
            _ = Auth.auth().addStateDidChangeListener { _, user in
                if let user = user {
                    self.isLoggedIn = user.isEmailVerified
                    self.email = user.email
                } else {
                    // we dont have a user
                    self.isLoggedIn = false
                    self.email = nil
                    self.signInAnonymouslyIfNeeded()
                }
            }
        }
    }

    func signInAnonymouslyIfNeeded() {
        if Auth.auth().currentUser == nil {
            Auth.auth().signInAnonymously { result, error in
                if let error = error {
                    print("error when singing as anonymous user: ", error.localizedDescription)
                } else if let _ = result?.user {
                    print("Signed as anonymous user")
                }
            }
        }
    }

    // we are using it for both anno and signed users ( basiclly user is always signed in so we can link data to with his FCM + trasfer flights from guest to real account )
    func getIdToken() async -> String? {
        guard let user = Auth.auth().currentUser else {
            return nil
        }

        do {
            let token = try await user.getIDToken()
            return token
        } catch {
            print("error fetching user token : \(error.localizedDescription)")
            return nil
        }
    }

    // its not robust -> but we are carefull when to use it so no worry
    func register(email: String, password: String) async -> Bool {
        guard let currentUser = Auth.auth().currentUser else {
            print("no anonymous user to link")
            return false
        }

        let credential = EmailAuthProvider.credential(withEmail: email, password: password)

        do {
            let result = try await currentUser.link(with: credential)
            print("linked anonymous account with email:", result.user.email ?? "unknown")
            try await result.user.sendEmailVerification()
            
            // force update as in soe cases it wont be updated unless re-lunched
            await MainActor.run {
                self.email = result.user.email
                self.isLoggedIn = result.user.isEmailVerified
            }
            
            return true
        } catch let error as NSError {
            // we will not show hey this email is already used so w just return false
            print("error during account registration: ", error.localizedDescription)
            return false
        }
    }

    func login(email: String, password: String) async -> LoginResult {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)

            if result.user.isEmailVerified {
                await MainActor.run {
                    self.isLoggedIn = true
                }
                return .success
            } else {
                return .emailNotVerified
            }
        } catch {
            return .wrongData
        }
    }

    func logout() {
        do {
            try Auth.auth().signOut()
        } catch let error as NSError {
            print("error during logout: ", error.localizedDescription)
        }
    }
}
