//
//  MeaCardData.h
//  MeaCardData
//
//  Copyright © 2019 MeaWallet AS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MeaCardData/McdCardData.h>

NS_ASSUME_NONNULL_BEGIN

@interface MeaCardData : NSObject

+ (void)getCardData:(NSString *_Nonnull)cardId secret:(NSString *_Nonnull)secret completionHandler:(void (^)(McdCardData *_Nullable cardData, NSError *_Nullable error))completionHandler;

+ (NSString *_Nonnull)versionCode;
+ (NSString *_Nonnull)versionName;
+ (void)setDebugLoggingEnabled:(BOOL)enabled;

@end

NS_ASSUME_NONNULL_END
