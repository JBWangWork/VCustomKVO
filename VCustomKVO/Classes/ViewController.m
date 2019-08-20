//
//  ViewController.m
//  VCustomKVO
//
//  Created by wang on 2019/8/19.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import "TestViewController.h"
#import "Person.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)pushToNextViewController:(UIButton *)sender {
    TestViewController *vc = [[TestViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self getClasses:[Person class]];
}

// 遍历类以及子类
- (void)getClasses:(Class)cls {
    if (!cls) return;
    // 注册类的总数
    int count = objc_getClassList(NULL, 0);
    // 创建一个数组，其中包含给定对象
    NSMutableArray *mArr = [NSMutableArray arrayWithObject:cls];
    // 获取所有已注册的类
    Class *classes = (Class *)malloc(sizeof(Class)*count);
    objc_getClassList(classes, count);
    for (int i = 0; i < count; i++) {
        if (cls == class_getSuperclass(classes[i])) {
            [mArr addObject:classes[i]];
        }
    }
    free(classes);
    NSLog(@"classes --- %@", mArr);
}
@end
