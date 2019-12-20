#import "UIImage+drawText.h"


@implementation UIImage (drawText_extension)

+(UIImage *)drawText:(NSString *)text diagonallyOnImage:(UIImage *)image alpha:(double)transparencyAlpha fontSize:(double)size rotation:(WatermarkRotation)rotation { 
    UIFont *font;

    // Check if size is not nil / empty and set the size
    if (size) {
        font = [UIFont boldSystemFontOfSize:size];
    }
    else { // default value
        font = [UIFont boldSystemFontOfSize:65];
    }

    UIColor *textColor;
    
    // Check if transparencyAlpha is not nil / empty and set the color
    if (transparencyAlpha) {
        textColor = [UIColor colorWithRed:255 green:0 blue:0 alpha:transparencyAlpha];
    }
    else { // default value
        textColor = [UIColor colorWithRed:255 green:0 blue:0 alpha:0.4];
    }
    
    // Compute rect to draw the text inside
    NSDictionary *attr = @{NSForegroundColorAttributeName: textColor, NSFontAttributeName: font};
    CGSize textSize = [text sizeWithAttributes:attr];
    CGSize imageSize = image.size;
    // Create a bitmap context into which the text will be rendered.
    UIGraphicsBeginImageContextWithOptions(textSize, NO, 0.0);
    // Render the text
    [text drawAtPoint:CGPointMake(0,0) withAttributes:attr];
    // Retrieve the image
    UIImage* img = UIGraphicsGetImageFromCurrentImageContext();

    CGImageRef imageRef = [img CGImage];
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);


    CGContextRef bitmap = CGBitmapContextCreate(NULL, textSize.width, textSize.width, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);

    switch (rotation) {
        case WatermarkRotation90left:
            CGContextRotateCTM (bitmap, DEGREES_RADIANS(-90));
            CGContextTranslateCTM(bitmap, -textSize.width, 0);
            break;

        case WatermarkRotation90right:
            CGContextRotateCTM (bitmap, DEGREES_RADIANS(90));
            CGContextTranslateCTM(bitmap, 0, -textSize.width);
            break;

        case WatermarkRotation45ltr:
            CGContextRotateCTM (bitmap, DEGREES_RADIANS(45));
            CGContextTranslateCTM(bitmap, textSize.width/4, -textSize.width/2);
            break;

        case WatermarkRotation45rtl:
            CGContextRotateCTM (bitmap, DEGREES_RADIANS(-45));
            CGContextTranslateCTM(bitmap, -textSize.width/2, textSize.width/4);
            break;

        default:
            break;
    }

    CGContextDrawImage(bitmap, CGRectMake(0, (textSize.width/2)-(textSize.height/2), textSize.width, textSize.height), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage* newImage = [UIImage imageWithCGImage:ref];

    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);

    // Use existing opacity as is
    [image drawInRect:CGRectMake(0,0,imageSize.width,imageSize.height)];


    if (rotation == WatermarkRotation90left) {
        [newImage drawInRect:CGRectMake(-((textSize.width/2)-(textSize.height/2)),(imageSize.height/2)-(textSize.width/2),textSize.width,textSize.width) blendMode:kCGBlendModeNormal alpha:1.0];
    }else if(rotation == WatermarkRotation90right){
        [newImage drawInRect:CGRectMake((imageSize.width-textSize.width/2)-(textSize.height/2),(imageSize.height/2)-(textSize.width/2),textSize.width,textSize.width) blendMode:kCGBlendModeNormal alpha:1.0];
    }else{
        [newImage drawInRect:CGRectMake((imageSize.width/2)-(textSize.width/2),(imageSize.height/2)-(textSize.width/2),textSize.width,textSize.width) blendMode:kCGBlendModeNormal alpha:1.0];
    }


    UIImage *mergedImage = UIGraphicsGetImageFromCurrentImageContext();


    UIGraphicsEndImageContext();
    return mergedImage;
}

@end