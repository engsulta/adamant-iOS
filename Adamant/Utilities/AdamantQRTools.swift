//
//  AdamantQRTools.swift
//  Adamant
//
//  Created by Anokhov Pavel on 20.02.2018.
//  Copyright © 2018 Adamant. All rights reserved.
//

import Foundation
import EFQRCode

enum QRToolGenerateResult {
	case success(UIImage)
	case failure(error: Error)
}

enum QRToolDecodeResult {
	case success(String)
	case none
	case failure(error: Error)
}

class AdamantQRTools {
	static func generateQrFrom(string: String) -> QRToolGenerateResult {
		if let qr = EFQRCode.generate(content: string) {
			let image = UIImage(cgImage: qr)
			return .success(image)
		}
		
		return .failure(error: AdamantError(message: "Failed to generate QR from: \(string)"))
	}
	
	static func readQR(_ qr: UIImage) -> QRToolDecodeResult {
		guard let image = qr.cgImage else {
			print("Failed to get image?")
			return .none
		}
		
		if let result = EFQRCode.recognize(image: image)?.first {
			return .success(result)
		}
		
		return .none
	}
	
	private init() {}
}