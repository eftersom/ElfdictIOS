//
//  dictionary.h
//  elfdict
//
//  Created by Rebecca Mitchell on 3/31/13.
//  Copyright (c) 2013 Rebecca M. All rights reserved. 
//

#import <Foundation/Foundation.h>

@interface WordDefinition : NSObject {
    NSString *word;
    NSString *translation;
}

@property(retain) NSString *word;
@property(retain) NSString *translation;
@property(retain) NSString *comments;
@property(retain) NSString *author;

@end