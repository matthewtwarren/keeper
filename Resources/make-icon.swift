// Draws the Keeper icon and writes Resources/AppIcon.icns, AppIcon.png and AppIcon-light.png. Run with `make icon`.
import AppKit

struct Palette {
    let background: CGColor
    let border: CGColor
}

let dark = Palette(
    background: CGColor(srgbRed: 0x10 / 255, green: 0x10 / 255, blue: 0x15 / 255, alpha: 1),
    border: CGColor(srgbRed: 0x2A / 255, green: 0x2A / 255, blue: 0x35 / 255, alpha: 1)
)
let light = Palette(
    background: CGColor(srgbRed: 0xEC / 255, green: 0xEC / 255, blue: 0xEF / 255, alpha: 1),
    border: CGColor(srgbRed: 0xD2 / 255, green: 0xD2 / 255, blue: 0xD9 / 255, alpha: 1)
)
let accent = CGColor(srgbRed: 0x50 / 255, green: 0x63 / 255, blue: 0x85 / 255, alpha: 1)
let tag = CGColor(srgbRed: 0x5B / 255, green: 0xC2 / 255, blue: 0x36 / 255, alpha: 1)

// Same 64-unit grid and outer square as Crate's logo.svg, with a tagged photo in place of the record.
func drawLogo(_ context: CGContext, _ palette: Palette) {
    context.setStrokeColor(accent)
    context.setLineCap(.round)
    context.setLineJoin(.round)

    context.setLineWidth(2.5)
    context.addPath(CGPath(roundedRect: CGRect(x: 4, y: 4, width: 56, height: 56), cornerWidth: 6, cornerHeight: 6, transform: nil))
    context.strokePath()

    context.addPath(CGPath(roundedRect: CGRect(x: 11, y: 19, width: 42, height: 28), cornerWidth: 2, cornerHeight: 2, transform: nil))
    context.strokePath()

    context.setLineWidth(2)
    context.strokeEllipse(in: CGRect(x: 17.5, y: 24.5, width: 7, height: 7))
    context.addLines(between: [
        CGPoint(x: 14, y: 43.5), CGPoint(x: 24, y: 34), CGPoint(x: 31, y: 40.5),
        CGPoint(x: 37, y: 35), CGPoint(x: 50, y: 43.5),
    ])
    context.strokePath()

    let dot = CGRect(x: 45.5, y: 14.5, width: 11, height: 11)
    context.setFillColor(palette.background)
    context.fillEllipse(in: dot.insetBy(dx: -2.5, dy: -2.5))
    context.setFillColor(tag)
    context.fillEllipse(in: dot)
}

func renderPNG(size: Int, _ palette: Palette = dark) -> Data {
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil, pixelsWide: size, pixelsHigh: size, bitsPerSample: 8, samplesPerPixel: 4,
        hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0
    )!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    let context = NSGraphicsContext.current!.cgContext

    // Work on a 1024 canvas with a top-left origin, matching SVG coordinates.
    context.scaleBy(x: CGFloat(size) / 1024, y: CGFloat(size) / 1024)
    context.translateBy(x: 0, y: 1024)
    context.scaleBy(x: 1, y: -1)

    // macOS icon grid: an 824pt tile centred on the 1024 canvas.
    let tile = CGPath(roundedRect: CGRect(x: 100, y: 100, width: 824, height: 824), cornerWidth: 185, cornerHeight: 185, transform: nil)
    context.addPath(tile)
    context.setFillColor(palette.background)
    context.fillPath()
    context.addPath(tile)
    context.setStrokeColor(palette.border)
    context.setLineWidth(6)
    context.strokePath()

    context.translateBy(x: 192, y: 192)
    context.scaleBy(x: 10, y: 10)
    drawLogo(context, palette)

    NSGraphicsContext.restoreGraphicsState()
    return rep.representation(using: .png, properties: [:])!
}

let resources = URL(fileURLWithPath: CommandLine.arguments[1])
// For the README
try renderPNG(size: 256).write(to: resources.appendingPathComponent("AppIcon.png"))
try renderPNG(size: 256, light).write(to: resources.appendingPathComponent("AppIcon-light.png"))
let iconset = FileManager.default.temporaryDirectory.appendingPathComponent("AppIcon.iconset")
try? FileManager.default.removeItem(at: iconset)
try FileManager.default.createDirectory(at: iconset, withIntermediateDirectories: true)
for points in [16, 32, 128, 256, 512] {
    try renderPNG(size: points).write(to: iconset.appendingPathComponent("icon_\(points)x\(points).png"))
    try renderPNG(size: points * 2).write(to: iconset.appendingPathComponent("icon_\(points)x\(points)@2x.png"))
}

let iconutil = Process()
iconutil.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
iconutil.arguments = ["-c", "icns", iconset.path, "-o", resources.appendingPathComponent("AppIcon.icns").path]
try iconutil.run()
iconutil.waitUntilExit()
exit(iconutil.terminationStatus)
