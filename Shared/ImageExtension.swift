//
//  ImageExtension.swift
//  Email Alias Watch App
//
//  Created by Sven Op de Hipt on 23.02.24.
//

import SwiftUI

#if os(macOS)
typealias NativeImage = NSImage
#else
typealias NativeImage = UIImage
#endif

extension Image {
    init(native nativeImage: NativeImage) {
        #if os(macOS)
        self.init(nsImage: nativeImage)
        #else
        self.init(uiImage: nativeImage)
        #endif
    }
}

#if os(macOS)
extension NSBitmapImageRep {
    var png: Data? { representation(using: .png, properties: [:]) }
}
extension Data {
    var bitmap: NSBitmapImageRep? { NSBitmapImageRep(data: self) }
}
extension NSImage {
    var png: Data? { tiffRepresentation?.bitmap?.png }
}
#endif
