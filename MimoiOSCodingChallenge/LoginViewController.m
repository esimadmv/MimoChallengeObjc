//
//  LoginViewController.m
//  MimoiOSCodingChallenge
//
//  Created by Ehsan on 2017-09-23.
//  Copyright © 2017 Mimohello GmbH. All rights reserved.
//

#import "LoginViewController.h"
#import "SettingsViewController.h"


@interface LoginViewController ()

@property (strong, nonatomic) UIView *container;
@property (strong, nonatomic) UITextField *emailField;
@property (strong, nonatomic) UITextField *passwordField;
@property (strong, nonatomic) UITextView *welcome;
@property UIColor *mimoColor;
@property NSString *urlOrigin;
@property Boolean isLoginView;
@property Boolean completed;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _isLoginView = YES; // set YES for login and NO for sign up
    _urlOrigin = @"https://mimo-test.auth0.com";
    self.view.backgroundColor = [UIColor whiteColor];
    _mimoColor = [UIColor colorWithRed:0.0f/255.0f
                                 green:200.0f/255.0f
                                  blue:96.0f/255.0f
                                 alpha:1.0f];
    
    [self setupLogin];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    // Do any additional setup after loading the view.
    
}


- (void)viewDidAppear:(BOOL)animated{
    NSString *email = [[NSUserDefaults standardUserDefaults] stringForKey:@"email"];
    NSString *idToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"id"];
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"accessToken"];
    if(email != nil && idToken != nil && accessToken != nil){
        SettingsViewController *vc = [[SettingsViewController alloc] init];
        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (void)setupLogin {
    CGFloat height = 300;
    _container = [[UIView  alloc] initWithFrame:
                  CGRectMake(0,self.view.bounds.size.height - 300, self.view.bounds.size.width, 300)];
    
    
    _welcome = [[UITextView  alloc] initWithFrame:
                CGRectMake(60,100, self.view.bounds.size.width - 120, 150)];
    _welcome.userInteractionEnabled = NO;
    _welcome.textColor = _mimoColor;
    [_welcome setFont:[UIFont fontWithName:@"Helvetica" size:30]];
    _welcome.textAlignment = NSTextAlignmentCenter;
    _welcome.text = NSLocalizedString(@"WELCOME TO MIMO iOS CHALLENGE", @"Login Page Title");
    [self.view addSubview:_welcome];
    
    UILabel *emailLabel = [[UILabel  alloc] initWithFrame:
                           CGRectMake(60,_container.bounds.size.height - height, _container.bounds.size.width - 120, 20)];
    emailLabel.text = NSLocalizedString(@"Email", @"Email Label");
    emailLabel.textColor = [UIColor lightGrayColor];
    [_container addSubview:emailLabel];
    
    height -= 20;
    _emailField = [[UITextField  alloc] initWithFrame:
                   CGRectMake(60,_container.bounds.size.height - height, _container.bounds.size.width - 120, 44)];
    [_emailField setKeyboardType:UIKeyboardTypeEmailAddress];
    _emailField.delegate = self;
    _emailField.tag = 0;
    [self setupTextField:_emailField];
    
    height -= 54;
    UILabel *passLabel = [[UILabel  alloc] initWithFrame:
                          CGRectMake(60,_container.bounds.size.height - height, _container.bounds.size.width - 120, 20)];
    passLabel.text = NSLocalizedString(@"Password", @"Password Label");
    passLabel.textColor = [UIColor lightGrayColor];
    [_container addSubview:passLabel];
    
    height -= 20;
    _passwordField = [[UITextField  alloc] initWithFrame:
                      CGRectMake(60,_container.bounds.size.height - height, _container.bounds.size.width - 120, 44)];
    _passwordField.tag = 1;
    _passwordField.delegate = self;
    _passwordField.secureTextEntry = YES;
    [self setupTextField:_passwordField];
    
    
    height -= 74;
    UIButton *login = [UIButton buttonWithType:UIButtonTypeCustom];
    if (_isLoginView) {
        [login addTarget:self
                  action:@selector(signinClicked:)
        forControlEvents:UIControlEventTouchUpInside];
        [login setTitle:NSLocalizedString(@"Login", @"Login Button Title") forState:UIControlStateNormal];
    } else  {
        [login addTarget:self
              action:@selector(signupClicked:)
        forControlEvents:UIControlEventTouchUpInside];
        [login setTitle:NSLocalizedString(@"Sign Up", @"Login Button Title") forState:UIControlStateNormal];
    }
    login.backgroundColor = _mimoColor;
    [login setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal ];
    login.layer.cornerRadius = 5;
    login.clipsToBounds = YES;
    login.frame = CGRectMake(60, _container.bounds.size.height - height, _container.bounds.size.width - 120, 44);
    [_container addSubview:login];
    
    [self.view addSubview:_container];
    
    
}

-(void) setupTextField:(UITextField*) textField {
    
    textField.layer.borderWidth = 1;
    textField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    textField.layer.cornerRadius = 5;
    [_container addSubview:textField];
}

-(void) signupClicked:(UIButton*)sender {

    NSString *email = _emailField.text;
    NSString *pass = _passwordField.text;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //Background Thread
        NSString *url = [NSString stringWithFormat:@"%@/dbconnections/signup",_urlOrigin];
        NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        NSString *postData = [NSString stringWithFormat:@"&client_id=%s&username=%@&password=%@&connection=%s&grant_type=%s&scope=%s", "PAn11swGbMAVXVDbSCpnITx5Utsxz1co", email, pass,"Username-Password-Authentication","password","openid profile email"]; //Send the POST Values
        NSLog(@"%@", postData);
        NSString *length = [NSString stringWithFormat:@"%d", [postData length]];
        [urlRequest setValue:length forHTTPHeaderField:@"Content-Length"];
        
        
        NSDictionary *tmp = [[NSDictionary alloc] initWithObjectsAndKeys:
                             @"PAn11swGbMAVXVDbSCpnITx5Utsxz1co", @"client_id",
                             email, @"email",
                             pass, @"password",
                             @"Username-Password-Authentication", @"connection",
                             @"password", @"grant_type",
                             @"openid profile email", @"scope",
                             nil];
        NSError *error;
        NSData *postdata = [NSJSONSerialization dataWithJSONObject:tmp options:0 error:&error];
        [urlRequest setHTTPBody:postdata];
        
        NSData *returnData = [[NSData alloc]init];
        
        returnData = [NSURLConnection sendSynchronousRequest: urlRequest returningResponse: nil error: nil];
        
        //Get the Result of Request
        NSString *response = [[NSString alloc] initWithBytes:[returnData bytes] length:[returnData length] encoding:NSUTF8StringEncoding];
        
        NSLog(@"Response >>>> %@",response);
        NSData *data = [response dataUsingEncoding:NSUTF8StringEncoding];
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        if([json objectForKey:@"error"])
        {
            _completed = NO;
            NSLog(@"Error%@",json);
        }
        else
        {
            _completed = YES;
            
        }

        dispatch_async(dispatch_get_main_queue(), ^(void){
            if (_completed){
                [self loginInBackground];
            } else {
                UIAlertController * alert = [UIAlertController
                                             alertControllerWithTitle:@"Error"
                                             message:@"user already exist"
                                             preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* yesButton = [UIAlertAction
                                            actionWithTitle:@"Ok"
                                            style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                //Handle your yes please button action here
                                            }];
                
                [alert addAction:yesButton];
                [self presentViewController:alert animated:YES completion:nil];
            }

        });
    });
    
}


