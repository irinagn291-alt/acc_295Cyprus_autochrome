import SwiftUI

/// Root after launch. Onboarding first, then the filmstrip. Review keys open once.
struct ContentView: View {
    @ObservedObject var session: StripSession
    @State private var ready = false
    @State private var appliedReview = false
    @State private var garden = false
    @State private var settings = false

    var body: some View {
        Group {
            if !ready {
                DesignTokens.bg.ignoresSafeArea()
            } else if !session.fold.onboardingComplete {
                OnboardingView(session: session)
            } else {
                MomentsView(session: session)
                    .sheet(isPresented: $garden) {
                        GardenView(session: session)
                    }
                    .sheet(isPresented: $settings) {
                        SettingsView(session: session)
                    }
            }
        }
        .modifier(StripRampInstaller())
        .task {
            guard !ready else { return }
            await session.boot()
            ready = true
            openReviewIfNeeded()
        }
        .onChange(of: session.fold.onboardingComplete) { _, complete in
            if complete {
                openReviewIfNeeded()
            }
        }
    }

    private func openReviewIfNeeded() {
        guard session.fold.onboardingComplete, !appliedReview else { return }
        appliedReview = true
        switch ReviewLaunch.screen {
        case "log", "garden":
            garden = true
            settings = false
        case "goals", "settings":
            settings = true
            garden = false
        case "today", "moments":
            garden = false
            settings = false
        default:
            break
        }
    }
}

#Preview {
    ContentView(session: .live())
}
