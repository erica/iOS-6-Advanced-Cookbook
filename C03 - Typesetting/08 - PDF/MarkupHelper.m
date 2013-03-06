/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import "MarkupHelper.h"
#import "FancyString.h"

#define BASE_TEXT_SIZE	24.0f
#define STRMATCH(STRING1, STRING2) ([[STRING1 uppercaseString] rangeOfString:[STRING2 uppercaseString]].location != NSNotFound)

@implementation MarkupHelper
+ (NSAttributedString *) stringFromMarkup: (NSString *) aString
{
    // Core Fonts
    UIFont *baseFont = [UIFont fontWithName:@"Futura" size:14.0f];
    UIFont *headerFont = [UIFont fontWithName:@"Futura" size:14.0f];
    
	// Prepare to scan
	NSScanner *scanner = [NSScanner scannerWithString:aString];
	[scanner setCharactersToBeSkipped:[NSCharacterSet newlineCharacterSet]];
    
	// Initialize a string helper
    FancyString *string = [FancyString string];
    
    string.paragraphStyle.firstLineHeadIndent = 4.0f;
    string.paragraphStyle.headIndent = 4.0f;
    string.paragraphStyle.tailIndent = -4.0f;
    string.font = baseFont;

	while (scanner.scanLocation < aString.length)
	{
		NSString *contentText = nil; // scan to tag
		[scanner scanUpToString:@"<" intoString:&contentText];

        // Process entities and append
        contentText = [contentText stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
        if (contentText)
            [string appendFormat:@"%@", contentText];
		
		// Scan for the next tag
		NSString *tagText = nil;
        [scanner scanUpToString:@">" intoString:&tagText];
        if (scanner.scanLocation < aString.length)
            scanner.scanLocation += 1;
        tagText = [tagText stringByAppendingString:@">"];
		
		// -- PROCESS TAGS -- 
		
		// Header Tags
		if (STRMATCH(tagText, @"</h")) // finish any headline
		{
            [string popContext];
			[string appendFormat:@"\n"];
            continue;
		}

        if (STRMATCH(tagText, @"<h"))
        {
            int hlevel = 0;
            if (STRMATCH(tagText, @"<h1>")) hlevel = 1;
            else if (STRMATCH(tagText, @"<h2>")) hlevel = 2;
            else if (STRMATCH(tagText, @"<h3>")) hlevel = 3;
            
            [string performTransientAttributeBlock:^(){
                // add a wee spacer
                string.font = [UIFont boldSystemFontOfSize:8.0f];
                [string appendFormat:@"\n"];
            }];
            
            [string saveContext];
            string.bold = YES;
            string.font = [UIFont fontWithName:headerFont.fontName size:20.0f + MAX(0, (4 - hlevel)) * 4.0f];
        }

        // Bold and Italics
        if (STRMATCH(tagText, @"<b>")) string.bold = YES;
        if (STRMATCH(tagText, @"</b>")) string.bold = NO;
        if (STRMATCH(tagText, @"<i>")) string.italic = YES;
        if (STRMATCH(tagText, @"</i>")) string.italic = NO;
        
        // Paragraph and line break tags
		if (STRMATCH(tagText, @"<br")) [string appendFormat:@"\n"];
        if (STRMATCH(tagText, @"</p")) [string appendFormat:@"\n\n"];
        
        // Color
        if (STRMATCH(tagText, @"<color"))
        {
            if STRMATCH(tagText, @"blue")
                string.foregroundColor = [UIColor blueColor];
            if STRMATCH(tagText, @"red")
                string.foregroundColor = [UIColor redColor];
            if STRMATCH(tagText, @"green")
                string.foregroundColor = [UIColor greenColor];
        }
        if (STRMATCH(tagText, @"</color>"))
            string.foregroundColor = nil;
		
        // Size
		if (STRMATCH(tagText, @"<size"))
		{
			// Scan the value for the new font size
			NSScanner *newScanner = [NSScanner scannerWithString:tagText];
			NSCharacterSet *cs = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
			[newScanner setCharactersToBeSkipped:cs];

            CGFloat fontSize;
			[newScanner scanFloat:&fontSize];
            [string saveContext];
            string.font = [UIFont fontWithName:string.font.fontName size:fontSize];
		}
        if (STRMATCH(tagText, @"</size>"))
            [string popContext];
 	}
    
    return string.string;
}

@end
