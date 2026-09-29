import SwiftUI

/// SPEC section 7. The only place these hex values live — reach colours
/// and the font family through here. Keep this file and its values.
enum DesignTokens {
    /// #EFE7EB
    static let bg = Color(red: 0.937255, green: 0.905882, blue: 0.921569)
    static let bgHex = "#EFE7EB"
    /// #F6F3F3
    static let surface = Color(red: 0.964706, green: 0.952941, blue: 0.952941)
    static let surfaceHex = "#F6F3F3"
    /// #29151F
    static let ink = Color(red: 0.160784, green: 0.082353, blue: 0.121569)
    static let inkHex = "#29151F"
    /// #C2292E
    static let accent = Color(red: 0.760784, green: 0.160784, blue: 0.180392)
    static let accentHex = "#C2292E"
    /// #6D5561
    static let muted = Color(red: 0.427451, green: 0.333333, blue: 0.380392)
    static let mutedHex = "#6D5561"
    static let fontFamily = "Avenir Next"
}
