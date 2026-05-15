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
        ScrollView {
            VStack(spacing: 8) {
                VStack(spacing: 6) {
                    DiveScreenHeader("SCHERMI", subtitle: "REFERENCE VISUALS", accent: DiveUI.blue, systemImage: "photo")
                    HStack {
                        Text("IMMAGINI")
                            .font(.system(size: 10, weight: .black, design: .rounded))
                            .foregroundStyle(DiveUI.secondaryText)
                        Spacer()
                        DiveStatusPill("\(imageStore.imageNames.count)", color: DiveUI.green)
                    }
                }

                if imageStore.imageNames.isEmpty {
                    DivePanel(stroke: DiveUI.yellow) {
                        Text("NESSUNA IMMAGINE")
                            .font(.headline.bold())
                            .foregroundStyle(DiveUI.yellow)
                    }
                } else {
                    ForEach(imageStore.imageNames, id: \.self) { name in
                        DiveCommandButton(name, systemImage: "photo", color: DiveUI.blue) {
                            selectedName = name
                        }
                    }
                }
            }
            .padding(.horizontal, DiveUI.screenPadding)
            .padding(.vertical, 8)
        }
    }

    private func imageDetail(name: String, resourceName: String) -> some View {
        ZStack(alignment: .top) {
            Image(resourceName, bundle: .main)
                .resizable()
                .scaledToFit()
                .ignoresSafeArea()

            HStack {
                Text(name)
                    .font(.caption2.bold())
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(.black.opacity(0.72)))
                Spacer()
                Button {
                    selectedName = nil
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                        .padding(6)
                        .background(Circle().fill(.black.opacity(0.72)))
                }
                .buttonStyle(.plain)
            }
            .padding(6)
        }
    }
}

