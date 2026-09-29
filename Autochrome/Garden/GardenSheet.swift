import SwiftUI

/// Sheet over Moments. Walks panes and counts panes and flare marks.
struct GardenView: View {
    @ObservedObject var session: StripSession
    @Environment(\.dismiss) private var dismiss
    @Environment(\.stripRamp) private var ramp
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var shown = false
    @State private var opened: Pane?

    var body: some View {
        NavigationStack {
            Group {
                if session.projectionFailed {
                    errorBody
                } else if session.fold.panes.isEmpty {
                    emptyBody
                } else {
                    listBody
                }
            }
            .background(DesignTokens.bg.ignoresSafeArea())
            .navigationTitle("Garden")
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
            .sheet(item: $opened) { pane in
                momentPage(pane)
            }
        }
        .onAppear {
            if reduceMotion {
                shown = true
            } else {
                withAnimation(.easeOut(duration: 0.36)) { shown = true }
            }
        }
    }

    private var listBody: some View {
        List {
            Section {
                Text("Past moments")
                    .font(StripType.display(ramp.display))
                    .foregroundStyle(DesignTokens.ink)
                    .lineLimit(2)
                    .minimumScaleFactor(0.6)
                Text("Open a saved day to read it.")
                    .font(StripType.body(ramp.body))
                    .foregroundStyle(DesignTokens.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .listRowBackground(DesignTokens.surface)
            Section {
                ForEach(Array(session.fold.panes.sorted { $0.daykey > $1.daykey }.enumerated()), id: \.element.id) { index, pane in
                    Button {
                        opened = pane
                    } label: {
                        let savedOn = DayKey.moment(pane.daykey)
                        VStack(alignment: .leading, spacing: StripSpace.tight) {
                            Text(title(pane.emotionID))
                                .font(StripType.headline(ramp.headline))
                                .foregroundStyle(DesignTokens.ink)
                                .lineLimit(1)
                            Text("Saved \(savedOn)")
                                .font(StripType.body(ramp.body))
                                .foregroundStyle(DesignTokens.ink)
                                .lineLimit(2)
                                .minimumScaleFactor(0.8)
                            Text("Open this moment")
                                .font(StripType.caption(ramp.caption))
                                .foregroundStyle(DesignTokens.accent)
                        }
                        .frame(maxWidth: .infinity, minHeight: StripSpace.hit, alignment: .leading)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint("Opens this saved moment")
                    .opacity(shown ? 1 : 0)
                    .animation(
                        reduceMotion ? nil : .easeOut(duration: 0.36).delay(min(0.05 * Double(index), 0.36)),
                        value: shown
                    )
                }
            }
            .listRowBackground(DesignTokens.surface)
        }
        .scrollContentBackground(.hidden)
    }

    private var emptyBody: some View {
        VStack(alignment: .leading, spacing: StripSpace.loose) {
            Spacer(minLength: StripSpace.field)
            Image("aut_EmptyList")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 240, maxHeight: 240)
                .accessibilityHidden(true)
            Text("Nothing saved yet")
                .font(StripType.display(ramp.display))
                .foregroundStyle(DesignTokens.ink)
                .lineLimit(3)
                .minimumScaleFactor(0.6)
            Text("Keep today's moment and it will show up here.")
                .font(StripType.body(ramp.body))
                .foregroundStyle(DesignTokens.muted)
            Spacer(minLength: StripSpace.field)
            Button {
                dismiss()
            } label: {
                Text("Back to Moments")
                    .frame(maxWidth: .infinity, minHeight: StripSpace.hit)
                    .contentShape(Rectangle())
            }
            .buttonStyle(SoftCardButtonStyle())
        }
        .padding(StripSpace.base)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var errorBody: some View {
        VStack(alignment: .leading, spacing: StripSpace.loose) {
            Spacer(minLength: StripSpace.field)
            Text("Garden could not save")
                .font(StripType.display(ramp.display))
                .foregroundStyle(DesignTokens.ink)
                .lineLimit(3)
                .minimumScaleFactor(0.6)
            Text("The last write did not land on this device.")
                .font(StripType.body(ramp.body))
                .foregroundStyle(DesignTokens.muted)
            Spacer(minLength: StripSpace.field)
            Button {
                Task { await session.flushNow() }
            } label: {
                Text("Try again")
                    .frame(maxWidth: .infinity, minHeight: StripSpace.hit)
                    .contentShape(Rectangle())
            }
            .buttonStyle(SoftCardButtonStyle())
        }
        .padding(StripSpace.base)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private func title(_ id: String) -> String {
        session.fold.emotionLabels.first { $0.id == id }?.title ?? id
    }

    private func momentPage(_ pane: Pane) -> some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: StripSpace.loose) {
                let savedOn = DayKey.moment(pane.daykey)
                Text(title(pane.emotionID))
                    .font(StripType.display(ramp.display))
                    .foregroundStyle(DesignTokens.ink)
                    .lineLimit(2)
                    .minimumScaleFactor(0.6)
                Text("Saved \(savedOn)")
                    .font(StripType.title(ramp.title))
                    .foregroundStyle(DesignTokens.ink)
                Text("This is the moment saved from that day.")
                    .font(StripType.body(ramp.body))
                    .foregroundStyle(DesignTokens.muted)
                if pane.photoRelativePath != nil {
                    Text("A photo is saved with this moment.")
                        .font(StripType.body(ramp.body))
                        .foregroundStyle(DesignTokens.ink)
                }
                if pane.voiceRelativePath != nil {
                    Text("A voice clip is saved with this moment.")
                        .font(StripType.body(ramp.body))
                        .foregroundStyle(DesignTokens.ink)
                }
                Spacer(minLength: StripSpace.field)
                Button {
                    opened = nil
                } label: {
                    Text("Close")
                        .frame(maxWidth: .infinity, minHeight: StripSpace.hit)
                        .contentShape(Rectangle())
                }
                .buttonStyle(SoftCardButtonStyle())
            }
            .padding(StripSpace.base)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .background(DesignTokens.bg.ignoresSafeArea())
            .navigationTitle("Moment")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
