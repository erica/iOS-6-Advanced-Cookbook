/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import "Geometry-Aspect.h"


CGRect CGRectCenteredInRect(CGRect rect, CGRect mainRect)
{
    CGFloat dx = CGRectGetMidX(mainRect)-CGRectGetMidX(rect);
    CGFloat dy = CGRectGetMidY(mainRect)-CGRectGetMidY(rect);
	return CGRectOffset(rect, dx, dy);
}

CGFloat CGAspectScaleFill(CGSize sourceSize, CGRect destRect)
{
    CGSize destSize = destRect.size;
    CGFloat scaleW = destSize.width / sourceSize.width;
	CGFloat scaleH = destSize.height / sourceSize.height;
    return MAX(scaleW, scaleH);
}

CGFloat CGAspectScaleFit(CGSize sourceSize, CGRect destRect)
{
    CGSize destSize = destRect.size;
    CGFloat scaleW = destSize.width / sourceSize.width;
	CGFloat scaleH = destSize.height / sourceSize.height;
    return MIN(scaleW, scaleH);
}

CGSize CGSizeFitInSize(CGSize sourceSize, CGSize destSize)
{
	CGFloat destScale;
	CGSize newSize = sourceSize;
	
	if (newSize.height && (newSize.height > destSize.height))
	{
		destScale = destSize.height / newSize.height;
		newSize.width *= destScale;
		newSize.height *= destScale;
	}
	
	if (newSize.width && (newSize.width >= destSize.width))
	{
		destScale = destSize.width / newSize.width;
		newSize.width *= destScale;
		newSize.height *= destScale;
	}
	
	return newSize;
}

// Only scales down, not up, and centers result
CGRect CGRectFitSizeInRect(CGSize sourceSize, CGRect destRect)
{
    CGSize destSize = destRect.size;
	CGSize targetSize = CGSizeFitInSize(sourceSize, destSize);
	float dWidth = destSize.width - targetSize.width;
	float dHeight = destSize.height - targetSize.height;
	
	return CGRectMake(dWidth / 2.0f, dHeight / 2.0f, targetSize.width, targetSize.height);
}

CGRect CGRectAspectFitRect(CGSize sourceSize, CGRect destRect)
{
    CGSize destSize = destRect.size;
	CGFloat destScale = CGAspectScaleFit(sourceSize, destRect);
	
	CGFloat newWidth = sourceSize.width * destScale;
	CGFloat newHeight = sourceSize.height * destScale;
	
	float dWidth = ((destSize.width - newWidth) / 2.0f);
	float dHeight = ((destSize.height - newHeight) / 2.0f);
	
    // 	CGRect rect = CGRectMake(destRect.origin.x + dWidth, destRect.origin.y + dHeight, newWidth, newHeight);
	CGRect rect = CGRectMake(dWidth, dHeight, newWidth, newHeight);
	return rect;
}

CGRect CGRectAspectFillRect(CGSize sourceSize, CGRect destRect)
{
    CGSize destSize = destRect.size;
	CGFloat destScale = CGAspectScaleFill(sourceSize, destRect);
	
	CGFloat newWidth = sourceSize.width * destScale;
	CGFloat newHeight = sourceSize.height * destScale;
	
	float dWidth = ((destSize.width - newWidth) / 2.0f);
	float dHeight = ((destSize.height - newHeight) / 2.0f);
	
	CGRect rect = CGRectMake(dWidth, dHeight, newWidth, newHeight);
	return rect;
}
