//
// BitchatApp.swift
// bitchat
//
// This is free and unencumbered software released into the public domain.
// For more information, see <https://unlicense.org>
//

import SwiftUI
import UserNotifications

@main
struct BitchatApp: App {
    static let bundleID = Bundle.main.bundleIdentifier ?? "chat.bitchat"
    static let groupID = "group.\(bundleID)"

    @StateObject private var runtime: AppRuntime
    @StateObject private var disappearing: DisappearingMessagesSweeper
    @AppStorage(AppTheme.storageKey) private var appThemeRawValue = AppTheme.matrix.rawValue
    #if os(iOS)
    @Environment(\.scenePhase) var scenePhase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #elseif os(macOS)
    @NSApplicationDelegateAdaptor(MacAppDelegate.self) var appDelegate
    #endif

    init() {
        let rt = AppRuntime()
        _runtime = StateObject(wrappedValue: rt)
        // C4: local disappearing-messages sweeper over the same ConversationStore.
        // Default OFF, so it prunes nothing until the user picks a retention window.
        _disappearing = StateObject(wrappedValue: DisappearingMessagesSweeper(store: rt.conversations))
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.appTheme, AppTheme(rawValue: appThemeRawValue) ?? .matrix)
                .environmentObject(runtime.publicChatModel)
                .environmentObject(runtime.privateInboxModel)
                .environmentObject(runtime.privateConversationModel)
                .environmentObject(runtime.verificationModel)
                .environmentObject(runtime.conversationUIModel)
                .environmentObject(runtime.locationChannelsModel)
                .environmentObject(runtime.peerListModel)
                .environmentObject(runtime.appChromeModel)
                .onAppear {
                    appDelegate.runtime = runtime
                    // imeCep: start the mesh as soon as the app opens.
                    runtime.start()
                }
                .disappearingMessagesSweep(disappearing)   // C4: retention sweep (default off)
                .onOpenURL { url in
                    runtime.handleOpenURL(url)
                }
                #if os(iOS)
                .onChange(of: scenePhase) { newPhase in
                    runtime.handleScenePhaseChange(newPhase)
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    runtime.handleDidBecomeActiveNotification()
                }
                #elseif os(macOS)
                .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
                    runtime.handleMacDidBecomeActiveNotification()
                }
                #endif
        }
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        #endif
    }
}

#if os(iOS)
final class AppDelegate: NSObject, UIApplicationDelegate {
    weak var runtime: AppRuntime?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        runtime?.applicationWillTerminate()
    }
}
#endif

#if os(macOS)
import AppKit

final class MacAppDelegate: NSObject, NSApplicationDelegate {
    weak var runtime: AppRuntime?

    func applicationWillTerminate(_ notification: Notification) {
        runtime?.applicationWillTerminate()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}
#endif

final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    weak var runtime: AppRuntime?

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let identifier = response.notification.request.identifier
        let userInfo = response.notification.request.content.userInfo

        Task { @MainActor in
            self.runtime?.handleNotificationResponse(identifier: identifier, userInfo: userInfo)
        }
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let identifier = notification.request.identifier
        let userInfo = notification.request.content.userInfo

        Task {
            let options = await self.runtime?.presentationOptions(
                forNotificationIdentifier: identifier,
                userInfo: userInfo
            ) ?? [.banner, .sound]
            completionHandler(options)
        }
    }
}
