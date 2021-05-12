//
//  MyApiClient.m
//  TPSStripe
//
//  Created by Дмитрий Яценко on 05.05.2021.
//  Copyright © 2021 Tipsi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyApiClient.h"

@implementation MyAPIClient

+ (instancetype)sharedClient {
    static id sharedClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ sharedClient = [[self alloc] init]; });
    return sharedClient;
}

- (void)_callOnMainThread:(void (^)(void))block {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            block();
        });
    }
}

- (void)setDelegate:(id)aDelegate {
    delegate = aDelegate; /// Not retained
}


- (void)createCustomerKeyWithAPIVersion:(NSString *)apiVersion completion:(STPJSONResponseCompletionBlock)completion {
    if (!self.sessionId) {
           NSError *error = [NSError errorWithDomain:@"MyAPIClientErrorDomain"
                                                code:0
                                            userInfo:@{NSLocalizedDescriptionKey: @"You must set a backend base URL in Constants.m to create a payment intent."}];
           [self _callOnMainThread:^{ completion(nil, error); }];
           return;
       }
    NSURL *url = [NSURL URLWithString:@"https://api.tokentransit.com/user/stripe_ephemeral_key"];
    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    urlComponents.queryItems = @[[[NSURLQueryItem alloc] initWithName:@"stripe_api_version" value:apiVersion]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlComponents.URL];

    [request setHTTPMethod:@"POST"];
    [request setValue:self.ttApiKey forHTTPHeaderField:@"Token-Transit-Api-Key"];
    [request setValue:self.ttApiVersion forHTTPHeaderField:@"Token-Transit-Api-Version"];

    NSDictionary *cookieProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"tokentransit.com", NSHTTPCookieDomain,
                            @"\\", NSHTTPCookiePath,
                            @"user_session_id", NSHTTPCookieName,
                            self.sessionId, NSHTTPCookieValue,
                            nil];

    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    NSArray* cookieArray = [NSArray arrayWithObject:cookie];
    NSDictionary * headers = [NSHTTPCookie requestHeaderFieldsWithCookies:cookieArray];
    [request setAllHTTPHeaderFields:headers];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data != nil && [response isKindOfClass:[NSHTTPURLResponse class]] && ((NSHTTPURLResponse *)response).statusCode == 200) {
            [self->delegate keyWasObtained:TRUE];
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            completion(json, nil);
        } else {
            [self->delegate keyWasObtained:FALSE];
            completion(nil, error);
        }
    }];
    [task resume];
}

@end
