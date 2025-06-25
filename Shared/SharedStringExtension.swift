//
//  StringExtension.swift
//  Email Alias
//
//  Created by Sven Op de Hipt on 25.10.23.
//

import SwiftUI
#if os(watchOS)
import QRCodeGenerator
#else
import CoreImage.CIFilterBuiltins
#endif

extension String {
    static func random(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._"
        return String((0..<length).map { _ in letters.randomElement()! })
    }
    
    func generateQRCode() -> NativeImage? {
        #if os(watchOS)
        guard let qr = try? QRCode.encode(text: self, ecl: .high) else {
            return nil
        }
        let dim = qr.size
        let cs = CGColorSpaceCreateDeviceGray()
        guard let ctx = CGContext(
            data: nil,
            width: dim + 2,
            height: dim + 2,
            bitsPerComponent: 8,
            bytesPerRow: dim + 2,
            space: cs,
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        ) else {
            return nil
        }

        // White background
        ctx.setFillColor(gray: 1, alpha: 1)
        ctx.fill(CGRect(x: 0, y: 0, width: dim + 2, height: dim + 2))

        // Black modules
        ctx.setFillColor(gray: 0, alpha: 1)
        for row in 0..<dim {
            for col in 0..<dim where qr.getModule(x: row, y: col) {
                ctx.fill(CGRect(x: col + 1,
                                y: row + 1,
                                width: 1,
                                height: 1))
            }
        }

        guard let cgImage = ctx.makeImage() else {
            return nil
        }
        #else
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(utf8)

        guard let outputImage = filter.outputImage else {
            return nil
        }
        let scaledOutputImage = outputImage.transformed(by: CGAffineTransformMakeScale(10, 10))
        guard let cgImage = context.createCGImage(scaledOutputImage, from: scaledOutputImage.extent) else {
            return nil
        }
        #endif
        
        #if os(macOS)
        return NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
        #else
        return UIImage(cgImage: cgImage)
        #endif
    }
}
