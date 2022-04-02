//
//  McdCardData.h
//  MeaCardData
//
//  Copyright © 2019 MeaWallet AS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface McdCardData : NSObject

@property (nonatomic, copy, readonly, nonnull) NSString *pan;
@property (nonatomic, copy, readonly, nonnull) NSString *cvv;

+ (instancetype)cardDataWithPan:(NSString *_Nonnull)pan
                            cvv:(NSString *_Nonnull)cvv;
+ (instancetype)cardDataWithDictionary:(NSDictionary *_Nonnull)dictionary;
- (BOOL)isValid;

@end

NS_ASSUME_NONNULL_END
