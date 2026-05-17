import SwiftUI

struct SnorkelingView: View {
    @EnvironmentObject private var exploration: ExplorationStore
    @EnvironmentObject private var gps: GPSManager
    @EnvironmentObject private var compass: CompassManager
    @EnvironmentObject private var dive: DiveManager
    @StateObject private var watchSync = WatchSyncService.shared
    @State private var screen: SnorkelingScreen = .live
    @State private var selectedMarker: GPSInterestMarker?
    @State private var lastSavedMarker: GPSInterestMarker?
    @AppStorage(HapticService.experimentalHapticsEnabledKey) private var experimentalHapticsEnabled = true
    @AppStorage("dirdiving_snorkeling_alarm_max_depth_meters") private var snorkelingAlarmMaxDepthMeters = 10.0
    @AppStorage("dirdiving_snorkeling_alarm_max_minutes") private var snorkelingAlarmMaxMinutes = 60
    @AppStorage("dirdiving_snorkeling_alarm_max_distance_km") private var snorkelingAlarmMaxDistanceKm = 5.0
    @AppStorage("dirdiving_snorkeling_alarm_low_battery_percent") private var snorkelingAlarmLowBatteryPercent = 20

    private var bearingDelta: Double {
        let delta = exploration.liveTargetBearing - compass.headingDegrees
        if delta > 180 { return delta - 360 }
        if delta < -180 { return delta + 360 }
        return delta
    }

    var body: some View {
        ZStack {
            DiveScreenBackground()

            Group {
                switch screen {
                case .live:
                    liveScreen
                case .waypointMap:
                    mapScreen(mode: .waypoint)
                case .returnMap:
                    mapScreen(mode: .returnToEntry)
                case .waypointDirection:
                    waypointDirectionScreen
                case .markerSaved:
                    markerSavedScreen
                case .markerLog:
                    markerLogScreen
                case .markerDetail:
                    markerDetailScreen
                case .settings:
                    snorkelingSettingsScreen
                case .alarms:
                    snorkelingAlarmsScreen
                case .compassCalibration:
                    compassCalibrationScreen
                case .mapLegend:
                    mapLegendScreen
                }
            }
        }
        .onAppear {
            compass.start()
            gps.start()
            startSnorkelingSessionIfNeeded()
        }
        .onDisappear {
            gps.stop()
            compass.stop()
        }
        .onReceive(gps.$lastSpeedMetersPerSecond) { speed in
            exploration.updateSnorkelingProgress(
                speedMetersPerSecond: speed,
                currentPoint: gps.currentBestPoint()
            )
            evaluateSnorkelingAlarms()
        }
        .onChange(of: dive.currentDepthMeters) { _, _ in
            evaluateSnorkelingAlarms()
        }
    }

    private var liveScreen: some View {
        GeometryReader { geometry in
            let contentWidth = geometry.size.width - 18
            let rightWidth = min(66, contentWidth * 0.26)
            let leftWidth = contentWidth - rightWidth - 9

            VStack(spacing: 7) {
                topBar(title: "SNORKELING", systemImage: "figure.pool.swim")
                statusRow(exploration.isSnorkelingSessionActive ? "IN ATTIVITÀ" : "SESSIONE NON AVVIATA")
                if let warning = exploration.snorkelingWarning {
                    snorkelingWarningPanel(warning)
                }
                activityMetricsPanel
                depthAndGpsSection(leftWidth: leftWidth, rightWidth: rightWidth)
                Button {
                    exploration.startNavigation()
                    screen = .waypointMap
                } label: {
                    waypointPanel(mode: .waypoint)
                }
                .buttonStyle(.plain)
                controls(kind: .live)
            }
            .padding(.horizontal, 9)
            .padding(.top, 9)
            .padding(.bottom, 7)
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
        }
    }

    @ViewBuilder
    private func mapScreen(mode: SnorkelingMapMode) -> some View {
        if mode == .waypoint {
            waypointMapScreen
        } else {
            returnMapScreen
        }
    }

    private var waypointMapScreen: some View {
        VStack(spacing: 7) {
            topBar(title: "SNORKELING", systemImage: "figure.pool.swim")
            statusRow("VERSO WAYPOINT")

            Text("MAPPA WAYPOINT")
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundStyle(DiveUI.blue)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
                .frame(maxWidth: .infinity, alignment: .center)
            schematicMapNotice("MAPPA SCHEMATICA - NO TILE ONLINE")

            waypointSummaryCard
            SnorkelingWaypointMapView(waypointName: exploration.activeWaypoint.name, gpsOKText: gpsMapStatusText)
            backButton
        }
        .padding(.horizontal, 9)
        .padding(.top, 9)
        .padding(.bottom, 7)
    }

    private var returnMapScreen: some View {
        VStack(spacing: 7) {
            topBar(title: "SNORKELING", systemImage: "figure.pool.swim")

            Text("MAPPA RITORNO")
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundStyle(DiveUI.blue)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
                .frame(maxWidth: .infinity, alignment: .center)
            schematicMapNotice("RITORNO SCHEMATICO - ENTRY GPS SURFACE")

            if exploration.hasSnorkelingEntryPoint {
                returnSummaryCard
                SnorkelingReturnMapView(gpsOKText: gpsMapStatusText)
            } else {
                unavailablePanel(
                    title: "PUNTO DI PARTENZA NON DISPONIBILE",
                    message: "Avvia la sessione in superficie con GPS disponibile per usare Mappa Ritorno.",
                    color: DiveUI.yellow
                )
            }
            backButton
        }
        .padding(.horizontal, 9)
        .padding(.top, 9)
        .padding(.bottom, 7)
    }

    private var waypointDirectionScreen: some View {
        VStack(spacing: 8) {
            topBar(title: "SNORKELING", systemImage: "figure.pool.swim")

            Text("DIREZIONE WAYPOINT")
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundStyle(DiveUI.blue)
                .lineLimit(1)
                .minimumScaleFactor(0.74)
                .frame(maxWidth: .infinity, alignment: .center)

            DirectionWaypointDial(
                bearing: waypointBearing,
                bearingDelta: bearingDelta,
                cardinal: cardinalText(for: .waypoint)
            )
            .frame(width: 173, height: 173)
            .frame(maxWidth: .infinity)

            waypointDirectionCard
            backButton
        }
        .padding(.horizontal, 9)
        .padding(.top, 9)
        .padding(.bottom, 7)
    }

    private func topBar(title: String, systemImage: String) -> some View {
        HStack(alignment: .top) {
            HStack(spacing: 7) {
                Image(systemName: systemImage)
                    .font(.system(size: 22, weight: .black))
                    .foregroundStyle(DiveUI.cyan)
                    .frame(width: 29, height: 28)
                Text(title)
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(DiveUI.cyan)
                    .lineLimit(1)
            }

            Spacer()

            Button {
                screen = .settings
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 17, weight: .black))
                    .foregroundStyle(DiveUI.cyan)
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)

