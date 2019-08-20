//
//  VKVOInfo.m
//  VCustomKVO
//
//  Created by wang on 2019/8/14.
//  Copyright © 2019 wang. All rights reserved.
//

#import "VKVOInfo.h"

@implementation VKVOInfo
- (instancetype)initWithObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath handleBlock:(VKVOBlock)handleBlock {
    if (self = [super init]) {
        self.observer = observer;
        self.keyPath = keyPath;
        self.handleBlock = handleBlock;
    }
    return self;
}
@end
