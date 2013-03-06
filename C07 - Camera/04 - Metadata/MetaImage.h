/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>

#define STRINGKEY(_x_) ((__bridge NSString *)_x_)
#define EXIFKEY STRINGKEY(kCGImagePropertyExifDictionary)
#define GPSKEY STRINGKEY(kCGImagePropertyGPSDictionary)

NSMutableDictionary *imagePropertiesDictionaryForFilePath(NSString *path);
NSMutableDictionary *imagePropertiesFromImage(UIImage *image);

@interface MetaImage : NSObject
@property (nonatomic, strong, readonly) UIImage *image;
@property (nonatomic, readonly) NSMutableDictionary *properties;
@property (nonatomic, readonly) NSMutableDictionary *exif;
@property (nonatomic, readonly) NSMutableDictionary *gps;

- (BOOL) writeToPath: (NSString *) path;
- (id) objectForKeyedSubscript: (id) key;
- (void) setObject: (id) object forKeyedSubscript: (id < NSCopying >) aKey;

+ (NSArray *) imageSpecificDictionaryKeys;
+ (NSArray *) exifKeys;
+ (NSArray *) gpsKeys;

+ (instancetype) newImage: (UIImage *) image;
+ (instancetype) imageFromPath: (NSString *) path;
@end