            VStack(alignment: .trailing, spacing: 1) {
                HStack(spacing: 3) {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 13, weight: .bold))
                    Text(temperatureText)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .monospacedDigit()
                }
                .foregroundStyle(DiveUI.blue)

                // TODO: Replace this visual placeholder if a watch clock value becomes part of the view model.
                Text("--:--")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .monospacedDigit()
            }
        }
    }

    private func statusRow(_ title: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "water.waves")
                .font(.system(size: 18, weight: .black))
            Text(title)
                .font(.system(size: 15, weight: .black, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.78)
            Spacer(minLength: 0)
        }
        .foregroundStyle(DiveUI.green)
    }

    private var activityMetricsPanel: some View {
        HStack(spacing: 0) {
            compactMetric(title: "RUNTIME", value: Formatters.time(exploration.runtimeSeconds), unit: "min", color: .white)
            divider(height: 56)
            compactMetric(title: "DISTANZA", value: distanceKilometersText, unit: "km", color: DiveUI.blue)
            divider(height: 56)
            compactMetric(title: "VEL. MEDIA", value: averageSpeedText, unit: "km/h", color: DiveUI.blue)
        }
        .frame(maxWidth: .infinity, minHeight: 78)
        .background(
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .fill(Color.black.opacity(0.42))
                .overlay(
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .stroke(DiveUI.cyan.opacity(0.78), lineWidth: 1.2)
                )
                .shadow(color: DiveUI.cyan.opacity(0.14), radius: 5, x: 0, y: 0)
        )
    }

    private func compactMetric(title: String, value: String, unit: String, color: Color) -> some View {
        VStack(spacing: 1) {
            Text(title)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(value)
                .font(.system(size: 28, weight: .black, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.54)
            Text(unit)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }

    private func divider(height: CGFloat) -> some View {
        Rectangle()
            .fill(.white.opacity(0.32))
            .frame(width: 1, height: height)
    }

    private func depthAndGpsSection(leftWidth: CGFloat, rightWidth: CGFloat) -> some View {
        HStack(alignment: .top, spacing: 9) {
            VStack(alignment: .leading, spacing: 8) {
                depthReadout
                snorkelingSummaryCards
            }
            .frame(width: leftWidth, alignment: .leading)

            gpsColumn
                .frame(width: rightWidth)
        }
    }

    private var depthReadout: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("PROFONDITÀ ATTUALE")
                .font(.system(size: 14, weight: .black, design: .rounded))
                .foregroundStyle(DiveUI.blue)
                .lineLimit(1)
                .minimumScaleFactor(0.64)
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(Formatters.one(dive.currentDepthMeters))
                    .font(.system(size: 72, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.38)
                    .layoutPriority(1)
                Text("m")
                    .font(.system(size: 31, weight: .black, design: .rounded))
                    .foregroundStyle(DiveUI.blue)
                    .padding(.bottom, 9)
            }
        }
    }

    private var snorkelingSummaryCards: some View {
        HStack(spacing: 7) {
            summaryCard(title: "PROF. MASSIMA", value: Formatters.one(dive.maxDepthMeters), unit: "m")
            summaryCard(title: "TEMPO TOTALE", value: totalRuntimeText, unit: "ore")
        }
    }

    private func summaryCard(title: String, value: String, unit: String) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.58)
            HStack(alignment: .lastTextBaseline, spacing: 3) {
                Text(value)
                    .font(.system(size: 25, weight: .black, design: .rounded))
                    .foregroundStyle(DiveUI.blue)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.56)
                Text(unit)
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(DiveUI.blue)
                    .padding(.bottom, 2)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 58)
        .background(
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .fill(Color.black.opacity(0.45))
                .overlay(
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .stroke(.white.opacity(0.34), lineWidth: 1.1)
                )
        )
    }

    private var gpsColumn: some View {
        VStack(spacing: 7) {
            Text("GPS")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
            Image(systemName: "cellularbars")
                .font(.system(size: 29, weight: .black))
                .foregroundStyle(exploration.hasSnorkelingPosition ? DiveUI.green : DiveUI.yellow)
            Text(gpsQualityText)
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundStyle(exploration.hasSnorkelingPosition ? DiveUI.green : DiveUI.yellow)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            Rectangle()
                .fill(.white.opacity(0.28))
                .frame(maxWidth: .infinity)
                .frame(height: 1)
                .padding(.vertical, 7)

            Text("SEGNALE")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
            Text(signalText)
                .font(.system(size: 11, weight: .black, design: .rounded))
                .foregroundStyle(exploration.hasSnorkelingPosition ? DiveUI.green : DiveUI.yellow)
                .lineLimit(2)
                .minimumScaleFactor(0.62)
        }
        .padding(.leading, 8)
        .frame(maxHeight: 170)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(.white.opacity(0.28))
                .frame(width: 1)
        }
    }

    private func waypointPanel(mode: SnorkelingMapMode) -> some View {
        HStack(spacing: 0) {
            HStack(spacing: 9) {
                Image(systemName: mode.panelIcon)
                    .font(.system(size: 36, weight: .black))
                    .foregroundStyle(DiveUI.yellow)

                VStack(alignment: .leading, spacing: 1) {
                    Text(mode.panelTitle)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text(mode == .returnToEntry ? entryNameText : exploration.activeWaypoint.name)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(DiveUI.yellow)
                        .lineLimit(1)
                        .minimumScaleFactor(0.62)
                    HStack(alignment: .lastTextBaseline, spacing: 3) {
                        Text(distanceText(for: mode))
                            .font(.system(size: 35, weight: .black, design: .rounded))
                            .foregroundStyle(DiveUI.yellow)
                            .monospacedDigit()
                        Text("m")
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .foregroundStyle(DiveUI.yellow)
                            .padding(.bottom, 4)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            divider(height: 64)

            VStack(spacing: 2) {
                Text("DIREZIONE")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                HStack(spacing: 5) {
                    Text(bearingText(for: mode))
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(DiveUI.yellow)
                        .monospacedDigit()
                    Image(systemName: "location.north.fill")
                        .font(.system(size: 31, weight: .black))
                        .foregroundStyle(DiveUI.yellow)
                        .rotationEffect(.degrees(bearingDelta))
                }
                Text(cardinalText(for: mode))
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(DiveUI.yellow)
            }
            .frame(width: 92)
        }
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, minHeight: 86)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.black.opacity(0.43))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(DiveUI.yellow.opacity(0.9), lineWidth: 1.2)
                )
                .shadow(color: DiveUI.yellow.opacity(0.14), radius: 5, x: 0, y: 0)
        )
    }

    private var waypointSummaryCard: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text("PROSSIMO WAYPOINT")
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundStyle(DiveUI.cyan)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                Text(exploration.activeWaypoint.name)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                Text("DISTANZA")
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .foregroundStyle(DiveUI.yellow)
                    .lineLimit(1)
                HStack(alignment: .lastTextBaseline, spacing: 3) {
                    Text(distanceText(for: .waypoint))
                        .font(.system(size: 29, weight: .black, design: .rounded))
                        .foregroundStyle(DiveUI.yellow)
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)
                    Text("m")
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(DiveUI.yellow)
                        .padding(.bottom, 3)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            divider(height: 66)
                .padding(.horizontal, 9)

            VStack(spacing: 1) {
                Text("DIREZIONE")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                HStack(spacing: 6) {
                    VStack(spacing: 0) {
                        Text(bearingText(for: .waypoint))
                            .font(.system(size: 27, weight: .black, design: .rounded))
                            .foregroundStyle(DiveUI.yellow)
                            .monospacedDigit()
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        Text(cardinalText(for: .waypoint))
                            .font(.system(size: 12, weight: .black, design: .rounded))
                            .foregroundStyle(DiveUI.yellow)
                    }
                    Image(systemName: "location.north.fill")
                        .font(.system(size: 28, weight: .black))
                        .foregroundStyle(DiveUI.yellow)
                        .rotationEffect(.degrees(bearingDelta))
                }
            }
            .frame(width: 83)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .frame(maxWidth: .infinity, minHeight: 84)
        .background(
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .fill(Color.black.opacity(0.48))
                .overlay(
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .stroke(.white.opacity(0.34), lineWidth: 1.1)
                )
        )
    }

    private var backButton: some View {
        Button {
            screen = .live
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 17, weight: .black))
                Text("INDIETRO")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
            .foregroundStyle(DiveUI.blue)
            .frame(maxWidth: .infinity, minHeight: 45)
            .background(
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .fill(Color.black.opacity(0.36))
                    .overlay(
                        RoundedRectangle(cornerRadius: 13, style: .continuous)
                            .stroke(DiveUI.blue.opacity(0.75), lineWidth: 1.3)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private var returnSummaryCard: some View {
        VStack(spacing: 9) {
            Text("RITORNO AL PUNTO DI PARTENZA")
                .font(.system(size: 11, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.66)
                .frame(maxWidth: .infinity, alignment: .center)

            HStack(spacing: 0) {
                VStack(spacing: 2) {
                    Text("DISTANZA")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    HStack(alignment: .lastTextBaseline, spacing: 3) {
                        Text(distanceText(for: .returnToEntry))
                            .font(.system(size: 29, weight: .black, design: .rounded))
                            .foregroundStyle(DiveUI.yellow)
                            .monospacedDigit()
                            .lineLimit(1)
                            .minimumScaleFactor(0.62)
                        Text("m")
                            .font(.system(size: 13, weight: .black, design: .rounded))
                            .foregroundStyle(DiveUI.yellow)
                            .padding(.bottom, 3)
                    }
                }
                .frame(maxWidth: .infinity)

                divider(height: 48)

                HStack(spacing: 7) {
                    VStack(spacing: 0) {
                        Text("DIREZIONE")
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                        Text(bearingText(for: .returnToEntry))
                            .font(.system(size: 27, weight: .black, design: .rounded))
                            .foregroundStyle(DiveUI.yellow)
                            .monospacedDigit()
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        Text(cardinalText(for: .returnToEntry))
                            .font(.system(size: 12, weight: .black, design: .rounded))
                            .foregroundStyle(DiveUI.yellow)
                    }

                    Image(systemName: "location.north.fill")
                        .font(.system(size: 28, weight: .black))
                        .foregroundStyle(DiveUI.yellow)
                        .rotationEffect(.degrees(returnBearing - compass.headingDegrees))
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, minHeight: 84)
        .background(
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .fill(Color.black.opacity(0.48))
                .overlay(
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .stroke(.white.opacity(0.34), lineWidth: 1.1)
                )
        )
    }

    private var waypointDirectionCard: some View {
        VStack(spacing: 8) {
            Text("VERSO WAYPOINT")
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Text(exploration.activeWaypoint.name)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Rectangle()
                .fill(.white.opacity(0.18))
                .frame(maxWidth: .infinity)
                .frame(height: 1)

            HStack(spacing: 9) {
                Text("DISTANZA")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.82))
                    .lineLimit(1)
                divider(height: 25)
                HStack(alignment: .lastTextBaseline, spacing: 3) {
                    Text(distanceText(for: .waypoint))
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundStyle(DiveUI.yellow)
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text("m")
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundStyle(DiveUI.yellow)
                        .padding(.bottom, 2)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, minHeight: 96)
        .background(
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .fill(Color.black.opacity(0.48))
                .overlay(
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .stroke(.white.opacity(0.34), lineWidth: 1.1)
                )
        )
    }

    private var markerSavedScreen: some View {
        let marker = lastSavedMarker
        return VStack(spacing: 10) {
            topBar(title: "SNORKELING", systemImage: "figure.pool.swim")
            Spacer(minLength: 8)
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64, weight: .black))
                .foregroundStyle(DiveUI.green)
                .shadow(color: DiveUI.green.opacity(0.42), radius: 8, x: 0, y: 0)
            Text("MARCATORE\nSALVATO")
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundStyle(DiveUI.green)
                .multilineTextAlignment(.center)
            Text(marker?.latitude == nil ? "GPS non disponibile" : "Da arricchire su iPhone")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(marker?.latitude == nil ? DiveUI.yellow : .white)
                .multilineTextAlignment(.center)
            markerCoordinateSummary(marker)
            watchSyncBoundaryPanel(
                title: "WATCH -> IPHONE POI",
                message: "Payload accodato/inviato: \(watchSync.experimentalLastKind). Stato: \(watchSync.experimentalDeliveryState). Coda: \(watchSync.experimentalQueueCount).",
                color: DiveUI.cyan
            )
            HStack(spacing: 8) {
                compactAction("LOG", icon: "list.bullet.rectangle", color: DiveUI.cyan) {
                    screen = .markerLog
                }
                compactAction("DETTAGLI", icon: "info.circle", color: DiveUI.green) {
                    selectedMarker = marker
                    screen = .markerDetail
                }
            }
            backButton
        }
        .padding(.horizontal, 9)
        .padding(.top, 9)
        .padding(.bottom, 7)
        .task(id: marker?.id) {
            try? await Task.sleep(nanoseconds: 1_600_000_000)
            await MainActor.run {
                guard screen == .markerSaved else { return }
                screen = .live
            }
        }
    }

    private var markerLogScreen: some View {
        ScrollView {
            VStack(spacing: 8) {
                topBar(title: "MARCATORI", systemImage: "mappin.circle.fill")
                Text("LOG MARCATORI")
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(DiveUI.cyan)
                    .frame(maxWidth: .infinity)
                if exploration.markers.isEmpty {
                    unavailablePanel(
                        title: "NESSUN MARCATORE",
                        message: "Tocca MARCATORE nella schermata live per salvare un POI leggero.",
                        color: DiveUI.secondaryText
                    )
                } else {
                    ForEach(Array(exploration.markers.prefix(8))) { marker in
                        Button {
                            selectedMarker = marker
                            screen = .markerDetail
                        } label: {
                            markerLogRow(marker)
                        }
                        .buttonStyle(.plain)
                    }
                }
                backButton
            }
            .padding(.horizontal, 9)
            .padding(.top, 9)
            .padding(.bottom, 7)
        }
    }

    private var markerDetailScreen: some View {
        let marker = selectedMarker ?? lastSavedMarker
        return VStack(spacing: 9) {
            topBar(title: "MARCATORI", systemImage: "mappin.circle.fill")
            Text("DETTAGLIO MARCATORE")
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundStyle(DiveUI.cyan)
                .frame(maxWidth: .infinity)
            if let marker {
                VStack(spacing: 7) {
                    detailLine("Ora", value: Self.markerTimeFormatter.string(from: marker.timestamp), color: .white)
                    detailLine("Distanza", value: marker.distanceFromEntryMeters > 0 ? "\(Int(marker.distanceFromEntryMeters.rounded())) m" : "--", color: DiveUI.yellow)
                    detailLine("Direzione", value: "\(Int(marker.bearingDegrees.rounded()))° \(cardinal(for: marker.bearingDegrees))", color: DiveUI.yellow)
                    detailLine("Profondità", value: "\(Formatters.one(marker.depthMeters)) m", color: DiveUI.blue)
                    detailLine("Temperatura", value: marker.temperatureCelsius.map { "\(Formatters.one($0)) °C" } ?? "--", color: DiveUI.blue)
                    detailLine("Waypoint", value: marker.activeWaypointName ?? "--", color: DiveUI.cyan)
                    detailLine("Sessione", value: marker.sessionID ?? "--", color: DiveUI.secondaryText)
                    detailLine("Stato", value: marker.isEnriched ? "Arricchito" : "Da arricchire su iPhone", color: marker.isEnriched ? DiveUI.green : DiveUI.yellow)
                }
                .padding(10)
                .background(markerPanel(stroke: DiveUI.cyan.opacity(0.62)))
                watchSyncBoundaryPanel(
                    title: "SYNC POI EXPERIMENTAL",
                    message: "Stato: \(watchSync.experimentalDeliveryState). Coda locale Watch: \(watchSync.experimentalQueueCount). ACK/retry persistente completo ancora LAB.",
                    color: DiveUI.cyan
                )
                Text("TODO Watch experimental: eliminazione marcatore con conferma dedicata.")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(DiveUI.red)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                unavailablePanel(title: "MARCATORE NON DISPONIBILE", message: "Torna al log marcatori e seleziona un POI.", color: DiveUI.yellow)
            }
            backToMarkerLogButton
        }
        .padding(.horizontal, 9)
        .padding(.top, 9)
        .padding(.bottom, 7)
    }

    private var snorkelingSettingsScreen: some View {
        ScrollView {
            VStack(spacing: 8) {
                topBar(title: "SNORKELING", systemImage: "gearshape")
                Text("IMPOSTAZIONI SNORKELING")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(DiveUI.cyan)
                    .frame(maxWidth: .infinity)
                settingsRow("Log Marcatori", subtitle: "\(exploration.markers.count) salvati", icon: "list.bullet.rectangle", color: DiveUI.green, destination: .markerLog)
                settingsRow("Allarmi Snorkeling", subtitle: "Soglie sperimentali", icon: "bell", color: DiveUI.yellow, destination: .alarms)
                settingsRow("Calibrazione Bussola", subtitle: "Istruzioni sensore", icon: "location.north.circle", color: DiveUI.cyan, destination: .compassCalibration)
                settingsRow("Legenda Icone Mappe", subtitle: "Waypoint, entry e POI", icon: "map", color: DiveUI.blue, destination: .mapLegend)
                Toggle(isOn: $experimentalHapticsEnabled) {
                    Text("Haptic sperimentali")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                }
                .tint(DiveUI.green)
                .padding(10)
                .background(markerPanel(stroke: DiveUI.green.opacity(0.45)))
                compactAction("TERMINA SESSIONE", icon: "stop.circle", color: DiveUI.red) {
                    exploration.endSnorkeling()
                    HapticService.shared.notify()
                    screen = .live
                }
                backButton
            }
            .padding(.horizontal, 9)
            .padding(.top, 9)
            .padding(.bottom, 7)
        }
    }

    private var snorkelingAlarmsScreen: some View {
        VStack(spacing: 9) {
            topBar(title: "SNORKELING", systemImage: "bell")
            Text("ALLARMI SNORKELING")
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundStyle(DiveUI.blue)
            VStack(spacing: 0) {
                persistedAlarmRow(
                    "Profondità massima",
                    value: "\(Formatters.one(snorkelingAlarmMaxDepthMeters)) m",
                    decrement: { snorkelingAlarmMaxDepthMeters = max(1, snorkelingAlarmMaxDepthMeters - 0.5) },
                    increment: { snorkelingAlarmMaxDepthMeters = min(40, snorkelingAlarmMaxDepthMeters + 0.5) }
                )
                persistedAlarmRow(
                    "Tempo massimo",
                    value: "\(snorkelingAlarmMaxMinutes) min",
                    decrement: { snorkelingAlarmMaxMinutes = max(5, snorkelingAlarmMaxMinutes - 5) },
                    increment: { snorkelingAlarmMaxMinutes = min(240, snorkelingAlarmMaxMinutes + 5) }
                )
                persistedAlarmRow(
                    "Distanza massima",
                    value: "\(Formatters.one(snorkelingAlarmMaxDistanceKm)) km",
                    decrement: { snorkelingAlarmMaxDistanceKm = max(0.5, snorkelingAlarmMaxDistanceKm - 0.5) },
                    increment: { snorkelingAlarmMaxDistanceKm = min(20, snorkelingAlarmMaxDistanceKm + 0.5) }
                )
                persistedAlarmRow(
                    "Batteria bassa",
                    value: "\(snorkelingAlarmLowBatteryPercent) % OFF",
                    decrement: { snorkelingAlarmLowBatteryPercent = max(5, snorkelingAlarmLowBatteryPercent - 5) },
                    increment: { snorkelingAlarmLowBatteryPercent = min(50, snorkelingAlarmLowBatteryPercent + 5) }
                )
            }
            .background(markerPanel(stroke: .white.opacity(0.28)))
            Text("Profondità, tempo e distanza sono enforce locali con haptic warning. Batteria è solo configurata: sensore batteria non collegato in questo pass.")
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(DiveUI.yellow)
                .fixedSize(horizontal: false, vertical: true)
            settingsBackButton
        }
        .padding(.horizontal, 9)
        .padding(.top, 9)
        .padding(.bottom, 7)
    }

    private var compassCalibrationScreen: some View {
        VStack(spacing: 9) {
            topBar(title: "BUSSOLA", systemImage: "location.north.circle")
            unavailablePanel(
                title: "CALIBRAZIONE BUSSOLA",
                message: "Muovi lentamente Apple Watch formando un 8. Mantieni il Watch lontano da metallo, magneti e motori. Questa schermata non modifica gli algoritmi bussola.",
                color: DiveUI.cyan
            )
            settingsBackButton
        }
        .padding(.horizontal, 9)
        .padding(.top, 9)
        .padding(.bottom, 7)
    }

    private var mapLegendScreen: some View {
        ScrollView {
            VStack(spacing: 8) {
                topBar(title: "MAPPE", systemImage: "map")
                Text("LEGENDA ICONE MAPPE")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(DiveUI.cyan)
                legendRow("location.north.fill", title: "Posizione attuale", color: DiveUI.green)
                legendRow("scope", title: "Waypoint", color: DiveUI.yellow)
                legendRow("house.circle", title: "Punto di partenza", color: DiveUI.cyan)
                legendRow("mappin.circle.fill", title: "POI / Marcatore", color: DiveUI.green)
                legendRow("point.topleft.down.curvedto.point.bottomright.up", title: "Rotta waypoint", color: DiveUI.yellow)
                legendRow("arrow.uturn.backward", title: "Rotta ritorno", color: DiveUI.cyan)
                settingsBackButton
            }
            .padding(.horizontal, 9)
            .padding(.top, 9)
            .padding(.bottom, 7)
        }
    }

    private func controls(kind: SnorkelingControlsKind) -> some View {
        HStack(spacing: 7) {
            DiveCommandButton("MARCATORE", systemImage: "mappin.circle.fill", color: DiveUI.green) {
                saveMarker()
            }
            DiveCommandButton(kind.middleTitle, systemImage: kind.middleIcon, color: DiveUI.cyan) {
                switch kind {
                case .live:
                    exploration.startReturnMode()
                    screen = .returnMap
                case .waypointMap, .returnMap:
                    screen = .live
                }
            }
            DiveCommandButton("BUSSOLA", systemImage: "location.north.circle", color: .white.opacity(0.8)) {
                exploration.startNavigation()
                screen = .waypointDirection
            }
        }
    }

    private func saveMarker() {
        let point = gps.currentBestPoint()
        let marker = exploration.saveMarker(
            gpsPoint: point,
            depthMeters: dive.currentDepthMeters,
            temperatureCelsius: dive.currentTemperatureCelsius,
            bearingDegrees: compass.headingDegrees
        )
        lastSavedMarker = marker
        selectedMarker = marker
        screen = .markerSaved
        WatchSyncService.shared.transferExperimentalPOI(marker)
        if point == nil {
            HapticService.shared.warnIfNeeded()
        } else {
            HapticService.shared.confirm()
        }
    }

    private func startSnorkelingSessionIfNeeded() {
        let point = gps.currentBestPoint()
        exploration.startSnorkelingIfNeeded(entryPoint: point)
        if point == nil {
            HapticService.shared.warnIfNeeded()
        } else {
            HapticService.shared.notify()
        }
    }

    private func evaluateSnorkelingAlarms() {
        guard exploration.isSnorkelingSessionActive else { return }
        if dive.currentDepthMeters >= snorkelingAlarmMaxDepthMeters {
            triggerSnorkelingAlarm("ALLARME PROFONDITÀ \(Formatters.one(dive.currentDepthMeters)) m")
            return
        }
        if exploration.runtimeSeconds / 60 >= Double(snorkelingAlarmMaxMinutes) {
            triggerSnorkelingAlarm("ALLARME TEMPO \(snorkelingAlarmMaxMinutes) min")
            return
        }
        if exploration.distanceMeters / 1_000 >= snorkelingAlarmMaxDistanceKm {
            triggerSnorkelingAlarm("ALLARME DISTANZA \(Formatters.one(exploration.distanceMeters / 1_000)) km")
            return
        }
        if exploration.snorkelingWarning?.hasPrefix("ALLARME") == true {
            exploration.updateSnorkelingWarning(nil)
        }
    }

    private func triggerSnorkelingAlarm(_ warning: String) {
        guard exploration.snorkelingWarning != warning else { return }
        exploration.updateSnorkelingWarning(warning)
        HapticService.shared.warnIfNeeded()
    }

    private func markerCoordinateSummary(_ marker: GPSInterestMarker?) -> some View {
        VStack(spacing: 4) {
            Text(marker?.latitude == nil ? "GPS NON DISPONIBILE" : coordinatePairText(marker))
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(marker?.latitude == nil ? DiveUI.yellow : .white)
                .monospacedDigit()
                .lineLimit(2)
                .minimumScaleFactor(0.68)
            Text("Sync POI: \(watchSync.experimentalDeliveryState)")
                .font(.system(size: 9, weight: .semibold, design: .rounded))
                .foregroundStyle(DiveUI.secondaryText)
                .lineLimit(2)
                .minimumScaleFactor(0.62)
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(markerPanel(stroke: DiveUI.green.opacity(0.58)))
    }

    private func compactAction(_ title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(title)
            }
            .font(.system(size: 12, weight: .black, design: .rounded))
            .foregroundStyle(color)
            .frame(maxWidth: .infinity, minHeight: 42)
            .background(markerPanel(stroke: color.opacity(0.72)))
        }
        .buttonStyle(.plain)
    }

    private func snorkelingWarningPanel(_ warning: String) -> some View {
        HStack(spacing: 7) {
            Image(systemName: warning.hasPrefix("ALLARME") ? "exclamationmark.triangle.fill" : "location.slash")
                .font(.system(size: 14, weight: .black))
            Text(warning)
                .font(.system(size: 10, weight: .black, design: .rounded))
                .lineLimit(2)
                .minimumScaleFactor(0.62)
            Spacer(minLength: 0)
        }
        .foregroundStyle(warning.hasPrefix("ALLARME") ? DiveUI.red : DiveUI.yellow)
        .padding(.horizontal, 9)
        .frame(maxWidth: .infinity, minHeight: 30)
        .background(markerPanel(stroke: (warning.hasPrefix("ALLARME") ? DiveUI.red : DiveUI.yellow).opacity(0.62)))
    }

    private func schematicMapNotice(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 9, weight: .black, design: .rounded))
            .foregroundStyle(DiveUI.yellow)
            .lineLimit(1)
            .minimumScaleFactor(0.62)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity)
            .background(markerPanel(stroke: DiveUI.yellow.opacity(0.36)))
    }

    private func markerLogRow(_ marker: GPSInterestMarker) -> some View {
        HStack(spacing: 8) {
            Image(systemName: marker.category.symbol)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(marker.isEnriched ? DiveUI.green : DiveUI.yellow)
                .frame(width: 30, height: 30)
                .background(Circle().fill(Color.black.opacity(0.46)))
            VStack(alignment: .leading, spacing: 2) {
                Text("\(marker.category.rawValue) • \(Self.markerTimeFormatter.string(from: marker.timestamp))")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(marker.isEnriched ? "Arricchito" : "Da arricchire su iPhone")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(marker.isEnriched ? DiveUI.green : DiveUI.yellow)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
            Text(marker.distanceFromEntryMeters > 0 ? "\(Int(marker.distanceFromEntryMeters.rounded())) m" : "--")
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundStyle(DiveUI.cyan)
                .monospacedDigit()
        }
        .padding(9)
        .background(markerPanel(stroke: DiveUI.cyan.opacity(0.36)))
    }

    private func detailLine(_ title: String, value: String, color: Color) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(DiveUI.secondaryText)
            Spacer(minLength: 8)
            Text(value)
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.62)
        }
    }

    private func settingsRow(_ title: String, subtitle: String, icon: String, color: Color, destination: SnorkelingScreen) -> some View {
        Button {
            screen = destination
        } label: {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(color)
                    .frame(width: 28)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(DiveUI.secondaryText)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .black))
                    .foregroundStyle(.white.opacity(0.55))
            }
            .padding(10)
            .background(markerPanel(stroke: color.opacity(0.38)))
        }
        .buttonStyle(.plain)
    }

    private func persistedAlarmRow(_ title: String, value: String, decrement: @escaping () -> Void, increment: @escaping () -> Void) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
            Spacer()
            Text(value)
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundStyle(DiveUI.yellow)
                .monospacedDigit()
            Button(action: decrement) {
                Image(systemName: "minus")
                    .font(.system(size: 10, weight: .black))
                    .foregroundStyle(DiveUI.cyan)
                    .frame(width: 24, height: 24)
                    .background(RoundedRectangle(cornerRadius: 7).stroke(DiveUI.cyan.opacity(0.68), lineWidth: 1))
            }
            .buttonStyle(.plain)
            Button(action: increment) {
                Image(systemName: "plus")
                    .font(.system(size: 10, weight: .black))
                    .foregroundStyle(DiveUI.cyan)
                    .frame(width: 24, height: 24)
                    .background(RoundedRectangle(cornerRadius: 7).stroke(DiveUI.cyan.opacity(0.68), lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
        .frame(height: 40)
    }

    private var settingsBackButton: some View {
        compactAction("IMPOSTAZIONI", icon: "arrow.left", color: DiveUI.blue) {
            screen = .settings
        }
    }

    private var backToMarkerLogButton: some View {
        compactAction("LOG MARCATORI", icon: "arrow.left", color: DiveUI.blue) {
            screen = .markerLog
        }
    }

    private func legendRow(_ icon: String, title: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .black))
                .foregroundStyle(color)
                .frame(width: 30)
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
            Spacer()
        }
        .padding(9)
        .background(markerPanel(stroke: color.opacity(0.34)))
    }

    private func unavailablePanel(title: String, message: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(color)
                .multilineTextAlignment(.center)
            Text(message)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.82))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 92)
        .background(markerPanel(stroke: color.opacity(0.55)))
    }

    private func watchSyncBoundaryPanel(title: String, message: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 5) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 11, weight: .black))
                Text(title)
                    .font(.system(size: 10, weight: .black, design: .rounded))
            }
            .foregroundStyle(color)
            Text(message)
                .font(.system(size: 9, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.78))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(9)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(markerPanel(stroke: color.opacity(0.42)))
    }

    private func markerPanel(stroke: Color) -> some View {
        RoundedRectangle(cornerRadius: 13, style: .continuous)
            .fill(Color.black.opacity(0.48))
            .overlay(RoundedRectangle(cornerRadius: 13, style: .continuous).stroke(stroke, lineWidth: 1.2))
    }

    private func coordinatePairText(_ marker: GPSInterestMarker?) -> String {
        guard let latitude = marker?.latitude, let longitude = marker?.longitude else { return "GPS NON DISPONIBILE" }
        return String(format: "%.5f, %.5f", latitude, longitude)
    }

    private var temperatureText: String {
        guard let temp = dive.currentTemperatureCelsius else { return "--.- \u{00B0}C" }
        return "\(Formatters.one(temp)) \u{00B0}C"
    }

    private var distanceKilometersText: String {
        String(format: "%.2f", exploration.distanceMeters / 1_000)
    }

    private var averageSpeedText: String {
        String(format: "%.1f", exploration.averageSpeedKnots * 1.852)
    }

    private var totalRuntimeText: String {
        let totalMinutes = max(0, Int(exploration.runtimeSeconds / 60))
        return String(format: "%02d:%02d", totalMinutes / 60, totalMinutes % 60)
    }

    private var gpsQualityText: String {
        exploration.hasSnorkelingPosition ? "SURFACE" : "NO FIX"
    }

    private var signalText: String {
        exploration.hasSnorkelingPosition ? "DISPONIBILE" : "GPS NON DISP."
    }

    private var gpsMapStatusText: String {
        exploration.hasSnorkelingPosition ? "GPS OK" : "GPS NON DISPONIBILE"
    }

    private var directionCardinal: String {
        cardinal(for: exploration.liveTargetBearing)
    }

    private var waypointBearing: Double {
        let bearing = exploration.liveTargetBearing
        if bearing == 0 {
            // TODO: Remove this visual fallback once a selected waypoint bearing is guaranteed during previews/idle state.
            return 128
        }
        return bearing
    }

    private var entryNameText: String {
        // TODO: Replace with the saved entry-point label if snorkeling sessions expose a named entry location.
        "Ingresso Barca"
    }

    private var returnBearing: Double {
        // TODO: Replace with entry-point bearing when ExplorationStore exposes the live return bearing separately.
        let bearing = exploration.snorkelingState == .returnMode ? exploration.liveTargetBearing : 214
        return bearing == 0 ? 214 : bearing
    }

    private func distanceText(for mode: SnorkelingMapMode) -> String {
        let distance = mode == .returnToEntry ? exploration.entryDistanceMeters : exploration.liveTargetDistanceMeters
        if mode == .returnToEntry && distance <= 0 {
            return "--"
        }
        return "\(Int(distance.rounded()))"
    }

    private func bearingText(for mode: SnorkelingMapMode) -> String {
        let bearing = mode == .returnToEntry ? returnBearing : waypointBearing
        return String(format: "%03d\u{00B0}", Int(bearing.rounded()))
    }

    private func cardinalText(for mode: SnorkelingMapMode) -> String {
        cardinal(for: mode == .returnToEntry ? returnBearing : waypointBearing)
    }

    private func cardinal(for bearing: Double) -> String {
        let normalized = (bearing.truncatingRemainder(dividingBy: 360) + 360).truncatingRemainder(dividingBy: 360)
        switch normalized {
        case 337.5..<360, 0..<22.5: return "N"
        case 22.5..<67.5: return "NE"
        case 67.5..<112.5: return "E"
        case 112.5..<157.5: return "SE"
        case 157.5..<202.5: return "S"
        case 202.5..<247.5: return "SW"
        case 247.5..<292.5: return "W"
        default: return "NW"
        }
    }

    private static let markerTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}

