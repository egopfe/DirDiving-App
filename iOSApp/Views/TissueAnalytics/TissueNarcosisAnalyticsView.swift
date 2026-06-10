import SwiftUI

struct TissueAnalyticsEntryCard: View {
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "waveform.path.ecg")
                .font(.title3.weight(.semibold))
                .foregroundStyle(TissueAnalyticsTheme.accentBlue)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(DIRIOSLocalizer.string("tissue_analytics.entry.title"))
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.white)
                Text(DIRIOSLocalizer.string("tissue_analytics.entry.subtitle"))
                    .font(.caption)
                    .foregroundStyle(TissueAnalyticsTheme.labelSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(TissueAnalyticsTheme.labelMuted)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(TissueAnalyticsTheme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(TissueAnalyticsTheme.cardBorder, lineWidth: 1)
                )
        )
    }
}

struct TissueNarcosisAnalyticsView: View {
    let presentation: TissueAnalyticsPresentation
    var initialTab: TissueProfileTab = .tissues
    @AppStorage(IOSUnitPreference.storageKey) private var unitsRaw = IOSUnitPreference.metric.rawValue
    @State private var tab: TissueProfileTab
    @State private var selectedRuntimeSeconds: Int?
    @State private var showDisclaimer = false

    private var unitPreference: IOSUnitPreference { IOSUnitPreference.fromStorage(unitsRaw) }
    private var trace: TissueAnalyticsTrace { presentation.trace }

    init(presentation: TissueAnalyticsPresentation, initialTab: TissueProfileTab = .tissues) {
        self.presentation = presentation
        self.initialTab = initialTab
        _tab = State(initialValue: initialTab)
    }

    var body: some View {
        ZStack {
            TissueAnalyticsTheme.screenBackground.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    sourceCapsule
                    tabSelector
                    summaryStrip
                    tabContent
                    disclaimerFooter
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle(DIRIOSLocalizer.string("tissue_analytics.nav.title"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(TissueAnalyticsTheme.screenBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear {
            if selectedRuntimeSeconds == nil {
                selectedRuntimeSeconds = trace.samples.last?.runtimeSeconds
            }
        }
        .alert(DIRIOSLocalizer.string("tissue_analytics.disclaimer.title"), isPresented: $showDisclaimer) {
            Button(DIRIOSLocalizer.string("common.ok"), role: .cancel) {}
        } message: {
            Text(DIRIOSLocalizer.string("tissue_analytics.disclaimer.body"))
        }
    }

    private var sourceCapsule: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(trace.source.localizedTitle)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(TissueAnalyticsTheme.labelSecondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule(style: .continuous)
                            .fill(Color(red: 0.11, green: 0.11, blue: 0.12))
                            .overlay(Capsule(style: .continuous).stroke(TissueAnalyticsTheme.cardBorder, lineWidth: 1))
                    )
                Spacer()
            }
            if let footnote = trace.source.localizedFootnote {
                Text(footnote)
                    .font(.system(size: 11))
                    .foregroundStyle(TissueAnalyticsTheme.labelMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            [trace.source.localizedTitle, trace.source.localizedFootnote]
                .compactMap { $0 }
                .joined(separator: ". ")
        )
    }

    private var tabSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(TissueProfileTab.allCases) { item in
                    Button {
                        tab = item
                    } label: {
                        Text(item.localizedTitle)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(tab == item ? TissueAnalyticsTheme.accentBlue : TissueAnalyticsTheme.labelMuted)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(tab == item ? TissueAnalyticsTheme.tabSelectedBackground : Color.clear)
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(tab == item ? [.isSelected] : [])
                }
            }
            .padding(6)
        }
        .frame(height: 54)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(TissueAnalyticsTheme.tabContainer)
        )
    }

