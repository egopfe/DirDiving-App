import SwiftUI

struct iOSContentView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    iOSHeaderView()
                    iOSLiveDiveCard()
                    iOSStatusGrid()
                    iOSBuddyCard()
                    iOSLogCard()
                }
                .padding(18)
            }
            .background(iOSDiveUI.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.black, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }
}

private enum iOSDiveUI {
    static let background = Color.black
    static let blue = Color(red: 0.0, green: 0.48, blue: 1.0)
    static let green = Color(red: 0.18, green: 0.82, blue: 0.35)
    static let yellow = Color(red: 1.0, green: 0.84, blue: 0.04)
    static let red = Color(red: 1.0, green: 0.23, blue: 0.19)
    static let orange = Color(red: 1.0, green: 0.58, blue: 0.0)
    static let stroke = Color.white.opacity(0.26)
    static let text = Color.white
    static let muted = Color.white.opacity(0.68)
}

private struct iOSPanel<Content: View>: View {
    let stroke: Color
    let content: Content

    init(stroke: Color = iOSDiveUI.stroke, @ViewBuilder content: () -> Content) {
        self.stroke = stroke
        self.content = content()
    }

    var body: some View {
        content
            .padding(14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(stroke, lineWidth: 1)
                    )
            )
    }
}

private struct iOSHeaderView: View {
    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            OctopusMark()
                .frame(width: 44, height: 44)
                .foregroundStyle(iOSDiveUI.blue)

            VStack(alignment: .leading, spacing: 4) {
                Text("DIR DIVING")
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .foregroundStyle(iOSDiveUI.text)
                HStack(spacing: 8) {
                    Image(systemName: "water.waves")
                    Text("IN IMMERSIONE")
                }
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(iOSDiveUI.green)
            }

            Spacer()

            HStack(spacing: 6) {
                Image(systemName: "drop.fill")
                Text("19.6 C")
            }
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .foregroundStyle(iOSDiveUI.blue)
        }
    }
}

private struct iOSLiveDiveCard: View {
    var body: some View {
        iOSPanel(stroke: iOSDiveUI.green) {
            VStack(spacing: 18) {
                HStack(spacing: 0) {
                    iOSTopMetric(title: "TTV", value: "44.3", color: iOSDiveUI.green)
                    Divider().overlay(Color.white.opacity(0.3))
                    iOSTopMetric(title: "RunTime", value: "28", unit: "min", color: .white)
                }
                .frame(height: 70)

                HStack(alignment: .center, spacing: 18) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .lastTextBaseline, spacing: 6) {
                            Text("21.4")
                                .font(.system(size: 86, weight: .regular, design: .rounded))
                                .monospacedDigit()
                                .foregroundStyle(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.72)
                            Text("m")
                                .font(.system(size: 34, weight: .semibold, design: .rounded))
                                .foregroundStyle(iOSDiveUI.blue)
                        }

                        Text("PROFONDITA ATTUALE")
                            .font(.system(size: 19, weight: .semibold, design: .rounded))
                            .foregroundStyle(iOSDiveUI.blue)

                        HStack(spacing: 10) {
                            iOSSmallMetric(title: "PROF. MASSIMA", value: "27.8", unit: "m")
                            iOSSmallMetric(title: "PROF. MEDIA", value: "15.6", unit: "m")
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    iOSAscentGauge()
                        .frame(width: 92)
                }

                HStack(spacing: 14) {
                    Image(systemName: "stopwatch.fill")
                        .font(.system(size: 38, weight: .medium))
                    VStack(spacing: 0) {
                        Text("28:47")
                            .font(.system(size: 52, weight: .regular, design: .rounded))
                            .monospacedDigit()
                        Text("CRONOMETRO")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                    }
                }
                .foregroundStyle(iOSDiveUI.yellow)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(iOSDiveUI.yellow, lineWidth: 1)
                )

                HStack(spacing: 10) {
                    iOSCommandButton(title: "START", image: "play.fill", color: iOSDiveUI.green)
                    iOSCommandButton(title: "STOP", image: "stop.fill", color: iOSDiveUI.red)
                    iOSCommandButton(title: "RESET", image: "arrow.clockwise", color: .white.opacity(0.72))
                }
            }
        }
    }
}

