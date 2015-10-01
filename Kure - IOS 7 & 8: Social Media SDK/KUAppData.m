//
//  KUAppData.m
//  kure
//
//  Created by Kyle Ju on 2015-07-16.
//  Copyright (c) 2015 kure. All rights reserved.
//

#import "KUAppData.h"
#import "KUAPIHelper.h"
#import "KUEvent.h"

@interface KUAppData ()

@property (strong, nonatomic) KUAccountPreference *accountPreference;
@property (strong, nonatomic) KUActivity *activity;
@property (strong, nonatomic) NSArray *allCategories;
@property (copy, nonatomic) NSArray *allStores;
@property (copy, nonatomic) NSArray *regions;
@property (strong, nonatomic) KUPromotion *promotion;
@property (strong, nonatomic) KUProduct *product;
@property (copy, nonatomic) NSArray *allEvents;


@end

@implementation KUAppData

+ (id)sharedCache {
    static KUAppData *sharedCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCache = [[self alloc] init];
    });
    return sharedCache;
}

#pragma mark - Cache

- (void)cacheMyEnvoyPointsBadgeCount:(NSInteger)myEnvoyPointsBadgeCount {
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setInteger:myEnvoyPointsBadgeCount forKey:@"myEnvoyPointsBadgeCount"];
}

- (void)cacheMyLoyaltyPointsBadgeCount:(NSInteger)myLoyaltyPointsBadgeCount {
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setInteger:myLoyaltyPointsBadgeCount forKey:@"myLoyaltyPointsBadgeCount"];
}

- (void)cacheEventsBadgeCount:(NSInteger)eventsBadgeCount {
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setInteger:eventsBadgeCount forKey:@"eventsBadgeCount"];
}

- (void)cachePromotionsBadgeCount:(NSInteger)promotionsBadgeCount {
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setInteger:promotionsBadgeCount forKey:@"promotionsBadgeCount"];
}

- (void)cacheProductsBadgeCount:(NSInteger)productsBadgeCount {
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setInteger:productsBadgeCount forKey:@"productsBadgeCount"];
}

- (void)cacheDeviceToken:(NSString *)deviceToken {
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:deviceToken forKey:@"deviceToken"];
}

- (void)cacheVerifyDeviceResponse:(NSString *)phone and:(NSString *)verificationID {
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:phone forKey:@"phone"];
    [user setObject:verificationID forKey:@"verificationID"];
}

- (void)cacheRegisterDeviceResponse:(NSString *)deviceID and:(NSString *)deviceKey and:(NSString *)requiresAccountSetup and:(NSString *)sessionID {
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:deviceID forKey:@"deviceID"];
    [user setObject:deviceKey forKey:@"deviceKey"];
    [user setObject:requiresAccountSetup forKey:@"requiresAccountSetup"];
    [user setObject:sessionID forKey:@"sessionID"];
}

- (void)cacheAuthDeviceResponse:(NSString *)requiresAccountSetup and:(NSString *)sessionID {
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:requiresAccountSetup forKey:@"requiresAccountSetup"];
    [user setObject:sessionID forKey:@"sessionID"];
}

- (void)cacheAccountPreference {
    [[KUAPIHelper sharedClient] accountPreferenceGet:^(KUAccountPreference *accountPreference) {
        self.accountPreference = accountPreference;
    }];
}

- (void)cacheRegions {
    [[KUAPIHelper sharedClient] region:^(NSArray *regions) {
        self.regions = regions;
    }];
}

#pragma mark - Retrieve

- (NSInteger)retrieveMyEnvoyPointsBadgeCount {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"myEnvoyPointsBadgeCount"];
}

- (NSInteger)retrieveMyLoyaltyPointsBadgeCount {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"myLoyaltyPointsBadgeCount"];
}

- (NSInteger)retrieveEventsBadgeCount {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"eventsBadgeCount"];
}

- (NSInteger)retrievePromotionsBadgeCount {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"promotionsBadgeCount"];
}

- (NSInteger)retrieveProductsBadgeCount {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"productsBadgeCount"];
}

- (KUAccountPreference*)retrieveAccountPreference {
    return self.accountPreference;
}

- (NSString*)retrieveDeviceID {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"deviceID"];
}

- (NSString*)retrieveDeviceKey {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"deviceKey"];
}

- (NSString*)retrieveDeviceToken {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"deviceToken"];
}

- (NSString*)retrievePhone {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"phone"];
}

- (NSString*)retrieveVerificationID {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"verificationID"];
}

