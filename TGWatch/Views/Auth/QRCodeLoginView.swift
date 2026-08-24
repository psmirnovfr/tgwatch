import SwiftUI
import QRCode

struct QRCodeLoginView: View {
    @EnvironmentObject var telegram: TelegramService
    let link: String
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                if let qrImage = generateQRCode(from: link) {
                    Image(decorative: qrImage, scale: 1.0)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .padding()
                        .background(Color.black)
                        .cornerRadius(8)
                } else {
                    Text("Ошибка генерации QR")
                        .foregroundColor(.red)
                }
                
                Text("Откройте Telegram → Настройки → Устройства → Привязать устройство")
                    .font(.system(size: 12))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("QR-код")
    }
    
    private func generateQRCode(from link: String) -> CGImage? {
        let doc = QRCode.Document(utf8String: link)
        doc.design.backgroundColor(CGColor(gray: 0, alpha: 1))
        doc.design.style.onPixels = QRCode.FillStyle.Solid(CGColor(gray: 1, alpha: 1))
        doc.design.shape.eye = QRCode.EyeShape.RoundedRect()
        doc.errorCorrection = .high
        
        return doc.cgImage(CGSize(width: 200, height: 200))
    }
}
