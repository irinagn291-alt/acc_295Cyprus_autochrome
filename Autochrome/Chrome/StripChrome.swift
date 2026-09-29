import SwiftUI

/// Spacing, radii, and type for the filmstrip. One unit, two radii, six steps.
enum StripSpace {
    static let unit: CGFloat = 8
    static let tight: CGFloat = 8
    static let base: CGFloat = 16
    static let loose: CGFloat = 24
    static let field: CGFloat = 32
    static let page: CGFloat = 48
    static let hit: CGFloat = 48
}

enum StripRadius {
    static let surface: CGFloat = 18
    static let chip: CGFloat = 8
}

enum StripType {
    static func display(_ size: CGFloat) -> Font {
        .custom(DesignTokens.fontFamily, size: size, relativeTo: .largeTitle).weight(.heavy)
    }

    static func title(_ size: CGFloat) -> Font {
        .custom(DesignTokens.fontFamily, size: size, relativeTo: .title).weight(.semibold)
    }

    static func headline(_ size: CGFloat) -> Font {
        .custom(DesignTokens.fontFamily, size: size, relativeTo: .headline).weight(.medium)
    }

    static func body(_ size: CGFloat) -> Font {
        .custom(DesignTokens.fontFamily, size: size, relativeTo: .body).weight(.regular)
    }

    static func caption(_ size: CGFloat) -> Font {
        .custom(DesignTokens.fontFamily, size: size, relativeTo: .caption).weight(.medium)
    }

    static func micro(_ size: CGFloat) -> Font {
        .custom(DesignTokens.fontFamily, size: size, relativeTo: .caption2).weight(.regular)
    }
}

struct StripRamp {
    var display: CGFloat
    var title: CGFloat
    var headline: CGFloat
    var body: CGFloat
    var caption: CGFloat
    var micro: CGFloat
}

private struct StripRampKey: EnvironmentKey {
    static let defaultValue = StripRamp(
        display: 44,
        title: 28,
        headline: 20,
        body: 17,
        caption: 13,
        micro: 11
    )
}

extension EnvironmentValues {
    var stripRamp: StripRamp {
        get { self[StripRampKey.self] }
        set { self[StripRampKey.self] = newValue }
    }
}

/// Installs Dynamic Type sizes once so screens share the six steps.
struct StripRampInstaller: ViewModifier {
    @ScaledMetric(relativeTo: .largeTitle) private var display: CGFloat = 44
    @ScaledMetric(relativeTo: .title) private var title: CGFloat = 28
    @ScaledMetric(relativeTo: .headline) private var headline: CGFloat = 20
    @ScaledMetric(relativeTo: .body) private var body: CGFloat = 17
    @ScaledMetric(relativeTo: .caption) private var caption: CGFloat = 13
    @ScaledMetric(relativeTo: .caption2) private var micro: CGFloat = 11

    func body(content: Content) -> some View {
        content.environment(
            \.stripRamp,
            StripRamp(
                display: display,
                title: title,
                headline: headline,
                body: body,
                caption: caption,
                micro: micro
            )
        )
    }
}

enum StripCount {
    static let decimal: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()

    static func text(_ value: Int) -> String {
        decimal.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}

struct SoftCardButtonStyle: ButtonStyle {
    enum Kind {
        case primary
        case quiet
        case destructive
    }

    var kind: Kind = .primary
    var enabled: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(StripType.headline(20))
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity, minHeight: StripSpace.hit)
            .padding(.horizontal, StripSpace.base)
            .background {
                RoundedRectangle(cornerRadius: StripRadius.surface, style: .continuous)
                    .fill(fill(pressed: configuration.isPressed))
            }
            .overlay {
                RoundedRectangle(cornerRadius: StripRadius.surface, style: .continuous)
                    .strokeBorder(DesignTokens.ink.opacity(0.12), lineWidth: 1)
            }
            .contentShape(RoundedRectangle(cornerRadius: StripRadius.surface, style: .continuous))
            .opacity(enabled ? 1 : 0.45)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }

    private var foreground: Color {
        switch kind {
        case .primary:
            DesignTokens.surface
        case .quiet:
            DesignTokens.ink
        case .destructive:
            DesignTokens.accent
        }
    }

    private func fill(pressed: Bool) -> Color {
        let base: Color
        switch kind {
        case .primary:
            base = DesignTokens.accent
        case .quiet:
            base = DesignTokens.surface
        case .destructive:
            base = DesignTokens.surface
        }
        return pressed ? base.opacity(0.82) : base
    }
}

struct StripCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(StripSpace.base)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: StripRadius.surface, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: StripRadius.surface, style: .continuous)
                    .strokeBorder(DesignTokens.ink.opacity(0.08), lineWidth: 1)
            }
    }
}
