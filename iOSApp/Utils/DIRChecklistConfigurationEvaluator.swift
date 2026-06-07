import Foundation

/// Evaluates whether an equipment checklist satisfies DIR configuration requirements for the hero badge.
enum DIRChecklistConfigurationEvaluator {
    static func isComplete(_ profile: EquipmentProfile) -> Bool {
        let items = profile.migratedChecklistItems
        return hasBiboConfigured(profile: profile, items: items)
            && hasReadyItem(in: items, matchingAny: Self.backupMaskKeywords)
            && hasReadyItem(in: items, matchingAny: Self.smbKeywords)
            && hasReadyItem(in: items, matchingAny: Self.spoolKeywords)
            && hasReadyGasConfigured(in: items)
            && hasReadyItem(in: items, matchingAny: Self.wetNoteKeywords)
            && hasSignalingBuoyWithSpool(in: items)
    }

    private static let biboKeywords = ["bibo", "twinset", "twin set", "doubles", "double tank", "backmount", "back mount"]
    private static let backupMaskKeywords = ["backup mask", "maschera backup", "maschera di backup"]
    private static let smbKeywords = ["smb", "dsmb"]
    private static let spoolKeywords = ["spool"]
    private static let wetNoteKeywords = ["wet note", "wet notes", "wetnote", "wetnotes", "lavagnetta"]
    private static let signalingBuoyKeywords = ["pallone", "sacco", "segnalamento", "dsmb", "smb"]

    private static func hasBiboConfigured(profile: EquipmentProfile, items: [EquipmentChecklistItem]) -> Bool {
        if hasReadyItem(in: items, matchingAny: biboKeywords) {
            return true
        }
        let configuration = normalized(profile.configuration)
        guard biboKeywords.contains(where: { configuration.contains($0) }) else {
            return false
        }
        return hasReadyGasConfigured(in: items)
    }

    private static func hasReadyGasConfigured(in items: [EquipmentChecklistItem]) -> Bool {
        items.contains { $0.isReady && $0.usesGas }
    }

    private static func hasSignalingBuoyWithSpool(in items: [EquipmentChecklistItem]) -> Bool {
        let readyItems = items.filter(\.isReady)
        let hasReadySpoolItem = readyItems.contains { normalized($0.title).contains("spool") }

        return readyItems.contains { item in
            let title = normalized(item.title)
            let isSignalingBuoy = signalingBuoyKeywords.contains { title.contains($0) }
            guard isSignalingBuoy else { return false }
            return title.contains("spool") || hasReadySpoolItem
        }
    }

    private static func hasReadyItem(in items: [EquipmentChecklistItem], matchingAny keywords: [String]) -> Bool {
        items.contains { item in
            guard item.isReady else { return false }
            let title = normalized(item.title)
            return keywords.contains { title.contains($0) }
        }
    }

    private static func normalized(_ text: String) -> String {
        text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .lowercased()
    }
}
