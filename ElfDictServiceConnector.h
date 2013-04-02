//
//  ElfDictServiceConnector.h
//  ElfDictIOS
//
//  Created by Rebecca Mitchell on 3/31/13. 
//  Copyright (c) 2013 Rebecca M. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ElfDictServiceConnector : NSObject {
    @private
    void (^m_completedHandler)(NSDictionary *result);
    void (^m_failedHandler)(NSString *errorMessage);
    
    NSMutableData *m_data;
    NSURLConnection *m_connection;
}

// Public methods
- (id) initWithHandler: (void (^)(NSDictionary *))completedHandler
     andFailureHandler: (void (^)(NSString *))failedHandler;
- (void) lookup: (NSString *)word;
- (NSString *)encodeString: (NSString *)string; 

@end
