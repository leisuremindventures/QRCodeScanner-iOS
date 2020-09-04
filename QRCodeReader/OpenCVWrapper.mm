#import "OpenCVWrapper.h"

#include <opencv2/objdetect.hpp>
#include <opencv2/imgcodecs.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <iostream>

using namespace cv;
using namespace std;

@implementation OpenCVWrapper 
static CGRect qrCodeRect;
static NSString* qrCodeText;
static UIImage* qrImage;
+(cv::Mat)cvMatFromUIImage:(UIImage *)image
{
  CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
  CGFloat cols = image.size.width;
  CGFloat rows = image.size.height;
  cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
  CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                 cols,                       // Width of bitmap
                                                 rows,                       // Height of bitmap
                                                 8,                          // Bits per component
                                                 cvMat.step[0],              // Bytes per row
                                                 colorSpace,                 // Colorspace
                                                 kCGImageAlphaNoneSkipLast |
                                                 kCGBitmapByteOrderDefault); // Bitmap info flags
  CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
  CGContextRelease(contextRef);
  return cvMat;
}
+(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
  NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
  CGColorSpaceRef colorSpace;
  if (cvMat.elemSize() == 1) {
      colorSpace = CGColorSpaceCreateDeviceGray();
  } else {
      colorSpace = CGColorSpaceCreateDeviceRGB();
  }
  CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
  // Creating CGImage from cv::Mat
  CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                     cvMat.rows,                                 //height
                                     8,                                          //bits per component
                                     8 * cvMat.elemSize(),                       //bits per pixel
                                     cvMat.step[0],                            //bytesPerRow
                                     colorSpace,                                 //colorspace
                                     kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                     provider,                                   //CGDataProviderRef
                                     NULL,                                       //decode
                                     false,                                      //should interpolate
                                     kCGRenderingIntentDefault                   //intent
                                     );
  // Getting UIImage from CGImage
  UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
  CGImageRelease(imageRef);
  CGDataProviderRelease(provider);
  CGColorSpaceRelease(colorSpace);
  return finalImage;
 }

+(NSString*)readQRCode:(UIImage*)image{
    cv::Mat rgbMat = [OpenCVWrapper cvMatFromUIImage:image];
    
    QRCodeDetector* qrDecoder = new QRCodeDetector();

    Mat bbox, rectifiedImage;

    std::string data = qrDecoder->detectAndDecode(rgbMat, bbox, rectifiedImage);
    if(data.length()>0)
    {
      cv::Rect rect = cv::boundingRect(bbox);
      qrCodeRect = CGRectMake(rect.x, rect.y, rect.width, rect.height);
      qrCodeText = [[NSString alloc] initWithUTF8String:data.c_str()];;
      rectifiedImage.convertTo(rectifiedImage, CV_8UC3);
      qrImage = [OpenCVWrapper UIImageFromCVMat:rectifiedImage];
      
    }
    qrDecoder->~QRCodeDetector();
    return qrCodeText;
}

+(CGRect)getQRCodeRect{
    return qrCodeRect;
}

+(NSString*)getQRCodeText{
    return qrCodeText;
}

+(UIImage*)getQRCodeImage{
    return qrImage;
}


@end
