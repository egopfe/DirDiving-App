import SwiftUI

struct DIRBrandMark: View {
    var body: some View {
        Group {
            if Bundle.main.url(forResource: "altosinistra", withExtension: "png") != nil {
                Image("altosinistra")
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
