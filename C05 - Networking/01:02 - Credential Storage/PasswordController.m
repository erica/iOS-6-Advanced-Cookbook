/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import "PasswordController.h"
#import "CredentialHelper.h"
#import "Utility.h"

@interface PasswordBaseController : UIViewController <UITextFieldDelegate>
@property (nonatomic) NSString *host;
@end

@implementation PasswordBaseController
{
    UITextField *userField;
    UITextField *passField;
    CredentialHelper *helper;
}

- (id) initWithHost: (NSString *) hostName
{
    if (self = [super init])
    {
        _host = hostName;
        helper = [CredentialHelper helperWithHost:hostName];
    }
    return self;
}

- (void) listCredentials
{
    // Never log passwords in production code
    NSLog(@"Protection space for %@ has %d credentials:", _host, helper.credentialCount);
    for (NSString *userName in helper.credentials.allKeys)
        NSLog(@"%@: %@", userName, helper[userName]);
}

- (void) storeCredentials
{
    if (!userField.text.length) return;
    [helper storeDefaultCredential:passField.text forKey:userField.text];
    [self listCredentials];
}

- (void) remove
{
    [helper removeCredential:userField.text];
    [self listCredentials];
    
    // Update GUI
    userField.text = @"";
    passField.text = @"";
    UIBarButtonItem *removeButton = self.navigationItem.leftBarButtonItems[1];
    removeButton.enabled = NO;
}

// Finish and store credentials
- (void) done
{
    [self storeCredentials];
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Finish without updating credentials
- (void) cancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Text Edits

// User tapping Done confirms changes. Store credentials
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self done];
    return YES;
}

// Only enable Cancel on edits
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    UIBarButtonItem *cancelButton = self.navigationItem.leftBarButtonItems[0];
    cancelButton.enabled = YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    // Empty the passfield upon a username clear
    if (textField == userField)
        passField.text = @"";
    return YES;
}

// Watch for known usernames during text edits
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField != userField) return YES;
    
    // Initially disable remove until there's a credential match
    UIBarButtonItem *removeButton = self.navigationItem.leftBarButtonItems[1];
    removeButton.enabled = NO;
    
    // Preemptively clear password field until there's a value for it
    passField.text = @"";
    
    // Calculate the target string that will occupy the username field
    NSString *username = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (!username) return YES;
    if (!username.length) return YES;
    
    // Always check if there's a matching password on file
    NSURLCredential *credential = [helper credentialForKey:username];
    if (!credential)
        return YES;
    
    // Match!
    passField.text = credential.password;
    removeButton.enabled = YES;
    
    // Never log passwords in production code!
    NSLog(@"Found match: %@: %@", username, passField.text);
    
    return YES;
}

#pragma mark - Load Defaults

- (void) viewWillAppear:(BOOL)animated
{
    // Disable the cancel button, there are no edits to cancel
    UIBarButtonItem *cancelButton = self.navigationItem.leftBarButtonItems[0];
    cancelButton.enabled = NO;
    
    // Disable the remove button, until a credential has been matched
    UIBarButtonItem *removeButton = self.navigationItem.leftBarButtonItems[1];
    removeButton.enabled = NO;
    
    NSURLCredential *credential = helper.defaultCredential;
    if (credential)
    {
        // Populate the fields
        userField.text = credential.user;
        passField.text = credential.password;
        
        // Enable credential removal
        removeButton.enabled = YES;
    }
}

#pragma mark - Load View

- (UITextField *) textField
{
    UITextField *textField = [[UITextField alloc] init];
    textField.delegate = self;
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.clearButtonMode = UITextFieldViewModeAlways;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    [self.view addSubview:textField];
    PREPCONSTRAINTS(textField);
    CENTER_VIEW_H(self.view, textField);
    
    return textField;
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Done", @selector(done));
    self.navigationItem.leftBarButtonItems =  @[
    BARBUTTON(@"Cancel", @selector(cancel)),
    BARBUTTON(@"Remove", @selector(remove)),
    BARBUTTON(@"List", @selector(listCredentials)),
    ];
    
    userField = [self textField];
    userField.placeholder = @"User Name";
    
    passField = [self textField];
    passField.secureTextEntry = YES;
    passField.placeholder = @"Password";
    
    NSDictionary *bindings = NSDictionaryOfVariableBindings(userField, passField);
    CONSTRAIN_VIEWS(self.view, @"V:|-[userField]-[passField]", bindings);
    CONSTRAIN_VIEWS(self.view, @"H:[userField(==200)]", bindings);
    CONSTRAIN_VIEWS(self.view, @"H:[passField(==200)]", bindings);
}
@end

@implementation PasswordController
+ (id) controllerWithHost: (NSString *) host
{
    PasswordBaseController *base = [[PasswordBaseController alloc] initWithHost:host];
    PasswordController *controller = [[PasswordController alloc] initWithRootViewController:base];
    return controller;
}
@end

