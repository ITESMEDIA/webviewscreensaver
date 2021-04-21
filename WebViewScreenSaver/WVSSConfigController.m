//
//  WVSSConfigController.m
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

#import "WVSSConfigController.h"
#import "WVSSConfig.h"

#import <WebKit/WebKit.h>

static NSString *const kURLTableRow = @"kURLTableRow";
// Configuration sheet columns.
static NSString *const kTableColumnURL = @"url";
static NSString *const kTableColumnTime = @"time";

NS_ENUM(NSInteger, WVSSColumn){kWVSSColumnURL = 0, kWVSSColumnDuration = 1};

@interface WVSSConfigController ()
@property(nonatomic, strong) WVSSConfig *config;
@end

@implementation WVSSConfigController

- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults {
  self = [super init];
  if (self) {
    self.config = [[WVSSConfig alloc] initWithUserDefaults:userDefaults];
  }
  return self;
}

- (void)synchronize {
  self.config.pin = self.pinField.stringValue;
  [self.config synchronize];
}

- (NSString *)pin {
  return self.config.pin;
}

#pragma mark - Actions

- (IBAction)resetData:(id)sender {
  NSAlert *alert = [[NSAlert alloc] init];
  [alert setMessageText:@"Clear History"];
  [alert setInformativeText:@"Clears history, cookies, cache and more."];
  [alert setIcon:[NSImage imageNamed:NSImageNameCaution]];
  [alert addButtonWithTitle:@"Clear Data"];
  [alert addButtonWithTitle:@"Cancel"];
  [alert setAlertStyle:NSAlertStyleWarning];
  [alert beginSheetModalForWindow:self.sheet
                completionHandler:^(NSModalResponse returnCode) {
                  if (returnCode == NSAlertFirstButtonReturn) {
                    [self clearWebViewHistory];
                  }
                }];
}

- (void)clearWebViewHistory {
  NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
  NSDate *since = [NSDate dateWithTimeIntervalSince1970:0];
  [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes
                                             modifiedSince:since
                                         completionHandler:^{
                                           NSLog(@"Web cache cleared");
                                         }];
}

#pragma mark - User Interface

- (NSWindow *)configureSheet {
  if (!self.sheet) {
    NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
    if (![thisBundle loadNibNamed:@"ConfigureSheet" owner:self topLevelObjects:NULL]) {
      // NSLog(@"Unable to load configuration sheet");
    }

    // If there is a urlListURL.
    if (self.config.pin.length) {
      self.pinField.stringValue = self.config.pin;
    } else {
      self.pinField.stringValue = @"";
    }
  }
  return self.sheet;
}

- (IBAction)dismissConfigSheet:(id)sender {
  [self synchronize];
  [self.delegate configController:self dismissConfigSheet:self.sheet];
}

@end
