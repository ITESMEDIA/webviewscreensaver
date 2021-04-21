//
//  WebViewScreenSaverView.m
//  WebViewScreenSaver
//
//  Created by Alastair Tse on 8/8/10.
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

#import "WebViewScreenSaverView.h"

// ScreenSaverDefaults module name.
static NSString *const kScreenSaverName = @"WebViewScreenSaver";

@interface WebViewScreenSaverView () <WVSSConfigControllerDelegate,
                                      WKUIDelegate,
                                      WKNavigationDelegate>

@end

@implementation WebViewScreenSaverView {
  WKWebView *_webView;
  BOOL _isPreview;
}

+ (BOOL)performGammaFade {
  return YES;
}

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview {
  NSUserDefaults *prefs = [ScreenSaverDefaults defaultsForModuleWithName:kScreenSaverName];
  return [self initWithFrame:frame isPreview:isPreview prefsStore:prefs];
}

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview prefsStore:(NSUserDefaults *)prefs {
  self = [super initWithFrame:frame isPreview:isPreview];
  if (self) {
    [self setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [self setAutoresizesSubviews:YES];

    _isPreview = isPreview;

    // Load state from the preferences.
    self.configController = [[WVSSConfigController alloc] initWithUserDefaults:prefs];
    self.configController.delegate = self;
  }
  return self;
}

- (void)dealloc {
}

#pragma mark - Configure Sheet

- (BOOL)hasConfigureSheet {
  return YES;
}

- (NSWindow *)configureSheet {
  return [self.configController configureSheet];
}

- (void)configController:(WVSSConfigController *)configController
      dismissConfigSheet:(NSWindow *)sheet {
  if (_isPreview) {
    [self loadFromStart];
  }
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
  [[NSApplication sharedApplication] endSheet:sheet];
#pragma GCC diagnostic pop
}

#pragma mark ScreenSaverView

- (void)startAnimation {
  [super startAnimation];

  // Create the webview for the screensaver.
  WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
  WKPreferences *preferences = [[WKPreferences alloc] init];
  preferences.javaScriptCanOpenWindowsAutomatically = NO;
  configuration.preferences = preferences;

  _webView = [[WKWebView alloc] initWithFrame:[self bounds] configuration:configuration];
  _webView.UIDelegate = self;
  _webView.navigationDelegate = self;
  [_webView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
  [_webView setAutoresizesSubviews:YES];
  [self addSubview:_webView];

  NSColor *color = [NSColor colorWithCalibratedWhite:0.0 alpha:1.0];
  [[_webView layer] setBackgroundColor:color.CGColor];
  [_webView setValue:@(YES)
              forKey:@"drawsTransparentBackground"];  // Deprecated and internal but works

  [self loadFromStart];
}

- (void)stopAnimation {
  [super stopAnimation];
  [_webView removeFromSuperview];
  //  [_webView close];
  _webView = nil;
}

#pragma mark Loading URLs

- (void)loadFromStart {
  NSString *url = @"https://iteslive.tv/";

  if (self.configController.pin.length) {
      url = [NSString stringWithFormat:@"https://iteslive.tv/%@", self.configController.pin];
  }

  [self loadURLThing:url];
}

- (void)loadURLThing:(NSString *)urlString {
  NSString *escapedUrlString =
      [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  NSURL *url = [NSURL URLWithString:urlString];

  if (url.scheme == nil) {
    url = [NSURL URLWithString:[@"file://" stringByAppendingString:escapedUrlString]];
  }

  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

  if ([url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"]) {
    [_webView loadRequest:request];
  } else if ([url.scheme isEqualToString:@"file"] || url.scheme == nil) {
    [_webView loadFileURL:url allowingReadAccessToURL:[url URLByDeletingLastPathComponent]];
  } else {
    // no-op
  }
}

- (void)animateOneFrame {
  [super animateOneFrame];
}

#pragma mark Focus Overrides

// A bunch of methods that captures all the input events to prevent
// the webview from getting any keyboard focus.

- (NSView *)hitTest:(NSPoint)aPoint {
  return self;
}

- (BOOL)acceptsFirstResponder {
  return NO;
}

- (BOOL)resignFirstResponder {
  return NO;
}

#pragma mark WKNavigationDelegate

- (void)webView:(WKWebView *)webView
    decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
                    decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
  // Don't open new windows.
  if (navigationAction.targetFrame == nil) {
    decisionHandler(WKNavigationActionPolicyCancel);
  }
  decisionHandler(WKNavigationActionPolicyAllow);
}

@end
