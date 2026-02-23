import SwiftUI

struct HeaderView: View {

    private let expediaURL = URL(string: "https://expedia.com/affiliates/expedia-home.6MzBG4e")!

    var body: some View {
        HStack(spacing: 12) {
            // App identity
            HStack(spacing: 8) {
                Text("🌴")
                    .font(.system(size: 28))
                VStack(alignment: .leading, spacing: 1) {
                    Text("JamaicaDeals")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text("Latest travel deals")
                        .font(.caption2)
                        .foregroundColor(Color.white.opacity(0.7))
                }
            }

            Spacer()

            // Expedia booking link
            Link(destination: expediaURL) {
                HStack(spacing: 6) {
                    Image(systemName: "airplane.departure")
                        .font(.subheadline)
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Book Now")
                            .font(.system(size: 12, weight: .bold))
                    }
                }
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(
                    LinearGradient(
                        colors: [Color(red: 0.0, green: 0.55, blue: 0.27),
                                 Color(red: 0.0, green: 0.40, blue: 0.20)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.yellow.opacity(0.6), lineWidth: 1)
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.black)
    }
}

#Preview {
    HeaderView()
}
