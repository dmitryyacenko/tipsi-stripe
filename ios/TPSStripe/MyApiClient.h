//
//  ExampleAPIClient.h
//  Non-Card Payment Examples
//
//  Created by Yuki Tokuhiro on 9/5/19.
//  Copyright © 2019 Stripe. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Stripe;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, MyAPIClientResult) {
    MyAPIClientResultSuccess,
    MyAPIClientResultFailure,
};

typedef void (^STPJSONResponseCompletionBlock)(NSDictionary * _Nullable result, NSError * _Nullable error);


@protocol MyApiClientDelegateMethods
- (void)keyWasObtained:(BOOL)result;
@end

@interface MyAPIClient : NSObject <STPCustomerEphemeralKeyProvider> {
    id<MyApiClientDelegateMethods> delegate;
}

- (void)setDelegate:(id)delegate;

@property NSString *sessionId;
@property NSString *ttApiKey;
@property NSString *ttApiVersion;
+ (instancetype)sharedClient;

#pragma mark - PaymentIntents (automatic confirmation)

/**
 Asks our example backend to create and confirm a PaymentIntent using automatic confirmation.

 The implementation of this function is not interesting or relevant to using PaymentIntents. The
 method signature is the most interesting part: you need some way to ask *your* backend to create
 a PaymentIntent with the correct properties, and then it needs to pass the client secret back.

 @param apiVersion additional parameters to pass to the example backend
 @param completion completion block called with status of backend call & the client secret if successful.
 @see https://stripe.com/docs/payments/payment-intents/ios
 */
- (void)createCustomerKeyWithAPIVersion:(NSString *)apiVersion completion:(STPJSONResponseCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
