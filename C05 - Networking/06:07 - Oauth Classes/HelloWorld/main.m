/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "Utility.h"
#import "CredentialHelper.h"
#import "OAuthHelper.h"
#import "NSData+Base64.h"

// Please use your own keys. These are my keys.
// #import "/Volumes/MusicAndData/Book Writing/66-6.0 Sample Code/API_Keys.h"

#error Define your own API Keys here
#define IMGUR_CONSUMER  @"Undefined"
#define IMGUR_SECRET    @"Undefined"

#define HOST @"imgur.com"

#define REQUEST_ENDPOINT    @"https://api.imgur.com/oauth/request_token"
#define AUTHORIZE_ENDPOINT  @"https://api.imgur.com/oauth/authorize"
#define ACCESS_ENDPOINT     @"https://api.imgur.com/oauth/access_token"


/*
 
 This is a little imgur-specific web view controller implementation
 for user authorization and retrieving an oauth_verifier code
 
 */

#pragma mark - Imgur web view controller

#define WEBVIEW_NOTIFICATION    @"ClosedAuthorizationWebView"

@interface  ImgurWebViewControllerBase : UIViewController <UIWebViewDelegate>
+ (id) controllerWithURL: (NSURL *) aURL;
@property (nonatomic) NSURL *url;
@end

@implementation ImgurWebViewControllerBase
{
    UIWebView *webView;
}

+ (id) controllerWithURL: (NSURL *) aURL
{
    ImgurWebViewControllerBase *wvc = [[ImgurWebViewControllerBase alloc] init];
    wvc.url = aURL;
    return wvc;
}

// Send an alert whenever the controller closes
- (void) close
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSNotification *notification = [NSNotification notificationWithName:WEBVIEW_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

// Scan for the validation code
- (NSString *) scanForCode: (NSString *) line
{
    NSMutableArray *content = [NSMutableArray array];
    
    NSScanner *scanner = [NSScanner scannerWithString:line];
    NSString *contentText = nil;
    NSString *tagText = nil;
    
    while (scanner.scanLocation < line.length)
    {
        [scanner scanUpToString:@"<" intoString:&contentText];
        [scanner scanUpToString:@">" intoString:&tagText];
        if (scanner.scanLocation < line.length)
            scanner.scanLocation += 1;
        [content addObject:contentText];
    }
    
    if (content.count > 2)
        return content[1];
    else
        return nil;
}

// Look for the "Your verification code is" pattern that imgur provides
- (void)webViewDidFinishLoad: (UIWebView *)aWebView
{
    NSString *string = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('content').innerHTML;"];
    
    NSString *searchString = @"Your verification code is";
    if ([string rangeOfString:searchString].location == NSNotFound)
        return;
    
    NSArray *lines = [string componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    for (NSString *line in lines)
    {
        if ([line rangeOfString:searchString].location == NSNotFound)
            continue;
        NSString *code = [self scanForCode:line];
        if (code)
        {
            CredentialHelper *helper = [CredentialHelper helperWithHost:HOST];
            [helper storeCredential:code forKey:@"oauth_verifier"];
        }
    }
    
    [self close]; // uncomment to allow auto-close when detected
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
        [webView loadRequest:request];
    }
    
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Close", @selector(close));
}
@end

@interface ImgurWebViewController : UINavigationController
@end

@implementation ImgurWebViewController
+ (id) controllerWithURL: (NSURL *) url
{
    ImgurWebViewControllerBase *base = [ImgurWebViewControllerBase controllerWithURL:url];
    if (!base) return nil;
    
    ImgurWebViewController *wvc = [[ImgurWebViewController alloc] initWithRootViewController:base];
    return wvc;
}
@end

#pragma mark - Test bed

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
{
    OAuthHelper *oauthHelper;
    CredentialHelper *credentialHelper;
}

- (void) processData: (NSData *) data
{
    if (!data)
    {
        NSLog(@"Error. No data returned from request.");
        return;
    }
    
    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (!dict)
    {
        NSLog(@"Error creating JSON: %@", error.localizedFailureReason);
        return;
    }
    
    NSLog(@"Results: %@", dict);
}

- (void) getStats
{
    NSData *data = [oauthHelper performGetRequest:@"http://api.imgur.com/2/stats.json"];
    [self processData:data];
}

- (void) accountInfo
{
    NSData *data = [oauthHelper performGetRequest:@"http://api.imgur.com/2/account.json"];
    [self processData:data];
}

- (void) imagesInAccount
{
    NSData *data = [oauthHelper performGetRequest:@"http://api.imgur.com/2/account/images.json"];
    [self processData:data];
}
//
- (void) test
{
    // There is no output to the screen. Check your console instead.
    [self getStats];
    [self accountInfo];
    [self imagesInAccount];
}

- (void) authenticate
{
    // Step 0. Clean up any old items
    [oauthHelper cleanUpVerifier];
    
    // Step 1. Request Tokens
    [oauthHelper requestTokens:REQUEST_ENDPOINT];
    
    // Step 2. Check that the oauth_token arrived
    NSString *token = credentialHelper[@"oauth_token"];
    if (!token)
    {
        NSLog(@"No token to authenticate with. Request tokens first");
        return;
    }
    
    // Step 3. Request User Access    
    NSString *requestString = [NSString stringWithFormat:@"%@?oauth_token=%@", AUTHORIZE_ENDPOINT, token];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(continueAuthentication) name:WEBVIEW_NOTIFICATION object:nil];
    ImgurWebViewController *wvc = [ImgurWebViewController controllerWithURL:[NSURL URLWithString:requestString]];
    [self presentViewController:wvc animated:YES completion:nil];
}

- (void) continueAuthentication
{
    // Step 4. Retrieve Access Token
    NSString *accessToken = credentialHelper[@"oauth_verifier"];
    if (!accessToken)
    {
        NSLog(@"User did not create an access token. App is not authorized.");
        return;
    }
    
    // Step 5. Authenticate with Access Token
    BOOL success = [oauthHelper authenticate:ACCESS_ENDPOINT];
    if (success)
        self.navigationItem.rightBarButtonItem = BARBUTTON(@"Test", @selector(test));
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    oauthHelper = [OAuthHelper helperWithHost:HOST];
    oauthHelper.consumerKey = IMGUR_CONSUMER;
    oauthHelper.consumerSecret = IMGUR_SECRET;

    credentialHelper = [CredentialHelper helperWithHost:HOST];
    self.navigationItem.leftBarButtonItem = BARBUTTON(@"Authenticate", @selector(authenticate));
    
    if (credentialHelper[@"authenticated"])
        self.navigationItem.rightBarButtonItem = BARBUTTON(@"Test", @selector(test));
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