import Foundation

/// Resolves embedded entitlement tier from build metadata. Runtime `SecTask` entitlement introspection
/// is not reliable on watchOS; provisioning must set `DIRDepthEntitlementTier` and/or compile flags.
enum DepthCapabilityEntitlementProbe {
    static let shallowEntitlementKey = "com.apple.developer.submerged-shallow-depth-and-pressure"
    static let fullEntitlementKey = "com.apple.developer.submerged-depth-and-pressure"
    static let legacyFullEntitlementKey = "com.apple.developer.coremotion.water-submersion"
    static let infoPlistTierKey = "DIRDepthEntitlementTier"

    static var testHook_hasShallowEntitlement: Bool?
    static var testHook_hasFullEntitlement: Bool?

    static var hasShallowEntitlement: Bool {
        if let testHook_hasShallowEntitlement { return testHook_hasShallowEntitlement }
        switch configuredTier {
        case .shallow, .full:
            return true
        case .none:
            return false
        }
    }

    static var hasFullEntitlement: Bool {
        if let testHook_hasFullEntitlement { return testHook_hasFullEntitlement }
        switch configuredTier {
        case .full:
            return true
        case .shallow, .none:
            return false
        }
    }

    private enum ConfiguredTier: String {
        case none
        case shallow
        case full
    }

    private static var configuredTier: ConfiguredTier {
        #if DEPTH_ENTITLEMENT_FULL
        return .full
        #elseif DEPTH_ENTITLEMENT_SHALLOW
        return .shallow
        #else
        if let raw = Bundle.main.object(forInfoDictionaryKey: infoPlistTierKey) as? String,
           let tier = ConfiguredTier(rawValue: raw.lowercased()) {
            return tier
        }
        return .none
        #endif
    }
}
