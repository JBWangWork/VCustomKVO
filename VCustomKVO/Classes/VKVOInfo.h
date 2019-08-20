//
//  VKVOInfo.h
//  VCustomKVO
//
//  Created by wang on 2019/8/14.
//  Copyright © 2019 wang. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "NSObject+VKVO.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^VKVOBlock)(NSObject *observer, NSString *keyPath, NSKeyValueObservingOptions options, id newValue, id oldValue);


@interface VKVOInfo : NSObject
@property (nonatomic, weak) NSObject *observer;
@property (nonatomic, copy) NSString *keyPath;
@property (nonatomic, assign) NSKeyValueObservingOptions options;
@property (nonatomic, copy) VKVOBlock handleBlock;

- (instancetype)initWithObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options handleBlock:(VKVOBlock)handleBlock;
@end

NS_ASSUME_NONNULL_END
