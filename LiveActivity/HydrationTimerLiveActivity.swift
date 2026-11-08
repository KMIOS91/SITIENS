//
//  HydrationTimerLiveActivity.swift
//  LiveActivity
//
//  Minuteur d'hydratation sur l'écran verrouillé et dans la Dynamic Island.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct HydrationTimerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: HydrationTimerAttributes.self) { context in
            LockScreenView(attributes: context.attributes, state: context.state, isStale: context.isStale)
                .activityBackgroundTint(Color.cyan.opacity(0.25))
                .activitySystemActionForegroundColor(.blue)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label("Hydratation", systemImage: "drop.fill")
                        .font(.headline)
                        .foregroundStyle(.cyan)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    RemainingText(state: context.state, isStale: context.isStale)
                        .font(.title2.monospacedDigit().bold())
                        .multilineTextAlignment(.trailing)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    TimerProgress(attributes: context.attributes, state: context.state, isStale: context.isStale)
                        .tint(.cyan)
                }
            } compactLeading: {
                Image(systemName: "drop.fill")
                    .foregroundStyle(.cyan)
            } compactTrailing: {
                RemainingText(state: context.state, isStale: context.isStale)
                    .monospacedDigit()
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 56)
            } minimal: {
                Image(systemName: "drop.fill")
                    .foregroundStyle(.cyan)
            }
            .keylineTint(.cyan)
        }
    }
}

// MARK: - Écran verrouillé

private struct LockScreenView: View {
    let attributes: HydrationTimerAttributes
    let state: HydrationTimerAttributes.ContentState
    let isStale: Bool

    private var finished: Bool { isFinishedNow(state, isStale: isStale) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label {
                    Text(finished ? "Il est temps de boire !" : "Prochaine hydratation")
                        .foregroundStyle(.primary)
                } icon: {
                    Image(systemName: finished ? "drop.fill" : "stopwatch")
                        .foregroundStyle(.cyan)
                }
                .font(.headline)
                Spacer()
                if state.isPaused {
                    Text("En pause")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                }
            }
            if !finished {
                RemainingText(state: state, isStale: isStale)
                    .font(.system(size: 40, weight: .bold, design: .rounded).monospacedDigit())
            }
            TimerProgress(attributes: attributes, state: state, isStale: isStale)
                .tint(finished ? .blue : .orange)
        }
        .padding()
    }
}

// MARK: - Composants

/// Vrai si le minuteur est terminé au moment où la vue est dessinée.
private func isFinishedNow(_ state: HydrationTimerAttributes.ContentState, isStale: Bool) -> Bool {
    state.isFinished || isStale || (state.frozenRemaining == nil && state.endDate <= .now)
}

private struct RemainingText: View {
    let state: HydrationTimerAttributes.ContentState
    let isStale: Bool

    var body: some View {
        if isFinishedNow(state, isStale: isStale) {
            Text("Buvez !")
        } else if let frozen = state.frozenRemaining {
            Text(Duration.seconds(frozen), format: .time(pattern: frozen >= 3600 ? .hourMinuteSecond : .minuteSecond))
        } else {
            // Décompte géré par le système : il continue même quand l'app est suspendue.
            Text(timerInterval: Date.now...state.endDate, countsDown: true)
        }
    }
}

private struct TimerProgress: View {
    let attributes: HydrationTimerAttributes
    let state: HydrationTimerAttributes.ContentState
    let isStale: Bool

    var body: some View {
        let total = max(attributes.totalSeconds, 1)
        if isFinishedNow(state, isStale: isStale) {
            ProgressView(value: 1)
        } else if let frozen = state.frozenRemaining {
            ProgressView(value: Double(total - frozen), total: Double(total))
        } else {
            let start = state.endDate.addingTimeInterval(-TimeInterval(total))
            ProgressView(timerInterval: start...state.endDate, countsDown: false) {
                EmptyView()
            } currentValueLabel: {
                EmptyView()
            }
        }
    }
}

// MARK: - Aperçus

extension HydrationTimerAttributes {
    fileprivate static var preview: HydrationTimerAttributes { .init(totalSeconds: 1800) }
}

extension HydrationTimerAttributes.ContentState {
    fileprivate static var running: Self { .init(endDate: .now.addingTimeInterval(1200), frozenRemaining: nil) }
    fileprivate static var paused: Self { .init(endDate: .now.addingTimeInterval(600), frozenRemaining: 600) }
    fileprivate static var finished: Self { .init(endDate: .now, frozenRemaining: 0) }
}

#Preview("Écran verrouillé", as: .content, using: HydrationTimerAttributes.preview) {
    HydrationTimerLiveActivity()
} contentStates: {
    HydrationTimerAttributes.ContentState.running
    HydrationTimerAttributes.ContentState.paused
    HydrationTimerAttributes.ContentState.finished
}
