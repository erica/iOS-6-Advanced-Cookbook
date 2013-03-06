/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import "FancyString.h"
#import <CoreText/CoreText.h>

#define MATCHSTART(STRING1, STRING2) ([[STRING1 uppercaseString] hasPrefix:[STRING2 uppercaseString]])

@implementation FancyString
{
    NSMutableArray *stack;
    NSMutableDictionary *top;
}

#pragma mark - Init -

- (id) init
{
    if (!(self = [super init])) return self;
    
    _string = [[NSMutableAttributedString alloc] init];
    stack = [NSMutableArray array];
    top = [NSMutableDictionary dictionary];
    
    _paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    _font = [UIFont fontWithName:@"Helvetica" size:12.0f];
    
    return self;
}

+ (id) string
{
    return [[FancyString alloc] init];
}

#pragma mark - String Building - 

- (void) appendFormat: (NSString  *) formatstring, ...
{
    if (!formatstring) return;
    
	va_list arglist;
	va_start(arglist, formatstring);
	NSString *outString = [[NSString alloc] initWithFormat:formatstring arguments:arglist];
	va_end(arglist);

    // Create a distinct style instance
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.attributes];
    NSMutableParagraphStyle *style = dict[NSParagraphStyleAttributeName];
    dict[NSParagraphStyleAttributeName] = [style copy];
    
	NSAttributedString *newString = [[NSAttributedString alloc] initWithString:outString attributes:dict];
    
	[_string appendAttributedString:newString];
}

- (void) performTransientAttributeBlock: (AttributesBlock) block
{
    [self saveContext];
    block();
    [self popContext];
}

#pragma mark - Attribute Dictionaries -
// Handle bold and italics
- (UIFont *) fontWithTraits
{
    // Core font elements
    NSString *familyName = self.font.familyName;
    CGFloat newFontSize = self.font.pointSize;
    
    // Return core font
    if (!self.bold && !self.italic)
        return [UIFont fontWithName:familyName size:newFontSize];
    
    // Create traits value
    NSUInteger appliedTraits = 0;
    if (self.bold) appliedTraits = kCTFontBoldTrait;
    if (self.italic) appliedTraits = appliedTraits | kCTFontItalicTrait;
    NSNumber *traitsValue = @(appliedTraits);
    
    // Build dictionary from family name and traits
    NSDictionary *traitDictionary = @{(NSString *)kCTFontSymbolicTrait:traitsValue};
    NSDictionary *dict =
    @{
        (NSString *)kCTFontFamilyNameAttribute:familyName,
        (NSString *)kCTFontTraitsAttribute:traitDictionary,
    };
    
    // Extract font descriptor
    CFDictionaryRef dictRef = CFBridgingRetain(dict);
	CTFontDescriptorRef desc = CTFontDescriptorCreateWithAttributes(dictRef);
    CFRelease(dictRef);

    // If this failed, return core font
    if (!desc)
        return [UIFont fontWithName:familyName size:newFontSize];
    
    // Otherwise, extract the new font name e.g. whatever-bold
    CTFontRef ctFont = CTFontCreateWithFontDescriptor(desc, self.font.pointSize, NULL);
    NSString *newFontName = CFBridgingRelease(CTFontCopyName(ctFont, kCTFontPostScriptNameKey));
    
    // Create font with trait-name
    return [UIFont fontWithName:newFontName size:newFontSize];
}

// Omitted: vertical text, kerning, baseline offset
// Not yet supported on iOS
- (NSDictionary *) attributes
{
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    
    // Font and Para Style
    if (!self.ignoreTraits)
        self.font = [self fontWithTraits];
    [attributes setObject:self.font forKey:NSFontAttributeName];
    [attributes setObject:self.paragraphStyle forKey:NSParagraphStyleAttributeName];
    
    // Colors
    if (self.foregroundColor)
        [attributes setObject:self.foregroundColor forKey:NSForegroundColorAttributeName];
    if (self.backgroundColor)
        [attributes setObject:self.backgroundColor forKey:NSBackgroundColorAttributeName];
    if (self.strokeColor)
        [attributes setObject:self.strokeColor forKey:NSStrokeColorAttributeName];
    
    // Other Styles
    [attributes setObject:@(self.strokeWidth) forKey:NSStrokeWidthAttributeName];
    [attributes setObject:@(self.underline) forKey:NSUnderlineStyleAttributeName];
    [attributes setObject:@(self.strikethrough) forKey:NSStrikethroughStyleAttributeName];
    if (self.shadow)
        [attributes setObject:self.shadow forKey:NSShadowAttributeName];
    [attributes setObject:@(self.useLigatures) forKey:NSLigatureAttributeName];

    return attributes;
}

