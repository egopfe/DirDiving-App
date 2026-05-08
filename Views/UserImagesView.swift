import SwiftUI

struct UserImagesView: View {
    @EnvironmentObject private var imageStore: UserImageStore
    @State private var selectedName: String?

    var body: some View {
        if let selectedName, let resourceName = imageStore.imageResourceName(for: selectedName) {
            ZStack(alignment: .top) {
                Image(resourceName, bundle: .main).resizable().scaledToFit().ignoresSafeArea()
                HStack {
                    Text(selectedName).font(.caption2).padding(4).background(.black.opacity(0.6)).clipShape(Capsule())
                    Spacer()
                    Button("X") { self.selectedName = nil }.font(.caption2)
                }.padding(6)
            }
        } else {
            List(imageStore.imageNames, id: \.self) { name in
                Button(name) { selectedName = name }
            }
            .navigationTitle("Schermi")
            .onAppear { imageStore.reload() }
        }
    }
}
