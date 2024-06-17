//
//  StringExtension.swift
//  Email Alias
//
//  Created by Sven Op de Hipt on 25.10.23.
//

import SwiftUI
#if os(watchOS)
import EFQRCode
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
        let cgImage = EFQRCode.generate(for: self)
        #else
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(utf8)

        let cgImage: CGImage?
        if let outputImage = filter.outputImage {
            let scaledOutputImage = outputImage.transformed(by: CGAffineTransformMakeScale(10, 10))
            cgImage = context.createCGImage(scaledOutputImage, from: scaledOutputImage.extent)
        }
        else {
            cgImage = nil
        }
        #endif
        if let cgImage {
            #if os(macOS)
            return NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
            #else
            return UIImage(cgImage: cgImage)
            #endif
        }

        return nil
    }
}
