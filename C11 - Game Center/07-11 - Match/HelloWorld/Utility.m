#import "Utility.h"

void alert(id formatstring, ...)
{
	if (!formatstring) return;
	va_list arglist;
	va_start(arglist, formatstring);
    NSString *outstring = [[NSString alloc] initWithFormat:formatstring arguments:arglist];
	va_end(arglist);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:outstring message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
    [alert show];
}
