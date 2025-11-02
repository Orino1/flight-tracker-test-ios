//
//  AppDelegate.swift
//  testprotect
//
//  Created by orino on 1/11/2025.
//

import Firebase
import FirebaseCore
import FirebaseMessaging
import UserNotifications
import SwiftUI

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()

        Messaging.messaging().delegate = self

        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { _, _ in })

        application.registerForRemoteNotifications()

        Messaging.messaging().token { token, error in
            if let error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token {
                print("FCM registration token: \(token)")
            }
        }

        return true
    }

    func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Oh no! Failed to register for remote notifications with error \(error)")
    }

    func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var readableToken = ""
        for index in 0 ..< deviceToken.count {
            readableToken += String(format: "%02.2hhx", deviceToken[index] as CVarArg)
        }
        print("Received an APNs device token: \(readableToken)")
    }
}

extension AppDelegate: MessagingDelegate {
    @objc func messaging(_: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        Task { @MainActor in
            // MARK: - this is the most hacky sulotion for such a problem that may or may not accure lol
            while AuthViewModel.shared == nil {
                print("------------")
                print("if this print stm shown once or twice we are good, if shown none this is even better, if it keeps looping we have a problem")
                print("------------")
                try? await Task.sleep(nanoseconds: 500_000_000)
            }
            // the problem is as following

            // AuthViewModel have a singlton .shared -> its created as soon as we initiated a new instance of that class aka in main app on line @StateObject private var authViewModel = AuthViewModel()
            
            // however if this function runs before that ( wich i assum an app delegate would really be invoked before everything
            
            // when we call await AuthViewModel.shared?.getIdToken() its gonna be nil and we may never get the FCM to our backend this way
            
            // so the above sulotion of checking each 0.3s in theory should work ( but still a dirty trick lol )

            let authToken = await AuthViewModel.shared?.getIdToken()
            print("Firebase token: \(String(describing: fcmToken))")
            print("User auth token: \(String(describing: authToken))")
            await sendRequestWithFCM(bearer: authToken ?? "", fcmToken: fcmToken ?? "")
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _: UNUserNotificationCenter,
        willPresent _: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([[.banner, .list, .sound]])
    }

    func userNotificationCenter(
        _: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        NotificationCenter.default.post(
            name: Notification.Name("didReceiveRemoteNotification"),
            object: nil,
            userInfo: userInfo
        )
        completionHandler()
    }
}
