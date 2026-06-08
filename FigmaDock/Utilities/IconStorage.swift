import AppKit
import Foundation

enum IconStorage {
    private static var iconsDir: URL {
        Constants.appSupportDir.appendingPathComponent("icons")
    }

    static func saveImage(from sourceURL: URL, for pluginID: UUID) -> String? {
        try? FileManager.default.createDirectory(at: iconsDir, withIntermediateDirectories: true)
        let ext = sourceURL.pathExtension.isEmpty ? "png" : sourceURL.pathExtension
        let filename = "\(pluginID.uuidString).\(ext)"
        let destURL = iconsDir.appendingPathComponent(filename)

        if let image = NSImage(contentsOf: sourceURL) {
            guard let tiffData = image.tiffRepresentation,
                  let bitmapRep = NSBitmapImageRep(data: tiffData),
                  let pngData = bitmapRep.representation(using: .png, properties: [:]) else {
                return nil
            }
            let pngFilename = "\(pluginID.uuidString).png"
            let pngURL = iconsDir.appendingPathComponent(pngFilename)
            do {
                try pngData.write(to: pngURL)
                return pngFilename
            } catch {
                return nil
            }
        }

        do {
            if FileManager.default.fileExists(atPath: destURL.path) {
                try FileManager.default.removeItem(at: destURL)
            }
            try FileManager.default.copyItem(at: sourceURL, to: destURL)
            return filename
        } catch {
            return nil
        }
    }

    static func loadImage(filename: String) -> NSImage? {
        let url = iconsDir.appendingPathComponent(filename)
        return NSImage(contentsOf: url)
    }

    static func deleteImage(filename: String) {
        let url = iconsDir.appendingPathComponent(filename)
        try? FileManager.default.removeItem(at: url)
    }
}
