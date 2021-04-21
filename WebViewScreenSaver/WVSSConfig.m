//
//  WVSSConfig.m
//  WebViewScreenSaver
//
//  Created by Alastair Tse on 26/04/2015.
//
//  Copyright 2015 Alastair Tse.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "WVSSConfig.h"

// ScreenSaverDefault Keys
static NSString *const kScreenSaverPinKey = @"kScreenSaverPin";      // NSString (PIN)

@interface WVSSConfig ()
@property(nonatomic, strong) NSUserDefaults *userDefaults;
@end

@implementation WVSSConfig

- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults {
  self = [super init];
  if (self) {
    self.userDefaults = userDefaults;

    self.pin = [self loadPinFromUserDefaults:userDefaults];

    if (!self.pin) {
      self.pin = @"";
    }
  }
  return self;
}

- (NSString *)loadPinFromUserDefaults:(NSUserDefaults *)userDefaults {
  NSString *pinFromUserDefaults =
      [[userDefaults stringForKey:kScreenSaverPinKey] mutableCopy];
  return pinFromUserDefaults;
}

- (void)savePinToUserDefaults:(NSUserDefaults *)userDefaults {
  [userDefaults setObject:self.pin forKey:kScreenSaverPinKey];
}

- (void)synchronize {
  [self savePinToUserDefaults:self.userDefaults];
  [self.userDefaults synchronize];
}

@end
