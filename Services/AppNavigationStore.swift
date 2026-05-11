import Foundation
import Combine

@MainActor
final class AppNavigationStore: ObservableObject {
    static private(set) weak var shared: AppNavigationStore?

    @Published var selectedPage: AppPage = .live

    init() {
        Self.shared = self
    }
}