private enum SnorkelingScreen: Equatable {
    case live
    case waypointMap
    case returnMap
    case waypointDirection
    case markerSaved
    case markerLog
    case markerDetail
    case settings
    case alarms
    case compassCalibration
    case mapLegend
}

private enum SnorkelingControlsKind: Equatable {
    case live
    case waypointMap
    case returnMap

    var middleTitle: String {
        switch self {
        case .live:
            return "RITORNO"
        case .waypointMap, .returnMap:
            return "LIVE"
        }
    }

    var middleIcon: String {
        switch self {
        case .live:
            return "house.fill"
        case .waypointMap, .returnMap:
            return "play.fill"
        }
    }
}

private enum SnorkelingMapMode: Equatable {
    case waypoint
    case returnToEntry

    var headerTitle: String {
        switch self {
        case .waypoint: return "MAPPA"
        case .returnToEntry: return "RITORNO"
        }
    }

    var headerIcon: String {
        switch self {
        case .waypoint: return "map"
        case .returnToEntry: return "house"
        }
    }

    var statusTitle: String {
        switch self {
        case .waypoint: return "VERSO WAYPOINT"
        case .returnToEntry: return "MAPPA RITORNO"
        }
    }

    var mapTitle: String {
        switch self {
        case .waypoint: return "MAPPA WAYPOINT"
        case .returnToEntry: return "MAPPA RITORNO"
        }
    }

