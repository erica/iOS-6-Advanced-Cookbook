/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import "NSAttributedString-Rendered.h"

@implementation NSAttributedString (Rendered)
- (NSAttributedString *) versionWithoutNewLines
{
    NSMutableAttributedString *newString = [[NSMutableAttributedString alloc] initWithAttributedString:self];
    
    NSString *baseString = newString.string;
    baseString = [baseString stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    
    for (int loc = 0; loc < baseString.length; loc++)
    {
        NSRange range = NSMakeRange(loc, 1);
        NSString *substring = [baseString substringWithRange:range];
        [newString replaceCharactersInRange:range withString:substring];
    }
    
    return newString;
}

- (CGSize) renderedSize
{
    CGRect bounding = [self boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:0 context:nil];
    return bounding.size;
}

- (CGFloat) renderedWidth
{
    return self.renderedSize.width;
}

- (CGFloat) renderedHeight
{
    return self.renderedSize.height;
}

@end
