import SwiftUI

struct SnorkelingWatchMicroMapView: View {
    let presentation: SnorkelingWatchMicroMapPresentation
    var accent: Color = DiveUI.cyan
    var size: CGFloat = 72

    var body: some View {
        Group {
            if presentation.isAvailable {
                Canvas { context, canvasSize in
                    let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height * 0.82)
                    let scale = min(canvasSize.width, canvasSize.height) / 2

                    if presentation.routeLine.count >= 2 {
                        var path = Path()
                        for (index, point) in presentation.routeLine.enumerated() {
                            let mapped = map(point, center: center, scale: scale)
                            if index == 0 {
                                path.move(to: mapped)
                            } else {
                                path.addLine(to: mapped)
                            }
                        }
                        context.stroke(path, with: .color(accent.opacity(0.85)), lineWidth: 2)
                    }

                    if let next = presentation.nextWaypointPoint {
                        let mapped = map(next, center: center, scale: scale)
                        let rect = CGRect(x: mapped.x - 3, y: mapped.y - 3, width: 6, height: 6)
                        context.fill(Path(ellipseIn: rect), with: .color(DiveUI.yellow))
                    }

                    if let current = presentation.currentPoint {
                        let mapped = map(current, center: center, scale: scale)
                        let rect = CGRect(x: mapped.x - 4, y: mapped.y - 4, width: 8, height: 8)
                        context.fill(Path(ellipseIn: rect), with: .color(DiveUI.green))
                    }

                    if let bearing = presentation.entryDirectionDegrees {
                        let radians = (bearing - 90) * .pi / 180
                        let tip = CGPoint(
                            x: center.x + CGFloat(cos(radians)) * scale * 0.55,
                            y: center.y + CGFloat(sin(radians)) * scale * 0.55
                        )
                        var arrow = Path()
                        arrow.move(to: center)
                        arrow.addLine(to: tip)
                        context.stroke(arrow, with: .color(DiveUI.blue.opacity(0.9)), lineWidth: 2)
                    }
                }
                .accessibilityLabel(Text(String(localized: "snorkeling.watch.micro_map")))
            } else {
                VStack(spacing: 4) {
                    Image(systemName: "map")
                        .font(.caption)
                        .foregroundStyle(DiveUI.secondaryText)
                    Text(DIRWatchLocalizer.string(presentation.unavailableReasonKey ?? "snorkeling.watch.micro_map.unavailable"))
                        .font(DiveUI.Typography.hintCaption)
                        .foregroundStyle(DiveUI.secondaryText)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityLabel(Text(String(localized: "snorkeling.watch.micro_map.unavailable")))
            }
        }
        .frame(width: size, height: size)
        .background(DiveUI.panelFillRaised.opacity(0.65))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func map(_ point: SnorkelingWatchMicroMapPoint, center: CGPoint, scale: CGFloat) -> CGPoint {
        CGPoint(x: center.x + CGFloat(point.x) * scale, y: center.y + CGFloat(point.y) * scale)
    }
}
