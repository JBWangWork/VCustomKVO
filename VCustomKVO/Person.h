//
//  Person.h
//  VCustomKVO
//
//  Created by wang on 2019/8/8.
//  Copyright © 2019 wang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject {
@public
    NSString *name;
}
@property (nonatomic, copy) NSString *nickName;

+ (instancetype)shareInstance;
- (void)run;
@end

NS_ASSUME_NONNULL_END
