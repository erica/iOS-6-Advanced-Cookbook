/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "Utility.h"
#import <StoreKit/StoreKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "NSData-Base64.h"

#define PRODUCT_ID	@"com.sadun.moo.baaa"
#define SANDBOX	YES

@interface TestBedViewController : UIViewController  <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@end

@implementation TestBedViewController
{
    UIImageView *imageView;
    SystemSoundID moosound;
    SystemSoundID baasound;
    SystemSoundID adultsound;
    NSUInteger lastOrientation;
    BOOL subsequentSound;
    
    BOOL hasBaa;
    UIButton *purchaseButton;
    NSTimer *dismissalTimer;
    SKProduct *product;
    
    UIGestureRecognizer *longPressRecognizer;
}

#pragma mark - Payments
- (void) restorePurchases
{
	[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
{
    // NSLog(@"Removed transactions: %@", transactions);
}

- (void) checkReceipt: (SKPaymentTransaction *) transaction
{
    NSLog(@"Checking receipt data");
    NSString *receiptData = [transaction.transactionReceipt base64Encoding];
    NSDictionary *dictionary = @{@"receipt-data": receiptData};
    NSData *json = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
    if (!json)
    {
        NSLog(@"Error creating the JSON representation for the transaction receipt");
        return;
    }
    
    // Select target
	NSString *urlsting = SANDBOX ? @"https://sandbox.itunes.apple.com/verifyReceipt" : @"https://buy.itunes.apple.com/verifyReceipt";
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: urlsting]];
	if (!urlRequest)
    {
        NSLog(@"Error creating the URL request");
        return;
    }
	
	[urlRequest setHTTPMethod: @"POST"];
	[urlRequest setHTTPBody:json];
	
	NSError *error;
	NSURLResponse *response;
	NSData *result = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
	
	NSString *resultString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
    NSLog(@"Receipt Validation: %@", resultString);
}

- (void) completedPurchaseTransaction: (SKPaymentTransaction *) transaction
{
    NSArray *states = @[@"Purchasing", @"Purchased", @"Failed", @"Restored"];
    NSLog(@"Completed Purchase Transaction: %@", states[transaction.transactionState]);
    
    // PERFORM THE SUCCESS ACTION THAT UNLOCKS THE FEATURE HERE
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"baa"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    hasBaa = YES;
    
    // Update GUI accordingly
    if (purchaseButton)
    {
        [purchaseButton removeFromSuperview];
        purchaseButton = nil;
    }
    
    // Purchase success
    longPressRecognizer.enabled = NO;
    
    // Baaaaaa!
    AudioServicesPlaySystemSound(baasound);
    
    // Finish transaction
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    UIAlertView *okay = [[UIAlertView alloc] initWithTitle:@"Thank you for your purchase!" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [okay show];
    [self checkReceipt:transaction];
}

- (void) handleFailedTransaction: (SKPaymentTransaction *) transaction
{
    NSArray *states = @[@"Purchasing", @"Purchased", @"Failed", @"Restored"];
    NSLog(@"Failed transaction: %@", states[transaction.transactionState]);

    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        UIAlertView *okay = [[UIAlertView alloc] initWithTitle:@"Transaction Error. Please try again later." message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [okay show];
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
    // Restore the GUI
    longPressRecognizer.enabled = YES;
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
            case SKPaymentTransactionStateRestored:
                [self completedPurchaseTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self handleFailedTransaction:transaction];
                break;
            case SKPaymentTransactionStatePurchasing:
                [self restorePurchases];
                break;
            default: break;
        }
    }
}

#pragma mark - Product Info
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Error: Could not contact App Store properly: %@", error.localizedFailureReason);
}

- (void)requestDidFinish:(SKRequest *)request
{
    NSLog(@"Request finished");
}

- (void) alertView: (UIAlertView *) alertView clickedButtonAtIndex: (NSInteger)answer
{
    longPressRecognizer.enabled = NO; // mess with the GUI as you like
    
    NSLog(@"User %@ buy", answer ? @"will" : @"will not");
    if (!answer) return;
    
    // Ready to purchase
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
	// Find a product
	product = [[response products] lastObject];
	if (!product)
	{
        NSLog(@"Error: Could not find matching products...");
        longPressRecognizer.enabled = YES;
		return;
	}
	
	// Retrieve the localized price
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[numberFormatter setLocale:product.priceLocale];
	NSString *priceString = [numberFormatter stringFromNumber:product.price];
    
	// Show the information
    NSLog(@"About to ask user to purchase");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:product.localizedTitle message:product.localizedDescription delegate:self cancelButtonTitle:@"No Thanks" otherButtonTitles:priceString, nil];
    [alert show];
}

