//
//  SugarLeftMenu.m
//  MrCar
//
//  Created by 唐俊锋 on 15/5/26.
//
//

#import "SugarLeftMenu.h"

@interface SugarLeftMenu ()



@property (assign, readwrite, nonatomic) CGFloat     totalAngle;
@property (assign, readwrite, nonatomic) CGPoint     lastPoint;
@property (strong, readwrite, nonatomic) UIImageView *backgroundImageView;
@property (assign, readwrite, nonatomic) BOOL        visible;
@property (assign, readwrite, nonatomic) BOOL        leftMenuVisible;
@property (strong, readwrite, nonatomic) UIButton    *contentButton;

@property (strong, readwrite, nonatomic) UIView      *menuViewContainer;
@property (strong, readwrite, nonatomic) UIView      *contentViewContainer;

@property (assign, readwrite, nonatomic) BOOL        didNotifyDelegate;

@end

@implementation SugarLeftMenu

#pragma mark -
#pragma mark Instance lifecycle

- (id)init
{
    self                                                           = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self                                                           = [super initWithCoder:decoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

//initial setup
- (void)commonInit
{
    _menuViewContainer                                             = [[UIView alloc] init];
    _contentViewContainer                                          = [[UIView alloc] init];

    _animationDuration                                             = 0.35f;
    _interactivePopGestureRecognizerEnabled                        = YES;

    _panGestureEnabled                                             = YES;
    _panFromEdge                                                   = YES;
    _panMinimumOpenThreshold                                       = 60.0;

    _contentViewShadowEnabled                                      = NO;
    _contentViewShadowColor                                        = [UIColor blackColor];
    _contentViewShadowOffset                                       = CGSizeZero;
    _contentViewShadowOpacity                                      = 0.4f;
    _contentViewShadowRadius                                       = 8.0f;
    _contentViewFadeOutAlpha                                       = 1.0f;

    _contentViewScaleValue                                         = 0.7f;
    _contentViewRotatingAngle                                      = 30.0f;
    _contentViewTranslateX                                         = 150.0f;

    _menuViewRotatingAngle                                         = 30.0f;
    _menuViewTranslateX                                            = 150.0f;
}

#pragma mark -
#pragma mark Public methods

- (id)initWithContentViewController:(UIViewController *)contentViewController leftMenuViewController:(UIViewController *)leftMenuViewController
{
    self                                                           = [self init];
    if (self) {

    _contentViewController                                         = contentViewController;
    _leftMenuViewController                                        = leftMenuViewController;
    }
    return self;
}

- (void)presentLeftMenuViewController
{
    [self presentMenuViewContainerWithMenuViewController:self.leftMenuViewController];
    [self showLeftMenuViewController];
}

- (void)hideMenuViewController
{
    [self hideMenuViewControllerAnimated:YES];
}

- (void)setContentViewController:(UIViewController *)contentViewController animated:(BOOL)animated
{
    if (_contentViewController == contentViewController)
    {
        return;
    }

    //contentview controller updated
    if (!animated) {
        [self setContentViewController:contentViewController];
    } else {

        [self addChildViewController:contentViewController];
    contentViewController.view.alpha                               = 0;
    contentViewController.view.frame                               = self.contentViewContainer.bounds;
        [self.contentViewContainer addSubview:contentViewController.view];

        [UIView animateWithDuration:self.animationDuration animations:^{
    contentViewController.view.alpha                               = 1;
        } completion:^(BOOL finished) {
            [self hideViewController:self.contentViewController];
            [contentViewController didMoveToParentViewController:self];
    _contentViewController                                         = contentViewController;

            [self updateContentViewShadow];

        }];
    }
}

#pragma mark View life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.autoresizingMask                                     = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    self.backgroundImageView                                       = ({
    UIImageView *imageView                                         = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.image                                                = self.backgroundImage;
    imageView.contentMode                                          = UIViewContentModeScaleAspectFill;
    imageView.autoresizingMask                                     = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        imageView;
    });
    self.contentButton                                             = ({
    UIButton *button                                               = [[UIButton alloc] initWithFrame:CGRectNull];
        [button addTarget:self action:@selector(hideMenuViewController) forControlEvents:UIControlEventTouchUpInside];
        button;
    });

    [self.view addSubview:self.backgroundImageView];
    [self.view addSubview:self.menuViewContainer];
    [self.view addSubview:self.contentViewContainer];
    [self.view bringSubviewToFront:self.contentViewContainer];

    self.menuViewContainer.frame                                   = self.view.bounds;
    self.menuViewContainer.autoresizingMask                        = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    if (self.leftMenuViewController) {

        [self addChildViewController:self.leftMenuViewController];
    self.leftMenuViewController.view.frame                         = self.view.bounds;
    self.leftMenuViewController.view.autoresizingMask              = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        [self.menuViewContainer addSubview:self.leftMenuViewController.view];
        [self.leftMenuViewController didMoveToParentViewController:self];
    }

    self.contentViewContainer.frame                                = self.view.bounds;
    self.contentViewContainer.autoresizingMask                     = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    [self addChildViewController:self.contentViewController];
    self.contentViewController.view.frame                          = self.view.bounds;
    [self.contentViewContainer addSubview:self.contentViewController.view];
    [self.contentViewController didMoveToParentViewController:self];


    if (self.panGestureEnabled) {
    self.view.multipleTouchEnabled                                 = NO;
    UIPanGestureRecognizer *panGestureRecognizer                   = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
    panGestureRecognizer.delegate                                  = self;
        [_contentViewContainer addGestureRecognizer:panGestureRecognizer];
    }

    [_contentViewContainer setBackgroundColor:[UIColor clearColor]];
    [self updateContentViewShadow];
}

