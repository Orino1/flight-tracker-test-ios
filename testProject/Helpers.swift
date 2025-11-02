//
//  Helpers.swift
//  testProject
//
//  Created by orino on 2/11/2025.
//

import Foundation

func sendRequestWithFCM(bearer: String, fcmToken: String) async {
    guard let requestURL = URL(string: "http://127.0.0.1:8000/users/me/fcm-token/refresh") else { return }
    var request = URLRequest(url: requestURL)
    request.httpMethod = "GET"
    request.setValue("Bearer \(bearer)", forHTTPHeaderField: "Authorization")
    request.setValue(fcmToken, forHTTPHeaderField: "X-Fcm-Token")

    do {
        _ = try await URLSession.shared.data(for: request)
    } catch {
        print("req failed:", error)
    }
}

func sendRequestWithBearer(bearer: String) async {
    guard let requestURL = URL(string: "http://127.0.0.1:8000/users/me/hello") else { return }
    var request = URLRequest(url: requestURL)
    request.httpMethod = "GET"
    request.setValue("Bearer \(bearer)", forHTTPHeaderField: "Authorization")

    do {
        _ = try await URLSession.shared.data(for: request)
    } catch {
        print("req failed:", error)
    }
}
