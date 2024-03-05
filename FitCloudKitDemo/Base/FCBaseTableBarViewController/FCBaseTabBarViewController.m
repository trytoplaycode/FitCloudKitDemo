//
//  FCBaseTabBarViewController.m
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/7/11.
//

#import "FCBaseTabBarViewController.h"
#import "FCDefinitions.h"
#import "AppDelegate.h"

@interface FCBaseTabBarViewController ()
{
    NSMutableArray *_selectedPhotos;
    NSMutableArray *_selectedAssets;
    BOOL _isSelectOriginalPhoto;
    
    CGFloat _itemWH;
    CGFloat _margin;
}
@property (assign , nonatomic) NSInteger centerPlace;
@property (assign , nonatomic,getter=is_bulge) BOOL bulge;
@property (nonatomic, strong) NSMutableArray <UITabBarItem *>*items;

@end

@implementation FCBaseTabBarViewController
{
    int tabBarItemTag;
    BOOL firstInit;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialization];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backToHome) name:@"backToHome" object:nil];
}

- (void)backToHome {
    self.selectedIndex = 0;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (!firstInit)
    {
        firstInit = YES;
        if (self.centerPlace != -1 && self.items[self.centerPlace].tag != -1){
            self.selectedIndex = self.centerPlace;
        }else{
            self.selectedIndex = 0;
        }
        [self.tabbar setValue:[NSNumber numberWithInteger:self.selectedIndex] forKey:@"selectButtoIndex"];
    }
}

- (void)updateBrigd {
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"needUpdate"] boolValue]) {
        [self.tabbar setBrigdAtIndex:1];
    }else {
        [self.tabbar hiddenBrigdAtIndex:1];
    }
}

- (void)initialization {
    self.centerPlace = -1;
}

- (void)addChildController:(id)controller title:(NSString *)title imageName:(NSString *)imageName selectedImageName:(NSString *)selectedImageName{
    UIViewController *vc = [self findViewControllerWithobject:controller];
    vc.tabBarItem.title = title;
    vc.tabBarItem.image = [UIImage imageNamed:imageName];
    vc.tabBarItem.selectedImage = [UIImage imageNamed:selectedImageName];
    
    vc.tabBarItem.tag = tabBarItemTag++;
    [self.items addObject:vc.tabBarItem];
    [self addChildViewController:controller];
}

- (void)addCenterController:(nullable id)controller bulge:(BOOL)bulge title:(NSString *)title imageName:(NSString *)imageName selectedImageName:(NSString *)selectedImageName {
    _bulge = bulge;
    if (controller) {
        [self addChildController:controller title:title imageName:imageName selectedImageName:selectedImageName];
        self.centerPlace = tabBarItemTag-1;
    }else {
        UITabBarItem *item = [[UITabBarItem alloc]initWithTitle:title
                                                          image:[UIImage imageNamed:imageName]
                                                  selectedImage:[UIImage imageNamed:selectedImageName]];
        item.tag = -1;
        [self.items addObject:item];
        self.centerPlace = tabBarItemTag;
    }
}


- (UIViewController *)findViewControllerWithobject:(id)object{
    while ([object isKindOfClass:[UITabBarController class]] || [object isKindOfClass:[UINavigationController class]]){
        object = ((UITabBarController *)object).viewControllers.firstObject;
    }
    return object;
}

#pragma mark - Setter & Getter
- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    if (selectedIndex >= self.viewControllers.count){
        @throw [NSException exceptionWithName:@"selectedTabbarError"
                                       reason:@"Don't have the controller can be used, index beyond the viewControllers."
                                     userInfo:nil];
    }
    [super setSelectedIndex:selectedIndex];
    UIViewController *viewController = [self findViewControllerWithobject:self.viewControllers[selectedIndex]];
    [self.tabbar removeFromSuperview];
    [viewController.view addSubview:self.tabbar];
}

- (NSMutableArray <UITabBarItem *>*)items {
    if(!_items){
        _items = [NSMutableArray array];
    }
    return _items;
}

- (FCTabbar *)tabbar {
    if (!_tabbar) {
        _tabbar = [[FCTabbar alloc]initWithFrame:CGRectMake(self.tabBar.frame.origin.x, self.view.frame.size.height-kTabbarHeight, self.tabBar.frame.size.width, kTabbarHeight)];
        [_tabbar setValue:[NSNumber numberWithBool:self.bulge] forKey:@"bulge"];
        [_tabbar setValue:self forKey:@"controller"];
        [_tabbar setValue:[NSNumber numberWithInteger:self.centerPlace] forKey:@"centerPlace"];
        _tabbar.items = self.items;
        [self updateBrigd];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tabbar.frame.size.width, 1)];
        line.backgroundColor = UIColorFromRGB(0xe0e0e0, 0.5);
        [_tabbar addSubview:line];
        
        _tabbar.centerButtonCallback = ^{
            

        };
        
        for (UIView *loop in self.tabBar.subviews) {
            [loop removeFromSuperview];
        }
        self.tabBar.hidden = YES;
        [self.tabBar removeFromSuperview];
    }
    
    return _tabbar;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

@end
