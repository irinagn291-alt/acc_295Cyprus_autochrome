import SceneKit
import SwiftUI
import UIKit

/// Hero surface. One SceneKit filmstrip of glass panes. The matching pane is the playhead.
struct SceneMosaic: UIViewRepresentable {
    var panes: [Pane]
    var litIDs: Set<UUID>
    var titles: [String: String]
    var onTap: (UUID) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.backgroundColor = .clear
        view.antialiasingMode = .multisampling4X
        view.autoenablesDefaultLighting = false
        view.allowsCameraControl = false
        view.rendersContinuously = true
        let scene = SCNScene()
        scene.background.contents = UIColor(DesignTokens.bg)
        view.scene = scene

        let cameraNode = SCNNode()
        let camera = SCNCamera()
        camera.fieldOfView = 34
        camera.zNear = 0.1
        camera.zFar = 80
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 0.15, 8.4)
        scene.rootNode.addChildNode(cameraNode)

        let key = SCNNode()
        key.light = SCNLight()
        key.light?.type = .directional
        key.light?.intensity = 980
        key.light?.color = UIColor(DesignTokens.surface)
        key.eulerAngles = SCNVector3(-0.7, 0.35, 0)
        scene.rootNode.addChildNode(key)

        let fill = SCNNode()
        fill.light = SCNLight()
        fill.light?.type = .ambient
        fill.light?.intensity = 320
        fill.light?.color = UIColor(DesignTokens.bg)
        scene.rootNode.addChildNode(fill)

        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.tapped(_:)))
        view.addGestureRecognizer(tap)
        context.coordinator.view = view
        context.coordinator.onTap = onTap
        context.coordinator.rebuild(panes: panes, litIDs: litIDs, titles: titles)
        return view
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        context.coordinator.onTap = onTap
        context.coordinator.rebuild(panes: panes, litIDs: litIDs, titles: titles)
        context.coordinator.applyAccessibility(panes: panes, litIDs: litIDs, titles: titles)
    }

    @MainActor
    final class Coordinator: NSObject {
        weak var view: SCNView?
        var onTap: (UUID) -> Void = { _ in }
        private var stripRoot: SCNNode?
        private var signature = ""
        private let glassPrototype = Glass.makePrototype()
        private let leadMaterial = Glass.lead()
        private let accentMaterial = Glass.accent()
        private let holeMaterial = Glass.hole()

        func rebuild(panes: [Pane], litIDs: Set<UUID>, titles: [String: String]) {
            let ordered = panes.sorted { $0.daykey < $1.daykey }
            let next = ordered.map { "\($0.id.uuidString)-\(litIDs.contains($0.id))-\(titles[$0.emotionID] ?? "")" }.joined(separator: "|")
            guard next != signature, let scene = view?.scene else { return }
            signature = next
            stripRoot?.removeFromParentNode()
            let root = SCNNode()
            stripRoot = root
            scene.rootNode.addChildNode(root)

            let spacing: Float = 1.62
            let anchor = ordered.firstIndex { litIDs.contains($0.id) } ?? max(ordered.count - 1, 0)
            var positions: [Float] = []
            for (index, pane) in ordered.enumerated() {
                let lit = litIDs.contains(pane.id)
                let x = Float(index) * spacing - Float(anchor) * spacing
                positions.append(x)
                let paneNode = makePane(pane, lit: lit, x: x)
                root.addChildNode(paneNode)
            }
            if let first = positions.first, let last = positions.last {
                addRails(to: root, from: first, to: last)
            }
            if ordered.contains(where: { litIDs.contains($0.id) }) {
                addPlayhead(to: root)
            }
            view?.setNeedsDisplay()
        }

        func applyAccessibility(panes: [Pane], litIDs: Set<UUID>, titles: [String: String]) {
            guard let view, view.bounds.width > 1 else { return }
            let ordered = panes.sorted { $0.daykey < $1.daykey }
            view.isAccessibilityElement = false
            let width = view.bounds.width / CGFloat(max(ordered.count, 1))
            view.accessibilityElements = ordered.enumerated().map { index, pane in
                let element = UIAccessibilityElement(accessibilityContainer: view)
                let title = titles[pane.emotionID] ?? "Moment"
                let lit = litIDs.contains(pane.id)
                element.accessibilityLabel = lit ? "\(title), matches today" : title
                element.accessibilityHint = lit ? "Opens this saved day" : "Does not match today"
                element.accessibilityTraits = .button
                element.accessibilityFrameInContainerSpace = CGRect(
                    x: width * CGFloat(index),
                    y: 0,
                    width: width,
                    height: view.bounds.height
                )
                return element
            }
        }

        @objc func tapped(_ gesture: UITapGestureRecognizer) {
            guard let view else { return }
            let point = gesture.location(in: view)
            let hits = view.hitTest(point, options: nil)
            for hit in hits {
                var node: SCNNode? = hit.node
                while let current = node {
                    if let raw = current.name, let id = UUID(uuidString: raw) {
                        onTap(id)
                        return
                    }
                    node = current.parent
                }
            }
        }

        private func makePane(_ pane: Pane, lit: Bool, x: Float) -> SCNNode {
            let width: CGFloat = lit ? 1.28 : 1.02
            let height: CGFloat = lit ? 2.05 : 1.62
            let lead = SCNBox(width: width + 0.12, height: height + 0.12, length: 0.08, chamferRadius: 0.05)
            lead.materials = [leadMaterial]
            let leadNode = SCNNode(geometry: lead)

            let glass = SCNBox(width: width, height: height, length: 0.1, chamferRadius: 0.06)
            glass.materials = [Glass.pane(from: glassPrototype, emotionID: pane.emotionID, lit: lit)]
            let glassNode = SCNNode(geometry: glass)
            glassNode.position = SCNVector3(0, 0, 0.06)

            let node = SCNNode()
            node.name = pane.id.uuidString
            node.position = SCNVector3(x, lit ? 0.08 : 0, lit ? 0.42 : 0)
            node.addChildNode(leadNode)
            node.addChildNode(glassNode)
            return node
        }

        private func addRails(to root: SCNNode, from first: Float, to last: Float) {
            let span = CGFloat(last - first) + 2.1
            let center = (first + last) / 2
            for y: Float in [-1.28, 1.28] {
                let rail = SCNBox(width: span, height: 0.22, length: 0.06, chamferRadius: 0.04)
                rail.materials = [leadMaterial]
                let railNode = SCNNode(geometry: rail)
                railNode.position = SCNVector3(center, y, -0.12)
                root.addChildNode(railNode)

                let holes = max(Int(span / 0.42), 1)
                let start = Float(span) / -2
                for index in 0..<holes {
                    let hole = SCNCylinder(radius: 0.06, height: 0.07)
                    hole.materials = [holeMaterial]
                    let holeNode = SCNNode(geometry: hole)
                    holeNode.eulerAngles.x = Float.pi / 2
                    let localX = start + 0.24 + Float(index) * 0.42
                    holeNode.position = SCNVector3(center + localX, y, -0.06)
                    root.addChildNode(holeNode)
                }
            }
        }

        private func addPlayhead(to root: SCNNode) {
            let marker = SCNCone(topRadius: 0, bottomRadius: 0.16, height: 0.32)
            marker.materials = [accentMaterial]
            let markerNode = SCNNode(geometry: marker)
            markerNode.eulerAngles.x = Float.pi
            markerNode.position = SCNVector3(0, 1.62, 0.55)
            root.addChildNode(markerNode)

            for side: Float in [-0.82, 0.82] {
                let gate = SCNBox(width: 0.07, height: 2.35, length: 0.08, chamferRadius: 0.02)
                gate.materials = [accentMaterial]
                let gateNode = SCNNode(geometry: gate)
                gateNode.position = SCNVector3(side, 0.08, 0.5)
                root.addChildNode(gateNode)
            }
        }
    }
}