#pragma mark -
#pragma mark Private methods

- (void)presentMenuViewContainerWithMenuViewController:(UIViewController *)menuViewController
{
    [self setAnchorPoint:CGPointMake(0.0, 0.5) forView:_menuViewContainer];
    self.menuViewContainer.transform                               = CGAffineTransformIdentity;
    self.menuViewContainer.frame                                   = self.view.bounds;

    //menu view rotation transform
    CATransform3D menuRotationTransform                            = _leftMenuViewController.view.layer.transform;
    menuRotationTransform                                          = CATransform3DMakeRotation(_menuViewRotatingAngle * M_PI/180.0f, 0.0f, -1.0f, 0.0f);
    CATransform3D sublayerTransform                                = _leftMenuViewController.view.superview.layer.sublayerTransform;
    sublayerTransform.m34                                          = 1.0f / -300.0f;
    _leftMenuViewController.view.superview.layer.sublayerTransform = sublayerTransform;
    _leftMenuViewController.view.layer.transform                   = menuRotationTransform;

    //rotation view translate transform
    CATransform3D menuTranslateTransform                           = _menuViewContainer.layer.transform;
    menuTranslateTransform                                         = CATransform3DTranslate(menuTranslateTransform, -_menuViewTranslateX, 0, 0);
    _menuViewContainer.layer.transform                             = menuTranslateTransform;

    if ([self.delegate conformsToProtocol:@protocol(SugarLeftMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:willShowMenuViewController:)]) {
        [self.delegate sideMenu:self willShowMenuViewController:menuViewController];
    }
}