- (NSString*)retrieveRequiresAccountSetup {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"requiresAccountSetup"];
}

- (NSArray*)retrieveRegions {
    return self.regions;
}

- (void)cacheAllStores {
    [[KUAPIHelper sharedClient] getStores:^(NSArray *stores){
        self.allStores = stores;
    }];
}
- (NSArray *)getAllStores {
    return self.allStores;
}
- (void)cacheAllActivity:(KUActivity *)activity {
    self.activity = activity;
}

- (KUActivity *)returnActivity {
    return self.activity;
}

- (void)cacheAllCategories {
    [[KUAPIHelper sharedClient] getCategory:^(NSArray *result) {
        self.allCategories = result;
    }];
}

- (NSArray *)getAllCategories {
    return self.allCategories;
}


- (void)cacheEvents {
    [[KUAPIHelper sharedClient] getEvent:^(NSArray *events) {
        self.allEvents = events;
    }];
}

- (NSArray *)getEvents {
    NSMutableArray *returnArrya = [[NSMutableArray alloc] init];
    NSDate *now = [NSDate date];
    for (KUEvent *each in self.allEvents) {
        if ([each.endsOn laterDate:now] && [each.startsOn earlierDate: now]) {
            [returnArrya addObject:each];
        }
    }
    return returnArrya;
}
- (void)cachePromotion {
    NSNumber *until;
    if (self.promotion) {
        until = self.promotion.until;
    } else {
        until = @0;
    }
     [[KUAPIHelper sharedClient] getPromotion:until success:^(KUPromotion *returnObject) {
         if (self.promotion) {
             self.promotion.until = returnObject.until;
             NSMutableArray *array = [self.promotion.results mutableCopy];
             for (KUPromotionResult *eachOne in returnObject.results) {
                 BOOL inLoop = false;
                 if (eachOne.status == 0) continue;
                 for (KUPromotionResult *orgObject in array) {
                     if ([orgObject.id isEqualToString:eachOne.id]) {
                         [array removeObject:orgObject];
                         [array addObject:eachOne];
                         inLoop = true;
                         break;
                     }
                 }
                 if(!inLoop) {
                     [array addObject:eachOne];
                 }
             }
             self.promotion.results = array;
         } else {
             self.promotion = [[KUPromotion alloc] init];
             self.promotion.until = returnObject.until;
             NSMutableArray *array = [[NSMutableArray alloc] init];
             for (KUPromotionResult *eachOne in returnObject.results) {
                 if (eachOne.status == 0) continue;
                 [array addObject:eachOne];
             }
             self.promotion.results = array;
         }
     }];
}

- (NSArray *)getPromotionResult {
    NSMutableArray *returnArrya = [[NSMutableArray alloc] init];
    NSDate *now = [NSDate date];
    for (KUPromotionResult *each in self.promotion.results) {
        if ([each.displayUntil laterDate:now] && [each.displayAfter earlierDate: now]) {
            [returnArrya addObject:each];
        }
    }
    return returnArrya;
}

- (void)cacheProduct {
    NSNumber *until;
    if (self.product) {
        until = self.product.until;
    } else {
        until = @0;
    }
    [[KUAPIHelper sharedClient] getNewProducts:until success:^(KUProduct *returnObject) {
        if (self.product) {
            self.product.until = returnObject.until;
            NSMutableArray *array = [self.product.results mutableCopy];
            for (KUProductResult *eachOne in returnObject.results) {
                BOOL inLoop = false;
                if (eachOne.status == 0) continue;
                for (KUProductResult *orgObject in array) {
                    if ([orgObject.id isEqualToString:eachOne.id]) {
                        [array removeObject:orgObject];
                        [array addObject:eachOne];
                        inLoop = true;
                        break;
                    }
                }
                if(!inLoop) {
                    [array addObject:eachOne];
                }
            }
            self.product.results = array;
        } else {
            self.product = [[KUProduct alloc] init];
            self.product.until = returnObject.until;
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (KUProductResult *eachOne in returnObject.results) {
                if (eachOne.status == 0) continue;
                [array addObject:eachOne];
            }
            self.product.results = array;
        }
    }];
}

- (NSArray *)getProductResult {
    return self.product.results;
}

- (void)removeAllCache {
    self.accountPreference = nil;
    self.activity = nil;
    self.allCategories = nil;
    self.allStores = nil;
    self.regions = nil;
    self.promotion = nil;
    self.product = nil;
    self.allEvents = nil;
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
}
@end
