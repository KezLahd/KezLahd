// Renders a local HTML page to a PNG at 2x with WebKit.
// swift tools/render.swift <page.html#fragment> <out.png> <width> <height>   (height 0: fit the page)
import AppKit
import WebKit

let a = CommandLine.arguments
let page = a[1], out = a[2]
let w = Double(a[3])!, h = Double(a[4])!
let startH = h == 0 ? 400 : h
let parts = page.split(separator: "#", maxSplits: 1).map(String.init)
var url = URL(fileURLWithPath: parts[0])
if parts.count > 1 { url = URL(string: url.absoluteString + "#" + parts[1])! }

final class Shot: NSObject, WKNavigationDelegate {
    let view = WKWebView(frame: NSRect(x: 0, y: 0, width: w, height: startH))
    func start() {
        view.navigationDelegate = self
        view.setValue(false, forKey: "drawsBackground")
        view.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent().deletingLastPathComponent())
    }
    func webView(_ v: WKWebView, didFinish _: WKNavigation!) {
        // Wait for the web fonts, then a beat for layout.
        v.evaluateJavaScript("document.fonts.ready.then(() => 1)") { _, _ in
            v.evaluateJavaScript("document.getElementById('m') ? Math.ceil(document.getElementById('m').getBoundingClientRect().bottom + 6) : 0") { fit, _ in
            if h == 0, let fit = fit as? Double { v.frame.size.height = fit; v.window?.setContentSize(NSSize(width: w, height: fit)) }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                let c = WKSnapshotConfiguration(); c.snapshotWidth = NSNumber(value: w * 2)
                v.takeSnapshot(with: c) { img, err in
                    guard let img, let tiff = img.tiffRepresentation, let rep = NSBitmapImageRep(data: tiff),
                          let png = rep.representation(using: .png, properties: [:]) else { print(err ?? "no image"); exit(1) }
                    try! png.write(to: URL(fileURLWithPath: out)); exit(0)
                }
            }
            }
        }
    }
}
let app = NSApplication.shared
let shot = Shot()
let win = NSWindow(contentRect: NSRect(x: 0, y: 0, width: w, height: startH), styleMask: [.borderless], backing: .buffered, defer: false)
win.contentView = shot.view
shot.start()
DispatchQueue.main.asyncAfter(deadline: .now() + 30) { print("timed out"); exit(1) }
app.run()
