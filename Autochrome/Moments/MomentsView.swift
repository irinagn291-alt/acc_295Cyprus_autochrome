import PhotosUI
import SwiftUI
import UIKit

/// Home mechanic. The filmstrip stays. Seat, Develop, and Flare live here.
struct MomentsView: View {
    @ObservedObject var session: StripSession
    @Environment(\.stripRamp) private var ramp
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var garden = false
    @State private var settings = false
    @State private var emotionID = EmotionLabel.starter[0].id
    @State private var photoItem: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var booth = VoiceBooth()
    @State private var composer = false
    @State private var appeared = false

    private var daykey: Int { DayKey.make(from: Date()) }
    private var phase: StripPhase { session.fold.phase(on: daykey) }
    private var litIDs: Set<UUID> { Set(session.fold.litPanes(on: daykey).map(\.id)) }

    var body: some View {
        ZStack(alignment: .top) {
            DesignTokens.bg.ignoresSafeArea()
            if session.recovery == .startedBlank && session.fold.frames.isEmpty {
                errorPage
            } else if phase == .blank {
                blankPage
            } else {
                populated
            }
            if session.showSuccess {
                Image("aut_SuccessMark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 72, height: 72)
                    .accessibilityHidden(true)
                    .padding(.top, StripSpace.page)
            }
        }
        .sheet(isPresented: $garden) {
            GardenView(session: session)
        }
        .sheet(isPresented: $settings) {
            SettingsView(session: session)
        }
        .onAppear {
            if reduceMotion {
                appeared = true
            } else {
                withAnimation(.easeOut(duration: 0.36)) { appeared = true }
            }
        }
        .onChange(of: photoItem) { _, item in
            guard let item else { return }
            Task {
                photoData = try? await item.loadTransferable(type: Data.self)
            }
        }
    }

    private var populated: some View {
        VStack(alignment: .leading, spacing: StripSpace.base) {
            header
            ZStack {
                SceneMosaic(
                    panes: session.fold.panes,
                    litIDs: litIDs,
                    titles: Dictionary(uniqueKeysWithValues: session.fold.emotionLabels.map { ($0.id, $0.title) })
                ) { id in
                    session.flare(paneID: id)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .frame(minHeight: 320)
                .accessibilityElement(children: .contain)
                if let name = hueTitle, flareReady {
                    Text(name)
                        .font(StripType.display(ramp.display))
                        .foregroundStyle(DesignTokens.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }
            }
            VStack(alignment: .leading, spacing: StripSpace.base) {
                if let line = session.stagedLine {
                    Text(line)
                        .font(StripType.body(ramp.body))
                        .foregroundStyle(DesignTokens.ink)
                }
                if let notice = session.notice {
                    Text(notice)
                        .font(StripType.body(ramp.body))
                        .foregroundStyle(DesignTokens.ink)
                }
                if composer {
                    composerCard
                }
                if flareReady, let match = session.fold.litPanes(on: daykey).first {
                    let matchTitle = label(for: match.emotionID)
                    Button {
                        session.flare(paneID: match.id)
                    } label: {
                        Text("Open \(matchTitle)")
                            .frame(maxWidth: .infinity, minHeight: StripSpace.hit)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(SoftCardButtonStyle(kind: .primary, enabled: !session.busy))
                    .disabled(session.busy)
                    .accessibilityHint("Opens the saved day that matches today")
                }
                controls
            }
            .padding(.horizontal, StripSpace.base)
        }
        .padding(.bottom, StripSpace.base)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .opacity(appeared ? 1 : 0)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: StripSpace.base) {
            VStack(alignment: .leading, spacing: StripSpace.tight) {
                Text(verbWord)
                    .font(StripType.display(ramp.display))
                    .foregroundStyle(DesignTokens.ink)
                    .lineLimit(2)
                    .minimumScaleFactor(0.6)
                Text(jobLine)
                    .font(StripType.body(ramp.body))
                    .foregroundStyle(DesignTokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
            HStack(spacing: StripSpace.tight) {
                sheetButton("Garden") { garden = true }
                sheetButton("Settings") { settings = true }
            }
        }
        .padding(.top, StripSpace.tight)
        .padding(.horizontal, StripSpace.base)
    }

    private var verbWord: String {
        if flareReady {
            return "Open"
        }
        switch phase {
        case .blank, .bare:
            return "Save"
        case .seated:
            return "Keep"
        case .cut:
            return "Open"
        }
    }

    private var flareReady: Bool {
        (phase == .seated || phase == .cut) && !litIDs.isEmpty
    }

    private var jobLine: String {
        switch phase {
        case .blank:
            "Save a warm moment."
        case .bare:
            "Save today, then keep it with your other days."
        case .seated:
            "Keep this day so a matching one can stand out."
        case .cut:
            hueTitle.map { "Today is \($0). Tap that day to open it." }
                ?? "Tap the day that matches today."
        }
    }

    private var hueTitle: String? {
        session.fold.todayEmotionID(on: daykey).map { label(for: $0) }
    }

    @ViewBuilder
    private var controls: some View {
        if phase == .seated && !flareReady {
            Button {
                Task { await session.develop() }
            } label: {
                Label("Keep this day", systemImage: "square.on.square")
                    .frame(maxWidth: .infinity, minHeight: StripSpace.hit)
                    .contentShape(Rectangle())
            }
            .buttonStyle(SoftCardButtonStyle(enabled: !session.busy))
            .disabled(session.busy)
        } else if canSeat {
            Button {
                composer.toggle()
            } label: {
                Label("Save today", systemImage: "plus")
                    .frame(maxWidth: .infinity, minHeight: StripSpace.hit)
                    .contentShape(Rectangle())
            }
            .buttonStyle(SoftCardButtonStyle(enabled: !session.busy))
            .disabled(session.busy)
        }
    }

    private var canSeat: Bool {
        phase == .blank || phase == .bare
    }

    private var composerCard: some View {
        StripCard {
            VStack(alignment: .leading, spacing: StripSpace.base) {
                Text("Save a moment")
                    .font(StripType.title(ramp.title))
                    .foregroundStyle(DesignTokens.ink)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: StripSpace.tight) {
                        ForEach(session.fold.emotionLabels) { label in
                            Button {
                                emotionID = label.id
                            } label: {
                                Text(label.title)
                                    .font(StripType.caption(ramp.caption))
                                    .foregroundStyle(emotionID == label.id ? DesignTokens.surface : DesignTokens.ink)
                                    .padding(.horizontal, StripSpace.base)
                                    .frame(minHeight: StripSpace.hit)
                                    .background(
                                        emotionID == label.id ? DesignTokens.accent : DesignTokens.surface,
                                        in: RoundedRectangle(cornerRadius: StripRadius.chip, style: .continuous)
                                    )
                                    .contentShape(RoundedRectangle(cornerRadius: StripRadius.chip, style: .continuous))
                            }
                            .buttonStyle(.plain)
                            .accessibilityAddTraits(emotionID == label.id ? .isSelected : [])
                        }
                    }
                }
                let photoAttached = photoData != nil
                PhotosPicker(selection: $photoItem, matching: .images) {
                    Label(photoAttached ? "Photo attached" : "Attach photo", systemImage: "photo")
                        .frame(maxWidth: .infinity, minHeight: StripSpace.hit)
                        .contentShape(Rectangle())
                }
                .buttonStyle(SoftCardButtonStyle(kind: .quiet))
                voiceBlock
                Button {
                    Task {
                        await session.seat(emotionID: emotionID, photo: photoData, voice: booth.clip)
                        photoData = nil
                        photoItem = nil
                        booth.clear()
                        composer = false
                    }
                } label: {
                    Text(session.busy ? "Saving" : "Save this moment")
                        .frame(maxWidth: .infinity, minHeight: StripSpace.hit)
                        .contentShape(Rectangle())
                }
                .buttonStyle(SoftCardButtonStyle(enabled: !session.busy))
                .disabled(session.busy)
            }
        }
    }

    private var voiceBlock: some View {
        VStack(alignment: .leading, spacing: StripSpace.tight) {
            if booth.needsContinue {
                Text("A short voice clip stays on this device.")
                    .font(StripType.caption(ramp.caption))
                    .foregroundStyle(DesignTokens.muted)
                Button {
                    booth.continueToSystemPrompt()
                } label: {
                    Text("Continue")
                        .frame(maxWidth: .infinity, minHeight: StripSpace.hit)
                        .contentShape(Rectangle())
                }
                .buttonStyle(SoftCardButtonStyle(kind: .quiet))
            } else if booth.recording {
                Button {
                    booth.stop()
                } label: {
                    Text("Stop voice")
                        .frame(maxWidth: .infinity, minHeight: StripSpace.hit)
                        .contentShape(Rectangle())
                }
                .buttonStyle(SoftCardButtonStyle(kind: .quiet))
            } else {
                Button {
                    booth.askToRecord()
                } label: {
                    Label(booth.clip == nil ? "Add voice" : "Voice attached", systemImage: "waveform")
                        .frame(maxWidth: .infinity, minHeight: StripSpace.hit)
                        .contentShape(Rectangle())
                }
                .buttonStyle(SoftCardButtonStyle(kind: .quiet))
            }
            if booth.denied {
                Text("Voice stays off. Open Settings if you want a clip later.")
                    .font(StripType.caption(ramp.caption))
                    .foregroundStyle(DesignTokens.muted)
                Button("Open Settings") {
                    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                    UIApplication.shared.open(url)
                }
                .frame(minHeight: StripSpace.hit)
            }
        }
    }

    private var blankPage: some View {
        VStack(alignment: .leading, spacing: StripSpace.loose) {
            Spacer(minLength: StripSpace.field)
            Image("aut_EmptyHome")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 280, maxHeight: 280)
                .frame(maxWidth: .infinity)
                .accessibilityHidden(true)
            Text("Nothing saved yet")
                .font(StripType.display(ramp.display))
                .foregroundStyle(DesignTokens.ink)
                .lineLimit(3)
                .minimumScaleFactor(0.6)
            Text("Save a warm moment")
                .font(StripType.body(ramp.body))
                .foregroundStyle(DesignTokens.muted)
            if composer {
                composerCard
            }
            Spacer(minLength: StripSpace.field)
            Button {
                composer = true
            } label: {
                Text("Save this moment")
                    .frame(maxWidth: .infinity, minHeight: StripSpace.hit)
                    .contentShape(Rectangle())
            }
            .buttonStyle(SoftCardButtonStyle())
            .disabled(session.busy)
        }
        .padding(StripSpace.base)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var errorPage: some View {
        VStack(alignment: .leading, spacing: StripSpace.loose) {
            Spacer(minLength: StripSpace.field)
            Text("Saved moments could not be read")
                .font(StripType.display(ramp.display))
                .foregroundStyle(DesignTokens.ink)
                .lineLimit(4)
                .minimumScaleFactor(0.6)
            Text("They did not open, so this screen started empty.")
                .font(StripType.body(ramp.body))
                .foregroundStyle(DesignTokens.muted)
            Spacer(minLength: StripSpace.field)
            Button {
                Task { await session.reload() }
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

    private func sheetButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .frame(maxWidth: .infinity, minHeight: StripSpace.hit)
                .contentShape(Rectangle())
        }
        .buttonStyle(SoftCardButtonStyle(kind: .quiet))
        .accessibilityLabel(title)
    }

    private func label(for id: String) -> String {
        session.fold.emotionLabels.first { $0.id == id }?.title ?? id
    }
}
