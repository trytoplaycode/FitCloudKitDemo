//
//  FCContactsDetailViewController.m
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/7/31.
//

#import "FCContactsDetailViewController.h"
#import <Toast.h>

@interface FCContactsDetailViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UITextField *numberTF;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@end

@implementation FCContactsDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNavBar:NSLocalizedString(@"Add Contacts", nil)];
    [self addNavRightButton:NSLocalizedString(@"Delete", nil) isImage:NO];
    self.nameTF.text = self.model.title;
    self.numberTF.text = self.model.value;
    if (self.model) {
        [self.saveButton setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
    }
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightButtonAction {
    [self.view endEditing:YES];
    if (self.deleteContactsCallback) {
        self.deleteContactsCallback(self.model);
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (IBAction)addContactsAction:(id)sender {
    [self.view endEditing:YES];
    if (self.nameTF.text.length == 0) {
        [self.view makeToast:NSLocalizedString(@"Please input the name", nil)];
        return;
    }
    if (self.numberTF.text.length == 0) {
        [self.view makeToast:NSLocalizedString(@"Please input the phone number", nil)];
        return;
    }
    if (self.model) {
        self.model.title = self.nameTF.text;
        self.model.value = self.numberTF.text;
        if (self.editContactsCallback) {
            self.editContactsCallback(self.model, self.indexPath);
        }
    }else {
        if (self.addContactsCallback) {
            FCCommenCellModel *model = [FCCommenCellModel new];
            model.title = self.nameTF.text;
            model.value = self.numberTF.text;
            self.addContactsCallback(model);
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setModel:(FCCommenCellModel *)model {
    _model = model;
}

@end
