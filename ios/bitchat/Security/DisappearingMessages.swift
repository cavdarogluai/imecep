//
// DisappearingMessages.swift
// imeCep — Auto-destruct message retention (Aegis spec C4), v1
//
// Part of imeCep, built on bitchat.
//
// Spec C4 asks for messages that self-destruct after a user-defined TTL. This v1
// implements the LOCAL half safely and without touching bitchat's wire protocol:
// a retention window is enforced on THIS device by periodically pruning messages
// older than the window from ConversationStore (its public intent API keeps the
// ID map consistent and emits `.messageRemoved`, so the UI updates for free).
//
// Deliberately conservative for an overnight, un-runtime-tested change:
//   • Default is OFF — until the user picks a window, nothing is pruned.
//   • It only ever calls ConversationStore's existing public `removeMessages`
//     intent; no core store internals are modified.
//   • It does NOT alter the over-the-air packet or BitchatMessage, so it cannot
//     break messaging or sync.
//   • Source of truth is a single UserDefaults key, read fresh on every sweep and
//     written by the settings UI (@AppStorage) — no stale in-memory copy.
//
// FOLLOW-UP (documented, NOT done here — it is a protocol change and must be
// runtime-tested): propagate the chosen TTL to the recipient so BOTH devices
// expire the same message at the same wall-clock (Signal-style "timer on read").
// That needs a field on the wire message + handshake, deferred on purpose.
//

import SwiftUI
import Combine

/// User-selectable retention window. `off` disables pruning entirely.
enum RetentionTTL: String, CaseIterable, Identifiable {
    case off, tenMinutes, oneHour, eightHours, oneDay, oneWeek

    /// Shared persistence key — the settings UI and the sweeper agree on this.
    /// Boring name so decoy-mode storage inspection reveals nothing unusual.
    static let storageKey = "imecep.retention.ttl"

    var id: String { rawValue }

    /// Retention window in seconds, or `nil` when disabled.
    var interval: TimeInterval? {
        switch self {
        case .off:        return nil
        case .tenMinutes: return 10 * 60
        case .oneHour:    return 60 * 60
        case .eightHours: return 8 * 60 * 60
        case .oneDay:     return 24 * 60 * 60
        case .oneWeek:    return 7 * 24 * 60 * 60
        }
    }

    var label: String {
        switch self {
        case .off:        return "Off"
        case .tenMinutes: return "10m"
        case .oneHour:    return "1h"
        case .eightHours: return "8h"
        case .oneDay:     return "24h"
        case .oneWeek:    return "7d"
        }
    }

    /// The currently selected window from persistent storage (the single source
    /// of truth shared with the settings UI).
    static var current: RetentionTTL {
        RetentionTTL(rawValue: UserDefaults.standard.string(forKey: storageKey) ?? "") ?? .off
    }
}

/// Prunes expired messages from every conversation on a coarse cadence.
@MainActor
final class DisappearingMessagesSweeper: ObservableObject {
    private let store: ConversationStore

    init(store: ConversationStore) {
        self.store = store
    }

    /// Remove every message older than the retention window. No-op when off.
    func sweep(now: Date = Date()) {
        guard let interval = RetentionTTL.current.interval else { return }
        let cutoff = now.addingTimeInterval(-interval)
        // conversationIDs is a value-type snapshot; removeMessages mutates the
        // store's collections, so we iterate the snapshot, not a live view.
        for id in store.conversationIDs {
            store.removeMessages(from: id) { $0.timestamp < cutoff }
        }
    }
}

// MARK: - Periodic sweep driver

private struct DisappearingSweepModifier: ViewModifier {
    @ObservedObject var sweeper: DisappearingMessagesSweeper
    @Environment(\.scenePhase) private var scenePhase
    // A coarse cadence is fine — retention is a privacy window, not a stopwatch.
    private let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()

    func body(content: Content) -> some View {
        content
            .onAppear { sweeper.sweep() }
            .onReceive(timer) { _ in sweeper.sweep() }
            // Audit 🟡 H: the 30s timer is suspended while backgrounded, so sweep
            // once more the moment we background — expired messages should not sit
            // in memory while the (possibly-seized) device is idle.
            .onChange(of: scenePhase) { phase in
                if phase == .background { sweeper.sweep() }
            }
    }
}

extension View {
    /// Run the retention sweep on appear and every 30s. Attach once at the root.
    func disappearingMessagesSweep(_ sweeper: DisappearingMessagesSweeper) -> some View {
        modifier(DisappearingSweepModifier(sweeper: sweeper))
    }
}
