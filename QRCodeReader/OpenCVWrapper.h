#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface OpenCVWrapper : NSObject

+(NSString*)readQRCode:(UIImage*)image;
+(CGRect)getQRCodeRect;
+(NSString*)getQRCodeText;
+(UIImage*)getQRCodeImage;

@end

NS_ASSUME_NONNULL_END
