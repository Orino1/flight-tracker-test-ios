//
//  PushNotifications.swift
//  testprotect
//
//  Created by orino on 1/11/2025.
//

import SwiftUI

private enum ScreenType {
    case login
    case regester
}

struct AuthScreenView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        if authViewModel.isLoggedIn {
            VStack(spacing: 12) {
                Text("Welcom")
                Text("Your are logged in")
                Text("with follwing email: \(authViewModel.email ?? "--")")
                Button {
                    authViewModel.logout()
                } label: {
                    Text("Login")
                        .foregroundStyle(Color(.systemBackground))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.primary)
                        .clipShape(.capsule)
                }
                .buttonStyle(.plain)
            }
            .padding()
        } else {
            SharedScreen()
        }
    }
    
    private struct SharedScreen: View {
        @State private var selectedScreen: ScreenType = .login

        var body: some View {
            switch selectedScreen {
            case .login:
                LoginView(selectedScreen: $selectedScreen)
            case .regester:
                RegisterView(selectedScreen: $selectedScreen)
            }
        }
    }
    
    private struct LoginView: View {
        @EnvironmentObject var authViewModel: AuthViewModel
        @Binding var selectedScreen: ScreenType

        @State private var email: String = ""
        @State private var password: String = ""
        
        @State private var alertMsg: String = ""
        @State private var showAlert = false


        var body: some View {
            VStack(spacing: 12) {
                Text("Login")
                TextField("email", text: $email)
                    .foregroundColor(.primary)
                    .font(.system(size: 17))
                    .multilineTextAlignment(.leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(99)
                    .overlay(
                        RoundedRectangle(cornerRadius: 99)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            .shadow(color: Color.black.opacity(0.2), radius: 2, x: 1, y: 1)
                            .clipShape(RoundedRectangle(cornerRadius: 99))
                            .shadow(color: Color.white.opacity(0.3), radius: 2, x: -1, y: -1)
                            .clipShape(RoundedRectangle(cornerRadius: 99))
                    )
                TextField("password", text: $password)
                    .foregroundColor(.primary)
                    .font(.system(size: 17))
                    .multilineTextAlignment(.leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(99)
                    .overlay(
                        RoundedRectangle(cornerRadius: 99)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            .shadow(color: Color.black.opacity(0.2), radius: 2, x: 1, y: 1)
                            .clipShape(RoundedRectangle(cornerRadius: 99))
                            .shadow(color: Color.white.opacity(0.3), radius: 2, x: -1, y: -1)
                            .clipShape(RoundedRectangle(cornerRadius: 99))
                    )
                Button {
                    Task {
                        let result = await authViewModel.login(email: email, password: password)

                        switch result {
                        case .success:
                            // teh view will be gone so do nothing here
                            print("we are good")
                        case .wrongData:
                            alertMsg = "Wrong data"
                            showAlert = true
                        case .emailNotVerified:
                            alertMsg = "email not verified"
                            showAlert = true
                        }
                    }
                    
                } label: {
                    Text("Login")
                        .foregroundStyle(Color(.systemBackground))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.primary)
                        .clipShape(.capsule)
                }
                .buttonStyle(.plain)
                .alert("result", isPresented: $showAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(alertMsg)
                }
                HStack {
                    Spacer()
                    Button {
                        withAnimation {
                            selectedScreen = .regester
                        }
                    } label: {
                        Text("create new account")
                            .underline()
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private struct RegisterView: View {
        @EnvironmentObject var authViewModel: AuthViewModel
        @Binding var selectedScreen: ScreenType

        @State private var email: String = ""
        @State private var password: String = ""
        
        @State private var alertMsg: String = ""
        @State private var showAlert = false

        var body: some View {
            VStack(spacing: 12) {
                Text("Register new account")
                TextField("email", text: $email)
                    .foregroundColor(.primary)
                    .font(.system(size: 17))
                    .multilineTextAlignment(.leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(99)
                    .overlay(
                        RoundedRectangle(cornerRadius: 99)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            .shadow(color: Color.black.opacity(0.2), radius: 2, x: 1, y: 1)
                            .clipShape(RoundedRectangle(cornerRadius: 99))
                            .shadow(color: Color.white.opacity(0.3), radius: 2, x: -1, y: -1)
                            .clipShape(RoundedRectangle(cornerRadius: 99))
                    )
                TextField("password", text: $password)
                    .foregroundColor(.primary)
                    .font(.system(size: 17))
                    .multilineTextAlignment(.leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(99)
                    .overlay(
                        RoundedRectangle(cornerRadius: 99)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            .shadow(color: Color.black.opacity(0.2), radius: 2, x: 1, y: 1)
                            .clipShape(RoundedRectangle(cornerRadius: 99))
                            .shadow(color: Color.white.opacity(0.3), radius: 2, x: -1, y: -1)
                            .clipShape(RoundedRectangle(cornerRadius: 99))
                    )
                Button {
                    Task {
                        let result = await authViewModel.register(email: email, password: password)
                        if result {
                            alertMsg = "Check your email"
                            showAlert = true
                        } else {
                            alertMsg = "Check your input"
                            showAlert = true
                        }
                    }
                } label: {
                    Text("Register")
                        .foregroundStyle(Color(.systemBackground))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.primary)
                        .clipShape(.capsule)
                }
                .buttonStyle(.plain)
                .alert("result", isPresented: $showAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(alertMsg)
                }
                HStack {
                    Spacer()
                    Button {
                        withAnimation {
                            selectedScreen = .login
                        }
                        
                    } label: {
                        Text("login")
                            .underline()
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
//    AuthScreenView()
}
