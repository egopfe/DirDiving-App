import SwiftUI

struct WatchStartupDefaultActivityPickerView: View {
    var body: some View {
        ZStack {
            DiveScreenBackground()
            List {
                ForEach(DIRActivityMode.allCases) { mode in
                    Button {
                        DIRStartupSelectionPolicy.defaultActivityMode = mode
                        HapticService.shared.confirm()
                    } label: {
                        HStack {
                            Text(localizedName(mode))
                                .foregroundStyle(.white)
                            Spacer()
                            if DIRStartupSelectionPolicy.defaultActivityMode == mode {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(DiveUI.green)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(String(localized: "settings.startup.default_activity"))
        .watchSubscreenBackToolbar()
    }

    private func localizedName(_ mode: DIRActivityMode) -> String {
        switch mode {
        case .diving: return String(localized: "startup.activity.diving")
        case .apnea: return String(localized: "startup.activity.apnea")
        case .snorkeling: return String(localized: "startup.activity.snorkeling")
        }
    }
}

struct WatchStartupDefaultDivingModePickerView: View {
    var body: some View {
        ZStack {
            DiveScreenBackground()
            List {
                ForEach(DIRDivingMode.allCases) { mode in
                    Button {
                        DIRStartupSelectionPolicy.defaultDivingMode = mode
                        HapticService.shared.confirm()
                    } label: {
                        HStack {
                            Text(localizedName(mode))
                                .foregroundStyle(.white)
                            Spacer()
                            if DIRStartupSelectionPolicy.defaultDivingMode == mode {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(DiveUI.green)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(String(localized: "settings.diving.default_mode"))
        .watchSubscreenBackToolbar()
    }

    private func localizedName(_ mode: DIRDivingMode) -> String {
        switch mode {
        case .gauge: return String(localized: "startup.diving_mode.gauge.title")
        case .fullComputer: return String(localized: "startup.diving_mode.full_computer.title")
        }
    }
}
