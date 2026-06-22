import SwiftUI

struct IOSCompanionSettingsToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    var accessibilityHint: String? = nil
    var identifier: String? = nil

    var body: some View {
        Toggle(isOn: $isOn) {
            Text(title)
                .foregroundStyle(.white)
                .font(.callout)
                .fixedSize(horizontal: false, vertical: true)
        }
        .tint(DIRTheme.cyan)
        .padding(.vertical, 4)
        .accessibilityLabel(title)
        .accessibilityHint(accessibilityHint ?? "")
        .accessibilityIdentifier(identifier ?? title)
    }
}

struct IOSCompanionSettingsStepperRow: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let formattedValue: String
    var identifier: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .foregroundStyle(DIRTheme.muted)
                    .font(.callout)
                Spacer()
                Text(formattedValue)
                    .foregroundStyle(.white)
                    .font(.callout.weight(.semibold))
                    .multilineTextAlignment(.trailing)
            }
            HStack(spacing: 16) {
                stepButton(systemName: "minus.circle.fill", enabled: value > range.lowerBound) {
                    value = max(range.lowerBound, (value - step).rounded(toPlaces: 2))
                }
                Spacer()
                stepButton(systemName: "plus.circle.fill", enabled: value < range.upperBound) {
                    value = min(range.upperBound, (value + step).rounded(toPlaces: 2))
                }
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(formattedValue)")
        .accessibilityIdentifier(identifier ?? title)
    }

    private func stepButton(systemName: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.title2.weight(.semibold))
                .foregroundStyle(enabled ? DIRTheme.cyan : DIRTheme.muted)
                .frame(minWidth: 44, minHeight: 44)
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }
}

struct IOSCompanionSettingsIntStepperRow: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let step: Int
    let formattedValue: String
    var identifier: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .foregroundStyle(DIRTheme.muted)
                    .font(.callout)
                Spacer()
                Text(formattedValue)
                    .foregroundStyle(.white)
                    .font(.callout.weight(.semibold))
                    .multilineTextAlignment(.trailing)
            }
            HStack(spacing: 16) {
                stepButton(systemName: "minus.circle.fill", enabled: value > range.lowerBound) {
                    value = max(range.lowerBound, value - step)
                }
                Spacer()
                stepButton(systemName: "plus.circle.fill", enabled: value < range.upperBound) {
                    value = min(range.upperBound, value + step)
                }
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(formattedValue)")
        .accessibilityIdentifier(identifier ?? title)
    }

    private func stepButton(systemName: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.title2.weight(.semibold))
                .foregroundStyle(enabled ? DIRTheme.cyan : DIRTheme.muted)
                .frame(minWidth: 44, minHeight: 44)
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }
}

struct IOSCompanionSettingsNavigationRow: View {
    let title: String
    let systemImage: String
    let destination: AnyView
    var identifier: String? = nil

    init<Destination: View>(
        title: String,
        systemImage: String,
        identifier: String? = nil,
        @ViewBuilder destination: () -> Destination
    ) {
        self.title = title
        self.systemImage = systemImage
        self.identifier = identifier
        self.destination = AnyView(destination())
    }

    var body: some View {
        NavigationLink {
            destination
        } label: {
            HStack {
                Label(title, systemImage: systemImage)
                    .foregroundStyle(DIRTheme.cyan)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(DIRTheme.muted)
            }
            .font(.callout.weight(.semibold))
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityIdentifier(identifier ?? title)
    }
}

struct IOSCompanionSettingsResetButton: View {
    let title: String
    let action: () -> Void
    var identifier: String? = nil

    var body: some View {
        Button(role: .destructive, action: action) {
            Label(title, systemImage: "arrow.counterclockwise")
                .font(.callout.weight(.semibold))
                .foregroundStyle(DIRTheme.orange)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(RoundedRectangle(cornerRadius: 8).stroke(DIRTheme.orange.opacity(0.8), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityHint(DIRIOSLocalizer.string("settings.reset.a11y.hint"))
        .accessibilityIdentifier(identifier ?? "settings.reset")
    }
}

struct IOSCompanionSettingsFootnoteText: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption2)
            .foregroundStyle(DIRTheme.muted)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.top, 2)
    }
}

private extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
