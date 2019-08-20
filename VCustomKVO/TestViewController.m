//
//  TestViewController.m
//  VCustomKVO
//
//  Created by wang on 2019/8/19.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "TestViewController.h"
#import <objc/runtime.h>
#import "NSObject+VKVO.h"
#import "Person.h"

@interface TestViewController ()

@property (nonatomic, strong) Person *person;

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //    [self getClasses:[Person class]];
    //    [self getClasses:NSClassFromString(@"NSKVONotifying_Person")];
    //
    //    [self getClassAllMethod:[Person class]];
    //    [self getClassAllMethod:NSClassFromString(@"NSKVONotifying_Person")];
    //
    //    [self getClassProperty:[Person class]];
    //    [self getClagetClassPropertyssAllIvar:NSClassFromString(@"NSKVONotifying_Person")];
    //
    //    [self getClassAllIvar:[Person class]];
    //    [self getClassAllIvar:NSClassFromString(@"NSKVONotifying_Person")];
    
    //    self.person = [[Person alloc] init];
    self.person = [Person new];
    self.person.nickName = @"hhhh";
    
    //    [self.person addObserver:self forKeyPath:@"nickName" options:(NSKeyValueObservingOptionNew) context:NULL];
    //    [self.person addObserver:self forKeyPath:@"name" options:(NSKeyValueObservingOptionNew) context:NULL];
    //    [self.person v_addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:NULL];
    [self.person v_addObserver:self forKeyPath:@"nickName" options:NSKeyValueObservingOptionNew handleBlock:^(NSObject * _Nonnull observer, NSString * _Nonnull keyPath, NSKeyValueObservingOptions options, id  _Nonnull newValue, id  _Nonnull oldValue) {
        NSLog(@"%@----%@----%lu----%@----%@", observer, keyPath, options, newValue, oldValue);
    }];
    
    //    self.person->name = @"wahaha";
    //    NSLog(@"---------------------");
    //    [self getClassAllIvar:[Person class]];
    //    [self getClassAllIvar:NSClassFromString(@"NSKVONotifying_Person")];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:(UIBarButtonItemStylePlain) target:self action:@selector(backView)];
    
}

- (void)backView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.person.nickName = [NSString stringWithFormat:@"%@+", self.person.nickName];
}

// 遍历方法 -- 判断imp指针是否改变也就是重写
- (void)getClassAllMethod:(Class)cls {
    if (!cls) return;
    unsigned int count = 0;
    Method *methodList = class_copyMethodList(cls, &count);
    for (int i = 0; i<count; i++) {
        Method method = methodList[i];
        SEL sel = method_getName(method);
        IMP imp = class_getMethodImplementation(cls, sel);
        NSLog(@"%@ --- %p",NSStringFromSelector(sel), imp);
    }
    free(methodList);
}

// 遍历属性
- (void)getClassProperty:(Class)cls {
    if (!cls) return;
    //获取类中的属性列表
    unsigned int propertyCount = 0;
    objc_property_t * properties = class_copyPropertyList(cls, &propertyCount);
    for (int i = 0; i<propertyCount; i++) {
        NSLog(@"属性的名称为 : %s",property_getName(properties[i]));
        /**
         特性编码 具体含义
         R readonly
         C copy
         & retain
         N nonatomic
         G(name) getter=(name)
         S(name) setter=(name)
         D @dynamic
         W weak
         P 用于垃圾回收机制
         */
        NSLog(@"属性的特性字符串为: %s",property_getAttributes(properties[i]));
    }
    //释放属性列表数组
    free(properties);
}

// 遍历变量
- (void)getClassAllIvar:(Class)cls {
    if (!cls) return;
    unsigned int count = 0;
    Ivar *ivarList = class_copyIvarList(cls, &count);
    for (int i = 0; i<count; i++) {
        Ivar ivar = ivarList[i];
        NSLog(@"%s",ivar_getName(ivar));
    }
    free(ivarList);
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

- (void)dealloc {
    NSLog(@"testViewDealloc");
}

@end