    var panelTitle: String {
        switch self {
        case .waypoint: return "VERSO WAYPOINT"
        case .returnToEntry: return "RITORNO AL PUNTO INIZIO"
        }
    }

    var panelIcon: String {
        switch self {
        case .waypoint: return "scope"
        case .returnToEntry: return "house.circle"
        }
    }

    var routeColor: Color {
        switch self {
        case .waypoint: return DiveUI.yellow
        case .returnToEntry: return DiveUI.cyan
        }
    }

    var targetColor: Color {
        switch self {
        case .waypoint: return DiveUI.yellow
        case .returnToEntry: return DiveUI.cyan
        }
    }
}

private struct SnorkelingWaypointMapView: View {
    let waypointName: String
    let gpsOKText: String

    var body: some View {
        SnorkelingRouteMapPanel(
            mode: .waypoint,
            waypointName: waypointName,
            gpsOKText: gpsOKText
        )
    }
}

private struct SnorkelingReturnMapView: View {
    let gpsOKText: String

    var body: some View {
        SnorkelingRouteMapPanel(
            mode: .returnToEntry,
            waypointName: "INGRESSO",
            gpsOKText: gpsOKText
        )
    }
}

private struct SnorkelingRouteMapPanel: View {
    let mode: SnorkelingMapMode
    let waypointName: String
    let gpsOKText: String

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            // Experimental Watch maps intentionally avoid online tile rendering in this pass.
            // TODO: Sync packaged MBTiles/offline map snapshots from the iOS companion for production use.
            // OSM public tile servers have usage policies; production should use approved/self-hosted tiles or MBTiles.
            // OpenSeaMap is an optional marine overlay; GEBCO/EMODnet are future bathymetry overlay sources.
            // TODO: Replace this schematic projection with real current/target map coordinates if the store exposes them for drawing.
            let current: CGPoint = {
                if mode == .waypoint {
                    return CGPoint(x: size.width * 0.34, y: size.height * 0.72)
                }
                return CGPoint(x: size.width * 0.58, y: size.height * 0.72)
            }()
            let target: CGPoint = {
                if mode == .waypoint {
                    return CGPoint(x: size.width * 0.86, y: size.height * 0.38)
                }
                return CGPoint(x: size.width * 0.26, y: size.height * 0.20)
            }()
            let seabed = [
                CGPoint(x: size.width * 0.02, y: size.height * 0.76),
                CGPoint(x: size.width * 0.11, y: size.height * 0.68),
                CGPoint(x: size.width * 0.21, y: size.height * 0.73),
                CGPoint(x: size.width * 0.31, y: size.height * 0.65),
                CGPoint(x: size.width * 0.44, y: size.height * 0.69),
                CGPoint(x: size.width * 0.56, y: size.height * 0.60),
                CGPoint(x: size.width * 0.72, y: size.height * 0.66),
                CGPoint(x: size.width * 0.98, y: size.height * 0.55)
            ]
            let routePoints = route(from: current, to: target, in: size)

            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(red: 0.0, green: 0.025, blue: 0.04).opacity(0.98))

                MarineDepthBackdrop()
                    .fill(DiveUI.cyan.opacity(0.05))
                    .padding(6)

                MarineGrid()
                    .stroke(DiveUI.cyan.opacity(0.10), lineWidth: 0.45)
                    .padding(10)

                Path { path in
                    path.addLines(seabed)
                }
                .stroke(DiveUI.green.opacity(0.19), style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))

                Path { path in
                    path.addLines(routePoints)
                }
                .stroke(
                    mode.routeColor,
                    style: StrokeStyle(
                        lineWidth: 2.4,
                        lineCap: .round,
                        lineJoin: .round,
                        dash: [8, 5]
                    )
                )
                .shadow(color: mode.routeColor.opacity(0.35), radius: 4, x: 0, y: 0)

                zoomControls
                    .position(x: size.width * 0.91, y: size.height * 0.70)

                scaleIndicator
                    .position(x: size.width * 0.17, y: size.height * 0.90)

                if mode == .returnToEntry {
                    targetMarker
                        .position(target)
                    currentMarker
                        .position(current)
                } else {
                    currentMarker
                        .position(current)
                    targetMarker
                        .position(target)
                    Text(waypointName)
                        .font(.system(size: 9, weight: .semibold, design: .rounded))
                        .foregroundStyle(DiveUI.yellow)
                        .lineLimit(1)
                        .minimumScaleFactor(0.62)
                        .position(x: min(size.width - 44, target.x + 24), y: target.y + 22)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(mode == .waypoint ? DiveUI.blue.opacity(0.46) : DiveUI.cyan.opacity(0.95), lineWidth: 1.4)
            )
        }
        .frame(maxWidth: .infinity, minHeight: mode == .waypoint ? 195 : 180)
    }

    private var zoomControls: some View {
        VStack(spacing: 9) {
            mapControlIcon("plus")
            mapControlIcon("minus")
            mapControlIcon("scope")
        }
    }

    private func mapControlIcon(_ systemImage: String) -> some View {
        Image(systemName: systemImage)
            .font(.system(size: 17, weight: .black))
            .foregroundStyle(.white)
            .frame(width: 30, height: 30)
            .background(
                Circle()
                    .fill(Color.black.opacity(0.62))
                    .overlay(Circle().stroke(.white.opacity(0.42), lineWidth: 1))
            )
    }

    private var scaleIndicator: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("100 m")
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: 54, y: 0))
                path.move(to: CGPoint(x: 0, y: -5))
                path.addLine(to: CGPoint(x: 0, y: 2))
                path.move(to: CGPoint(x: 54, y: -5))
                path.addLine(to: CGPoint(x: 54, y: 2))
            }
            .stroke(.white.opacity(0.86), lineWidth: 1)
            .frame(width: 54, height: 8)
        }
    }

    private func route(from current: CGPoint, to target: CGPoint, in size: CGSize) -> [CGPoint] {
        if mode == .returnToEntry {
            return [
                current,
                CGPoint(x: size.width * 0.54, y: size.height * 0.62),
                CGPoint(x: size.width * 0.47, y: size.height * 0.48),
                CGPoint(x: size.width * 0.37, y: size.height * 0.34),
                target
            ]
        } else {
            return [
                current,
                CGPoint(x: size.width * 0.43, y: size.height * 0.64),
                CGPoint(x: size.width * 0.52, y: size.height * 0.55),
                CGPoint(x: size.width * 0.62, y: size.height * 0.45),
                CGPoint(x: size.width * 0.74, y: size.height * 0.34),
                target
            ]
        }
    }

    private var currentMarker: some View {
        ZStack {
            Circle()
                .fill(DiveUI.blue)
                .frame(width: 25, height: 25)
                .overlay(Circle().stroke(.white.opacity(0.9), lineWidth: 1.3))
            Image(systemName: "location.north.fill")
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(.white)
                .offset(y: -1)
        }
        .shadow(color: DiveUI.blue.opacity(0.55), radius: 4, x: 0, y: 0)
    }

    private var targetMarker: some View {
        ZStack {
            Circle()
                .stroke(mode.targetColor, lineWidth: 3)
                .frame(width: 30, height: 30)
            Image(systemName: mode == .waypoint ? "scope" : "house.fill")
                .font(.system(size: mode == .waypoint ? 20 : 14, weight: .black))
                .foregroundStyle(mode.targetColor)
        }
        .shadow(color: mode.targetColor.opacity(0.35), radius: 4, x: 0, y: 0)
    }
}

