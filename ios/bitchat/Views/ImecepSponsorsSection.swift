import SwiftUI

/// imeCep — "Sponsorlar" area. Data-driven: add entries to `ImecepSponsors.all`.
/// Sponsors are acknowledgements only (no payments, no tracking, no ads in the mesh).
struct ImecepSponsor: Identifiable {
    let id: String
    let name: String
    let blurb: String?
    let url: URL?
}

enum ImecepSponsors {
    /// Intentionally empty until real sponsors are confirmed.
    static let all: [ImecepSponsor] = []
    static let becomeSponsorURL = URL(string: "mailto:desk@smartia.bg?subject=imeCep%20sponsor")
}

struct ImecepSponsorsSection: View {
    @ThemedPalette private var palette
    var sponsors: [ImecepSponsor] = ImecepSponsors.all

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader("app_info.sponsors.title")
            if sponsors.isEmpty {
                Text("app_info.sponsors.description")
                    .bitchatFont(size: 13)
                    .foregroundColor(palette.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                ForEach(sponsors) { sponsor in
                    VStack(alignment: .leading, spacing: 2) {
                        if let url = sponsor.url {
                            Link(sponsor.name, destination: url)
                                .bitchatFont(size: 14, weight: .semibold)
                                .foregroundColor(palette.accent)
                        } else {
                            Text(sponsor.name)
                                .bitchatFont(size: 14, weight: .semibold)
                                .foregroundColor(palette.primary)
                        }
                        if let blurb = sponsor.blurb {
                            Text(blurb)
                                .bitchatFont(size: 12)
                                .foregroundColor(palette.secondary)
                        }
                    }
                }
            }
            if let url = ImecepSponsors.becomeSponsorURL {
                Link("app_info.sponsors.cta", destination: url)
                    .bitchatFont(size: 13, weight: .semibold)
                    .foregroundColor(palette.accent)
            }
        }
        .accessibilityElement(children: .contain)
    }
}
