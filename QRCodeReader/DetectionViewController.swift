import UIKit
import AVFoundation
import Vision

class DetectionViewController: ViewController {
    var text = ""
    var flag = true
    
    override func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let imageBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        let ciimage : CIImage = CIImage(cvPixelBuffer: imageBuffer)
        let image : UIImage = self.convert(cmage: ciimage)
        let qrCode : String? = OpenCVWrapper.readQRCode(image)
        if(qrCode != nil && qrCode!.count>0){
            DispatchQueue.main.async {

                self.flag = false
                
                let rect : CGRect = OpenCVWrapper.getQRCodeRect()
                let qrcodeImage = OpenCVWrapper.getQRCodeImage()
                
                if(qrCode != self.text){
                    self.textLabel.removeFromSuperview()
                }
                self.levelLayer.removeFromSuperlayer()
                self.textLabel.font = self.textLabel.font.withSize(15)
                self.levelLayer.path = UIBezierPath(roundedRect: rect,
                                          cornerRadius: 5).cgPath
                self.levelLayer.fillColor = UIColor.red.cgColor
                self.levelLayer.opacity = 0.4
                
                
                self.textLabel.frame = rect
                self.textLabel.text = qrCode
                self.textLabel.textColor = UIColor.white
                self.textLabel.layer.borderColor = UIColor.green.cgColor
                self.textLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
                self.textLabel.numberOfLines = 0
                self.textLabel.layer.borderWidth = 2.0
                self.textLabel.transform = CGAffineTransform(rotationAngle: .pi/2)
                self.textLabel.adjustsFontSizeToFitWidth=true
                
                
                if(qrCode != self.text){
                    self.view.addSubview(self.textLabel)
                }
                
                self.text = qrCode ?? ""
                
                self.previewLayer.addSublayer(self.levelLayer)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.levelLayer.removeFromSuperlayer()
                }
            
            }
            
        }
        
        
    }
    
    // Convert CIImage to CGImage
    func convert(cmage:CIImage) -> UIImage
    {
         let context:CIContext = CIContext.init(options: nil)
         let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
         let image:UIImage = UIImage.init(cgImage: cgImage)
         return image
    }
    
    override func setupAVCapture() {
        super.setupAVCapture()
        // start the capture
        startCaptureSession()
    }
    
}

extension UIImage {
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!

        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}