private struct DirectionWaypointDial: View {
    let bearing: Double
    let bearingDelta: Double
    let cardinal: String

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)

            ZStack {
                Circle()
                    .stroke(.white.opacity(0.11), lineWidth: 1)
                    .frame(width: size * 0.98, height: size * 0.98)

                ForEach(0..<72, id: \.self) { tick in
                    Rectangle()
                        .fill(tick % 6 == 0 ? .white.opacity(0.76) : .white.opacity(0.28))
                        .frame(width: tick % 6 == 0 ? 1.6 : 0.8, height: tick % 6 == 0 ? 10 : 5)
                        .offset(y: -size * 0.47)
                        .rotationEffect(.degrees(Double(tick) * 5))
                }

                ForEach(directionLabels(size: size), id: \.label) { marker in
                    Text(marker.label)
                        .font(.system(size: marker.isCardinal ? 19 : 11, weight: .black, design: .rounded))
                        .foregroundStyle(marker.isCardinal ? .white : .white.opacity(0.82))
                        .rotationEffect(.degrees(marker.counterRotation))
                        .position(marker.position)
                }

                Circle()
                    .stroke(
                        DiveUI.yellow.opacity(0.88),
                        style: StrokeStyle(lineWidth: 1.7, lineCap: .round, dash: [1.5, 4])
                    )
                    .frame(width: size * 0.64, height: size * 0.64)
                    .shadow(color: DiveUI.yellow.opacity(0.22), radius: 4, x: 0, y: 0)

                Image(systemName: "location.north.fill")
                    .font(.system(size: 39, weight: .black))
                    .foregroundStyle(DiveUI.yellow)
                    .offset(y: -size * 0.20)
                    .rotationEffect(.degrees(bearingDelta))
                    .shadow(color: DiveUI.yellow.opacity(0.3), radius: 4, x: 0, y: 0)

                VStack(spacing: 3) {
                    Text(String(format: "%03d\u{00B0}", Int(bearing.rounded())))
                        .font(.system(size: 41, weight: .regular, design: .rounded))
                        .foregroundStyle(DiveUI.yellow)
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text(cardinal)
                        .font(.system(size: 22, weight: .regular, design: .rounded))
                        .foregroundStyle(DiveUI.yellow)
                        .lineLimit(1)
                }
                .offset(y: size * 0.16)

                Image(systemName: "triangle.fill")
                    .font(.system(size: 8, weight: .black))
                    .foregroundStyle(DiveUI.blue)
                    .offset(y: -size * 0.54)
                    .rotationEffect(.degrees(180))
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }

    private func directionLabels(size: CGFloat) -> [DirectionDialMarker] {
        let labels: [(String, Double, Bool)] = [
            ("N", 0, true),
            ("30", 30, false),
            ("60", 60, false),
            ("E", 90, true),
            ("120", 120, false),
            ("150", 150, false),
            ("S", 180, true),
            ("210", 210, false),
            ("240", 240, false),
            ("W", 270, true),
            ("300", 300, false),
            ("330", 330, false)
        ]

        return labels.map { label, angle, isCardinal in
            let radians = (angle - 90) * .pi / 180
            let radius = size * 0.39
            return DirectionDialMarker(
                label: label,
                position: CGPoint(
                    x: size / 2 + cos(radians) * radius,
                    y: size / 2 + sin(radians) * radius
                ),
                counterRotation: 0,
                isCardinal: isCardinal
            )
        }
    }
}

