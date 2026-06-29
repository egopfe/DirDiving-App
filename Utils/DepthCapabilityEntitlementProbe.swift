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
        return runtimeAuthorityTier == .shallow || runtimeAuthorityTier == .full
    }

    static var hasFullEntitlement: Bool {
        if let testHook_hasFullEntitlement { return testHook_hasFullEntitlement }
        return runtimeAuthorityTier == .full
    }

    /// Compile-time signing authority takes precedence over Info.plist metadata (CONS-007).
    static var runtimeAuthorityTier: ConfiguredTier {
        #if DEPTH_ENTITLEMENT_FULL
        return .full
        #elseif DEPTH_ENTITLEMENT_SHALLOW
        return .shallow
        #else
        return .none
        #endif
    }

    enum ConfiguredTier: String {
        case none
        case shallow
        case full
    }

    /// Metadata-only tier from Info.plist when compile-time authority is absent (non-authoritative for safety).
    static var infoPlistMetadataTier: ConfiguredTier {
        if let raw = Bundle.main.object(forInfoDictionaryKey: infoPlistTierKey) as? String,
           let tier = ConfiguredTier(rawValue: raw.lowercased()) {
            return tier
        }
        return .none
    }

    private static var configuredTier: ConfiguredTier {
        if runtimeAuthorityTier != .none {
            return runtimeAuthorityTier
        }
        if let raw = Bundle.main.object(forInfoDictionaryKey: infoPlistTierKey) as? String,
           let tier = ConfiguredTier(rawValue: raw.lowercased()) {
            return tier
        }
        return .none
    }
}
