import CoreLocation
import Foundation
import SwiftUI

@MainActor
final class IOSLocationPermissionService: NSObject, ObservableObject {
    @Published private(set) var authorizationStatus: CLAuthorizationStatus
    @Published private(set) var permissionState: ApneaMapPermissionState

    private let locationManager = CLLocationManager()

    override init() {
        let status = CLLocationManager.authorizationStatus()
        authorizationStatus = status
        permissionState = Self.map(status)
        super.init()
        locationManager.delegate = self
    }

    func refresh() {
        let status = locationManager.authorizationStatus
        authorizationStatus = status
        permissionState = Self.map(status)
    }

    func requestWhenInUseIfNeeded() {
        refresh()
        guard authorizationStatus == .notDetermined else { return }
        locationManager.requestWhenInUseAuthorization()
    }

    func requestWhenInUseFromUserAction() {
        refresh()
        guard authorizationStatus == .notDetermined else { return }
        locationManager.requestWhenInUseAuthorization()
    }

    var isAuthorized: Bool {
        authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }

    var isDeniedOrRestricted: Bool {
        authorizationStatus == .denied || authorizationStatus == .restricted
    }

    nonisolated static func map(_ status: CLAuthorizationStatus) -> ApneaMapPermissionState {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            return .authorized
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        case .notDetermined:
            return .notDetermined
        @unknown default:
            return .notDetermined
        }
    }
}

extension IOSLocationPermissionService: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            authorizationStatus = manager.authorizationStatus
            permissionState = Self.map(manager.authorizationStatus)
        }
    }
}