- (void) setAttributesFromDictionary: (NSDictionary *) dictionary
{

    // Update active properties
    _paragraphStyle = dictionary[NSParagraphStyleAttributeName];
    
    // Establish font
    _font = dictionary[NSFontAttributeName];
    CTFontSymbolicTraits traits = CTFontGetSymbolicTraits((__bridge CTFontRef)(self.font));
    self.bold = (traits & kCTFontBoldTrait) != 0;
    self.italic = (traits & kCTFontItalicTrait) != 0;    

    // Colors
    _foregroundColor = dictionary[NSForegroundColorAttributeName];
    _backgroundColor = dictionary[NSBackgroundColorAttributeName];
    _strokeColor = dictionary[NSStrokeColorAttributeName];
    
    // Other
    _strokeWidth = ((NSNumber *)dictionary[NSStrokeWidthAttributeName]).floatValue;
    _underline = ((NSNumber *)dictionary[NSUnderlineStyleAttributeName]).boolValue;
    _strikethrough = ((NSNumber *)dictionary[NSStrikethroughStyleAttributeName]).boolValue;
    _useLigatures = ((NSNumber *)dictionary[NSLigatureAttributeName]).boolValue;    
    _shadow = dictionary[NSShadowAttributeName];
}

#pragma mark - Stack Operations -

- (void) saveContext
{
    [stack addObject:self.attributes];
    top = [NSMutableDictionary dictionaryWithDictionary:top];
    
    // Create a copy of the style, to point to a distinct object
    _paragraphStyle = [_paragraphStyle mutableCopy];
    top[NSParagraphStyleAttributeName] = _paragraphStyle;
}

- (void) pushReset
{
    [stack addObject:top];
    top = [NSMutableDictionary dictionary];
    _paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    _font = [UIFont fontWithName:@"Helvetica" size:12.0f];
}

- (BOOL) popContext
{
    if (!stack.count) return NO;
    
    // Pop it
    top = [stack lastObject];
    [stack removeLastObject];
    [self setAttributesFromDictionary:top];
    
    return (stack.count > 0);
}

- (BOOL) isEmpty
{
    return (stack.count == 0);
}

#pragma mark - Utility -

- (void) setAlignment: (NSString *) theAlignment
{
	if (!theAlignment)
        self.paragraphStyle.alignment = NSTextAlignmentNatural;
    else if (MATCHSTART(theAlignment, @"n"))
        self.paragraphStyle.alignment = NSTextAlignmentNatural;
	else if (MATCHSTART(theAlignment, @"l"))
        self.paragraphStyle.alignment =  NSTextAlignmentLeft;
	else if (MATCHSTART(theAlignment, @"c"))
        self.paragraphStyle.alignment =  NSTextAlignmentCenter;
    else if (MATCHSTART(theAlignment, @"r"))
        self.paragraphStyle.alignment =  NSTextAlignmentRight;
	else if (MATCHSTART(theAlignment, @"j"))
        self.paragraphStyle.alignment =  NSTextAlignmentJustified;
}

- (void) setBreakMode: (NSString *) theBreakMode
{
	if (!theBreakMode)
        self.paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
	else if (MATCHSTART(theBreakMode, @"word"))
        self.paragraphStyle.lineBreakMode =  NSLineBreakByWordWrapping;
	else if (MATCHSTART(theBreakMode, @"char"))
        self.paragraphStyle.lineBreakMode =  NSLineBreakByCharWrapping;
	else if (MATCHSTART(theBreakMode, @"clip"))
        self.paragraphStyle.lineBreakMode =  NSLineBreakByClipping;
	else if (MATCHSTART(theBreakMode, @"head"))
        self.paragraphStyle.lineBreakMode =  NSLineBreakByTruncatingHead;
	else if (MATCHSTART(theBreakMode, @"tail"))
        self.paragraphStyle.lineBreakMode =  NSLineBreakByTruncatingTail;
	else if (MATCHSTART(theBreakMode, @"mid"))
        self.paragraphStyle.lineBreakMode =  NSLineBreakByTruncatingMiddle;
}
@end
