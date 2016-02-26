//
//  SugarLeftMenu.h
//  MrCar
//
//  Created by 唐俊锋 on 15/5/26.
//
//

#import <UIKit/UIKit.h>

@protocol  SugarLeftMenuDelegate;


@interface SugarLeftMenu : UIViewController<UIGestureRecognizerDelegate>

@property(strong,readwrite,nonatomic)UIViewController *contentViewController;
@property(strong,readwrite,nonatomic)UIViewController *leftMenuViewController;
@property(weak,readwrite,nonatomic)id<SugarLeftMenuDelegate>delegate;


@property (assign,readwrite,nonatomic) NSTimeInterval animationDuration;
@property (strong,readwrite,nonatomic) UIImage        *backgroundImage;
@property (assign,readwrite,nonatomic) BOOL           panFromEdge;
@property (assign,readwrite,nonatomic) BOOL           panGestureEnabled;

@property (assign, readwrite, nonatomic) NSUInteger panMinimumOpenThreshold;
@property (assign, readwrite, nonatomic) IBInspectable BOOL interactivePopGestureRecognizerEnabled;

@property (assign, readwrite, nonatomic) IBInspectable BOOL contentViewShadowEnabled;
@property (strong, readwrite, nonatomic) IBInspectable UIColor *contentViewShadowColor;
@property (assign, readwrite, nonatomic) IBInspectable CGSize contentViewShadowOffset;
@property (assign, readwrite, nonatomic) IBInspectable CGFloat contentViewShadowOpacity;
@property (assign, readwrite, nonatomic) IBInspectable CGFloat contentViewShadowRadius;
@property (assign, readwrite, nonatomic) IBInspectable                        CGFloat                contentViewFadeOutAlpha;

@property (assign, readwrite, nonatomic) IBInspectable                        CGFloat                contentViewScaleValue;
@property (assign, readwrite, nonatomic) IBInspectable                        CGFloat                contentViewRotatingAngle;
@property (assign, readwrite, nonatomic) IBInspectable                        CGFloat                contentViewTranslateX;

@property (assign, readwrite, nonatomic) IBInspectable                        CGFloat                menuViewRotatingAngle;
@property (assign, readwrite, nonatomic) IBInspectable                        CGFloat                menuViewTranslateX;

#pragma mark
- (id)initWithContentViewController:(UIViewController *)contentViewController
             leftMenuViewController:(UIViewController *)leftMenuViewController;
- (void)presentLeftMenuViewController;
- (void)hideMenuViewController;
- (void)setContentViewController:(UIViewController *)contentViewController animated:(BOOL)animated;


@end

@protocol SugarLeftMenuDelegate <NSObject>

@optional
- (void)sideMenu:(SugarLeftMenu *)sideMenu didRecognizePanGesture:(UIPanGestureRecognizer *)recognizer;
- (void)sideMenu:(SugarLeftMenu *)sideMenu willShowMenuViewController:(UIViewController *)menuViewController;
- (void)sideMenu:(SugarLeftMenu *)sideMenu didShowMenuViewController:(UIViewController *)menuViewController;
- (void)sideMenu:(SugarLeftMenu *)sideMenu willHideMenuViewController:(UIViewController *)menuViewController;
- (void)sideMenu:(SugarLeftMenu *)sideMenu didHideMenuViewController:(UIViewController *)menuViewController;

@end
