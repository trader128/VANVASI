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

    private var accent: Color {
        entry.lockEnabled ? Color(red: 0.83, green: 0.69, blue: 0.22) : .white.opacity(0.4) // gold when locked
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: entry.lockEnabled ? "lock.fill" : "lock.open")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(accent)
                Spacer()
                Circle()
                    .fill(accent)
                    .frame(width: 6, height: 6)
                    .opacity(entry.lockEnabled ? 1 : 0.3)
            }

            Spacer(minLength: 0)

            Text(entry.lockEnabled ? "MONK MODE" : "OFF")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .tracking(1.2)
                .foregroundStyle(.white.opacity(entry.lockEnabled ? 0.95 : 0.5))

            Text(entry.lockEnabled ? "Focus locked" : "Unlocked")
                .font(.system(size: 11, weight: .regular))
                .foregroundStyle(.white.opacity(0.4))
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [Color.black, Color(red: 0.08, green: 0.07, blue: 0.05)],
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
        .description("Lock status")
        .supportedFamilies([.systemSmall])
    }
}
