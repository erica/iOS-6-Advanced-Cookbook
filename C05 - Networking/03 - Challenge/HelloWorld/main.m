/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "Utility.h"

@interface  WebViewController : UIViewController <UIWebViewDelegate>
+ (id) controllerWithURL: (NSURL *) aURL;
@property (nonatomic) NSURL *url;
@property (nonatomic) BOOL shouldFail;
@end

@implementation WebViewController
{
    NSURLConnection *connection;
    UIWebView *webView;
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSString *source = DATASTR(data);
    [webView loadHTMLString:source baseURL:_url];
    
    // Force clean the cache -- so you can "fail" after success
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (void)connection:(NSURLConnection *) connection willSendRequestForAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge
{
    if (!challenge.previousFailureCount)
    {
        // Build a one-time use credential
        NSURLCredential *credential = [NSURLCredential credentialWithUser:@"PrivateAccess" password:_shouldFail ? @"foo" : @"tuR7!mZ#eh" persistence:NSURLCredentialPersistenceNone];
        [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
    }
    else
    {
        // Stop challenge after first failure
        [challenge.sender cancelAuthenticationChallenge:challenge];
        [webView loadHTMLString:@"<h1>Failed</h1>" baseURL:nil];
    }
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection;
{
    NSLog(@"Being queried about credential storage. Saying no.");
    return NO;
}

+ (id) controllerWithURL: (NSURL *) aURL
{
    WebViewController *wvc = [[WebViewController alloc] init];
    wvc.url = aURL;
    return wvc;
}

- (void) loadView
{
    [super loadView];
    webView = [[UIWebView alloc] init];
    webView.delegate = self;
    self.view = webView;
    
    if (_url)
    {
        self.title = _url.host;
        NSURLRequest *request = [NSURLRequest requestWithURL:_url];
        connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
}
@end


@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
- (void) auth
{
    // Load the web view
    NSURL *url = [NSURL URLWithString:@"http://ericasadun.com/Private"];
    WebViewController *wvc = [WebViewController controllerWithURL:url];
    wvc.shouldFail = NO;
    [self.navigationController pushViewController:wvc animated:YES];
}

- (void) fail
{
    // Load the web view
    NSURL *url = [NSURL URLWithString:@"http://ericasadun.com/Private"];
    WebViewController *wvc = [WebViewController controllerWithURL:url];
    wvc.shouldFail = YES;
    [self.navigationController pushViewController:wvc animated:YES];
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItems = @[
    BARBUTTON(@"Auth", @selector(auth)),
    BARBUTTON(@"Fail", @selector(fail)),
    ];
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