/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "Utility.h"

#import "ImgurUploadOperation.h"

@interface  WebViewController : UIViewController
+ (id) controllerWithURL: (NSURL *) aURL;
@property (nonatomic) NSURL *url;
@end

@implementation WebViewController
+ (id) controllerWithURL: (NSURL *) aURL
{
    WebViewController *wvc = [[WebViewController alloc] init];
    wvc.url = aURL;
    return wvc;
}

- (void) loadView
{
    [super loadView];
    UIWebView *webView = [[UIWebView alloc] init];
    self.view = webView;
    
    if (_url)
    {
        self.title = _url.host;
        NSURLRequest *request = [NSURLRequest requestWithURL:_url];
        [webView loadRequest:request];
    }
}
@end

@interface TestBedViewController : UIViewController <ImgurUploadOperationDelegate>
@end

@implementation TestBedViewController
{
    NSURL *linkURL;
    UITextView *textView;
}

- (void) openLink
{
    if (!linkURL) return;
    WebViewController *wvc = [WebViewController controllerWithURL:linkURL];
    [self.navigationController pushViewController:wvc animated:YES];
}

- (void) handleImgurOperationError: (NSString *) errorMessage
{
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem.enabled = YES;
    
    NSLog(@"%@", errorMessage);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
    [alert show];
}

- (void) finishedImgurOperationWithData: (NSData *) data
{
    self.navigationItem.leftBarButtonItem.enabled = YES;

    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (!json)
    {
        NSLog(@"JSON Error: %@", error.localizedFailureReason);
        return;
    }

    textView.text = json.description;
    
    NSString *errorString = json[@"error"][@"message"];
    if (errorString)
    {
        self.navigationItem.rightBarButtonItem = nil;
        NSLog(@"Site Error: %@", errorString);
    }
    
    NSString *link = json[@"upload"][@"links"][@"imgur_page"];
    if (link)
    {
        linkURL = [NSURL URLWithString:link];
        if (linkURL)
        {
            self.navigationItem.rightBarButtonItem = BARBUTTON(@"Link", @selector(openLink));
            [self openLink];
        }
    }
}

- (void) generateImage
{
    self.navigationItem.leftBarButtonItem.enabled = NO;
    UIImage *image = blockImage(300.0f);
    ImgurUploadOperation *op = [ImgurUploadOperation operationWithDelegate:self andImage:image];
    [op start];
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = BARBUTTON(@"Generate", @selector(generateImage));
    
    textView = [[UITextView alloc] init];
    [self.view addSubview:textView];
    PREPCONSTRAINTS(textView);
    STRETCH_VIEW(self.view, textView);
    
    textView.editable = NO;
    textView.font = [UIFont fontWithName:@"Futura" size:24.0f];
}
@end

#pragma mark -

#pragma mark Application Setup
@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
{
	UIWindow *window;
}
@end
@implementation TestBedAppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{	
    // [application setStatusBarHidden:YES];
    [[UINavigationBar appearance] setTintColor:COOKBOOK_PURPLE_COLOR];
    
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	TestBedViewController *tbvc = [[TestBedViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:tbvc];
    window.rootViewController = nav;
	[window makeKeyAndVisible];
    return YES;
}
@end
int main(int argc, char *argv[]) {
    @autoreleasepool {
        int retVal = UIApplicationMain(argc, argv, nil, @"TestBedAppDelegate");
        return retVal;
    }
}