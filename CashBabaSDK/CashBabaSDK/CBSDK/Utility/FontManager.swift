//
//  FontManager.swift
//  CBSDKTestApp
//
//  Created by Imrul Kayes on 10/13/25.
//

import UIKit

// Singleton to manage font registration
public class FontManager {
    
    // Static property to ensure fonts are registered only once
    private static var isFontsRegistered = false
    
    // Shared instance of FontManager (optional if you need to manage state)
    public static let shared = FontManager()
    
    // Expose fonts as properties through an instance
    public var fonts: Fonts
    
    private init() {
        // Initialize the fonts property
        self.fonts = Fonts()
        
        // Check if fonts are registered and register if needed
        if !FontManager.isFontsRegistered {
            registerFonts()
            FontManager.isFontsRegistered = true
        }
    }
    
    // Function to register fonts
    private func registerFonts() {
        let fonts = Fonts()
        let fontNames = [
            fonts.interBold,
            fonts.interSemiBold,
            fonts.interRegular,
            fonts.interMedium,
            fonts.robotoBold,
            fonts.robotoLight,
            fonts.robotoMedium,
            fonts.robotoRegular,
            fonts.kohinoorBold,
            fonts.kohinoorLight,
            fonts.kohinoorMedium,
            fonts.kohinoorRegular,
            fonts.kohinoorSemiBold,
            fonts.esRebondBold
        ]
        
        // Register each font if not already registered
        for fontName in fontNames {
            registerFontIfNeeded(fontName)
        }
    }
    
    // Function to check if a font is already registered and register if needed
    private func registerFontIfNeeded(_ fontName: String) {
        if !isFontRegistered(fontName) {
            registerFont(fontName)
        }
    }
    
    // Function to check if a font is registered
    private func isFontRegistered(_ fontName: String) -> Bool {
        return UIFont(name: fontName, size: 1.0) != nil
    }
    
    // Register font from the framework's bundle
    private func registerFont(_ fontName: String) {
        // Access the bundle of the XCFramework using the current class
        let bundle = Bundle(for: FontManager.self)
        guard let fontURL = bundle.url(forResource: fontName, withExtension: "ttf") ??
                            bundle.url(forResource: fontName, withExtension: "otf") else {
            print("Font \(fontName) not found in the bundle")
            return
        }
        
        guard let dataProvider = CGDataProvider(url: fontURL as CFURL),
              let font = CGFont(dataProvider) else {
            print("Failed to load font \(fontName)")
            return
        }
        
        var error: Unmanaged<CFError>?
        if !CTFontManagerRegisterGraphicsFont(font, &error) {
            print("Failed to register font \(fontName)")
        }
    }
    
    // Fonts struct exposes font names
    public struct Fonts {
        public let esRebondBold = "ESRebondGrotesqueTRIAL-Bold"
        public let interBold = "Inter-Bold"
        public let interSemiBold = "Inter-SemiBold"
        public let interRegular = "Inter-Regular"
        public let interMedium = "Inter-Medium"
        public let robotoBold = "Roboto-Bold"
        public let robotoLight = "Roboto-Light"
        public let robotoMedium = "Roboto-Medium"
        public let robotoRegular = "Roboto-Regular"
        public let kohinoorBold = "KohinoorBangla-Bold"
        public let kohinoorLight = "KohinoorBangla-Light"
        public let kohinoorMedium = "KohinoorBangla-Medium"
        public let kohinoorRegular = "KohinoorBangla-Regular"
        public let kohinoorSemiBold = "KohinoorBangla-Semibold"
    }
}

