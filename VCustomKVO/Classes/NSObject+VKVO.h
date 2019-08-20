//
//  NSObject+VKVO.h
//  VCustomKVO
//
//  Created by wang on 2019/8/9.
//  Copyright © 2019 wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VKVOInfo.h"

NS_ASSUME_NONNULL_BEGIN


@interface NSObject (VKVO)
- (void)v_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath handleBlock:(VKVOBlock)handleBlock;
@end

NS_ASSUME_NONNULL_END
