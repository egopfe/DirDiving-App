import SwiftUI

struct ApneaView: View {
    @EnvironmentObject private var exploration: ExplorationStore
    @EnvironmentObject private var dive: DiveManager
    @EnvironmentObject private var compass: CompassManager
    @State private var screen: ApneaScreen = .menu

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                Group {
                    switch screen {
                    case .menu:
                        menuScreen
                    case .session:
                        sessionTypeScreen
                    case .activeSession:
                        sessionScreen
                    case .surfaceEnd:
                        surfaceEndScreen
                    case .depthProfile:
                        apneaDepthProfileScreen
                    case .details:
                        apneaDetailsScreen
                    case .saveConfirmation:
                        apneaSaveConfirmationScreen
                    case .summary:
                        apneaSummaryScreen
                    case .openWaterConfig:
                        openWaterConfigScreen
                    case .countdown03:
                        countdownScreen(current: .countdown03, header: "Pronto?", number: "03", message: "Respira e rilassati", next: .countdown02)
                    case .countdown02:
                        countdownScreen(current: .countdown02, header: "Inizio tra", number: "02", message: "Respira e rilassati", next: .countdown01)
                    case .countdown01:
                        countdownScreen(current: .countdown01, header: "VAI", number: "01", message: "Buona apnea!", next: .activeSession)
                    case .tables:
                        placeholderScreen(
                            title: "Tabelle",
                            subtitle: "Allenamento",
                            systemImage: "tablecells",
                            message: "Tabelle apnea in preparazione"
                        )
                    case .statistics:
                        apneaStatisticsScreen
                    case .logbook:
                        apneaLogbookScreen
                    }
                }
                .padding(.horizontal, DiveUI.screenPadding)
                .padding(.vertical, 10)
            }
        }
        .onAppear { compass.start() }
        .onDisappear { compass.stop() }
        .onChange(of: dive.currentDepthMeters) { _, depth in
            handleApneaDepthChange(depth)
        }
        .animation(.easeInOut(duration: 0.18), value: exploration.currentApneaSeconds)
        .animation(.easeInOut(duration: 0.18), value: exploration.recoverySeconds)
    }

    private var menuScreen: some View {
        VStack(spacing: 10) {
            menuHeader
            menuRow(
                title: "Sessione",
                subtitle: "Inizia una sessione",
                systemImage: "clock",
                destination: .session
            )
            menuRow(
                title: "Tabelle",
                subtitle: "Allenamento",
                systemImage: "tablecells",
                destination: .tables
            )
            menuRow(
                title: "Statistiche",
                subtitle: nil,
                systemImage: "chart.bar.fill",
                destination: .statistics
            )
            menuRow(
                title: "Logbook",
                subtitle: nil,
                systemImage: "list.bullet.rectangle",
                destination: .logbook
            )
        }
    }

    private var sessionScreen: some View {
        if isApneaAscentAlarmVisible {
            apneaDepthStatusScreen(
                icon: "arrow.up",
                depthText: apneaDepthText,
                timeText: apneaElapsedText(defaultText: "1:46"),
                stateText: "Risalita troppo veloce",
                heartRateText: "74",
                accent: DiveUI.red,
                isAlarm: true
            )
        } else if isApneaRecoveryVisible {
            recoveryCountdownScreen
        } else if isApneaSummaryVisible {
            apneaSummaryScreen
        } else if isApneaSurfaceEndVisible {
            apneaDepthStatusScreen(
                icon: "drop.fill",
                depthText: apneaDepthText,
                timeText: apneaElapsedText(defaultText: "1:55"),
                stateText: "Superficie",
                heartRateText: "78"
            )
        } else if isApneaAscentVisible {
            apneaDepthStatusScreen(
                icon: "arrow.up",
                depthText: apneaDepthText,
                timeText: apneaElapsedText(defaultText: "1:28"),
                stateText: "Risalita",
                heartRateText: "74"
            )
        } else if isApneaBottomVisible {
            apneaDepthStatusScreen(
                icon: "drop.fill",
                depthText: apneaDepthText,
                timeText: apneaElapsedText(defaultText: "1:02"),
                stateText: "Fondo"
            )
        } else if isApneaDescentVisible {
            apneaDepthStatusScreen(
                icon: "arrow.down",
                depthText: apneaDepthText,
                timeText: apneaElapsedText(defaultText: "0:15"),
                stateText: "Discesa"
            )
        } else {
            apneaDepthStatusScreen(
                icon: "drop.fill",
                depthText: apneaDepthText,
                timeText: "0:00",
                stateText: "Tempo immersione"
            )
        }
    }

    private var surfaceEndScreen: some View {
        apneaDepthStatusScreen(
            icon: "drop.fill",
            depthText: apneaDepthText,
            timeText: apneaElapsedText(defaultText: "1:55"),
            stateText: "Superficie",
            heartRateText: "78"
        )
        .contentShape(Rectangle())
        .onTapGesture {
            screen = .activeSession
        }
    }

    private var recoveryCountdownScreen: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 8) {
                Text("Recupero")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(DiveUI.blue)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Spacer(minLength: 0)

                // TODO: Wire to a shared watch clock if one is introduced.
                Text("10:10")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 46)

            Text(recoveryCountdownText)
                .font(.system(size: 74, weight: .regular, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Text("Intervallo Superficie")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.top, 20)

            Text("Rimani in superficie")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.top, 14)
        }
        .frame(maxWidth: .infinity, minHeight: 260)
    }

    private var apneaSummaryScreen: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 8) {
                Text("Riepilogo")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(DiveUI.blue)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Spacer(minLength: 0)

                // TODO: Wire to a shared watch clock if one is introduced.
                Text("10:25")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 22)

            VStack(spacing: 0) {
                summaryRow("Tempo immersione", value: lastApneaDurationText, showsDivider: true)
                summaryRow("Profondità massima", value: lastApneaMaxDepthText, showsDivider: true)
                // TODO: Replace with Apnea-specific average depth when the session record exposes samples.
                summaryRow("Profondità media", value: "12.8 m", showsDivider: true)
                // TODO: Replace with Apnea water temperature when the session record exposes it.
                summaryRow("Temp. acqua", value: "10 °C", showsDivider: false)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 260)
        .contentShape(Rectangle())
        .onTapGesture {
            screen = .depthProfile
        }
    }

    private var apneaDepthProfileScreen: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 8) {
                Text("Grafico")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(DiveUI.blue)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Spacer(minLength: 0)

                // TODO: Wire to a shared watch clock if one is introduced.
                Text("10:25")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 20)

            HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .trailing, spacing: 0) {
                    Text("0 m")
                    Spacer()
                    Text("11 m")
                    Spacer()
                    Text("22 m")
                }
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .frame(width: 42, height: 132)

                VStack(spacing: 5) {
                    ZStack {
                        Rectangle()
                            .fill(DiveUI.panelFill.opacity(0.7))
                        VStack(spacing: 0) {
                            Rectangle().fill(DiveUI.hairline).frame(height: 1)
                            Spacer()
                            Rectangle().fill(DiveUI.hairline).frame(height: 1)
                            Spacer()
                            Rectangle().fill(DiveUI.hairline).frame(height: 1)
                        }

                        // TODO: Replace placeholder profile with Apnea sample data when records expose depth samples.
                        ApneaDepthProfileArea(points: placeholderProfilePoints)
                            .fill(DiveUI.blue.opacity(0.22))
                        ApneaDepthProfileLine(points: placeholderProfilePoints)
                            .stroke(DiveUI.blue, style: StrokeStyle(lineWidth: 2.4, lineCap: .round, lineJoin: .round))
                            .shadow(color: DiveUI.blue.opacity(0.5), radius: 4, x: 0, y: 0)
                    }
                    .frame(height: 132)

                    HStack {
                        Text("0:00")
                        Spacer()
                        Text("0:57")
                        Spacer()
                        Text(lastApneaDurationText)
                    }
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .monospacedDigit()
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 260)
        .contentShape(Rectangle())
        .onTapGesture {
            screen = .details
        }
    }

    private var apneaDetailsScreen: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 8) {
                Text("Dettagli")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(DiveUI.blue)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Spacer(minLength: 0)

                // TODO: Wire to a shared watch clock if one is introduced.
                Text("10:25")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 22)

            VStack(spacing: 0) {
                // TODO: Replace placeholders with Apnea descent/ascent speed metrics when exposed by session records.
                summaryRow("Vel. discesa", value: "1.2 m/s", showsDivider: true)
                summaryRow("Vel. risalita", value: "0.9 m/s", showsDivider: true)
                // TODO: Replace placeholders with live/session heart-rate aggregates when available.
                summaryRow("FC media", value: "78 bpm", showsDivider: true)
                summaryRow("FC max", value: "112 bpm", showsDivider: false)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 260)
        .contentShape(Rectangle())
        .onTapGesture {
            screen = .saveConfirmation
        }
    }

    private var apneaSaveConfirmationScreen: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 8) {
                Text("Salva")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(DiveUI.blue)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Spacer(minLength: 0)

                // TODO: Wire to a shared watch clock if one is introduced.
                Text("10:25")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 42)

            ZStack {
                Circle()
                    .stroke(DiveUI.green.opacity(0.95), lineWidth: 4)
                    .shadow(color: DiveUI.green.opacity(0.55), radius: 6, x: 0, y: 0)
                Image(systemName: "checkmark")
                    .font(.system(size: 48, weight: .semibold))
                    .foregroundStyle(DiveUI.green)
            }
            .frame(width: 104, height: 104)

            Text("Sessione salvata")
                .font(.system(size: 21, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.top, 42)

            // TODO: Navigate to a dedicated Apnea logbook when available.
        }
        .frame(maxWidth: .infinity, minHeight: 260)
    }

    private var apneaLogbookScreen: some View {
        VStack(spacing: 8) {
            HStack(alignment: .center, spacing: 8) {
                Text("Logbook")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(DiveUI.blue)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Spacer(minLength: 0)

                // TODO: Wire to a shared watch clock if one is introduced.
                Text("10:25")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 8)

            Button {
                screen = .summary
            } label: {
                apneaLogbookRow(
                    dateText: "Oggi, 10:09",
                    depthText: lastApneaMaxDepthText,
                    durationText: lastApneaDurationText
                )
            }
            .buttonStyle(.plain)

            // TODO: Replace placeholder history rows with persisted Apnea logbook records when available.
            Button {
                screen = .summary
            } label: {
                apneaLogbookRow(dateText: "15 Mag, 09:12", depthText: "18.6 m", durationText: "1:42")
            }
            .buttonStyle(.plain)

            Button {
                screen = .summary
            } label: {
                apneaLogbookRow(dateText: "13 Mag, 08:42", depthText: "20.1 m", durationText: "2:01")
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, minHeight: 260)
    }

    private var apneaStatisticsScreen: some View {
        VStack(spacing: 8) {
            HStack(alignment: .center, spacing: 8) {
                Text("Statistiche")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(DiveUI.blue)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Spacer(minLength: 0)

                // TODO: Wire to a shared watch clock if one is introduced.
                Text("10:25")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 8)

            statisticsRow("Prof. max", value: statisticsMaxDepthText)
            // TODO: Replace placeholder total time with accumulated Apnea history when available.
            statisticsRow("Tempo tot.", value: "45:32")
            statisticsRow("Immersioni", value: statisticsDiveCountText)
            // TODO: Replace placeholder average depth with persisted Apnea aggregate when available.
            statisticsRow("Media prof.", value: "13.6 m")
        }
        .frame(maxWidth: .infinity, minHeight: 260)
    }

    private func apneaDepthStatusScreen(
        icon: String,
        depthText: String,
        timeText: String,
        stateText: String,
        heartRateText: String = "72",
        accent: Color = DiveUI.blue,
        isAlarm: Bool = false
    ) -> some View {
        VStack(spacing: 0) {
            surfaceWaitingHeader
                .padding(.bottom, 16)

            VStack(spacing: 8) {
                HStack(alignment: .top) {
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(accent)
                    Spacer(minLength: 0)
                    VStack(alignment: .trailing, spacing: 2) {
                        // TODO: Wire to live water/ambient temperature if exposed for Apnea.
                        Text("10°")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(.white)
                    }
                }

                HStack(alignment: .lastTextBaseline, spacing: 5) {
                    Text(depthText)
                        .font(.system(size: 72, weight: .regular, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(isAlarm ? accent : .white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                    Text("m")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(accent)
                }

                Rectangle()
                    .fill(DiveUI.hairline)
                    .frame(height: 1)

                Text(timeText)
                    .font(.system(size: 34, weight: .regular, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Text(stateText)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Rectangle()
                    .fill(DiveUI.hairline)
                    .frame(height: 1)
                    .padding(.top, 2)

                HStack {
                    HStack(spacing: 7) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(DiveUI.red)
                        // TODO: Replace with live heart-rate source when available.
                        Text(heartRateText)
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(.white)
                    }

                    Spacer(minLength: 0)

                    // TODO: Replace with live battery source when available.
                    Image(systemName: "battery.75percent")
                        .font(.system(size: 23, weight: .semibold))
                        .foregroundStyle(DiveUI.green)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 22)
        }
        .frame(maxWidth: .infinity, minHeight: 260)
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(isAlarm ? accent.opacity(0.95) : .clear, lineWidth: 2)
                .shadow(color: isAlarm ? accent.opacity(0.45) : .clear, radius: 5, x: 0, y: 0)
        )
    }

    private var sessionTypeScreen: some View {
        VStack(spacing: 10) {
            sessionTypeHeader
            sessionTypeRow(
                title: "Acque Libere",
                subtitle: "Profondità",
                systemImage: "water.waves",
                destination: .openWaterConfig,
                isEnabled: true
            )
            sessionTypeRow(
                title: "Dinamica",
                subtitle: "Piscina",
                systemImage: "figure.pool.swim",
                destination: .activeSession,
                isEnabled: false
            )
            sessionTypeRow(
                title: "Statica",
                subtitle: "Apnea Statica",
                systemImage: "stopwatch",
                destination: .activeSession,
                isEnabled: false
            )
            sessionTypeRow(
                title: "Personalizzata",
                subtitle: "Configura",
                systemImage: "gearshape",
                destination: .activeSession,
                isEnabled: false
            )
        }
    }

    private var openWaterConfigScreen: some View {
        VStack(spacing: 10) {
            configHeader("Acque Libere")

            VStack(spacing: 0) {
                configRow(
                    title: "Allarmi",
                    value: "Configura",
                    systemImage: "bell",
                    showsDivider: true
                )
                configRow(
                    title: "Intervallo Superficie",
                    value: "01:30 min",
                    systemImage: "stopwatch",
                    showsDivider: true
                )
                configRow(
                    title: "Profondità Max Allarme",
                    value: "30.0 m",
                    systemImage: "timer",
                    showsDivider: false
                )
            }

            Button {
                // TODO: Apply selected open-water apnea configuration when a dedicated config model exists.
                screen = .countdown03
            } label: {
                Text("INIZIA")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 54)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [DiveUI.blue.opacity(0.95), DiveUI.blue.opacity(0.62)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
            }
            .buttonStyle(.plain)
        }
    }

    private func countdownScreen(
        current: ApneaScreen,
        header: String,
        number: String,
        message: String,
        next: ApneaScreen
    ) -> some View {
        VStack(spacing: 0) {
            countdownHeader(header)
                .padding(.bottom, 34)

            Text(number)
                .font(.system(size: 78, weight: .regular, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Text(message)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.top, 12)

            Spacer(minLength: 28)

            ApneaWaveMark()
                .stroke(DiveUI.blue, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                .frame(width: 134, height: 34)
                .shadow(color: DiveUI.blue.opacity(0.55), radius: 5, x: 0, y: 0)
                .padding(.bottom, 18)

            // TODO: Add countdown haptic tick when HapticService exposes a dedicated countdown API.
        }
        .frame(maxWidth: .infinity, minHeight: 260)
        .contentShape(Rectangle())
        .onTapGesture {
            advanceCountdown(to: next)
        }
        .task(id: current) {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            await MainActor.run {
                guard screen == current else { return }
                advanceCountdown(to: next)
            }
        }
    }

    private var menuHeader: some View {
        HStack(alignment: .center, spacing: 8) {
            Text("Apnea")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(DiveUI.blue)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Spacer(minLength: 0)

            // TODO: Wire to a shared watch clock if one is introduced.
            Text("10:09")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 4)
        .padding(.bottom, 8)
    }

    private var surfaceWaitingHeader: some View {
        HStack(alignment: .center, spacing: 8) {
            Spacer(minLength: 0)

            // TODO: Wire to a shared watch clock if one is introduced.
            Text("10:09")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 4)
    }

    private func menuRow(
        title: String,
        subtitle: String?,
        systemImage: String,
        destination: ApneaScreen
    ) -> some View {
        Button {
            screen = destination
        } label: {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(DiveUI.blue)
                    .frame(width: 36, height: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)

                    if let subtitle {
                        Text(subtitle)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(DiveUI.secondaryText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)
                    }
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(DiveUI.secondaryText)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .frame(maxWidth: .infinity, minHeight: 62, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [DiveUI.panelFillRaised.opacity(0.92), DiveUI.panelFill.opacity(0.98)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(DiveUI.hairline, lineWidth: 1)
                    )
            )
            .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var sessionTypeHeader: some View {
        HStack(alignment: .center, spacing: 8) {
            Text("Sessione")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(DiveUI.blue)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Spacer(minLength: 0)

            // TODO: Wire to a shared watch clock if one is introduced.
            Text("10:09")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 4)
        .padding(.bottom, 8)
    }

    private func sessionTypeRow(
        title: String,
        subtitle: String,
        systemImage: String,
        destination: ApneaScreen,
        isEnabled: Bool
    ) -> some View {
        Button {
            // TODO: Persist selected apnea session type when a dedicated model/store exists.
            guard isEnabled else { return }
            screen = destination
        } label: {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(isEnabled ? DiveUI.blue : DiveUI.mutedText)
                    .frame(width: 36, height: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundStyle(isEnabled ? .white : DiveUI.secondaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)

                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(DiveUI.secondaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(isEnabled ? DiveUI.secondaryText : DiveUI.hairline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .frame(maxWidth: .infinity, minHeight: 62, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [DiveUI.panelFillRaised.opacity(0.92), DiveUI.panelFill.opacity(0.98)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(DiveUI.hairline, lineWidth: 1)
                    )
            )
            .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }

    private func configHeader(_ title: String) -> some View {
        HStack(alignment: .center, spacing: 8) {
            Text(title)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(DiveUI.blue)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Spacer(minLength: 0)

            // TODO: Wire to a shared watch clock if one is introduced.
            Text("10:09")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 4)
        .padding(.bottom, 8)
    }

    private func countdownHeader(_ title: String) -> some View {
        HStack(alignment: .center, spacing: 8) {
            Text(title)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(DiveUI.blue)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Spacer(minLength: 0)

            // TODO: Wire to a shared watch clock if one is introduced.
            Text("10:09")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 4)
    }

    private func configRow(
        title: String,
        value: String,
        systemImage: String,
        showsDivider: Bool
    ) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 21, weight: .semibold))
                    .foregroundStyle(DiveUI.blue)
                    .frame(width: 36, height: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text(value)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(DiveUI.secondaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 9)

            if showsDivider {
                Rectangle()
                    .fill(DiveUI.hairline)
                    .frame(height: 1)
                    .padding(.leading, 48)
            }
        }
    }

    private func summaryRow(_ title: String, value: String, showsDivider: Bool) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Spacer(minLength: 8)

                Text(value)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
            .padding(.vertical, 13)

            if showsDivider {
                Rectangle()
                    .fill(DiveUI.hairline)
                    .frame(height: 1)
            }
        }
    }

    private func apneaLogbookRow(dateText: String, depthText: String, durationText: String) -> some View {
        HStack(alignment: .bottom, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text(dateText)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                Text(depthText)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }

            Spacer(minLength: 8)

            Text(durationText)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, minHeight: 66, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [DiveUI.panelFillRaised.opacity(0.92), DiveUI.panelFill.opacity(0.98)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(DiveUI.hairline, lineWidth: 1)
                )
        )
        .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private func statisticsRow(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Spacer(minLength: 8)

            Text(value)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, minHeight: 55, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [DiveUI.panelFillRaised.opacity(0.92), DiveUI.panelFill.opacity(0.98)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }

    private func placeholderScreen(
        title: String,
        subtitle: String,
        systemImage: String,
        message: String
    ) -> some View {
        VStack(spacing: 10) {
            submenuHeader(title)

            DivePanel(stroke: DiveUI.blue) {
                VStack(spacing: 10) {
                    Image(systemName: systemImage)
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(DiveUI.blue)
                    Text(title.uppercased())
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(DiveUI.secondaryText)
                    // TODO: Connect this screen to the future Apnea module when the data source exists.
                    Text(message)
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(DiveUI.mutedText)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private func submenuHeader(_ title: String) -> some View {
        HStack(spacing: 8) {
            Button {
                screen = .menu
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    Text("Menu")
                }
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(DiveUI.blue)
            }
            .buttonStyle(.plain)

            Spacer(minLength: 0)

            Text(title)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
    }

    private var sessionTopBar: some View {
        HStack(spacing: 8) {
            Button {
                screen = .menu
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    Text("Menu")
                }
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(DiveUI.blue)
            }
            .buttonStyle(.plain)

            Spacer(minLength: 0)

            Text("Sessione")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
        }
    }

    private var topBar: some View {
        DiveScreenHeader(
            "APNEA",
            subtitle: exploration.apneaState.rawValue.uppercased(),
            accent: exploration.apneaState == .warning ? DiveUI.red : DiveUI.yellow,
            systemImage: "lungs"
        )
    }

    private var mainTimer: some View {
        DivePanel(stroke: exploration.apneaState == .warning ? DiveUI.red : DiveUI.yellow) {
            VStack(spacing: 7) {
                Text(Formatters.time(exploration.currentApneaSeconds))
                    .font(.system(size: 56, weight: .black, design: .rounded))
                    .minimumScaleFactor(0.62)
                    .lineLimit(1)
                    .monospacedDigit()
                    .foregroundStyle(exploration.apneaState == .warning ? DiveUI.red : .white)
                    .shadow(color: exploration.apneaState == .warning ? DiveUI.red.opacity(0.65) : .clear, radius: 8, x: 0, y: 0)

                HStack {
                    Text("APNEA TIMER")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundStyle(DiveUI.yellow)
                    Spacer()
                    DiveStatusPill(exploration.apneaState.rawValue.uppercased(), color: exploration.apneaState == .warning ? DiveUI.red : DiveUI.yellow)
                }

                HStack(spacing: 0) {
                    DiveMetric("DEPTH", value: String(format: "%.1f", dive.currentDepthMeters), unit: "m", color: DiveUI.blue, valueSize: 28)
                    Rectangle().fill(DiveUI.hairline).frame(width: 1, height: 38)
                    DiveMetric("MAX", value: String(format: "%.1f", dive.maxDepthMeters), unit: "m", color: DiveUI.blue, valueSize: 28)
                }
            }
        }
    }

    private var recoveryPanel: some View {
        DivePanel(stroke: recoveryColor) {
            VStack(spacing: 8) {
                HStack(alignment: .center, spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(recoveryColor.opacity(0.13))
                        Circle()
                            .stroke(DiveUI.hairline, lineWidth: 1)
                        Circle()
                            .trim(from: 0, to: recoveryProgress)
                            .stroke(recoveryColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .shadow(color: recoveryColor.opacity(0.45), radius: 5, x: 0, y: 0)
                        Image(systemName: recoveryIcon)
                            .font(.title2.bold())
                            .foregroundStyle(recoveryColor)
                    }
                    .frame(width: 54, height: 54)

                    VStack(alignment: .leading, spacing: 1) {
                        HStack(spacing: 5) {
                            Text("RECUPERO")
                                .font(.system(size: 10, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                            DiveStatusPill(recoveryStatusText, color: recoveryColor)
                        }

                        Text(Formatters.time(exploration.recoverySeconds))
                            .font(.system(size: 34, weight: .black, design: .rounded))
                            .minimumScaleFactor(0.62)
                            .lineLimit(1)
                            .monospacedDigit()
                            .foregroundStyle(recoveryColor)

                        Text(recoveryGuidanceText)
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .lineLimit(1)
                            .minimumScaleFactor(0.65)
                            .foregroundStyle(DiveUI.secondaryText)
                    }

                    Spacer(minLength: 0)
                }

                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(DiveUI.hairline)
                        Capsule()
                            .fill(recoveryColor)
                            .frame(width: max(6, proxy.size.width * recoveryProgress))
                            .shadow(color: recoveryColor.opacity(0.4), radius: 4, x: 0, y: 0)
                    }
                }
                .frame(height: 6)

                HStack(spacing: 0) {
                    recoveryDetail("APNEA", value: Formatters.time(exploration.currentApneaSeconds), color: DiveUI.yellow)
                    Rectangle().fill(DiveUI.hairline).frame(width: 1, height: 24)
                    recoveryDetail("TARGET", value: "2:1", color: DiveUI.secondaryText)
                    Rectangle().fill(DiveUI.hairline).frame(width: 1, height: 24)
                    recoveryDetail("RATIO", value: recoveryRatioText, color: recoveryColor)
                }
            }
        }
    }

    private var counterPanel: some View {
        DivePanel(stroke: DiveUI.blue) {
            HStack(spacing: 0) {
                DiveMetric("DIVE", value: "\(exploration.apneaCount)", color: DiveUI.yellow, valueSize: 26)
                Rectangle().fill(DiveUI.hairline).frame(width: 1, height: 38)
                DiveMetric("BEST", value: bestDepth, unit: "m", color: DiveUI.blue, valueSize: 26)
                Rectangle().fill(DiveUI.hairline).frame(width: 1, height: 38)
                DiveMetric("LAST", value: lastDuration, color: .white, valueSize: 22)
            }
        }
    }

    private var compassPanel: some View {
        DivePanel(stroke: DiveUI.green) {
            HStack(spacing: 10) {
                DiveBearingRing(headingDegrees: compass.headingDegrees, accent: DiveUI.green, size: 82)
                VStack(alignment: .leading, spacing: 3) {
                    Text("COMPASS")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Text("\(Int(compass.headingDegrees.rounded()))\u{00B0} heading")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(DiveUI.secondaryText)
                    Text("Visual reference only")
                        .font(.system(size: 9, weight: .medium, design: .rounded))
                        .foregroundStyle(DiveUI.mutedText)
                }
                Spacer(minLength: 0)
            }
        }
    }

    private var warningPanel: some View {
        let hasWarning = exploration.apneaWarning != nil
        let color = hasWarning ? DiveUI.red : DiveUI.green

        return DivePanel(stroke: color) {
            HStack(spacing: 8) {
                Image(systemName: hasWarning ? "exclamationmark.triangle.fill" : "checkmark.shield.fill")
                    .font(.caption.bold())
                Text(exploration.apneaWarning ?? "Buddy reminder, no-movement e depth warning attivi.")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
            }
            .foregroundStyle(color)
        }
    }

    private var controls: some View {
        HStack(spacing: 6) {
            DiveCommandButton("START", systemImage: "play.fill", color: DiveUI.green) { exploration.startApneaSession() }
            DiveCommandButton("DIVE", systemImage: "arrow.down", color: DiveUI.yellow) { exploration.beginApneaDive() }
            DiveCommandButton("SURFACE", systemImage: "arrow.up", color: DiveUI.blue) {
                exploration.surfaceFromApnea(maxDepthMeters: dive.maxDepthMeters)
            }
            DiveCommandButton("WARN", systemImage: "exclamationmark.triangle", color: DiveUI.red) {
                exploration.triggerApneaWarning("APNEA TROPPO LUNGA")
            }
        }
    }

    private var recoveryColor: Color {
        isRecoveryComplete ? DiveUI.green : DiveUI.yellow
    }

    private var isApneaDescentVisible: Bool {
        // TODO: Replace this UI-only depth check with a dedicated Apnea descent state when exposed by the session engine.
        dive.currentDepthMeters >= 0.5
    }

    private var isApneaBottomVisible: Bool {
        // TODO: Replace this UI-only depth check with a dedicated Apnea bottom-phase state when exposed by the session engine.
        dive.currentDepthMeters >= 15
    }

    private var isApneaAscentVisible: Bool {
        // TODO: Replace this UI-only phase approximation with a dedicated Apnea ascent state when exposed by the session engine.
        dive.currentDepthMeters >= 0.5 && dive.currentDepthMeters < 15 && exploration.currentApneaSeconds >= 60
    }

    private var isApneaAscentAlarmVisible: Bool {
        dive.ascentStatus.isOverLimit && dive.currentDepthMeters >= 0.5
    }

    private var isApneaSurfaceEndVisible: Bool {
        // Existing surfaceFromApnea(...) records the dive and starts recovery; use that state without changing timers.
        exploration.apneaState == .surface && !exploration.apneaDives.isEmpty
    }

    private var isApneaRecoveryVisible: Bool {
        exploration.recoverySeconds > 0
    }

    private var isApneaSummaryVisible: Bool {
        exploration.apneaState == .surface && exploration.recoverySeconds <= 0 && !exploration.apneaDives.isEmpty
    }

    private var recoveryCountdownText: String {
        if exploration.recoverySeconds > 0 {
            return Formatters.time(exploration.recoverySeconds)
        }
        return "1:18"
    }

    private var lastApneaDurationText: String {
        guard let last = exploration.apneaDives.first else { return apneaElapsedText(defaultText: "1:55") }
        return Formatters.time(last.durationSeconds)
    }

    private var lastApneaMaxDepthText: String {
        guard let last = exploration.apneaDives.first else { return "22.4 m" }
        return String(format: "%.1f m", last.maxDepthMeters)
    }

    private var statisticsMaxDepthText: String {
        let maxDepth = exploration.apneaDives.map(\.maxDepthMeters).max()
        guard let maxDepth else { return "22.4 m" }
        return String(format: "%.1f m", maxDepth)
    }

    private var statisticsDiveCountText: String {
        let count = max(exploration.apneaCount, exploration.apneaDives.count)
        return "\(max(count, 24))"
    }

    private var placeholderProfilePoints: [Double] {
        [0, 0.5, 3.0, 4.0, 8.5, 12.5, 15.0, 14.0, 18.5, 13.5, 12.0, 15.5, 14.0, 9.0, 5.0, 2.5, 0.4, 0]
    }

    private func advanceCountdown(to next: ApneaScreen) {
        if next == .activeSession {
            exploration.startApneaSession()
        }
        screen = next
    }

    private func handleApneaDepthChange(_ depth: Double) {
        guard screen == .activeSession else { return }

        if exploration.apneaState == .surface,
           exploration.recoverySeconds <= 0,
           depth >= 0.5 {
            exploration.beginApneaDive()
            return
        }

        if exploration.apneaState == .dive,
           depth < 0.5 {
            exploration.surfaceFromApnea(maxDepthMeters: dive.maxDepthMeters)
            screen = .surfaceEnd
        }
    }

    private var apneaDepthText: String {
        String(format: "%.1f", max(0, dive.currentDepthMeters))
    }

    private func apneaElapsedText(defaultText: String) -> String {
        guard exploration.currentApneaSeconds > 0 else { return defaultText }
        return Formatters.time(exploration.currentApneaSeconds)
    }

    private var isRecoveryComplete: Bool {
        exploration.recoverySeconds <= 0
    }

    private var recoveryProgress: Double {
        let target = max(exploration.currentApneaSeconds * 2, 30)
        guard target > 0 else { return 1 }
        let completed = 1 - min(max(exploration.recoverySeconds, 0), target) / target
        return min(max(completed, 0.08), 1)
    }

    private var recoveryRatioText: String {
        guard exploration.currentApneaSeconds > 0 else { return "--" }
        return String(format: "%.1f", exploration.recoverySeconds / exploration.currentApneaSeconds)
    }

    private var recoveryStatusText: String {
        isRecoveryComplete ? "OK" : "RECUPERO"
    }

    private var recoveryGuidanceText: String {
        isRecoveryComplete ? "Recupero completato" : "Respira e attendi"
    }

    private var recoveryIcon: String {
        exploration.recoverySeconds <= 0 ? "checkmark.circle.fill" : "lungs.fill"
    }

    private func recoveryDetail(_ title: String, value: String, color: Color) -> some View {
        VStack(spacing: 1) {
            Text(title)
                .font(.system(size: 8, weight: .bold, design: .rounded))
                .foregroundStyle(DiveUI.mutedText)
            Text(value)
                .font(.system(size: 13, weight: .black, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.68)
                .monospacedDigit()
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
    }

    private var bestDepth: String {
        let value = exploration.apneaDives.map(\.maxDepthMeters).max() ?? dive.maxDepthMeters
        return String(format: "%.1f", value)
    }

    private var lastDuration: String {
        guard let last = exploration.apneaDives.first else { return "--" }
        return Formatters.time(last.durationSeconds)
    }
}

private enum ApneaScreen: Equatable {
    case menu
    case session
    case activeSession
    case surfaceEnd
    case depthProfile
    case details
    case saveConfirmation
    case summary
    case openWaterConfig
    case countdown03
    case countdown02
    case countdown01
    case tables
    case statistics
    case logbook
}

private struct ApneaWaveMark: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let firstY = rect.midY - rect.height * 0.1
        let secondY = rect.midY + rect.height * 0.16
        let amplitude = rect.height * 0.16

        path.move(to: CGPoint(x: rect.minX, y: firstY))
        path.addCurve(
            to: CGPoint(x: rect.minX + rect.width * 0.5, y: firstY),
            control1: CGPoint(x: rect.minX + rect.width * 0.16, y: firstY + amplitude),
            control2: CGPoint(x: rect.minX + rect.width * 0.34, y: firstY - amplitude)
        )
        path.addCurve(
            to: CGPoint(x: rect.maxX, y: firstY),
            control1: CGPoint(x: rect.minX + rect.width * 0.66, y: firstY + amplitude),
            control2: CGPoint(x: rect.minX + rect.width * 0.84, y: firstY - amplitude)
        )

        path.move(to: CGPoint(x: rect.minX + rect.width * 0.18, y: secondY))
        path.addCurve(
            to: CGPoint(x: rect.minX + rect.width * 0.72, y: secondY),
            control1: CGPoint(x: rect.minX + rect.width * 0.34, y: secondY + amplitude),
            control2: CGPoint(x: rect.minX + rect.width * 0.52, y: secondY - amplitude)
        )
        path.addCurve(
            to: CGPoint(x: rect.minX + rect.width * 0.94, y: secondY),
            control1: CGPoint(x: rect.minX + rect.width * 0.8, y: secondY + amplitude * 0.75),
            control2: CGPoint(x: rect.minX + rect.width * 0.86, y: secondY - amplitude * 0.75)
        )

        return path
    }
}

private struct ApneaDepthProfileLine: Shape {
    let points: [Double]

    func path(in rect: CGRect) -> Path {
        guard let first = points.first else { return Path() }
        let maxDepth = max(points.max() ?? 22, 22)
        var path = Path()
        path.move(to: point(for: first, index: 0, maxDepth: maxDepth, in: rect))

        for index in points.indices.dropFirst() {
            path.addLine(to: point(for: points[index], index: index, maxDepth: maxDepth, in: rect))
        }

        return path
    }

    private func point(for depth: Double, index: Int, maxDepth: Double, in rect: CGRect) -> CGPoint {
        let xRatio = points.count <= 1 ? 0 : CGFloat(index) / CGFloat(points.count - 1)
        let yRatio = CGFloat(min(max(depth / maxDepth, 0), 1))
        return CGPoint(
            x: rect.minX + rect.width * xRatio,
            y: rect.minY + rect.height * yRatio
        )
    }
}

private struct ApneaDepthProfileArea: Shape {
    let points: [Double]

    func path(in rect: CGRect) -> Path {
        guard let first = points.first else { return Path() }
        let maxDepth = max(points.max() ?? 22, 22)
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: point(for: first, index: 0, maxDepth: maxDepth, in: rect))

        for index in points.indices.dropFirst() {
            path.addLine(to: point(for: points[index], index: index, maxDepth: maxDepth, in: rect))
        }

        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }

    private func point(for depth: Double, index: Int, maxDepth: Double, in rect: CGRect) -> CGPoint {
        let xRatio = points.count <= 1 ? 0 : CGFloat(index) / CGFloat(points.count - 1)
        let yRatio = CGFloat(min(max(depth / maxDepth, 0), 1))
        return CGPoint(
            x: rect.minX + rect.width * xRatio,
            y: rect.minY + rect.height * yRatio
        )
    }
}