private struct DirectionDialMarker {
    let label: String
    let position: CGPoint
    let counterRotation: Double
    let isCardinal: Bool
}

private struct MarineDepthBackdrop: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addCurve(
            to: CGPoint(x: rect.minX + rect.width * 0.26, y: rect.maxY),
            control1: CGPoint(x: rect.minX + rect.width * 0.10, y: rect.minY + rect.height * 0.18),
            control2: CGPoint(x: rect.minX + rect.width * 0.06, y: rect.minY + rect.height * 0.72)
        )
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()

        for index in 0..<5 {
            let offset = CGFloat(index) * rect.width * 0.08
            path.move(to: CGPoint(x: rect.minX + rect.width * 0.40 + offset, y: rect.minY + rect.height * 0.06))
            path.addCurve(
                to: CGPoint(x: rect.minX + rect.width * 0.54 + offset, y: rect.maxY),
                control1: CGPoint(x: rect.minX + rect.width * 0.52 + offset, y: rect.minY + rect.height * 0.28),
                control2: CGPoint(x: rect.minX + rect.width * 0.38 + offset, y: rect.minY + rect.height * 0.68)
            )
        }

        return path
    }
}

private struct MarineGrid: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        for index in 0...7 {
            let x = rect.minX + rect.width * CGFloat(index) / 7
            path.move(to: CGPoint(x: x, y: rect.minY))
            path.addLine(to: CGPoint(x: x + 12, y: rect.maxY))
        }

        for index in 0...7 {
            let y = rect.minY + rect.height * CGFloat(index) / 7
            path.move(to: CGPoint(x: rect.minX, y: y))
            path.addLine(to: CGPoint(x: rect.maxX, y: y + 8))
        }

        return path
    }
}
