/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import "MetaImage.h"
#import <ImageIO/ImageIO.h>
#import "UTIHelper.h"

CGImageRef imageRefAtPath(NSString *path)
{
    CFDictionaryRef options = (__bridge CFDictionaryRef)@{
    };
    
    CFURLRef url = (__bridge CFURLRef) [NSURL fileURLWithPath:path];
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL(url, options);
    if (imageSource == NULL)
    {
        NSLog(@"Error: Could not establish image source for file at path: %@", path);
        return NULL;
    }
    CGImageRef image = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
    CFRelease(imageSource);
    if (image == NULL)
    {
        NSLog(@"Image not created from image source.");
        return NULL;
    }
    
    return image;
}

NSMutableDictionary *imagePropertiesDictionaryForFilePath(NSString *path)
{
    CFDictionaryRef options = (__bridge CFDictionaryRef)@{
    };
    
    CFURLRef url = (__bridge CFURLRef) [NSURL fileURLWithPath:path];
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL(url, options);
    if (imageSource == NULL)
    {
        NSLog(@"Error: Could not establish image source for file at path: %@", path);
        return nil;
    }
    CFDictionaryRef imagePropertiesDictionary = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL);
    CFRelease(imageSource);
    
    return [NSMutableDictionary dictionaryWithDictionary:(__bridge_transfer NSDictionary *)imagePropertiesDictionary];
}

NSMutableDictionary *imagePropertiesFromImage(UIImage *image)
{
    CFDictionaryRef options = (__bridge CFDictionaryRef)@{
    };
    NSData *data = UIImageJPEGRepresentation(image, 1.0f);
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef) data, options);
    if (imageSource == NULL)
    {
        NSLog(@"Error: Could not establish image source");
        return nil;
    }
    CFDictionaryRef imagePropertiesDictionary = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL);
    CFRelease(imageSource);
    
    return [NSMutableDictionary dictionaryWithDictionary:(__bridge_transfer NSDictionary *)imagePropertiesDictionary];
}


@implementation MetaImage

#pragma mark EXIF

- (NSDictionary *) exif
{
    return _properties[STRINGKEY(kCGImagePropertyExifDictionary)];
}

- (id) objectForKeyedSubscript: (id) key
{
    return self.properties[key];
}

- (void) setObject: (id) object forKeyedSubscript: (id < NSCopying >) aKey
{
    self.properties[aKey] = object;
}

- (BOOL) writeToPath: (NSString *) path
{
    // Prepare to write to temporary path
    NSString *temporaryPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[path lastPathComponent]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:temporaryPath])
    {
        if (![[NSFileManager defaultManager] removeItemAtPath:temporaryPath error:nil])
        {
            NSLog(@"Could not establish temporary writing file");
            return NO;
        }
    }
    
    // Where to write to
    NSURL *temporaryURL = [NSURL fileURLWithPath:temporaryPath];
    CFURLRef url = (__bridge CFURLRef) temporaryURL;
    
    // What to write
    CGImageRef imageRef = self.image.CGImage;
    
    // Metadata
    NSDictionary *properties = [NSDictionary dictionaryWithDictionary:self.properties];
    CFDictionaryRef propertiesRef = (__bridge CFDictionaryRef) properties;
    
    // UTI
    NSString *uti = preferredUTIForExtension(path.pathExtension);
    if (!uti) uti = @"public.image";
    CFStringRef utiRef = (__bridge CFStringRef) uti;

    // Create image destination
    CGImageDestinationRef imageDestination = CGImageDestinationCreateWithURL(url, utiRef, 1, NULL);
    
    // Save data
    CGImageDestinationAddImage(imageDestination, imageRef, propertiesRef);
    CGImageDestinationFinalize(imageDestination);
    
    // Clean up
    CFRelease(imageDestination);
    
    // Move file into place
    NSURL *destURL = [NSURL fileURLWithPath:path];
    
    BOOL success;
    NSError *error;
    
    // Remove previous file
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        success = [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
        if (!success)
        {
            NSLog(@"Error: Could not overwrite file properly. Original not removed.");
            return NO;
        }
    }
    
    success = [[NSFileManager defaultManager] moveItemAtURL: temporaryURL toURL:destURL error:&error];
    if (!success)
    {
        NSLog(@"Error: could not move new file into place from %@: %@", temporaryURL, error.localizedFailureReason);
        return NO;
    }

    return YES;
}

#pragma mark - Creation

