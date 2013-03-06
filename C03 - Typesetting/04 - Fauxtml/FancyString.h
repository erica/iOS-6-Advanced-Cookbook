/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>
typedef void (^AttributesBlock)(void);

@interface FancyString : NSObject
+ (id) string; // new instance

// Attributes
@property (nonatomic, readonly) NSMutableAttributedString *string;
@property (nonatomic, readonly) NSDictionary *attributes;
- (void) setAttributesFromDictionary: (NSDictionary *) dictionary;

@property (nonatomic) BOOL ignoreTraits;

// Access
- (void) appendFormat: (NSString  *) formatstring, ...;
- (void) performTransientAttributeBlock: (AttributesBlock) block; // Thanks Charles Choi

// Clients access paragraph style properties directly
@property (nonatomic, readonly) NSMutableParagraphStyle *paragraphStyle;
- (void) setAlignment: (NSString *) theAlignment;
- (void) setBreakMode: (NSString *) theBreakMode;

// Client-controlled properties
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *foregroundColor;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIColor *strokeColor;

@property (nonatomic) CGFloat strokeWidth;
@property (nonatomic) BOOL useLigatures;
@property (nonatomic) NSShadow *shadow;

@property (nonatomic) BOOL strikethrough;
@property (nonatomic) BOOL underline;
@property (nonatomic) BOOL bold;
@property (nonatomic) BOOL italic;

- (void) saveContext;
- (BOOL) popContext;
@end
