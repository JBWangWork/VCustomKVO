//
//  NSObject+VKVO.m
//  VCustomKVO
//
//  Created by wang on 2019/8/9.
//  Copyright © 2019 wang. All rights reserved.
//

#import "NSObject+VKVO.h"
#import <objc/message.h>
#import <objc/runtime.h>

static NSString *const kVKVOPrefix = @"VKVONotifying_";
static NSString *const kVKVOAssiociateKey = @"kVKVO_AssiociateKey";

@implementation NSObject (VKVO)

- (void)v_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options handleBlock:(VKVOBlock)handleBlock {
    // 验证是否存在setter方法
    [self judgeSetterMethodFromKeyPath:keyPath];
    
    
    // 动态生成子类
    Class newClass = [self createChildClass:keyPath];
    // 把isa指针指向生成的KVONotifying子类
    object_setClass(self, newClass);
    VKVOInfo *KVOInfo = [[VKVOInfo alloc] initWithObserver:observer forKeyPath:keyPath options:options handleBlock:handleBlock];
    
    // 保存KVO信息
    NSMutableArray *infoArr = objc_getAssociatedObject(self, (__bridge const void * _Nonnull)(kVKVOAssiociateKey));
    if (!infoArr) {
        infoArr = [NSMutableArray arrayWithCapacity:1];
        objc_setAssociatedObject(self, (__bridge const void * _Nonnull)(kVKVOAssiociateKey), infoArr, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [infoArr addObject:KVOInfo];
    NSLog(@"%@", observer);
}

#pragma mark - 动态生成子类
- (Class)createChildClass:(NSString *)keyPath {
    NSString *oldName = NSStringFromClass([self class]);
    NSString *newName = [NSString stringWithFormat:@"%@%@", kVKVOPrefix, oldName];
    Class newClass = NSClassFromString(newName);
    // 如果内存不存在,创建生成新的类，防止重复创建生成新类
    if (newClass) return newClass;
    
    newClass = objc_allocateClassPair([self class], newName.UTF8String, 0);
    objc_registerClassPair(newClass);
    
    // 添加class方法
    SEL classSEL = NSSelectorFromString(@"class");
    Method classMethod = class_getInstanceMethod([self class], classSEL);
    const char *classType = method_getTypeEncoding(classMethod);
//    IMP classIMP = method_getImplementation(classMethod);
//    class_addMethod(childClass, classSEL, classIMP, classType);
//    class_addMethod(childClass, classSEL, (IMP)classMethod, classType);
    class_addMethod(newClass, classSEL, (IMP)v_class, classType);
    
    // 添加setter方法
    SEL setterSEL = NSSelectorFromString(setterForGetter(keyPath));
    Method setterMethod = class_getInstanceMethod([self class], setterSEL);
    const char *setterType = method_getTypeEncoding(setterMethod);
//    class_addMethod(childClass, setterSEL, method_getImplementation(setterMethod), setterType);
    class_addMethod(newClass, setterSEL, (IMP)v_setter, setterType);
    
    // 添加dealloc方法
    SEL deallocSEL = NSSelectorFromString(@"dealloc");
    Method deallocMethod = class_getInstanceMethod([self class], deallocSEL);
    const char *deallocType = method_getTypeEncoding(deallocMethod);
    class_addMethod(newClass, deallocSEL, (IMP)v_dealloc, deallocType);
    
    return newClass;
}

#pragma mark - imp
Class v_class(id self, SEL _cmd) {
    return class_getSuperclass(object_getClass(self));
}

static void v_dealloc(id self, SEL _cmd) {
//    return class_getSuperclass(object_getClass(self));
    Class superClass = [self class];
    object_setClass(self, superClass);
}

static void v_setter(id self, SEL _cmd, id newValue) {
    NSString *keyPath = getterForSetter(NSStringFromSelector(_cmd));
    id oldValue = [self valueForKey:keyPath];
    // 消息发
    /// Specifies the superclass of an instance.
    struct objc_super v_objc_super = {
        .receiver = self,
        .super_class = class_getSuperclass(object_getClass(self))
    };
    // 消息转发给父类
    void (*v_msgSendSuper)(void *, SEL, id) = (void *)objc_msgSendSuper;
    v_msgSendSuper(&v_objc_super, _cmd, newValue);
    
    // 响应回调
    NSMutableArray *infoArr = objc_getAssociatedObject(self, (__bridge const void * _Nonnull)(kVKVOAssiociateKey));
    for (VKVOInfo *info in infoArr) {
        if ([info.keyPath isEqualToString:keyPath]) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                if (info.handleBlock) {
                    info.handleBlock(info.observer, keyPath, info.options, newValue, oldValue);
                }
//                SEL obserSEL = @selector(observeValueForKeyPath:ofObject:change:context:);
//                void (*v_objc_msgSend)(id, SEL, id, id, id, void *) = (void *)objc_msgSend;
//                Class supperClass = (object_getClass(self));
//                v_objc_msgSend(info.observer, obserSEL, keyPath, supperClass, @{keyPath:newValue}, NULL);
            });
        }
    }
//    Class superClass = [self class];
//    object_setClass(self, superClass);
}

#pragma mark - 验证是否存在setter方法
- (void)judgeSetterMethodFromKeyPath:(NSString *)keyPath{
    Class superClass = object_getClass(self);
    SEL setterSeletor = NSSelectorFromString(setterForGetter(keyPath));
    Method setterMethod = class_getInstanceMethod(superClass, setterSeletor);
    if (!setterMethod) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"%@没有%@的setter方法", object_getClass(self), keyPath] userInfo:nil];
    }
}

#pragma mark - 从get方法获取set方法的名称 key ===>>> setKey:
static NSString *setterForGetter(NSString *getter){
    
    if (getter.length <= 0) return nil;
    
    NSString *firstString = [[getter substringToIndex:1] uppercaseString];
    NSString *leaveString = [getter substringFromIndex:1];
    
    return [NSString stringWithFormat:@"set%@%@:",firstString,leaveString];
}

#pragma mark - 从set方法获取getter方法的名称 set<Key>:===> key
static NSString *getterForSetter(NSString *setter){
    
    if (setter.length <= 0 || ![setter hasPrefix:@"set"] || ![setter hasSuffix:@":"]) return nil;
    
    NSRange range = NSMakeRange(3, setter.length-4);
    NSString *getter = [setter substringWithRange:range];
    NSString *firstString = [[getter substringToIndex:1] lowercaseString];
    return  [getter stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:firstString];
}
@end
