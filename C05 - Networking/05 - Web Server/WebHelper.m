/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.0 Edition
 BSD License, Use at your own risk
 */

#import "WebHelper.h"
#import "UIDevice-Reachability.h"

#define SAFE_PERFORM_WITH_ARG(THE_OBJECT, THE_SELECTOR, THE_ARG) (([THE_OBJECT respondsToSelector:THE_SELECTOR]) ? [THE_OBJECT performSelectorOnMainThread:THE_SELECTOR withObject:THE_ARG waitUntilDone:NO] : nil)

// Simple Alert Utility
void showAlert(id formatstring,...)
{
	if (!formatstring) return;

	va_list arglist;
	va_start(arglist, formatstring);
	id outstring = [[NSString alloc] initWithFormat:formatstring arguments:arglist];
	va_end(arglist);
	
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:outstring message:nil delegate:nil cancelButtonTitle:@"OK"otherButtonTitles:nil];
	[av show];
}

@implementation WebHelper
- (NSString *) getRequest: (int) fd
{
	static char buffer[BUFSIZE+1];
	int len = read(fd, buffer, BUFSIZE); 	
	buffer[len] = '\0';
	return [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
}

- (void) handleWebRequest: (int) fd
{
    if (!_delegate) return;
    if (![_delegate respondsToSelector:@selector(image)]) return;
    UIImage *image = (UIImage *)[_delegate performSelector:@selector(image)];
    if (!image) return;
    
    NSString *outcontent = [NSString stringWithFormat:@"HTTP/1.0 200 OK\r\nContent-Type: image/jpeg\r\n\r\n"];
    write (fd, [outcontent UTF8String], outcontent.length);
    NSData *data = UIImageJPEGRepresentation(image, 0.75f);
    write (fd, data.bytes, data.length);
    close(fd);    
}

// Listen for external requests
- (void) listenForRequests
{
    @autoreleasepool {
        static struct sockaddr_in cli_addr; 
        socklen_t length = sizeof(cli_addr);
        
        while (1 > 0) {
            if (!_isServing) return;

            if ((socketfd = accept(listenfd, (struct sockaddr *)&cli_addr, &length)) < 0)
            {
                _isServing = NO;
                [[NSOperationQueue mainQueue] addOperationWithBlock:^(){
                    SAFE_PERFORM_WITH_ARG(_delegate, @selector(serviceWasLost), nil);                    
                }];
                return;
            }
            
            [self handleWebRequest:socketfd];
        }
    }
}

// Begin serving data -- this is a private method called by startService
- (void) startServer
{
	static struct	sockaddr_in serv_addr;
	
	// Set up socket
	if((listenfd = socket(AF_INET, SOCK_STREAM,0)) < 0)	
	{
		_isServing = NO;
		SAFE_PERFORM_WITH_ARG(_delegate, @selector(serviceCouldNotBeEstablished), nil);
		return;
	}
	
    // Serve to a random port
	serv_addr.sin_family = AF_INET;
	serv_addr.sin_addr.s_addr = htonl(INADDR_ANY);
	serv_addr.sin_port = 0;
	
	// Bind
	if(bind(listenfd, (struct sockaddr *)&serv_addr,sizeof(serv_addr)) <0)	
	{
		_isServing = NO;
        SAFE_PERFORM_WITH_ARG(_delegate, @selector(serviceCouldNotBeEstablished), nil);
		return;
	}
	
	// Find out what port number was chosen.
	int namelen = sizeof(serv_addr);
	if (getsockname(listenfd, (struct sockaddr *)&serv_addr, (void *) &namelen) < 0) {
		close(listenfd);
		_isServing = NO;
        SAFE_PERFORM_WITH_ARG(_delegate, @selector(serviceCouldNotBeEstablished), nil);
		return;
	}
	
	_activePort = ntohs(serv_addr.sin_port);
	
	// Listen
	if(listen(listenfd, 64) < 0)	
	{
		_isServing = NO;
        SAFE_PERFORM_WITH_ARG(_delegate, @selector(serviceCouldNotBeEstablished), nil);
		return;
	} 
	
    _isServing = YES;
    [NSThread detachNewThreadSelector:@selector(listenForRequests) toTarget:self withObject:NULL];
    SAFE_PERFORM_WITH_ARG(_delegate, @selector(serviceWasEstablished:), self);
}

- (void) stopService
{
    printf("Shutting down service\n");
    _isServing = NO;
    close(listenfd);
    SAFE_PERFORM_WITH_ARG(_delegate, @selector(serviceDidEnd), nil);
}

+ (id) serviceWithDelegate:(id)delegate
{
	if (![[UIDevice currentDevice] networkAvailable])
	{
		showAlert(@"You are not connected to the network. Please do so before running this application.");
		return nil;
	}
    
    WebHelper *helper = [[WebHelper alloc] init];
    helper.delegate = delegate ;
    [helper startServer];
    return helper;
}	
@end