- (void)showLeftMenuViewController
{
    if (!self.leftMenuViewController) {
        return;
    }

    [self.leftMenuViewController beginAppearanceTransition:YES animated:YES];
    self.leftMenuViewController.view.hidden                        = NO;
    [self.view.window endEditing:YES];

    [self addContentButton];
    [self updateContentViewShadow];

    //anchor point set to change the origin of rotation. value ranges from 0 to 1.0 (0 to width/height)
    [self setAnchorPoint:CGPointMake(0.0, 0.5) forView:_menuViewContainer];
    [self setAnchorPoint:CGPointMake(1.0, 0.5) forView:_contentViewContainer];
    [self setAnchorPoint:CGPointMake(1.0, 0.5) forView:_contentViewController.view];

    [UIView animateWithDuration:self.animationDuration animations:^{

        //content view scale transform
    CATransform3D contentScaleTransform                            = _contentViewContainer.layer.transform;
    contentScaleTransform                                          = CATransform3DMakeScale(_contentViewScaleValue, _contentViewScaleValue,1.0f);
    _contentViewContainer.layer.transform                          = contentScaleTransform;

        //content view rotate transform
    CATransform3D contentRotateTransform                           = _contentViewController.view.layer.transform;
    contentRotateTransform                                         = CATransform3DMakeRotation(_contentViewRotatingAngle * M_PI/180.0f, 0.0f, -1.0f, 0.0f);
    CATransform3D sublayerTransform                                = _contentViewController.view.superview.layer.sublayerTransform;
    sublayerTransform.m34                                          = 1.0f / -300.0f;
    _contentViewController.view.superview.layer.sublayerTransform  = sublayerTransform;
    _contentViewController.view.layer.transform                    = contentRotateTransform;

        //content view translate transform
    CATransform3D contentTranslateTransform                        = _contentViewContainer.layer.transform;
    contentTranslateTransform                                      = CATransform3DTranslate(contentTranslateTransform, _contentViewTranslateX, 0, 0);
    _contentViewContainer.layer.transform                          = contentTranslateTransform;

        //menu view rotate transform
    CATransform3D menuRotateTransform                              = _leftMenuViewController.view.layer.transform;
    menuRotateTransform                                            = CATransform3DMakeRotation(0 * M_PI/180.0f, 0.0f, -1.0f, 0.0f);
    CATransform3D sublayerTransform1                               = _leftMenuViewController.view.superview.layer.sublayerTransform;
    sublayerTransform1.m34                                         = 1.0f / -300.0f;
    _leftMenuViewController.view.superview.layer.sublayerTransform = sublayerTransform1;
    _leftMenuViewController.view.layer.transform                   = menuRotateTransform;

    _menuViewContainer.layer.transform                             = CATransform3DIdentity;

    } completion:nil];

}


- (void)hideViewController:(UIViewController *)viewController
{
    [viewController willMoveToParentViewController:nil];
    [viewController.view removeFromSuperview];
    [viewController removeFromParentViewController];
}

