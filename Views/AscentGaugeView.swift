import SwiftUI

struct AscentGaugeView: View {
    let status: AscentStatus

    var body: some View {
        VStack(spacing: 2) {
            Text("ASC").font(.caption2).foregroundStyle(.secondary)
            Text(Formatters.one(status.currentRateMetersPerMinute))
                .font(.headline.monospacedDigit()).foregroundStyle(status.zone.color)
            GeometryReader { geometry in
                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 8).fill(.gray.opacity(0.20))
                    VStack(spacing: 0) {
                        Rectangle().fill(.red).frame(height: geometry.size.height * 0.33)
                        Rectangle().fill(.yellow).frame(height: geometry.size.height * 0.30)
                        Rectangle().fill(.green).frame(height: geometry.size.height * 0.37)
                    }.clipShape(RoundedRectangle(cornerRadius: 8))
                    let ratio = min(max(status.currentRateMetersPerMinute / max(status.limitMetersPerMinute, 0.1), 0), 1)
                    Rectangle().fill(.white).frame(height: 3).offset(y: -geometry.size.height * ratio)
                }
            }
            Text("MAX \(Formatters.one(status.limitMetersPerMinute))").font(.caption2).foregroundStyle(.secondary)
        }
    }
}
