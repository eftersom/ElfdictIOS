//
//  ElfDictServiceConnector.m
//  ElfDictIOS
//
//  Created by Rebecca Mitchell on 3/31/13. 
//  Copyright (c) 2013 Rebecca M. All rights reserved. 
//

#import "ElfDictServiceConnector.h"
#import "WordDefinition.h"

@implementation ElfDictServiceConnector

- (id) initWithHandler: (void (^)(NSDictionary *))completedHandler
     andFailureHandler: (void (^)(NSString *))failedHandler {
    
    self = [self init];
    
    if (self) {
        m_completedHandler = completedHandler;
        m_failedHandler = failedHandler;
    }
    
    return self;
}

- (void) lookup: (NSString *)word
{
    NSString *postDataString;
    NSMutableURLRequest *request;
    NSURL *serviceUrl;
    NSData *postData;
    
    // build the data string for the HTTP request and build a NSData object based on the
    // resulting data string.
    postDataString = [NSString stringWithFormat: @"term=%@", [self encodeString: word]];
    postData = [NSData dataWithBytes: [postDataString UTF8String] length: [postDataString length]];
    
    // Set up the HTTP POST request
    serviceUrl = [NSURL URLWithString: @"http://www.elfdict.com/api/translation/translate"];
    request = [[NSMutableURLRequest alloc] initWithURL: serviceUrl];
    
    [request setHTTPMethod: @"POST"];
    [request setValue: @"application/x-www-form-urlencoded" forHTTPHeaderField: @"Content-Type"];
    [request setHTTPBody: postData];
    
    if (m_connection) {
        [m_connection cancel];
        
        m_connection = nil;
        m_data = nil;
    }
    
    m_connection = [[NSURLConnection alloc] initWithRequest: request
                                                  delegate: self];
    
    if (!m_connection) {
        
        if (m_failedHandler) {
            m_failedHandler(@"ElfDict's web service is not responding");
        }
        
    } else {
        m_data = [[NSMutableData alloc] init];
    }
}

- (NSString *)encodeString:(NSString *)string {
    
    if (string == nil) {
        return @"";
    }
    
    return (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)string, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
}


#pragma mark NSURLConnectionDelegate
- (void)connection: (NSURLConnection *)connection didReceiveResponse: (NSURLResponse *)response
{
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
    
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    
    // receivedData is an instance variable declared elsewhere.
    [m_data setLength: 0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData: (NSData *)data
{
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    [m_data appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError: (NSError *)error
{
    m_connection = nil;
    m_data = nil;
    
    if (m_failedHandler) {
        m_failedHandler(@"Connection failed");
    }
}

- (void)connectionDidFinishLoading: (NSURLConnection *)connection
{
    NSError *error;
    id response = [NSJSONSerialization JSONObjectWithData: m_data
                                                  options: 0
                                                    error: &error];
    
    
    
    if (![response isKindOfClass: [NSDictionary class]]) {
        // Show an error message
        if (m_failedHandler) {
            m_failedHandler(@"Unexpected response");
        }
        
    } else {
        if (![[response objectForKey: @"succeeded"] isEqual: @"true"]) {
            // Show an error
            if (m_failedHandler) {
                m_failedHandler([response objectForKey: @"error"]);
            }
        } else {
            
            // Prepare a dictionary where language => words[]. Release previous search results.
            NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
            
            // Acquire teh dictionary for all translations
            id translations = [response objectForKey: @"response"];
            
            //NSLog(@"%@", translations);
            if (translations == nil || translations == [NSNull null]) {
                if (m_failedHandler) {
                    m_failedHandler(@"No such word was found in the dictionary");
                }
                goto connectionClose;
            }
            translations = [translations objectForKey: @"translations"];
            
            // Get all available languages, as the dictionary above maintains a key-value pair where the
            // key is the language, and the value is the array of words that matches the query
            NSArray *languages = [translations allKeys];
            
            // Iterate through each language
            for (int i = 0; i < languages.count; ++i) {
                
                // Acquire the language at the current index in the for-loop
                NSString *language = [languages objectAtIndex: i];
                
                // Acquire the *array* of words that matches the current language. These are in the *translations* dictionary
                // and the key is the language string itself.
                NSArray *wordObjArr = [translations objectForKey: language];
                
                // We will acquire all words - thus allocate a changable array with the capacity of the word array acquired above
                NSMutableArray *words = [[NSMutableArray alloc] initWithCapacity: wordObjArr.count];
                
                // Iterate through each word
                for (int j = 0; j < wordObjArr.count; ++j) {
                    
                    // Every "word" is actually just a dictionary with again key => value pairs. There are a lot of information to
                    // acquire from this dictionary, but we are only interested in the "word" itself as well as its "translation".
                    // So ACquire the dictionary, and look up the object for the keys "word" and "translations". These objects will
                    // be NSString and thus be assigned to the "entry" variable beneath (*def*)
                    NSDictionary *wordDictionary = [wordObjArr objectAtIndex: j];
                    
                    NSString *comments = [wordDictionary objectForKey: @"comments"];
                    
                    if ([comments isKindOfClass: [NSNull class]]) {
                        comments = nil;
                    }
                    
                    WordDefinition *def = [[WordDefinition alloc] init];
                    [def setAuthor: [wordDictionary objectForKey: @"authorName"]];
                    [def setWord: [wordDictionary objectForKey: @"word"]];
                    [def setTranslation: [wordDictionary objectForKey: @"translation"]];
                    [def setComments: comments];
                    
                    // Add the entry to the changable list of words
                    [words addObject: def];
                }
                
                // Assign the list of words to the key *language*, for an example "Sindarin => [ galadh, orn, eryn ]" for tree.
                [result setObject: words
                            forKey: language];
            }
            
            if (m_completedHandler) {
                m_completedHandler(result);
            }
        }
    }
    
connectionClose:
    
    // release the connection, and the data object
    m_connection = nil;
    m_data = nil;
}

@end