private enum Glass {
    static func makePrototype() -> SCNMaterial {
        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        material.metalness.contents = NSNumber(value: 0.05)
        material.roughness.contents = NSNumber(value: 0.16)
        material.fresnelExponent = 1.3
        material.isDoubleSided = true
        return material
    }

    static func pane(from prototype: SCNMaterial, emotionID: String, lit: Bool) -> SCNMaterial {
        let material = (prototype.copy() as? SCNMaterial) ?? makePrototype()
        let color = hue(emotionID, lit: lit)
        material.diffuse.contents = color
        material.transparency = lit ? 0.96 : 0.9
        material.roughness.contents = NSNumber(value: lit ? 0.12 : 0.42)
        if lit {
            material.emission.contents = color.withAlphaComponent(0.85)
        } else {
            material.emission.contents = UIColor.clear
        }
        return material
    }

    static func lead() -> SCNMaterial {
        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        material.diffuse.contents = UIColor(DesignTokens.ink)
        material.metalness.contents = NSNumber(value: 0.35)
        material.roughness.contents = NSNumber(value: 0.4)
        return material
    }

    static func accent() -> SCNMaterial {
        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        material.diffuse.contents = UIColor(DesignTokens.accent)
        material.emission.contents = UIColor(DesignTokens.accent).withAlphaComponent(0.2)
        material.metalness.contents = NSNumber(value: 0.1)
        material.roughness.contents = NSNumber(value: 0.3)
        return material
    }

    static func hole() -> SCNMaterial {
        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        material.diffuse.contents = UIColor(DesignTokens.surface)
        material.roughness.contents = NSNumber(value: 0.8)
        return material
    }

    private static func hue(_ emotionID: String, lit: Bool) -> UIColor {
        let accent = UIColor(DesignTokens.accent)
        let ink = UIColor(DesignTokens.ink)
        let muted = UIColor(DesignTokens.muted)
        let surface = UIColor(DesignTokens.surface)
        let base: UIColor
        switch emotionID {
        case "amber":
            base = accent
        case "harbor":
            base = mix(ink, muted, 0.35)
        case "linen":
            base = mix(surface, muted, 0.55)
        case "grove":
            base = mix(accent, ink, 0.42)
        default:
            base = muted
        }
        return lit ? base : mix(base, ink, 0.62)
    }

    private static func mix(_ a: UIColor, _ b: UIColor, _ amount: CGFloat) -> UIColor {
        var ar: CGFloat = 0, ag: CGFloat = 0, ab: CGFloat = 0, aa: CGFloat = 0
        var br: CGFloat = 0, bg: CGFloat = 0, bb: CGFloat = 0, ba: CGFloat = 0
        a.getRed(&ar, green: &ag, blue: &ab, alpha: &aa)
        b.getRed(&br, green: &bg, blue: &bb, alpha: &ba)
        return UIColor(
            red: ar + (br - ar) * amount,
            green: ag + (bg - ag) * amount,
            blue: ab + (bb - ab) * amount,
            alpha: 1
        )
    }
}
