//#import <Foundation/Foundation.h>
//#import <UIKit/UIKit.h>

@interface UIImage (drawText_extension)

#define DEGREES_RADIANS(angle) ((angle) / 180.0 * M_PI)
typedef enum:NSUInteger{
    WatermarkRotation90left=1,
    WatermarkRotation90right,
    WatermarkRotation45ltr,
    WatermarkRotation45rtl
}WatermarkRotation;

+(UIImage *)drawText:(NSString *)text diagonallyOnImage:(UIImage *)image alpha:(double)transparencyAlpha fontSize:(double)size rotation:(WatermarkRotation)rotation;
@end