-(void) signinClicked:(UIButton*)sender
{
    [self loginInBackground];
    
}

-(void) loginInBackground {
    NSString *email = _emailField.text;
    NSString *pass = _passwordField.text;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //Background Thread
        NSString *url = [NSString stringWithFormat:@"%@/oauth/ro",_urlOrigin];
        NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        NSString *postData = [NSString stringWithFormat:@"&client_id=%s&username=%@&password=%@&connection=%s&grant_type=%s&scope=%s", "PAn11swGbMAVXVDbSCpnITx5Utsxz1co", email, pass,"Username-Password-Authentication","password","openid profile email"]; //Send the POST Values
        NSLog(@"%@", postData);
        NSString *length = [NSString stringWithFormat:@"%d", [postData length]];
        [urlRequest setValue:length forHTTPHeaderField:@"Content-Length"];
        
        
        NSDictionary *tmp = [[NSDictionary alloc] initWithObjectsAndKeys:
                             @"PAn11swGbMAVXVDbSCpnITx5Utsxz1co", @"client_id",
                             email, @"username",
                             pass, @"password",
                             @"Username-Password-Authentication", @"connection",
                             @"password", @"grant_type",
                             @"openid profile email", @"scope",
                             nil];
        NSError *error;
        NSData *postdata = [NSJSONSerialization dataWithJSONObject:tmp options:0 error:&error];
        [urlRequest setHTTPBody:postdata];
        NSData *returnData = [[NSData alloc]init];
        
        returnData = [NSURLConnection sendSynchronousRequest: urlRequest returningResponse: nil error: nil];
        
        //Get the Result of Request
        NSString *response = [[NSString alloc] initWithBytes:[returnData bytes] length:[returnData length] encoding:NSUTF8StringEncoding];
        
        NSLog(@"Response >>>> %@",response);
        NSData *data = [response dataUsingEncoding:NSUTF8StringEncoding];
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        if([json objectForKey:@"error"])
        {
            _completed = NO;
            NSLog(@"Error%@",json);
        }
        else
        {
            NSLog(@"The response is - %@",json);
            NSString *accessToken = [json objectForKey:@"access_token"];
            NSString *idToken = [json objectForKey:@"id_token"];
            [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:@"accessToken"];
            [[NSUserDefaults standardUserDefaults] setObject:idToken forKey:@"id"];
            [[NSUserDefaults standardUserDefaults] setObject:email forKey:@"email"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            _completed = YES;
            
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            
            if (_completed){
                _passwordField.text = @"";
                _emailField.text = @"";
                SettingsViewController *vc = [[SettingsViewController alloc] init];
                [self presentViewController:vc animated:YES completion:nil];
            } else {
                UIAlertController * alert = [UIAlertController
                                             alertControllerWithTitle:@"Error"
                                             message:@"wrong username / password"
                                             preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* yesButton = [UIAlertAction
                                            actionWithTitle:@"Ok"
                                            style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                //Handle your yes please button action here
                                            }];
                
                [alert addAction:yesButton];
                [self presentViewController:alert animated:YES completion:nil];
            }
        });
    });
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissKeyboard {
    [[self view] endEditing:TRUE];
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
    NSInteger nextTag = textField.tag + 1;
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        [nextResponder becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return NO; // We do not want UITextField to insert line-breaks.
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    [self.view endEditing:YES];
    return YES;
}

- (void)keyboardDidShow:(NSNotification *)notification
{
    [_container setFrame:CGRectMake(0,50,self.view.bounds.size.width,300)];
    _welcome.hidden = YES;
}

-(void)keyboardDidHide:(NSNotification *)notification
{
    [_container setFrame:CGRectMake(0,self.view.bounds.size.height - 300,self.view.bounds.size.width,300)];
    _welcome.hidden = NO;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