- (id) initWithImage: (UIImage *) anImage properties: (NSDictionary *) properties
{
    if (!(self = [super init])) return self;
    
    _image = anImage;
    _properties = [NSMutableDictionary dictionaryWithDictionary:properties];

    NSMutableDictionary *exif = _properties[EXIFKEY];
    if (!exif)
        _properties[EXIFKEY] = [NSMutableDictionary dictionary];
    else
        _properties[EXIFKEY] = [NSMutableDictionary dictionaryWithDictionary:exif];
    
    NSMutableDictionary *gps = _properties[GPSKEY];
    if (!gps)
        _properties[GPSKEY] = [NSMutableDictionary dictionary];
    else
        _properties[GPSKEY] = [NSMutableDictionary dictionaryWithDictionary:gps];
    
    return self;
}

+ (instancetype) newImage: (UIImage *) image
{
    if (!image) return nil;
    NSDictionary *properties = imagePropertiesFromImage(image);
    MetaImage *mi = [[MetaImage alloc] initWithImage:image properties:properties];
    return mi;
}

+ (instancetype) imageFromPath: (NSString *) path
{
    NSDictionary *dictionary = imagePropertiesDictionaryForFilePath(path);
    if (!dictionary)
    {
        NSLog(@"Could not retrieve metadata from path");
        return nil;
    }
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    if (!image)
    {
        NSLog(@"Could not retrieve image from path");
        return nil;
    }
    MetaImage *mi = [[MetaImage alloc] initWithImage:image properties:dictionary];
    return mi;
}

#pragma mark - Keys

+ (NSArray *) exifKeys
{
    return @[
    STRINGKEY(kCGImagePropertyExifExposureTime),
    STRINGKEY(kCGImagePropertyExifFNumber),
    STRINGKEY(kCGImagePropertyExifExposureProgram),
    STRINGKEY(kCGImagePropertyExifSpectralSensitivity),
    STRINGKEY(kCGImagePropertyExifISOSpeedRatings),
    STRINGKEY(kCGImagePropertyExifOECF),
    STRINGKEY(kCGImagePropertyExifVersion),
    STRINGKEY(kCGImagePropertyExifDateTimeOriginal),
    STRINGKEY(kCGImagePropertyExifDateTimeDigitized),
    STRINGKEY(kCGImagePropertyExifComponentsConfiguration),
    STRINGKEY(kCGImagePropertyExifCompressedBitsPerPixel),
    STRINGKEY(kCGImagePropertyExifShutterSpeedValue),
    STRINGKEY(kCGImagePropertyExifApertureValue),
    STRINGKEY(kCGImagePropertyExifBrightnessValue),
    STRINGKEY(kCGImagePropertyExifExposureBiasValue),
    STRINGKEY(kCGImagePropertyExifMaxApertureValue),
    STRINGKEY(kCGImagePropertyExifSubjectDistance),
    STRINGKEY(kCGImagePropertyExifMeteringMode),
    STRINGKEY(kCGImagePropertyExifLightSource),
    STRINGKEY(kCGImagePropertyExifFlash),
    STRINGKEY(kCGImagePropertyExifFocalLength),
    STRINGKEY(kCGImagePropertyExifSubjectArea),
    STRINGKEY(kCGImagePropertyExifMakerNote),
    STRINGKEY(kCGImagePropertyExifUserComment),
    STRINGKEY(kCGImagePropertyExifSubsecTime),
    STRINGKEY(kCGImagePropertyExifSubsecTimeOrginal),
    STRINGKEY(kCGImagePropertyExifSubsecTimeDigitized),
    STRINGKEY(kCGImagePropertyExifFlashPixVersion),
    STRINGKEY(kCGImagePropertyExifColorSpace),
    STRINGKEY(kCGImagePropertyExifPixelXDimension),
    STRINGKEY(kCGImagePropertyExifPixelYDimension),
    STRINGKEY(kCGImagePropertyExifRelatedSoundFile),
    STRINGKEY(kCGImagePropertyExifFlashEnergy),
    STRINGKEY(kCGImagePropertyExifSpatialFrequencyResponse),
    STRINGKEY(kCGImagePropertyExifFocalPlaneXResolution),
    STRINGKEY(kCGImagePropertyExifFocalPlaneYResolution),
    STRINGKEY(kCGImagePropertyExifFocalPlaneResolutionUnit),
    STRINGKEY(kCGImagePropertyExifSubjectLocation),
    STRINGKEY(kCGImagePropertyExifExposureIndex),
    STRINGKEY(kCGImagePropertyExifSensingMethod),
    STRINGKEY(kCGImagePropertyExifFileSource),
    STRINGKEY(kCGImagePropertyExifSceneType),
    STRINGKEY(kCGImagePropertyExifCFAPattern),
    STRINGKEY(kCGImagePropertyExifCustomRendered),
    STRINGKEY(kCGImagePropertyExifExposureMode),
    STRINGKEY(kCGImagePropertyExifWhiteBalance),
    STRINGKEY(kCGImagePropertyExifDigitalZoomRatio),
    STRINGKEY(kCGImagePropertyExifFocalLenIn35mmFilm),
    STRINGKEY(kCGImagePropertyExifSceneCaptureType),
    STRINGKEY(kCGImagePropertyExifGainControl),
    STRINGKEY(kCGImagePropertyExifContrast),
    STRINGKEY(kCGImagePropertyExifSaturation),
    STRINGKEY(kCGImagePropertyExifSharpness),
    STRINGKEY(kCGImagePropertyExifDeviceSettingDescription),
    STRINGKEY(kCGImagePropertyExifSubjectDistRange),
    STRINGKEY(kCGImagePropertyExifImageUniqueID),
    STRINGKEY(kCGImagePropertyExifGamma),
    STRINGKEY(kCGImagePropertyExifCameraOwnerName),
    STRINGKEY(kCGImagePropertyExifBodySerialNumber),
    STRINGKEY(kCGImagePropertyExifLensSpecification),
    STRINGKEY(kCGImagePropertyExifLensMake),
    STRINGKEY(kCGImagePropertyExifLensModel),
    STRINGKEY(kCGImagePropertyExifLensSerialNumber),
    ];
}

