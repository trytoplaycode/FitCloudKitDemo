//
//  FCWatchFaceViewController.m
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/8/9.
//

#import "FCWatchFaceViewController.h"
#import "LocalizedButton.h"
#import "FCDailLibraryViewController.h"
#import "FCDailCustomViewController.h"
#import "FCDailComponentsViewController.h"

@interface FCWatchFaceViewController ()

@property (weak, nonatomic) IBOutlet LocalizedButton *libraryButton;
@property (weak, nonatomic) IBOutlet LocalizedButton *customButton;
@property (weak, nonatomic) IBOutlet UIButton *componentButton;

@end

@implementation FCWatchFaceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNavBar:NSLocalizedString(@"Dial", nil)];
    [self initialization];
}

- (void)initialization {
    self.libraryButton.clipsToBounds = YES;
    self.libraryButton.layer.cornerRadius = 8;
    self.customButton.clipsToBounds = YES;
    self.customButton.layer.cornerRadius = 8;
    self.componentButton.clipsToBounds = YES;
    self.componentButton.layer.cornerRadius = 8;
    
}
- (IBAction)libraryAction:(id)sender {
    FCDailLibraryViewController *dail = [FCDailLibraryViewController new];
    [self.navigationController pushViewController:dail animated:YES];
}

- (IBAction)customAction:(id)sender {
    FCDailCustomViewController *custom = [FCDailCustomViewController new];
    [self.navigationController pushViewController:custom animated:YES];
    
}
- (IBAction)componentsAction:(id)sender {
    FCDailComponentsViewController *components = [FCDailComponentsViewController new];
    [self.navigationController pushViewController:components animated:YES];
}

@end
