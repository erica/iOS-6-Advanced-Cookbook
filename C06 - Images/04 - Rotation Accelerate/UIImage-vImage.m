/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */


#import "UIImage-vImage.h"
#import "UIImage-Utils.h"

@implementation UIImage (vImage)
- (vImage_Buffer) baseBuffer
{
    vImage_Buffer buf;
    buf.height = self.size.height;
    buf.width = self.size.width;
    buf.rowBytes = sizeof(Byte) * self.size.width * 4; // ARGB
    return buf;
}

- (vImage_Buffer) buffer
{
    vImage_Buffer buf = [self baseBuffer];
    buf.data = (void *)self.bytes.bytes;
    return buf;
}

- (UIImage *) vImageRotate: (CGFloat) theta
{
    vImage_Buffer inBuffer = [self buffer];
    vImage_Buffer outBuffer = [self baseBuffer];
    Byte *outData = (Byte *)malloc(outBuffer.rowBytes * outBuffer.height);
    outBuffer.data = (void *) outData;
    uint8_t backColor[4] = {0xFF, 0, 0, 0};
    
    vImage_Error error = vImageRotate_ARGB8888(&inBuffer, &outBuffer, NULL, theta, backColor, 0);
    
    if (error)
    {
        NSLog(@"Error rotating image: %ld", error);
        free(outData);
        return self;
    }
    
    return [UIImage imageWithBytes:outData withSize:self.size];
}
@end