//hide left menu view controller
- (void)hideMenuViewControllerAnimated:(BOOL)animated
{
    UIViewController *visibleMenuViewController                    = self.leftMenuViewController;
    [visibleMenuViewController beginAppearanceTransition:NO animated:animated];
    if ([self.delegate conformsToProtocol:@protocol(SugarLeftMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:willHideMenuViewController:)]) {
        [self.delegate sideMenu:self willHideMenuViewController:self.leftMenuViewController];
    }

    self.visible                                                   = NO;
    self.leftMenuVisible                                           = NO;
    [self.contentButton removeFromSuperview];

    __typeof (self) __weak weakSelf                                = self;
    void (^animationBlock)(void)                                   = ^{
    __typeof (weakSelf) __strong strongSelf                        = weakSelf;
        if (!strongSelf) {
            return;
        }

        [UIView animateWithDuration:self.animationDuration animations:^{

            //content view scale transform
    CATransform3D contentScaleTransform                            = _contentViewContainer.layer.transform;
    contentScaleTransform                                          = CATransform3DMakeScale(1.0, 1.0,1.0f);
    _contentViewContainer.layer.transform                          = contentScaleTransform;

            //content view rotate transform
    CATransform3D contentRotateTransform                           = _contentViewController.view.layer.transform;
    contentRotateTransform                                         = CATransform3DMakeRotation(0 * M_PI/180.0f, 0.0f, 1.0f, 0.0f);
    CATransform3D sublayerTransform                                = _contentViewController.view.superview.layer.sublayerTransform;
    sublayerTransform.m34                                          = 1.0f / -300.0f;
    _contentViewController.view.superview.layer.sublayerTransform  = sublayerTransform;
    _contentViewController.view.layer.transform                    = contentRotateTransform;

            //content view translate transform
    CATransform3D contentTranslateTransform                        = _contentViewContainer.layer.transform;
    contentTranslateTransform                                      = CATransform3DTranslate(contentTranslateTransform, 0, 0, 0);
    _contentViewContainer.layer.transform                          = contentTranslateTransform;

            //menu view rotate transform
    CATransform3D menuRotateTransform                              = _leftMenuViewController.view.layer.transform;
    menuRotateTransform                                            = CATransform3DMakeRotation(_menuViewRotatingAngle * M_PI/180.0f, 0.0f, -1.0f, 0.0f);
    CATransform3D sublayerTransform1                               = _leftMenuViewController.view.superview.layer.sublayerTransform;
    sublayerTransform1.m34                                         = 1.0f / -300.0f;
    _leftMenuViewController.view.superview.layer.sublayerTransform = sublayerTransform1;
    _leftMenuViewController.view.layer.transform                   = menuRotateTransform;

            //menu view translate transform
    CATransform3D menuTranslateTransform                           = CATransform3DIdentity;
    menuTranslateTransform                                         = CATransform3DTranslate(menuTranslateTransform, -_menuViewTranslateX, 0, 0);
    _menuViewContainer.layer.transform                             = menuTranslateTransform;


        } completion:nil];

    strongSelf.contentViewContainer.frame                          = strongSelf.view.bounds;


    };
    void (^completionBlock)(void)                                  = ^{
    __typeof (weakSelf) __strong strongSelf                        = weakSelf;
        if (!strongSelf) {
            return;
        }
        [visibleMenuViewController endAppearanceTransition];
        if (!strongSelf.visible && [strongSelf.delegate conformsToProtocol:@protocol(SugarLeftMenuDelegate)] && [strongSelf.delegate respondsToSelector:@selector(sideMenu:didHideMenuViewController:)]) {
            [strongSelf.delegate sideMenu:strongSelf didHideMenuViewController:strongSelf.leftMenuViewController];
        }
    };

    if (animated) {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        [UIView animateWithDuration:self.animationDuration animations:^{
            animationBlock();
        } completion:^(BOOL finished) {
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            completionBlock();
        }];
    } else {
        animationBlock();
        completionBlock();
    }
}

//content button added as subview when left menu is shown
- (void)addContentButton
{
    if (self.contentButton.superview)
        return;

    self.contentButton.autoresizingMask                            = UIViewAutoresizingNone;
    self.contentButton.frame                                       = self.contentViewContainer.bounds;
    self.contentButton.autoresizingMask                            = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentViewController.view addSubview:self.contentButton];
}


//update shadow to content view
- (void)updateContentViewShadow
{
    if (self.contentViewShadowEnabled) {
    CALayer *layer                                                 = self.contentViewController.view.layer;
    UIBezierPath *path                                             = [UIBezierPath bezierPathWithRect:layer.bounds];
    layer.shadowPath                                               = path.CGPath;
    layer.shadowColor                                              = self.contentViewShadowColor.CGColor;
    layer.shadowOffset                                             = self.contentViewShadowOffset;
    layer.shadowOpacity                                            = self.contentViewShadowOpacity;
    layer.shadowRadius                                             = self.contentViewShadowRadius;
    }
}

#pragma mark -
#pragma mark UIGestureRecognizer Delegate (Private)

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if(![self isPreiOS8]){
        if (self.interactivePopGestureRecognizerEnabled && [self.contentViewController isKindOfClass:[UINavigationController class]]) {
    UINavigationController *navigationController                   = (UINavigationController *)self.contentViewController;
            if (navigationController.viewControllers.count > 1 && navigationController.interactivePopGestureRecognizer.enabled) {
                return NO;
            }
        }
    }else {

        if (self.panFromEdge && [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && !self.visible) {
    CGPoint point                                                  = [touch locationInView:gestureRecognizer.view];
            if (point.x < 20.0 || point.x > self.view.frame.size.width - 20.0) {
                return YES;
            } else {
                return NO;
            }
        }

    }

    return YES;
}