// "{TIFF}", "{GIF}", "{JFIF}", "{Exif}", "{PNG}", "{IPTC}", "{GPS}", "{Raw}", "{CIFF}", "{8BIM}", "{DNG}", "{ExifAux}"
+ (NSArray *) imageSpecificDictionaryKeys
{
    return @[
    STRINGKEY(kCGImagePropertyTIFFDictionary),
    STRINGKEY(kCGImagePropertyGIFDictionary),
    STRINGKEY(kCGImagePropertyJFIFDictionary),
    STRINGKEY(kCGImagePropertyExifDictionary),
    STRINGKEY(kCGImagePropertyPNGDictionary),
    STRINGKEY(kCGImagePropertyIPTCDictionary),
    STRINGKEY(kCGImagePropertyGPSDictionary),
    STRINGKEY(kCGImagePropertyRawDictionary),
    STRINGKEY(kCGImagePropertyCIFFDictionary),
    STRINGKEY(kCGImageProperty8BIMDictionary),
    STRINGKEY(kCGImagePropertyDNGDictionary),
    STRINGKEY(kCGImagePropertyExifAuxDictionary),
    ];
}

+ (NSArray *) gpsKeys
{
    return @[
    STRINGKEY(kCGImagePropertyGPSVersion),
    STRINGKEY(kCGImagePropertyGPSLatitudeRef),
    STRINGKEY(kCGImagePropertyGPSLatitude),
    STRINGKEY(kCGImagePropertyGPSLongitudeRef),
    STRINGKEY(kCGImagePropertyGPSLongitude),
    STRINGKEY(kCGImagePropertyGPSAltitudeRef),
    STRINGKEY(kCGImagePropertyGPSAltitude),
    STRINGKEY(kCGImagePropertyGPSTimeStamp),
    STRINGKEY(kCGImagePropertyGPSSatellites),
    STRINGKEY(kCGImagePropertyGPSStatus),
    STRINGKEY(kCGImagePropertyGPSMeasureMode),
    STRINGKEY(kCGImagePropertyGPSDOP),
    STRINGKEY(kCGImagePropertyGPSSpeedRef),
    STRINGKEY(kCGImagePropertyGPSSpeed),
    STRINGKEY(kCGImagePropertyGPSTrackRef),
    STRINGKEY(kCGImagePropertyGPSTrack),
    STRINGKEY(kCGImagePropertyGPSImgDirectionRef),
    STRINGKEY(kCGImagePropertyGPSImgDirection),
    STRINGKEY(kCGImagePropertyGPSMapDatum),
    STRINGKEY(kCGImagePropertyGPSDestLatitudeRef),
    STRINGKEY(kCGImagePropertyGPSDestLatitude),
    STRINGKEY(kCGImagePropertyGPSDestLongitudeRef),
    STRINGKEY(kCGImagePropertyGPSDestLongitude),
    STRINGKEY(kCGImagePropertyGPSDestBearingRef),
    STRINGKEY(kCGImagePropertyGPSDestBearing),
    STRINGKEY(kCGImagePropertyGPSDestDistanceRef),
    STRINGKEY(kCGImagePropertyGPSDestDistance),
    STRINGKEY(kCGImagePropertyGPSProcessingMethod),
    STRINGKEY(kCGImagePropertyGPSAreaInformation),
    STRINGKEY(kCGImagePropertyGPSDateStamp),
    STRINGKEY(kCGImagePropertyGPSDifferental),
    ];
}
@end
