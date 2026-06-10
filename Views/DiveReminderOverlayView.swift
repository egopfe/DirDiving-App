import SwiftUI

struct DiveReminderOverlayView: View {
    let content: DiveReminderOverlayContent
    var onDismiss: () -> Void = {}

    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()

            VStack(spacing: 6) {
                Image(systemName: "bell.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(DiveUI.yellow)

                Text(content.title)
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(DiveUI.yellow)
                    .multilineTextAlignment(.center)

                ForEach(content.messages, id: \.self) { message in
                    Text(message)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }

                if content.hiddenCount > 0 {
                    Text(String(format: String(localized: "dive_reminder.overlay.more_format"), content.hiddenCount))
                        .font(DiveUI.Typography.secondaryLabel)
                        .foregroundStyle(DiveUI.yellow)
                }

                Text("\(Formatters.time(TimeInterval(content.runtimeMinute * 60)))")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(DiveUI.secondaryText)
                    .monospacedDigit()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.black.opacity(0.82))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(DiveUI.yellow.opacity(0.85), lineWidth: 1.5)
                    )
            )
            .padding(.horizontal, 14)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onDismiss()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(overlayAccessibilityLabel)
        .accessibilityHint(String(localized: "dive_reminder.overlay.a11y.dismiss_hint"))
        .accessibilityAddTraits(.isButton)
        .transition(.opacity)
    }

    private var overlayAccessibilityLabel: String {
        var parts = [content.title]
        parts.append(contentsOf: content.messages)
        if content.hiddenCount > 0 {
            parts.append(String(format: String(localized: "dive_reminder.overlay.more_format"), content.hiddenCount))
        }
        parts.append(
            String(
                format: String(localized: "dive_reminder.overlay.runtime_a11y"),
                Formatters.time(TimeInterval(content.runtimeMinute * 60))
            )
        )
        return parts.joined(separator: ". ")
    }
}
