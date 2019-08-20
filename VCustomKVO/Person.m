//
//  Person.m
//  VCustomKVO
//
//  Created by wang on 2019/8/8.
//  Copyright © 2019 wang. All rights reserved.
//

#import "Person.h"

@implementation Person
static Person *_instance = nil;

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init] ;
    }) ;
    return _instance ;
}

+(id)allocWithZone:(struct _NSZone *)zone{
    return [Person shareInstance] ;
}

-(id)copyWithZone:(struct _NSZone *)zone{
    return [Person shareInstance] ;
}

- (void)run {
   NSLog(@"%s",__FUNCTION__);
}
@end
