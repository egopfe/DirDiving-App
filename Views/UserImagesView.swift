import SwiftUI

struct UserImagesView: View {
    @EnvironmentObject private var imageStore: UserImageStore
    @State private var selectedName: String?

    var body: some View {
        ZStack {
            DiveScreenBackground()

            if let selectedName, let resourceName = imageStore.imageResourceName(for: selectedName) {
                imageDetail(name: selectedName, resourceName: resourceName)
            } else {
                imageList
            }
        }
        .onAppear { imageStore.reload() }
    }

    private var imageList: some View {
        VStack(spacing: 5) {
            header

            Text("SCHERMI")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)

            VStack(spacing: 4) {
                if imageStore.imageNames.isEmpty {
                    ForEach(placeholderRows) { row in
                        placeholderImageRow(row)
                    }
                } else {
                    ForEach(Array(imageStore.imageNames.enumerated()), id: \.element) { index, name in
                        imageRow(name: name, index: index)
                            .onTapGesture {
                                selectedName = name
                            }
                    }
                }
            }
        }
        .padding(.horizontal, 11)
        .padding(.top, 9)
        .padding(.bottom, 8)
    }

    private var header: some View {
        HStack(alignment: .center) {
            HStack(spacing: 5) {
                DiveOctopusLogo(accent: DiveUI.yellow)
                    .frame(width: 23, height: 22, alignment: .leading)
                    .scaleEffect(0.68)
                Text("DIR DIVING")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundStyle(DiveUI.yellow)
                    .lineLimit(1)
            }

            Spacer()

            // TODO: Replace this visual placeholder if a watch clock value becomes part of the view model.
            Text("--:--")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .monospacedDigit()
        }
    }

    private func imageRow(name: String, index: Int) -> some View {
        let resourceName = imageStore.imageResourceName(for: name)
        let isSelected = selectedName == name || (selectedName == nil && index == 0)
        return HStack(spacing: 8) {
            thumbnail(resourceName: resourceName, index: index)
                .frame(width: 45, height: 26)

            VStack(alignment: .leading, spacing: 1) {
                Text("IMG \(index + 1)")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(imageCaption(for: name))
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .frame(minHeight: 35)
        .background(
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(Color.black.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .stroke(isSelected ? DiveUI.yellow : .white.opacity(0.2), lineWidth: isSelected ? 1.4 : 1)
                )
        )
        .contentShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
    }

    private func placeholderImageRow(_ row: PlaceholderImageRow) -> some View {
        // TODO: Replace placeholder rows with bundled UserImages assets when available.
        HStack(spacing: 8) {
            placeholderThumbnail(index: row.index)
                .frame(width: 45, height: 26)

            VStack(alignment: .leading, spacing: 1) {
                Text("IMG \(row.index + 1)")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                Text(row.caption)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .frame(minHeight: 35)
        .background(
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(Color.black.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .stroke(row.index == 0 ? DiveUI.yellow : .white.opacity(0.2), lineWidth: row.index == 0 ? 1.4 : 1)
                )
        )
    }

    private func thumbnail(resourceName: String?, index: Int) -> some View {
        ZStack {
            if let resourceName {
                Image(resourceName, bundle: .main)
                    .resizable()
                    .scaledToFill()
            } else {
                placeholderThumbnail(index: index)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .stroke(.white.opacity(0.25), lineWidth: 0.7)
        )
    }

    private func placeholderThumbnail(index: Int) -> some View {
        ZStack {
            LinearGradient(
                colors: placeholderColors(for: index),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Image(systemName: index == 3 ? "map" : "water.waves")
                .font(.system(size: 14, weight: .black))
                .foregroundStyle(.white.opacity(0.62))
        }
    }

    private func imageDetail(name: String, resourceName: String) -> some View {
        let index = imageIndex(for: name)
        return VStack(spacing: 8) {
            HStack {
                Spacer()
                // TODO: Replace this visual placeholder if a watch clock value becomes part of the view model.
                Text("--:--")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .monospacedDigit()
            }
            .padding(.horizontal, 12)
            .padding(.top, 9)

            Text("IMG \(index + 1)")
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)

            Image(resourceName, bundle: .main)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: 126)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(.white.opacity(0.18), lineWidth: 1)
                )
                .padding(.horizontal, 13)

            Text(imageCaption(for: name))
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            pageDots(currentIndex: index)

            Spacer(minLength: 0)

            Button {
                selectedName = nil
            } label: {
                Text("SCHERMI")
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .foregroundStyle(DiveUI.yellow)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .stroke(DiveUI.yellow.opacity(0.85), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
            .padding(.bottom, 6)
        }
    }

    private func pageDots(currentIndex: Int) -> some View {
        let count = max(imageStore.imageNames.count, 4)
        return HStack(spacing: 5) {
            ForEach(0..<count, id: \.self) { index in
                Circle()
                    .fill(index == currentIndex ? .white : .white.opacity(0.35))
                    .frame(width: 5, height: 5)
            }
        }
    }

    private func imageIndex(for name: String) -> Int {
        imageStore.imageNames.firstIndex(of: name) ?? 0
    }

    private func imageCaption(for name: String) -> String {
        let stem = name
            .split(separator: ".")
            .dropLast()
            .joined(separator: ".")
        guard !stem.isEmpty else { return name }
        return stem
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")
            .capitalized
    }

    private func placeholderColors(for index: Int) -> [Color] {
        switch index {
        case 1:
            return [DiveUI.blue.opacity(0.75), DiveUI.orange.opacity(0.85), .black]
        case 2:
            return [DiveUI.cyan.opacity(0.55), DiveUI.green.opacity(0.55), .black]
        case 3:
            return [DiveUI.blue.opacity(0.85), DiveUI.cyan.opacity(0.65), .black]
        default:
            return [DiveUI.blue.opacity(0.65), .black, DiveUI.green.opacity(0.38)]
        }
    }

    private var placeholderRows: [PlaceholderImageRow] {
        [
            PlaceholderImageRow(index: 0, caption: "Relitto"),
            PlaceholderImageRow(index: 1, caption: "Paramuricea clavata"),
            PlaceholderImageRow(index: 2, caption: "Grotta"),
            PlaceholderImageRow(index: 3, caption: "Mappa sito")
        ]
    }
}

private struct PlaceholderImageRow: Identifiable {
    let index: Int
    let caption: String

    var id: Int { index }
}