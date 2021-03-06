//
//  ViewController.h
//  kxmovieapp
//
//  Created by Kolyvan on 11.10.12.
//  Copyright (c) 2012 Konstantin Boukreev . All rights reserved.
//
//  https://github.com/kolyvan/kxmovie
//  this file is part of KxMovie
//  KxMovie is licenced under the LGPL v3, see lgpl-3.0.txt

#import <UIKit/UIKit.h>

@protocol KxMovieViewControllerDelegate<NSObject>
- (void)movieViewControCallback:(CGFloat)vWidth vHeigh:(CGFloat)vHeigh vDuration:(CGFloat)vDuration;
- (void)updateMoviePlayPosition:(CGFloat)position duration:(CGFloat)duration;
@end

@class KxMovieDecoder;

extern NSString * const KxMovieParameterMinBufferedDuration;    // Float
extern NSString * const KxMovieParameterMaxBufferedDuration;    // Float
extern NSString * const KxMovieParameterDisableDeinterlacing;   // BOOL

@interface KxMovieViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

+ (id) movieViewControllerWithContentPath: (NSString *) path
                               parameters: (NSDictionary *) parameters;

@property (readonly) BOOL playing;
@property (readonly) int duration;
@property (nonatomic, weak) id<KxMovieViewControllerDelegate> delegate;

- (void) play;
- (void) pause;
- (void) playDidTouch: (id) sender;
- (void) setMoviePosition: (CGFloat) position;

- (NSUInteger)getVideoWidth;
- (NSUInteger)getVideoHeigh;
- (BOOL)isRoration;

- (CGFloat)decodeFrameAndPresent:(CGFloat *)duration;
@end
