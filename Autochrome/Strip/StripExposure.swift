import Foundation

/// Desk formula for exposure and bath time. Hue-then-flare stays the home verb.
/// This type only exists so the film-meter invariant can be tested beside the strip.
enum StripExposure {
    /// EV = log2(N² / t). Non-positive inputs stay at zero.
    static func exposureValue(aperture n: Double, shutter t: Double) -> Double {
        guard n > 0, t > 0 else { return 0 }
        return log2((n * n) / t)
    }

    /// Reciprocity: t' = t^exponent.
    static func reciprocity(shutter t: Double, exponent: Double) -> Double {
        guard t > 0 else { return 0 }
        return pow(t, exponent)
    }

    /// Develop seconds: t * q10^((Tref − T) / 10) * push^stops, clamped to 30...3600.
    static func developSeconds(
        base t: Double,
        q10: Double,
        referenceC: Double,
        bathC: Double,
        push: Double,
        stops: Double
    ) -> Double {
        guard t > 0, q10 > 0, push > 0 else { return 30 }
        let raw = t * pow(q10, (referenceC - bathC) / 10) * pow(push, stops)
        return min(3600, max(30, raw))
    }
}
