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

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: entry.lockEnabled ? "lock.fill" : "lock.open")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.5))

            Text(entry.lockEnabled ? "Monk mode" : "Off")
                .font(.headline.weight(.ultraLight))
                .foregroundStyle(.white.opacity(0.9))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .containerBackground(for: .widget) {
            Color.black
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
        .description("Lock status")
        .supportedFamilies([.systemSmall])
    }
}
