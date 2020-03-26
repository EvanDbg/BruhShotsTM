@interface NSUserDefaults (Private)
-(id)objectForKey:(id)arg1 inDomain:(id)arg2;
@end

@interface SSScreenCapturer : NSObject
-(void)_saveImageToPhotoLibrary:(UIImage *)image environmentDescription:(id)env;
-(WatermarkRotation)currentRotation;
@end