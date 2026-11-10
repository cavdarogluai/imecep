//
// ImecepDisasterPanel.swift
// imeCep — one-tap "I'm safe" / SOS broadcast over the Bluetooth mesh, plus a
// low-power helper. iOS does not let an app close other apps or switch Low Power
// Mode itself; the helper dims this screen and tells the user how to turn it on.
//

import SwiftUI
#if os(iOS)
import UIKit
#endif

@MainActor
final class ImecepDisaster: ObservableObject {
    static let shared = ImecepDisaster()
    weak var chatViewModel: ChatViewModel?
    private var rebroadcastTask: Task<Void, Never>?

    static var isTurkish: Bool {
        (Locale.preferredLanguages.first ?? "").lowercased().hasPrefix("tr")
    }

    static func t(_ tr: String, _ en: String) -> String { isTurkish ? tr : en }

    /// Sends SOS or "I'm safe" to every phone in range as a public mesh message
    /// tagged #imecep:sos / #imecep:safe, then repeats it every 2 minutes for
    /// 30 minutes so phones that arrive later (rescuers, couriers) still get it.
    func sendStatus(sos: Bool) {
        guard let vm = chatViewModel else { return }
        let nick = vm.nickname
        let text = sos
            ? Self.t("🆘 SOS: \(nick) yardım istiyor.", "🆘 SOS: \(nick) needs help.") + " #imecep:sos"
            : Self.t("✅ GÜVENDEYİM: \(nick) güvende.", "✅ I AM SAFE: \(nick) is safe.") + " #imecep:safe"
        vm.meshService.sendMessage(text, mentions: [])
        vm.addMeshOnlySystemMessage(Self.t("Gönderildi: ", "Sent: ") + text)

        rebroadcastTask?.cancel()
        rebroadcastTask = Task { [weak vm] in
            for _ in 0..<15 {
                try? await Task.sleep(nanoseconds: 120 * 1_000_000_000)
                if Task.isCancelled { return }
                vm?.meshService.sendMessage(text, mentions: [])
            }
        }
    }

    func stop() {
        rebroadcastTask?.cancel()
        rebroadcastTask = nil
    }
}

struct ImecepDisasterPanel: View {
    @State private var confirmSos = false
    @State private var lowPowerInfo = false
    @State private var showGuide = false

    var body: some View {
        HStack(spacing: 6) {
            Button {
                ImecepDisaster.shared.sendStatus(sos: false)
            } label: {
                Text(ImecepDisaster.t("GÜVENDEYİM", "I'M SAFE"))
                    .font(.system(size: 13, weight: .bold))
                    .frame(maxWidth: .infinity, minHeight: 36)
            }
            .foregroundColor(.white)
            .background(Color(red: 0.18, green: 0.49, blue: 0.31))
            .clipShape(RoundedRectangle(cornerRadius: 8))

            Button {
                confirmSos = true
            } label: {
                Text("SOS")
                    .font(.system(size: 13, weight: .bold))
                    .frame(maxWidth: .infinity, minHeight: 36)
            }
            .foregroundColor(.white)
            .background(Color(red: 0.71, green: 0.14, blue: 0.09))
            .clipShape(RoundedRectangle(cornerRadius: 8))

            Button {
                #if os(iOS)
                UIScreen.main.brightness = 0.05
                #endif
                lowPowerInfo = true
            } label: {
                Text(ImecepDisaster.t("Afet modu", "Low power"))
                    .font(.system(size: 12))
                    .frame(maxWidth: .infinity, minHeight: 36)
            }
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary.opacity(0.6)))

            Button {
                showGuide = true
            } label: {
                Text(ImecepDisaster.t("Rehber", "Guide"))
                    .font(.system(size: 12))
                    .frame(maxWidth: .infinity, minHeight: 36)
            }
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary.opacity(0.6)))
        }
        .sheet(isPresented: $showGuide) { ImecepGuideView() }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .alert(ImecepDisaster.t("SOS gönderilsin mi?", "Send SOS?"), isPresented: $confirmSos) {
            Button(ImecepDisaster.t("SOS gönder", "Send SOS"), role: .destructive) {
                ImecepDisaster.shared.sendStatus(sos: true)
            }
            Button(ImecepDisaster.t("Vazgeç", "Cancel"), role: .cancel) {}
        } message: {
            Text(ImecepDisaster.t(
                "SOS çağrın Bluetooth ile yakındaki tüm telefonlara gider ve 30 dakika boyunca 2 dakikada bir tekrarlanır. imeCep 112'nin yerine geçmez: ulaşabildiğin anda 112'yi ara.",
                "Your SOS goes to every phone nearby over Bluetooth and is repeated every 2 minutes for 30 minutes. imeCep does not replace 112: call 112 whenever you can."))
        }
        .alert(ImecepDisaster.t("Afet modu", "Low power mode"), isPresented: $lowPowerInfo) {
            Button(ImecepDisaster.t("Tamam", "OK"), role: .cancel) {}
        } message: {
            Text(ImecepDisaster.t(
                "Ekran kısıldı. Denetim Merkezi'nden Düşük Güç Modu'nu aç. Uygulamalar diğer uygulamaları kapatamaz: ekranın altından yukarı kaydırıp diğerlerini kapat. imeCep Bluetooth ile mesaj taşımaya devam eder.",
                "Screen dimmed. Turn on Low Power Mode from Control Center. Apps cannot close other apps for you: swipe up from the bottom and close the others. imeCep keeps relaying messages over Bluetooth."))
        }
    }
}
