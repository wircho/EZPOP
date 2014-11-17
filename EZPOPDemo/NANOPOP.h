//
//  NANOPOP.h
//  POPImprovements
//
//  Created by Adolfo Rodriguez on 2014-09-12.
//  Copyright (c) 2014 Merchlar. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NANOPOPObject : NSObject

@property (nonatomic,readonly) id object;

@end

@interface NANOPOPController : NSObject

@end

@interface NANOPOP : NSObject

+ (void)objects:(NSArray*)objects animations:(void(^)(NANOPOPController *ctrl))animations withKey:(NSString*)key;

@end
