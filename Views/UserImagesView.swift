import SwiftUI
import UIKit

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
        .onChange(of: imageStore.imageNames) { _, names in
            if let selectedName, !names.contains(selectedName) {
                self.selectedName = nil
            }
        }
    }

    private var imageList: some View {
        VStack(spacing: 5) {
            header

            Text(String(localized: "user_images.list.title"))
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)

            VStack(spacing: 4) {
                if imageStore.imageNames.isEmpty {
                    imageEmptyState
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

            DiveClockText(size: 14)
        }
    }

    private func imageRow(name: String, index: Int) -> some View {
        let resourceName = imageStore.imageResourceName(for: name)
        let isSelected = selectedName == name || (selectedName == nil && index == 0)
        return HStack(spacing: 8) {
            thumbnail(resourceName: resourceName, index: index)
                .frame(width: 45, height: 26)

            VStack(alignment: .leading, spacing: 1) {
                Text(String(format: String(localized: "user_images.item.label"), index + 1))
                    .font(DiveUI.Typography.rowTitle)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(shortImageCaption(for: name))
                    .font(DiveUI.Typography.rowSubtitle)
                    .foregroundStyle(.white)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .frame(minHeight: 44)
        .background(
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(Color.black.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .stroke(isSelected ? DiveUI.yellow : .white.opacity(0.2), lineWidth: isSelected ? 1.4 : 1)
                )
        )
        .contentShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(String(format: String(localized: "user_images.a11y.row"), index + 1, imageCaption(for: name)))
        .accessibilityHint(String(localized: "user_images.a11y.row.hint"))
    }

    private var imageEmptyState: some View {
        VStack(spacing: 7) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 24, weight: .black))
                .foregroundStyle(DiveUI.cyan)
            Text(String(localized: "user_images.empty.title"))
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundStyle(.white)
            Text(String(localized: "user_images.empty.body"))
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(DiveUI.secondaryText)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(10)
        .frame(maxWidth: .infinity, minHeight: 92)
        .background(
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(Color.black.opacity(0.52))
                .overlay(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .stroke(DiveUI.cyan.opacity(0.40), lineWidth: 1)
                )
        )
    }

    private func thumbnail(resourceName: String?, index: Int) -> some View {
        ZStack {
            if let resourceName {
                storedImage(resourceName: resourceName)
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
        .accessibilityHidden(true)
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
                WatchDetailBackButton {
                    selectedName = nil
                }
                Spacer()
                DiveClockText(size: 14)
            }
            .padding(.horizontal, 12)
            .padding(.top, 9)

            Text(String(format: String(localized: "user_images.item.label"), index + 1))
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)

            storedImage(resourceName: resourceName)
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: 168)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(.white.opacity(0.18), lineWidth: 1)
                )
                .padding(.horizontal, 13)
                .accessibilityLabel(String(format: String(localized: "user_images.a11y.detail"), index + 1, imageCaption(for: name)))

            Text(shortImageCaption(for: name))
                .font(DiveUI.Typography.rowSubtitle)
                .foregroundStyle(.white)
                .lineLimit(2)
                .multilineTextAlignment(.center)

            pageDots(currentIndex: index)

            Spacer(minLength: 0)

            Button {
                selectedName = nil
            } label: {
                Text(String(localized: "user_images.list.title"))
                    .font(DiveUI.Typography.secondaryLabel)
                    .foregroundStyle(DiveUI.yellow)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .frame(minHeight: 40)
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

    private func shortImageCaption(for name: String) -> String {
        let caption = imageCaption(for: name)
        guard caption.count > 22 else { return caption }
        return String(caption.prefix(20)) + "…"
    }

    private func storedImage(resourceName: String) -> some View {
        Group {
            if let uiImage = WatchCompanionPhotoValidator.imageForDisplay(resourceName: resourceName) {
                Image(uiImage: uiImage)
                    .resizable()
            } else {
                Image(systemName: "photo")
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(.white.opacity(0.35))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.35))
            }
        }
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

}