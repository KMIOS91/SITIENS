//
//  HydrationTodayWidget.swift
//  LiveActivity
//
//  Widget « aujourd'hui » : quantité d'eau bue / objectif du jour.
//

import WidgetKit
import SwiftUI

struct HydrationEntry: TimelineEntry {
    let date: Date
    let snapshot: HydrationSnapshot?

    var liters: Double { snapshot?.litersToday(now: date) ?? 0 }
    var target: Double { snapshot?.targetLiters ?? 0 }
    var progress: Double { snapshot?.progressToday(now: date) ?? 0 }
    var hasProfile: Bool { target > 0 }
}

struct HydrationProvider: TimelineProvider {
    func placeholder(in context: Context) -> HydrationEntry {
        HydrationEntry(date: .now, snapshot: .init(liters: 1.2, targetLiters: 2, updatedAt: .now))
    }

    func getSnapshot(in context: Context, completion: @escaping (HydrationEntry) -> Void) {
        completion(context.isPreview ? placeholder(in: context)
                                     : HydrationEntry(date: .now, snapshot: SharedHydrationStore.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HydrationEntry>) -> Void) {
        let now = Date.now
        let snapshot = SharedHydrationStore.load()
        // Une seconde entrée à minuit remet l'affichage à zéro, même si l'app n'est pas ouverte.
        let midnight = Calendar.current.startOfDay(for: now.addingTimeInterval(86_400))
        let entries = [
            HydrationEntry(date: now, snapshot: snapshot),
            HydrationEntry(date: midnight, snapshot: snapshot),
        ]
        // L'app redemande une mise à jour à chaque verre ajouté (WidgetCenter).
        completion(Timeline(entries: entries, policy: .after(midnight)))
    }
}

struct HydrationTodayWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: SharedHydrationStore.widgetKind, provider: HydrationProvider()) { entry in
            HydrationWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    LinearGradient(colors: [.blue.opacity(0.3), .cyan.opacity(0.2)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                }
        }
        .configurationDisplayName("Hydratation du jour")
        .description("Quantité d'eau bue aujourd'hui par rapport à votre objectif.")
        .supportedFamilies([.systemSmall, .accessoryCircular, .accessoryRectangular])
    }
}

// MARK: - Vues

private struct HydrationWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: HydrationEntry

    var body: some View {
        switch family {
        case .accessoryCircular: circular
        case .accessoryRectangular: rectangular
        default: small
        }
    }

    private var litersText: Text {
        Text("\(entry.liters, format: .number.precision(.fractionLength(1))) L")
    }

    private var targetText: Text {
        Text("\(entry.target, format: .number.precision(.fractionLength(1))) L")
    }

    /// Écran d'accueil.
    private var small: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Hydratation", systemImage: "drop.fill")
                .font(.caption.bold())
                .foregroundStyle(.blue)

            Spacer(minLength: 0)

            if entry.hasProfile {
                litersText
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.6)
                Text("sur \(targetText) aujourd'hui")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                ProgressView(value: entry.progress)
                    .tint(entry.progress >= 1 ? .green : .blue)
            } else {
                Text("Choisissez un profil dans l'app")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    /// Écran verrouillé, rond.
    private var circular: some View {
        Gauge(value: entry.progress) {
            Image(systemName: "drop.fill")
        } currentValueLabel: {
            Text("\(entry.liters, format: .number.precision(.fractionLength(1)))")
        }
        .gaugeStyle(.accessoryCircular)
    }

    /// Écran verrouillé, rectangulaire.
    private var rectangular: some View {
        VStack(alignment: .leading, spacing: 2) {
            Label("Hydratation", systemImage: "drop.fill")
                .font(.headline)
            if entry.hasProfile {
                Text("\(litersText) / \(targetText)")
                ProgressView(value: entry.progress)
            } else {
                Text("Choisissez un profil")
            }
        }
    }
}

// MARK: - Aperçus

#Preview("Accueil", as: .systemSmall) {
    HydrationTodayWidget()
} timeline: {
    HydrationEntry(date: .now, snapshot: .init(liters: 1.2, targetLiters: 2, updatedAt: .now))
    HydrationEntry(date: .now, snapshot: .init(liters: 2, targetLiters: 2, updatedAt: .now))
    HydrationEntry(date: .now, snapshot: nil)
}
