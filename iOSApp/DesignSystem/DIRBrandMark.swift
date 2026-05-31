import SwiftUI
import UIKit

struct DIRBrandMark: View {
    var body: some View {
        Group {
            if let url = Bundle.main.url(forResource: "altosinistra", withExtension: "png"),
               let uiImage = UIImage(contentsOfFile: url.path) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "water.waves")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(DIRTheme.cyan)
            }
        }
    }
}
