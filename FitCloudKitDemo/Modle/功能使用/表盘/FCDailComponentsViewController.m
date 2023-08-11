//
//  FCDailComponentsViewController.m
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/8/9.
//

#import "FCDailComponentsViewController.h"
#import "FCNetworking.h"

@interface FCDailComponentsViewController ()

@end

@implementation FCDailComponentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNavBar:NSLocalizedString(@"DIAL COMPONENT", nil)];
    
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}



@end
