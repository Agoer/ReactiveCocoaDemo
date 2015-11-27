//
//  ViewController.m
//  ReactiveCocoaDemo
//
//  Created by chanli on 15/11/27.
//  Copyright © 2015年 aotumanlady Inc. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface ViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userTextField;

@property (weak, nonatomic) IBOutlet UITextField *pswTextfield;

@property (weak, nonatomic) IBOutlet UIButton *signinButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //监听输入
    [self.userTextField.rac_textSignal subscribeNext:^(id word){
        NSLog(@"%@",word);
    }];

    RACSignal *usernameSourceSignal =  self.userTextField.rac_textSignal;
    
    RACSignal *filteredUsername = [usernameSourceSignal filter:^BOOL(id value) {
        NSString *text = value;
        return text.length > 3;
    }];
    
    [filteredUsername subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
    
    }];
    

    [[self.userTextField.rac_textSignal filter:^BOOL(id value) {
     
        NSString *text = value;
        return text.length > 3;
        
    }]
    
    subscribeNext:^(id x) {
        
           NSLog(@"%@",x);
        
    }];
    
    [[[self.userTextField.rac_textSignal
       map:^id(NSString*text){
           return @(text.length);
       }]
      filter:^BOOL(NSNumber*length){
          return[length integerValue] > 3;
      }]
     subscribeNext:^(id x){
         NSLog(@"%@", x);
     }];
    
    
    RACSignal *validUsernameSignal =
    [self.userTextField.rac_textSignal
     map:^id(NSString *text) {
          return @([self isValidUsername:text]);
      }];
    
    RACSignal *validPasswordSignal =
    [self.pswTextfield.rac_textSignal
     map:^id(NSString *text) {
         return @([self isValidPassword:text]);
     }];
    
    RAC(self.pswTextfield,backgroundColor) =
    [validPasswordSignal
     map:^id(NSNumber *passwordValid){
         return [passwordValid boolValue] ? [UIColor clearColor] : [UIColor redColor];
     }];
    
    RAC(self.userTextField,backgroundColor) =
    [validUsernameSignal
     map:^id(NSNumber *usernameValid){
         return [usernameValid boolValue] ? [UIColor clearColor] : [UIColor redColor];
     }];
    
 RACSignal *signUpActiveSingle = [RACSignal combineLatest:@[validUsernameSignal,validPasswordSignal] reduce:^id(NSNumber*usernameValid, NSNumber *passwordValid){
     
     return @([usernameValid boolValue]&&[passwordValid boolValue]);
    
 }];
    
    [signUpActiveSingle subscribeNext:^(NSNumber *signupActive) {
       
        self.signinButton.enabled = [signupActive boolValue];
        
    }];
    
    
    [[self.signinButton rac_signalForControlEvents:UIControlEventTouchUpInside]
    
    subscribeNext:^(id x) {
       
        NSLog(@"button clicked");
    }];
    // Do any additional setup after loading the view, typically from a nib.
}


- (BOOL)isValidUsername:(NSString *)username {
    return username.length > 3;
}

- (BOOL)isValidPassword:(NSString *)password {
    return password.length > 3;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