#pragma mark - IAP
- (void) purchaseBaa: (UIButton *) button
{
    
    if (hasBaa)
    {
        longPressRecognizer.enabled = NO;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Already purchased!" message:@"You already bought baa!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
        [alert show];
        return;
    }
    
    // Tapped purchase. Get rid of timer.
    [dismissalTimer invalidate];
    dismissalTimer = nil;
    button.enabled = NO;
    
    longPressRecognizer.enabled = NO;
    
    AudioServicesPlaySystemSound(adultsound);
    
    [UIView animateWithDuration:0.3f animations:^() {
        button.alpha = 0.0f;
    }];
    
    // Begin purchase process
    SKProductsRequest *productRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:PRODUCT_ID]];
	productRequest.delegate = self;
	[productRequest start];
}

- (void) hidePurchaseButton: (NSTimer *) timer
{
    dismissalTimer = nil;
    [UIView animateWithDuration:0.3f animations:^(){
        purchaseButton.alpha = 0.0f;
        purchaseButton.enabled = NO;
    }];
}

- (void) revealPurchaseButton: (UIGestureRecognizer *) uigr
{
    if (dismissalTimer)
        [dismissalTimer invalidate];
    dismissalTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(hidePurchaseButton:) userInfo:nil repeats:NO];
    
    purchaseButton.enabled = YES;
    [UIView animateWithDuration:0.3f animations:^()
    {
        purchaseButton.alpha = 1.0f;
    }];
}

#pragma mark - Moo
- (void) moo
{
    // If first sound or no upgrade, always play moo
    if (!subsequentSound || !hasBaa)
    {
        AudioServicesPlaySystemSound(moosound);
        subsequentSound = YES;
        return;
    }
    
    // Upgraded audio available
    BOOL baa = ((random() % 10) == 0); // 10% chance - you have to work for it
    AudioServicesPlaySystemSound(baa ? baasound : moosound);
}

#pragma mark - Setup

- (void) loadView
{
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];

    srandom(time(0));
    lastOrientation = 999;
    hasBaa = [[NSUserDefaults standardUserDefaults] boolForKey:@"baa"];
    
    NSString *sndpath;
    
    // One Second
    sndpath = [[NSBundle mainBundle] pathForResource:@"Adult" ofType:@"wav"];
    if (sndpath)
        AudioServicesCreateSystemSoundID ((__bridge CFURLRef)[NSURL fileURLWithPath:sndpath], &adultsound);
    
    // Moo
    sndpath = [[NSBundle mainBundle] pathForResource:@"Moo" ofType:@"wav"];
    if (sndpath)
        AudioServicesCreateSystemSoundID ((__bridge CFURLRef)[NSURL fileURLWithPath:sndpath], &moosound);
    
    // Baa -- Only load if purchased
    sndpath = [[NSBundle mainBundle] pathForResource:@"Baah" ofType:@"wav"];
    if (sndpath)
        AudioServicesCreateSystemSoundID ((__bridge CFURLRef)[NSURL fileURLWithPath:sndpath], &baasound);
    
    // La la la. (Cite: Boynton. http://www.amazon.com/Moo-Baa-Sandra-Boynton/dp/067144901X )
    TestBedViewController __weak *weakself = self;    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceOrientationDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification)
     {
         NSUInteger orientation = [UIDevice currentDevice].orientation;
         if ((orientation == UIDeviceOrientationFaceDown) || (orientation == UIDeviceOrientationFaceUp))
         {
             if (lastOrientation == 999)
             {
                 lastOrientation = orientation;
                 return;
             }
             
             if (lastOrientation == orientation) return;
             
             lastOrientation = orientation;
             [weakself moo];
         }
     }];
    
    imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Moo.png"]];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.userInteractionEnabled = YES;
    [self.view addSubview:imageView];
    
    PREPCONSTRAINTS(imageView);
    STRETCH_VIEW(self.view, imageView);
    
    purchaseButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [purchaseButton setTitle:@"Buy a Baa!" forState:UIControlStateNormal];
    CALLBACK_PRESS(purchaseButton, @selector(purchaseBaa:));
    purchaseButton.titleLabel.font = [UIFont fontWithName:@"Futura" size: IS_IPHONE ? 14.0f : 36.0f];
    purchaseButton.frame = CGRectMake(0.0f, 0.0f, IS_IPHONE ? 200.0f : 400.0f, IS_IPHONE ? 40.0f : 60.0f);
    purchaseButton.backgroundColor = [UIColor clearColor];
    purchaseButton.alpha = 0.0f;
    purchaseButton.enabled = NO;
    [imageView addSubview:purchaseButton];
    
    PREPCONSTRAINTS(purchaseButton);
    CENTER_VIEW(imageView, purchaseButton);
    
    longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(revealPurchaseButton:)];
    [imageView addGestureRecognizer:longPressRecognizer];
    
    longPressRecognizer.enabled = !hasBaa;
    
    /* if (!hasBaa)
        [self restorePurchases]; */
}

- (void) dealloc
{
	if (moosound) AudioServicesDisposeSystemSoundID(moosound);
    if (baasound) AudioServicesDisposeSystemSoundID(baasound);
    if (adultsound) AudioServicesDisposeSystemSoundID(adultsound);
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