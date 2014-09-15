//
//  NANOPOP.m
//  POPImprovements
//
//  Created by Adolfo Rodriguez on 2014-09-12.
//  Copyright (c) 2014 Merchlar. All rights reserved.
//

#import "NANOPOP.h"

#import <POP/POP.h>


@implementation NANOPOPObject
{
    __weak id _object;
    __weak NANOPOPController *_controller;
}

- (id)object
{
    return _object;
}

- (instancetype)init
{
    self = [super init];
    if (self){
        
    }
    return self;
}

- (instancetype)initWithObject:(id)object controller:(NANOPOPController*)controller
{
    self = [super init];
    if (self){
        _object = object;
        _controller = controller;
    }
    return self;
}

@end

@implementation NANOPOPController



@end



@implementation NANOPOP

+ (NANOPOP*)instance
{
    static NANOPOP *nano;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        nano = [[NANOPOP alloc] init];
    });
    return nano;
}

+ (void)objects:(NSArray*)objects animations:(void (^)(NANOPOPController *))animations withKey:(NSString *)key
{
    
}

@end
