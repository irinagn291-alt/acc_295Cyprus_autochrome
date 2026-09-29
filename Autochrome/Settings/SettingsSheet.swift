import SwiftUI

/// Sheet for emotion labels, a confirmed strip reset, and the contact link.
struct SettingsView: View {
    @ObservedObject var session: StripSession
    @Environment(\.dismiss) private var dismiss
    @Environment(\.stripRamp) private var ramp
    @State private var confirmErase = false
    @State private var drafts: [String: String] = [:]

    var body: some View {
        NavigationStack {
            Group {
                if session.projectionFailed && session.fold.emotionLabels.isEmpty {
                    errorBody
                } else if session.fold.emotionLabels.isEmpty {
                    emptyBody
                } else {
                    formBody
                }
            }
            .background(DesignTokens.bg.ignoresSafeArea())
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .frame(width: StripSpace.hit, height: StripSpace.hit)
                            .contentShape(Rectangle())
                    }
                    .accessibilityLabel("Close")
                }
            }
        }
        .confirmationDialog(
            "Erase saved moments?",
            isPresented: $confirmErase,
            titleVisibility: .visible
        ) {
            Button("Erase moments on this device", role: .destructive) {
                Task {
                    await session.eraseStrip()
                    dismiss()
                }
            }
            Button("Keep moments", role: .cancel) {}
        } message: {
            Text("This removes every saved moment on this device, then opens the introduction again.")
        }
    }

    private var formBody: some View {
        Form {
            Section("Emotion labels") {
                ForEach(session.fold.emotionLabels) { label in
                    TextField(
                        label.title,
                        text: Binding(
                            get: { drafts[label.id] ?? label.title },
                            set: { drafts[label.id] = $0 }
                        )
                    )
                    .font(StripType.body(ramp.body))
                    .submitLabel(.done)
                    .onSubmit { commit(label.id) }
                }
                Button("Save labels") {
                    for label in session.fold.emotionLabels {
                        commit(label.id)
                    }
                }
                .frame(minHeight: StripSpace.hit)
            }
            Section("On this device") {
                Button("Show introduction again") {
                    Task { await session.replayOnboarding() }
                }
                .frame(minHeight: StripSpace.hit)
                Button("Erase saved moments", role: .destructive) {
                    confirmErase = true
                }
                .frame(minHeight: StripSpace.hit)
            }
            Section("Contact") {
                if let url = URL(string: "https://autochrome-strip.pro/contact-us") {
                    Link("Contact Autochrome", destination: url)
                        .frame(minHeight: StripSpace.hit)
                }
            }
            if session.projectionFailed {
                Section {
                    Text("The last save did not land.")
                        .font(StripType.caption(ramp.caption))
                        .foregroundStyle(DesignTokens.muted)
                    Button("Try again") {
                        Task { await session.flushNow() }
                    }
                    .frame(minHeight: StripSpace.hit)
                }
            }
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private var emptyBody: some View {
        VStack(alignment: .leading, spacing: StripSpace.loose) {
            Spacer(minLength: StripSpace.field)
            Text("No emotion labels")
                .font(StripType.display(ramp.display))
                .foregroundStyle(DesignTokens.ink)
            Text("Erase saved moments to restore the starter names.")
                .font(StripType.body(ramp.body))
                .foregroundStyle(DesignTokens.muted)
            Spacer(minLength: StripSpace.field)
            Button("Erase saved moments") { confirmErase = true }
                .buttonStyle(SoftCardButtonStyle(kind: .destructive))
        }
        .padding(StripSpace.base)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var errorBody: some View {
        VStack(alignment: .leading, spacing: StripSpace.loose) {
            Spacer(minLength: StripSpace.field)
            Text("Settings could not load")
                .font(StripType.display(ramp.display))
                .foregroundStyle(DesignTokens.ink)
            Text("The saved file did not open.")
                .font(StripType.body(ramp.body))
                .foregroundStyle(DesignTokens.muted)
            Spacer(minLength: StripSpace.field)
            Button("Try again") {
                Task { await session.reload() }
            }
            .buttonStyle(SoftCardButtonStyle())
        }
        .padding(StripSpace.base)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private func commit(_ id: String) {
        guard let draft = drafts[id] else { return }
        session.rename(id: id, title: draft)
    }
}
