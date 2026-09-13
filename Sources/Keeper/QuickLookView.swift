import Quartz
import SwiftUI

struct QuickLookView: NSViewRepresentable {
    let url: URL?
    var revision = 0

    final class Coordinator {
        var revision = 0
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> QLPreviewView {
        let view = QLPreviewView(frame: .zero, style: .compact)!
        view.autostarts = true
        return view
    }

    func updateNSView(_ view: QLPreviewView, context: Context) {
        if (view.previewItem as? NSURL) as URL? != url {
            view.previewItem = url as NSURL?
        } else if context.coordinator.revision != revision {
            view.refreshPreviewItem()
        }
        context.coordinator.revision = revision
    }
}
