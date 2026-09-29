import SwiftUI

/// Three full pages. Continue or Skip writes starter labels and the completion flag.
struct OnboardingView: View {
    @ObservedObject var session: StripSession
    @Environment(\.stripRamp) private var ramp
    @State private var page = 0

    private let pages: [(image: String, title: String, line: String)] = [
        ("aut_Onboarding1", "Good days, kept close", "Save today's warm moment with a feeling, a photo, or a short voice clip."),
        ("aut_Onboarding2", "Days you can look back on", "Keeping a day puts it with the others."),
        ("aut_Onboarding3", "Open a matching day", "Only days that share today's feeling stand out. Tap one to open it.")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: StripSpace.loose) {
            pageView(pages[page])
                .padding(.horizontal, StripSpace.tight)
            HStack(spacing: StripSpace.tight) {
                ForEach(pages.indices, id: \.self) { index in
                    RoundedRectangle(cornerRadius: StripRadius.chip, style: .continuous)
                        .fill(index == page ? DesignTokens.accent : DesignTokens.muted.opacity(0.35))
                        .frame(width: index == page ? 24 : 8, height: 8)
                        .accessibilityHidden(true)
                }
            }
            Button {
                if page < pages.count - 1 {
                    page += 1
                } else {
                    Task { await session.finishOnboarding() }
                }
            } label: {
                Text(page == pages.count - 1 ? "Continue" : "Next")
                    .frame(maxWidth: .infinity, minHeight: StripSpace.hit)
                    .contentShape(Rectangle())
            }
            .buttonStyle(SoftCardButtonStyle())
            Button {
                Task { await session.finishOnboarding() }
            } label: {
                Text("Skip")
                    .frame(maxWidth: .infinity, minHeight: StripSpace.hit)
                    .contentShape(Rectangle())
            }
            .buttonStyle(SoftCardButtonStyle(kind: .quiet))
        }
        .padding(StripSpace.base)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(DesignTokens.bg.ignoresSafeArea())
    }

    private func pageView(_ page: (image: String, title: String, line: String)) -> some View {
        VStack(alignment: .leading, spacing: StripSpace.loose) {
            Image(page.image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: 360)
                .accessibilityHidden(true)
            Text(page.title)
                .font(StripType.display(ramp.display))
                .foregroundStyle(DesignTokens.ink)
                .lineLimit(4)
                .minimumScaleFactor(0.55)
            Text(page.line)
                .font(StripType.body(ramp.body))
                .foregroundStyle(DesignTokens.muted)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
