import SwiftUI

struct DealCardView: View {

    let deal: TravelDeal

    var body: some View {
        Link(destination: deal.link) {
            VStack(alignment: .leading, spacing: 10) {

                // Source + date row
                HStack(spacing: 6) {
                    Image(systemName: "tag.fill")
                        .font(.caption)
                        .foregroundColor(.yellow)
                    Text(deal.source)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 0.0, green: 0.55, blue: 0.27))
                    Spacer()
                    if !deal.formattedDate.isEmpty {
                        Text(deal.formattedDate)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }

                // Title
                Text(deal.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                // Description
                Text(deal.plainDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)

                // CTA row
                HStack {
                    Label("Jamaica", systemImage: "mappin.circle.fill")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("View Deal →")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }
            .padding(14)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