#pragma mark -
#pragma mark Pan gesture recognizer (Private)

- (void)panGestureRecognized:(UIPanGestureRecognizer *)recognizer
{
    if ([self.delegate conformsToProtocol:@protocol(SugarLeftMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:didRecognizePanGesture:)])
        [self.delegate sideMenu:self didRecognizePanGesture:recognizer];

    if (!self.panGestureEnabled) {
        return;
    }

    CGPoint point                                                  = [recognizer translationInView:self.view];

    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self updateContentViewShadow];
    _totalAngle                                                    = 0;
    _lastPoint                                                     = CGPointMake(0, 0);

        [self addContentButton];
        [self.view.window endEditing:YES];
    self.didNotifyDelegate                                         = NO;
    }

    if (recognizer.state == UIGestureRecognizerStateChanged) {

    CGPoint newLocationPoint                                       = point;
        //track movement til x value is 300
        if(newLocationPoint.x >= 0 && newLocationPoint.x <= 300)
        {
            [self setAnchorPoint:CGPointMake(1.0, 0.5) forView:_contentViewContainer];
            [self setAnchorPoint:CGPointMake(1.0, 0.5) forView:_contentViewController.view];

            //calculation of scale, angle & translate for content view based on pan position
    CGFloat contentViewScale                                       = 1 + (_contentViewScaleValue - 1)* (newLocationPoint.x / 300);
    CGFloat angle                                                  = (newLocationPoint.x - _lastPoint.x) * _contentViewRotatingAngle/300;
    CGFloat tranformX                                              = newLocationPoint.x * _contentViewTranslateX/300;

            [UIView animateWithDuration:self.animationDuration animations:^{

    _totalAngle                                                    = _totalAngle + angle;

                //content view scale transform
    CATransform3D contentScaleTransform                            = _contentViewContainer.layer.transform;
    contentScaleTransform                                          = CATransform3DMakeScale(contentViewScale, contentViewScale,1.0f);
    _contentViewContainer.layer.transform                          = contentScaleTransform;

                //content view rotate transform
    CATransform3D contentRotateTransform                           = _contentViewController.view.layer.transform;
    contentRotateTransform                                         = CATransform3DMakeRotation(_totalAngle * M_PI/180.0f, 0.0f, -1.0f, 0.0f);
    CATransform3D sublayerTransform                                = _contentViewController.view.superview.layer.sublayerTransform;
    sublayerTransform.m34                                          = 1.0f / -300.0f;
    _contentViewController.view.superview.layer.sublayerTransform  = sublayerTransform;
    _contentViewController.view.layer.transform                    = contentRotateTransform;

                //content view translate transform
    CATransform3D contentTranslateTransform                        = _contentViewContainer.layer.transform;
    contentTranslateTransform                                      = CATransform3DTranslate(contentTranslateTransform, tranformX, 0, 0);
    _contentViewContainer.layer.transform                          = contentTranslateTransform;


                //calculation of scale, angle & translate for menu view based on pan position
    CGFloat menuAngle                                              = _menuViewRotatingAngle - (newLocationPoint.x) * _menuViewRotatingAngle/300;
    CGFloat menuTransformValue                                     = (_menuViewTranslateX * newLocationPoint.x/300) - _menuViewTranslateX - _menuViewContainer.frame.origin.x;

                //menu view rotate transform
    CATransform3D menuRotateTransform                              = _leftMenuViewController.view.layer.transform;
    menuRotateTransform                                            = CATransform3DMakeRotation(menuAngle * M_PI/180.0f, 0.0f, -1.0f, 0.0f);
    CATransform3D sublayerTransform1                               = _leftMenuViewController.view.superview.layer.sublayerTransform;
    sublayerTransform1.m34                                         = 1.0f / -300.0f;
    _leftMenuViewController.view.superview.layer.sublayerTransform = sublayerTransform1;
    _leftMenuViewController.view.layer.transform                   = menuRotateTransform;

                //menu view translate transform
    CATransform3D menuTranslateTransform                           = _menuViewContainer.layer.transform;
    menuTranslateTransform                                         = CATransform3DTranslate(menuTranslateTransform, menuTransformValue, 0, 0);
    _menuViewContainer.layer.transform                             = menuTranslateTransform;

            } completion:nil];
    _lastPoint.x                                                   = newLocationPoint.x;
        }


    self.leftMenuViewController.view.hidden                        = self.contentViewContainer.frame.origin.x < 0;

        if (!self.leftMenuViewController && self.contentViewContainer.frame.origin.x > 0) {

    self.contentViewContainer.transform                            = CGAffineTransformIdentity;
    self.contentViewContainer.frame                                = self.view.bounds;
    self.visible                                                   = NO;
    self.leftMenuVisible                                           = NO;
        }

    }

    if (recognizer.state == UIGestureRecognizerStateEnded) {

    self.didNotifyDelegate                                         = NO;

        // if minimum open threshold not satisfied, left menu is closed again
        if (self.panMinimumOpenThreshold > 0 && (self.contentViewContainer.frame.origin.x > 0 && self.contentViewContainer.frame.origin.x < self.panMinimumOpenThreshold))
        {
            [self hideMenuViewController];
        }
        else if (self.contentViewContainer.frame.origin.x == 0) {
            [self hideMenuViewControllerAnimated:NO];
        }
        else {
            if ([recognizer velocityInView:self.view].x > 0) {
                if (self.contentViewContainer.frame.origin.x < 0) {
                    [self hideMenuViewController];
                } else {
                    if (self.leftMenuViewController) {
                        [self showLeftMenuViewController];
                    }
                }
            }
        }
    }

}