    private var summaryStrip: some View {
        HStack(spacing: 0) {
            summaryColumn(
                title: DIRIOSLocalizer.string("tissue_analytics.summary.max_depth"),
                value: Formatters.depth(trace.summary.maxDepthMeters, units: unitPreference).text
            )
            divider
            summaryColumn(
                title: DIRIOSLocalizer.string("tissue_analytics.summary.bottom_time"),
                value: "\(trace.summary.bottomTimeMinutes)’"
            )
            divider
            summaryColumn(title: "TTR", value: "\(trace.summary.ttsMinutes)’")
            divider
            summaryColumn(title: "GF", value: "\(trace.summary.gfLow)/\(trace.summary.gfHigh)")
            divider
            summaryColumn(
                title: DIRIOSLocalizer.string("tissue_analytics.summary.mode"),
                value: trace.summary.modeTitle
            )
        }
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(TissueAnalyticsTheme.cardBackground)
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(TissueAnalyticsTheme.cardBorder, lineWidth: 1))
        )
    }

    private var divider: some View {
        Rectangle()
            .fill(TissueAnalyticsTheme.cardBorder)
            .frame(width: 1, height: 34)
    }

    private func summaryColumn(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 11))
                .foregroundStyle(TissueAnalyticsTheme.labelSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(value)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(TissueAnalyticsTheme.accentBlue)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var tabContent: some View {
        switch tab {
        case .summary:
            tissueLoadingCard
            narcoticLoadCard
        case .profile:
            diveProfileCard
        case .tissues:
            diveProfileCard
            tissueLoadingCard
            tissueTrendCard
            narcoticLoadCard
        case .gas:
            gasSegmentsCard
        case .deco:
            decoStopsCard
        }
    }

    private var disclaimerFooter: some View {
        Button {
            showDisclaimer = true
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "info.circle")
                Text(DIRIOSLocalizer.string("tissue_analytics.disclaimer.link"))
                    .font(.caption)
            }
            .foregroundStyle(TissueAnalyticsTheme.labelMuted)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func analyticsCard<Content: View>(title: String, headerTrailing: String? = nil, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                HStack(spacing: 6) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                    Button { showDisclaimer = true } label: {
                        Image(systemName: "info.circle")
                            .font(.system(size: 14))
                            .foregroundStyle(TissueAnalyticsTheme.labelMuted)
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
                if let headerTrailing {
                    Text(headerTrailing)
                        .font(.system(size: 12))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.trailing)
                }
            }
            content()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(TissueAnalyticsTheme.cardBackground)
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(TissueAnalyticsTheme.cardBorder, lineWidth: 1))
        )
    }

    private var diveProfileCard: some View {
        analyticsCard(title: DIRIOSLocalizer.string("tissue_analytics.card.dive_profile")) {
            TissueDiveProfileChart(
                points: trace.depthProfilePoints,
                segments: trace.segments,
                decoStops: trace.decoStops,
                unitPreference: unitPreference
            )
            .frame(minHeight: 220, maxHeight: 360)
        }
    }

    private var tissueLoadingCard: some View {
        analyticsCard(
            title: DIRIOSLocalizer.string("tissue_analytics.card.tissue_loading"),
            headerTrailing: String(
                format: DIRIOSLocalizer.string("tissue_analytics.controlling_compartment_format"),
                TissueAnalyticsTheme.controllingCompartmentLabel(index: trace.controllingCompartment)
            )
        ) {
            TissueCompartmentBarChart(
                compartments: trace.finalCompartments,
                controllingCompartment: trace.controllingCompartment
            )
            .frame(minHeight: 200, maxHeight: 340)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(UIUXAccessibilitySummaries.tissueCompartments(trace: trace))
        }
    }

    private var tissueTrendCard: some View {
        analyticsCard(
            title: DIRIOSLocalizer.string("tissue_analytics.card.tissue_trend"),
            headerTrailing: DIRIOSLocalizer.string("tissue_analytics.show.controlling")
        ) {
            TissueTrendChart(
                samples: trace.samples,
                controllingCompartment: trace.controllingCompartment,
                selectedRuntimeSeconds: $selectedRuntimeSeconds,
                unitPreference: unitPreference
            )
            .frame(minHeight: 240, maxHeight: 400)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(UIUXAccessibilitySummaries.tissueTrend(trace: trace, unitPreference: unitPreference))
        }
    }

    private var narcoticLoadCard: some View {
        analyticsCard(title: DIRIOSLocalizer.string("tissue_analytics.card.narcotic_load")) {
            TissueNarcoticLoadChart(
                samples: trace.samples,
                maxPPN2Bar: trace.maxPPN2Bar,
                endEquivalentMeters: trace.endEquivalentMeters,
                unitPreference: unitPreference
            )
            .frame(minHeight: 200, maxHeight: 340)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(UIUXAccessibilitySummaries.tissueNarcosis(trace: trace, unitPreference: unitPreference))
        }
    }

    private var gasSegmentsCard: some View {
        analyticsCard(title: DIRIOSLocalizer.string("tissue_analytics.tab.gas")) {
            if trace.segments.isEmpty {
                Text(DIRIOSLocalizer.string("tissue_analytics.gas.unavailable"))
                    .font(.caption)
                    .foregroundStyle(TissueAnalyticsTheme.labelMuted)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(trace.segments) { segment in
                        HStack {
                            Text(segment.gas)
                                .foregroundStyle(.white)
                            Spacer()
                            Text(Formatters.depth(segment.depthMeters, units: unitPreference).text)
                                .foregroundStyle(TissueAnalyticsTheme.labelSecondary)
                            Text("\(Int(segment.minutes.rounded())) min")
                                .foregroundStyle(TissueAnalyticsTheme.accentBlue)
                        }
                        .font(.caption)
                    }
                }
            }
        }
    }

    private var decoStopsCard: some View {
        analyticsCard(title: DIRIOSLocalizer.string("tissue_analytics.tab.deco")) {
            if trace.decoStops.isEmpty {
                Text(DIRIOSLocalizer.string("tissue_analytics.deco.no_stops"))
                    .font(.caption)
                    .foregroundStyle(TissueAnalyticsTheme.labelMuted)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(trace.decoStops) { stop in
                        HStack {
                            Text(Formatters.depth(stop.depthMeters, units: unitPreference).text)
                                .foregroundStyle(TissueAnalyticsTheme.accentBlue)
                            Text("\(stop.minutes) min")
                                .foregroundStyle(.white)
                            Spacer()
                            Text(stop.gas)
                                .foregroundStyle(TissueAnalyticsTheme.labelSecondary)
                        }
                        .font(.caption)
                    }
                }
            }
        }
    }
}

struct TissueAnalyticsUnavailableView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.xyaxis.line")
                .font(.largeTitle)
                .foregroundStyle(TissueAnalyticsTheme.labelMuted)
            Text(DIRIOSLocalizer.string("tissue_analytics.insufficient_data"))
                .font(.callout)
                .foregroundStyle(TissueAnalyticsTheme.labelSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(TissueAnalyticsTheme.screenBackground)
        .navigationTitle(DIRIOSLocalizer.string("tissue_analytics.nav.title"))
        .navigationBarTitleDisplayMode(.inline)
    }
}
