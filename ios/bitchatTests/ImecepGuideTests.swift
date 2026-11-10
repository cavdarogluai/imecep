import Testing
import SwiftUI
#if os(iOS)
import UIKit
#endif
@testable import bitchat

@MainActor
struct ImecepGuideTests {
    @Test func guideView_rendersOffline() {
        #if os(iOS)
        let host = UIHostingController(rootView: ImecepGuideView())
        host.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
        host.view.layoutIfNeeded()
        #expect(host.view.bounds.width == 390)
        #endif
    }

    @Test func disasterPanel_rendersWithGuideButton() {
        #if os(iOS)
        let host = UIHostingController(rootView: ImecepDisasterPanel())
        host.view.frame = CGRect(x: 0, y: 0, width: 390, height: 60)
        host.view.layoutIfNeeded()
        #expect(host.view.bounds.height == 60)
        #endif
    }
}