#pragma mark -
#pragma mark Setters

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    _backgroundImage                                               = backgroundImage;
    if (self.backgroundImageView)
    self.backgroundImageView.image                                 = backgroundImage;
}

- (void)setContentViewController:(UIViewController *)contentViewController
{
    if (!_contentViewController) {
    _contentViewController                                         = contentViewController;
        return;
    }
    [self hideViewController:_contentViewController];

    contentViewController.view.layer.transform                     = _contentViewController.view.layer.transform;
    contentViewController.view.layer.sublayerTransform             = _contentViewController.view.layer.sublayerTransform;
    _contentViewController                                         = contentViewController;

    [self addChildViewController:self.contentViewController];
    [self.contentViewContainer addSubview:self.contentViewController.view];
    [self.contentViewController didMoveToParentViewController:self];

    [self updateContentViewShadow];


    [self hideMenuViewController];
}
- (void)setLeftMenuViewController:(UIViewController *)leftMenuViewController
{
    if (!_leftMenuViewController) {
    _leftMenuViewController                                        = leftMenuViewController;
        return;
    }
    [self hideViewController:_leftMenuViewController];
    _leftMenuViewController                                        = leftMenuViewController;

    [self addChildViewController:self.leftMenuViewController];
    self.leftMenuViewController.view.frame                         = self.view.bounds;
    self.leftMenuViewController.view.autoresizingMask              = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.menuViewContainer addSubview:self.leftMenuViewController.view];
    [self.leftMenuViewController didMoveToParentViewController:self];

}

#pragma mark - Utilities
- (void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view {
    CGPoint oldOrigin                                              = view.frame.origin;
    view.layer.anchorPoint                                         = anchorPoint;
    CGPoint newOrigin                                              = view.frame.origin;

    CGPoint transition;
    transition.x                                                   = newOrigin.x - oldOrigin.x;
    transition.y                                                   = oldOrigin.y - oldOrigin.y;

    view.center                                                    = CGPointMake (view.center.x - transition.x, view.center.y - transition.y);
}

- (BOOL)isPreiOS8
{
    if ([NSProcessInfo instancesRespondToSelector:@selector(isOperatingSystemAtLeastVersion:)]) {
        // conditionally check for any version >= iOS 8 using 'isOperatingSystemAtLeastVersion'
        return NO;
    }

    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation

 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
*/

@end