private struct iOSTopMetric: View {
    let title: String
    let value: String
    var unit: String?
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundStyle(.white)
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 42, weight: .regular, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(color)
                if let unit {
                    Text(unit)
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundStyle(.white)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

private struct iOSSmallMetric: View {
    let title: String
    let value: String
    let unit: String

    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
            HStack(alignment: .lastTextBaseline, spacing: 3) {
                Text(value)
                    .font(.system(size: 29, weight: .regular, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(iOSDiveUI.blue)
                Text(unit)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(iOSDiveUI.blue)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(iOSDiveUI.stroke, lineWidth: 1)
        )
    }
}

private struct iOSAscentGauge: View {
    var body: some View {
        VStack(spacing: 6) {
            Text("VELOCITA\nRISALITA")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            HStack(spacing: 7) {
                VStack(alignment: .trailing, spacing: 12) {
                    Text("3.0").foregroundStyle(iOSDiveUI.red)
                    Text("2.3").foregroundStyle(iOSDiveUI.orange)
                    Text("1.5").foregroundStyle(iOSDiveUI.yellow)
                    Text("0.8").foregroundStyle(iOSDiveUI.green)
                    Text("0.0").foregroundStyle(iOSDiveUI.green)
                }
                .font(.system(size: 12, weight: .semibold, design: .rounded))

                ZStack(alignment: .bottom) {
                    VStack(spacing: 0) {
                        iOSDiveUI.red
                        iOSDiveUI.orange
                        iOSDiveUI.yellow
                        iOSDiveUI.green
                    }
                    .clipShape(Rectangle())
                    .frame(width: 26, height: 128)
                    .overlay(Rectangle().stroke(.white, lineWidth: 1))

                    VStack(spacing: 19) {
                        ForEach(0..<5) { _ in
                            Rectangle()
                                .fill(.white)
                                .frame(width: 38, height: 1)
                        }
                    }
                    .frame(height: 128)
                }
            }

            Text("m/min")
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundStyle(.white)
        }
    }
}

private struct iOSStatusGrid: View {
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            iOSStatusTile(title: "WATCH", value: "SYNC", detail: "Apple Watch Ultra", color: iOSDiveUI.green)
            iOSStatusTile(title: "GPS", value: "READY", detail: "Entry / exit points", color: iOSDiveUI.blue)
            iOSStatusTile(title: "ASC SET", value: "10.0", detail: "m/min base limit", color: iOSDiveUI.yellow)
            iOSStatusTile(title: "EXPORT", value: "CSV", detail: "Subsurface ready", color: iOSDiveUI.blue)
        }
    }
}

private struct iOSStatusTile: View {
    let title: String
    let value: String
    let detail: String
    let color: Color

    var body: some View {
        iOSPanel(stroke: color) {
            VStack(alignment: .leading, spacing: 7) {
                Text(title)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                Text(value)
                    .font(.system(size: 28, weight: .regular, design: .rounded))
                    .foregroundStyle(color)
                Text(detail)
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(iOSDiveUI.muted)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct iOSBuddyCard: View {
    var body: some View {
        iOSPanel(stroke: iOSDiveUI.green) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("BUDDY LINK")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(iOSDiveUI.green)
                    Spacer()
                    Text("PRE-DIVE")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(iOSDiveUI.yellow)
                }

                Text("Pairing and preset messages are prepared before immersion. Underwater pairing is blocked.")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(iOSDiveUI.muted)

                HStack(spacing: 10) {
                    iOSCommandButton(title: "PAIR", image: "link", color: iOSDiveUI.green)
                    iOSCommandButton(title: "MESSAGES", image: "message.fill", color: iOSDiveUI.blue)
                }
            }
        }
    }
}

private struct iOSLogCard: View {
    var body: some View {
        iOSPanel(stroke: iOSDiveUI.blue) {
            VStack(alignment: .leading, spacing: 12) {
                Text("DIVE LOG")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(iOSDiveUI.blue)

                ForEach(["Max 27.8 m  RunTime 28 min", "Avg 15.6 m  Temp 19.6 C"], id: \.self) { row in
                    HStack {
                        Text(row)
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundStyle(.white)
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 9)
                            .stroke(iOSDiveUI.stroke, lineWidth: 1)
                    )
                }

                iOSCommandButton(title: "EXPORT CSV", image: "square.and.arrow.up", color: iOSDiveUI.blue)
            }
        }
    }
}

private struct iOSCommandButton: View {
    let title: String
    let image: String
    let color: Color

    var body: some View {
        Button {} label: {
            HStack(spacing: 7) {
                Text(title)
                Image(systemName: image)
            }
            .font(.system(size: 14, weight: .semibold, design: .rounded))
            .foregroundStyle(color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(color.opacity(0.82), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

private struct OctopusMark: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let center = CGPoint(x: rect.midX, y: rect.minY + h * 0.36)
        path.addEllipse(in: CGRect(x: center.x - w * 0.19, y: center.y - h * 0.2, width: w * 0.38, height: h * 0.36))
        path.addEllipse(in: CGRect(x: center.x - w * 0.11, y: center.y - h * 0.07, width: w * 0.05, height: h * 0.05))
        path.addEllipse(in: CGRect(x: center.x + w * 0.06, y: center.y - h * 0.07, width: w * 0.05, height: h * 0.05))

        let starts = stride(from: 0.18, through: 0.82, by: 0.16).map { rect.minX + w * CGFloat($0) }
        for (index, startX) in starts.enumerated() {
            let y = rect.minY + h * 0.57
            path.move(to: CGPoint(x: startX, y: y))
            let direction: CGFloat = index.isMultiple(of: 2) ? -1 : 1
            path.addCurve(
                to: CGPoint(x: startX + direction * w * 0.08, y: rect.maxY - h * 0.1),
                control1: CGPoint(x: startX + direction * w * 0.1, y: y + h * 0.08),
                control2: CGPoint(x: startX - direction * w * 0.08, y: rect.maxY - h * 0.22)
            )
        }

        return path.strokedPath(.init(lineWidth: max(2, w * 0.06), lineCap: .round, lineJoin: .round))
    }
}

#Preview {
    iOSContentView()
}
