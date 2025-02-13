//
// Copyright (c) 2015-2020 Microsoft Corporation and Contributors.
// SPDX-License-Identifier: Apache-2.0
//
#import <Foundation/Foundation.h>
#import "ODWLogManager.h"
#import "ODWLogger.h"
#import "ODWEventProperties.h"
#import "ODWPrivacyGuard.h"
#import "ODWCommonDataContext.h"

int main(int argc, char** argv){
    @autoreleasepool{
        // 1DSCppSdkTest sandbox key. Replace with your own iKey!
        NSString* token = @"7c8b1796cbc44bd5a03803c01c2b9d61-b6e370dd-28d9-4a52-9556-762543cf7aa7-6991";

        ODWLogger* myLogger = [ODWLogManager loggerWithTenant: token];

        ODWPrivacyGuardInitConfig* pgInitConfig = [[ODWPrivacyGuardInitConfig alloc] init];
        [[pgInitConfig useEventFieldPrefix]: TRUE]

        [pgInitConfig dataContext] = [[ODWCommondataContext alloc] init];
        /*
         * Values below are case-insensitive, except for User Names.
         * PrivacyGuard converts everything to uppercase and uses that for comparison
         */
        [[pgInitConfig dataContext] setDomainName:@"TEST.MICROSOFT.COM"];
        [[pgInitConfig dataContext] setMachineName:@"Motherboard"];
        [[pgInitConfig dataContext] UserNames] = [[NSMutableArray alloc] init];
        [[[pgInitConfig dataContext] UserNames] addObject:@"Awesome Username"];
        [[pgInitConfig dataContext] UserAliases] = [[NSMutableArray alloc] init];
        [[[pgInitConfig dataContext] UserAliases] addObject:@"awesomeuser" ];
        [[pgInitConfig dataContext] IpAddresses] = [[NSMutableArray alloc] init];
        [[[pgInitConfig dataContext] IpAddresses] addObject:@"10.0.1.1"];
        [[[pgInitConfig dataContext] IpAddresses] addObject:@"192.168.1.1"];
        [[[pgInitConfig dataContext] IpAddresses] addObject:@"1234:4578:9abc:def0:bea4:ca4:ca1:d0g"];
        [[pgInitConfig dataContext] LanguageIdentifiers] = [[NSMutableArray alloc] init];
        [[[pgInitConfig dataContext] LanguageIdentifiers] addObject:@"en-US"];
        [[[pgInitConfig dataContext] LanguageIdentifiers] addObject:@"English (United States)"];
        [[pgInitConfig dataContext] MachineIds] = [[NSMutableArray alloc] init];
        [[[pgInitConfig dataContext] MachineIds] addObject:@"0450fe66-aeed-4059-99ca-4dd8702cbd1f"];
        [[pgInitConfig dataContext] OutOfScopeIdentifiers] = [[NSMutableArray alloc] init];
        [[[pgInitConfig dataContext] OutOfScopeIdentifiers] addObject:@"43efb3b1-c7a3-4f29-beea-63ccb28160ac"];
        [[[pgInitConfig dataContext] OutOfScopeIdentifiers] addObject:@"7d06a83a-200d-4ccb-bfc6-d0995c840bde"];
        [[[pgInitConfig dataContext] OutOfScopeIdentifiers] addObject:@"e1b2ece8-2451-4ea9-997a-6f37b50be8de"];

        if(myLogger){
            //If you have the logger, initializePrivacyGuard before logging data to ensure everything is inspected.
            [myLogger initializePrivacyGuardWithODWPrivacyGuardInitConfig: pgInitConfig];

            [myLogger logEventWithName: @"Simple_ObjC_Event"];
        }
        [ODWLogManager uploadNow];

        ODWEventProperties* event = [[ODWEventProperties alloc] initWithName: @"WEvtProps_ObjC_Event"
                                                           properties: @{
                                                                            @"result": @"Success", 
                                                                            @"seq": @2, 
                                                                            @"random": @3,
                                                                            @"secret": @5.75 
                                                                            } ];

        ODWLogger* logger2 = [ODWLogManager loggerForSource: @"source2"];
        if(logger2){
            [logger2 logEventWithEventProperties: event];
        }
        [ODWLogManager uploadNow];

        ODWEventProperties* event2 = [[ODWEventProperties alloc] initWithName:@"SetProps_ObjC_Event"];
        [event2 setProperty: @"result" withValue: @"Failure"];
        [event2 setProperty: @"intVal" withInt64Value: (int64_t)8165];
        [event2 setProperty: @"doubleVal" withDoubleValue: (double)1.24];
        [event2 setProperty: @"wasSuccessful" withBoolValue: YES];
        [event2 setProperty: @"myDate" withDateValue: [NSDate date]];
        [event2 setProperty: @"transactionId" withUUIDValue: [[NSUUID alloc] initWithUUIDString:@"DEADBEEF-1234-2345-3456-123456789ABC"]];

        [logger2 logEventWithEventProperties: event2];

        [[logger2 semanticContext] setAppId:@"MyAppId"];
        [[logger2 semanticContext] setUserId:@"m:1010101010101010"];
        [[logger2 semanticContext] setUserAdvertisingId:@"p:00000000-0000-0000-0000-000000000000"];
        ODWEventProperties* event3 = [[ODWEventProperties alloc] initWithName:@"SemanticContext_ObjC_Event"];
        [logger2 logEventWithEventProperties: event3];

        [logger2 logEventWithName:@"SemanticContext_EmptyEvent"];
        [ODWLogManager flushAndTeardown];
    }
    return 0;
}
