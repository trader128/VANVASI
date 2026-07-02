import WidgetKit
import SwiftUI

struct VANVASIWidgetEntry: TimelineEntry {
    let date: Date
    let lockEnabled: Bool
}

struct VANVASIWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> VANVASIWidgetEntry {
        VANVASIWidgetEntry(date: .now, lockEnabled: true)
    }

    func getSnapshot(in context: Context, completion: @escaping (VANVASIWidgetEntry) -> Void) {
        completion(currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<VANVASIWidgetEntry>) -> Void) {
        let entry = currentEntry()
        let next = Calendar.current.date(byAdding: .minute, value: 15, to: .now)!
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    private func currentEntry() -> VANVASIWidgetEntry {
        VANVASIWidgetEntry(date: .now, lockEnabled: SharedStore.monkLockEnabled)
    }
}

struct VANVASIWidgetView: View {
    let entry: VANVASIWidgetEntry

    private let accent = Color(red: 0.79, green: 0.66, blue: 0.38)
    private let void = Color(red: 0.04, green: 0.04, blue: 0.05)

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: entry.lockEnabled ? "lock.fill" : "lock.open")
                    .foregroundStyle(accent)
                Text("VANVASI")
                    .font(.caption2.weight(.semibold))
                    .tracking(2)
                    .foregroundStyle(.secondary)
            }

            Text(entry.lockEnabled ? "Monk mode" : "Unlocked")
                .font(.title3.weight(.light))
                .foregroundStyle(.primary)

            Text(entry.lockEnabled ? "Calls & messages only" : "Lock is off")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [Color(red: 0.12, green: 0.11, blue: 0.20), void],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

@main
struct VANVASIWidget: Widget {
    let kind = "VANVASIWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: VANVASIWidgetProvider()) { entry in
            VANVASIWidgetView(entry: entry)
        }
        .configurationDisplayName("VANVASI")
        .description("Your focus lock status.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
