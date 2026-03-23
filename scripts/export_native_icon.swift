import AppKit
import Foundation

let bundlePath = "/Applications/ChatGPT Atlas.app/Contents/Resources/Aura_AuraDesignSystem.bundle"
let outputDirectory = "/Users/Ricardo/Desktop/Extensions/chatgpt-atlas-fake/icons"
let assetName = "Aura/Icons/New/Medium/extensions"
let sizes = [16, 32, 48, 128]

guard let bundle = Bundle(path: bundlePath) else {
  fputs("Bundle not found at \(bundlePath)\n", stderr)
  exit(1)
}

guard let image = bundle.image(forResource: NSImage.Name(assetName)) else {
  fputs("Asset not found: \(assetName)\n", stderr)
  exit(2)
}

try FileManager.default.createDirectory(
  at: URL(fileURLWithPath: outputDirectory),
  withIntermediateDirectories: true
)

for size in sizes {
  let bitmap = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: size,
    pixelsHigh: size,
    bitsPerSample: 8,
    samplesPerPixel: 4,
    hasAlpha: true,
    isPlanar: false,
    colorSpaceName: .deviceRGB,
    bytesPerRow: 0,
    bitsPerPixel: 0
  )

  guard let rep = bitmap else {
    fputs("Failed to create bitmap for \(size)x\(size)\n", stderr)
    exit(3)
  }

  rep.size = NSSize(width: size, height: size)

  NSGraphicsContext.saveGraphicsState()
  guard let context = NSGraphicsContext(bitmapImageRep: rep) else {
    fputs("Failed to create graphics context for \(size)x\(size)\n", stderr)
    exit(4)
  }

  NSGraphicsContext.current = context
  image.draw(
    in: NSRect(x: 0, y: 0, width: size, height: size),
    from: .zero,
    operation: .copy,
    fraction: 1
  )
  context.flushGraphics()
  NSGraphicsContext.restoreGraphicsState()

  guard let pngData = rep.representation(using: .png, properties: [:]) else {
    fputs("Failed to encode PNG for \(size)x\(size)\n", stderr)
    exit(5)
  }

  let outputURL = URL(fileURLWithPath: outputDirectory)
    .appendingPathComponent("icon-\(size).png")
  try pngData.write(to: outputURL)
  print(outputURL.path)
}
