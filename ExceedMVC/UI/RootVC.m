//
//  RootVC.m
//  ExceedMVC
//
//  Created by CocoaChina_yangjh on 16/2/18.
//  Copyright © 2016年 yjh4866. All rights reserved.
//

#import "RootVC.h"

@interface RootVC ()
@property (nonatomic, assign) BOOL firstAppear;
@end

@implementation RootVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.firstAppear = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([self.delegate respondsToSelector:@selector(rootVC:didFirstAppear:)]) {
        [self.delegate rootVC:self didFirstAppear:self.firstAppear];
    }
    self.firstAppear = NO;
}

@end
