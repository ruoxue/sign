/**
 Copyright (c) 2017 Uber Technologies, Inc.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "UBSignatureDrawingViewController.h"
#import "UBSignatureDrawingModelAsync.h"

@interface UBSignatureDrawingViewController ()
{
    NSInteger drawTimes;// 需要绘制的点的数量
    NSInteger blockTimes;// 每一次绘制完成后，block回调执行次数
}

@property (nonatomic) BOOL isEmpty;

@property (nonatomic, readonly) UBSignatureDrawingModelAsync *model;
@property (nonatomic, readonly) NSOperationQueue *modelOperationQueue;
@property (nonatomic) CAShapeLayer *bezierPathLayer;

@property (nonatomic) UIImageView *imageView;

@property (nonatomic) UIImage *presetImage;

@end

@implementation UBSignatureDrawingViewController

#pragma mark - Init

- (instancetype)init
{
    return [self initWithImage:nil];
}

- (instancetype)initWithImage:(UIImage *)image
{
    if (self = [super initWithNibName:nil bundle:nil]) {
        _presetImage = image;
        _isEmpty = (!image);
        
        _model = [[UBSignatureDrawingModelAsync alloc] init];
    }
    
    return self;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
//    [self draw:@"(255,255,19912,0)(82,71,243,0)(73,75,52,0;75,52,0,0;52,0,17920,0;0,17920,19203,0)(77,73,908,0;53252,36920,49152,0;18691,35840,87,0)(110,70,500,0;57348,24607,16384,0;17921,62464,118,0)(130,63,337,0;33280,16129,20736,0)(123,52,276,0;45059,16401,16384,0;13313,5120,119,0)(107,54,788,0;27392,13827,5120,0)(102,85,323,0;24581,20500,12288,0;21761,17152,104,0)(109,103,291,0;53254,28690,12288,0;26369,8960,113,0)(126,82,460,0;32256,20993,52224,0)(129,75,796,0;4100,45105,49152,0;19203,7168,128,0)(126,96,282,0;57350,17,40961,0;24577,6656,4252,0)(205,62,419,0;53251,57370,12288,0;15873,41728,207,0)(209,75,787,0;75,787,0,0;787,0,53504,0;0,53504,19714,0)(209,106,450,0;106,450,0,0;450,0,53760,0;0,53760,27905,0)(222,103,697,0;56832,26370,47360,0)(239,80,914,0;61184,20483,37376,0)(253,75,915,0;53252,45113,12288,0;19203,37632,252,0)(248,100,211,0;63488,25600,54016,0)(244,113,1001,0;62464,28931,59648,0)(253,99,754,0;64768,25346,61952,0)(259,98,777,0;12294,8240,36864,0;25091,2304,256,0)(262,188,275,0)"];
    
    [self draw:self.pointStr];
}

#pragma mark - Public

- (void)reset
{
    [self.model reset];
    [self _updateViewFromModel];
}

- (UIImage *)fullSignatureImage
{
    return [self.model fullSignatureImage];
}

- (UIColor *)signatureColor
{
    return self.model.signatureColor;
}

- (void)setSignatureColor:(UIColor *)signatureColor
{
    self.model.signatureColor = signatureColor;
    self.bezierPathLayer.strokeColor = self.signatureColor.CGColor;
    self.bezierPathLayer.fillColor = self.signatureColor.CGColor;
}

- (void)setIsEmpty:(BOOL)isEmpty
{
    if (self.isEmpty == isEmpty) {
        return;
    }
    
    _isEmpty = isEmpty;
    
    if ([self.delegate respondsToSelector:@selector(signatureDrawingViewController:isEmptyDidChange:)]) {
        [self.delegate signatureDrawingViewController:self isEmptyDidChange:self.isEmpty];
    }
}


- (void)endPoint
{
    
    [self.model asyncEndContinuousLine];
    [self _updateViewFromModel];
}


-(void)draw:(NSString*)str{
    
    
    NSRange range = [str rangeOfString:@"("];
    NSString *ret=NULL;
    if (range.location != NSNotFound) {
        
        ret= [str substringFromIndex:range.location];
        
        NSLog(@"---%@",ret);
        
    }else{
        ret=str;
        NSLog(@"Not Found");
        
    }
    
    
    drawTimes = 0;
    blockTimes = 0;
    [self draw2:ret];
    //[self draw2:ret];
}
-(void)draw2:(NSString*)str {
    
    NSArray *array0 = [str componentsSeparatedByString:@")"];
    
   
    NSInteger count =array0.count;
    for(NSInteger i=0; i<count; i++){
        NSString *strItem0=array0[i];
        NSArray *array = [strItem0 componentsSeparatedByString:@";"];
        
        // 去掉几个多余的“点”，3个位置的点“可能”需要去除
        if (i==0||i==count-1||i==count-2) {
            NSString *s = array0[i];
            // 这里判断一下点位字符串，如果不包含';'，那么应该是多余点位
            if(![s containsString:@";"]){
                continue;
            }
        }
        
        for(NSString* strItem in array){
            
            if([strItem isEqualToString:@""]){
                drawTimes++;
               [self endPoint];
                continue;
            }
            NSLog(@"strItem%@",strItem);
            
            NSString *strItem0 = [strItem stringByReplacingOccurrencesOfString:@"(" withString:@""]; // 去掉空格
            if([strItem0 isEqualToString:@""]){
                drawTimes++;
               [self endPoint];
                continue;
            }
            
            
            NSArray *arrayItem = [strItem0 componentsSeparatedByString:@","];
            NSLog(@"strItem--%@",strItem0);
            CGPoint touchPoint = {[arrayItem[0] intValue]*3,[arrayItem[1] intValue]*3 + 100};
            
            
            int solid=[arrayItem[2] intValue];
            
            
            if(solid==0){
                continue;
            }
//            if (solid>255) {
//                solid=255;
//            }
            solid=solid/1024*255;
            int gray=255-solid;
             NSLog(@"gray--%d",gray);
            NSLog(@"solid--%d",solid);
            UIColor *uiColor= [UIColor colorWithRed:gray/255.0 green:gray/255.0 blue:gray/255.0 alpha:1];
//            [self setSignatureColor:uiColor];
            drawTimes++;
            [self initPoint: touchPoint  ];
            
        }
//        NSLog(@"strItem--ok2");
//        [self.model asyncEndContinuousLine];
        
        drawTimes++;
        [self endPoint];
    }
}





- (void)initPoint:(CGPoint)touchPoint  
{
 //   CGPoint touchPoint = {10,20};
    
//    if (endContinuousLine) {
//        [self.model asyncEndContinuousLine];
//    }
    
    
//    CGSize size={solid,solid};
    
//    [self.model setImageSize:size];
    
    [self.model asyncUpdateWithPoint:touchPoint];
    
    [self _updateViewFromModel];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    self.imageView = [[UIImageView alloc] init];
    [self.imageView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.imageView];
    
    self.bezierPathLayer = ({
        CAShapeLayer *layer = [[CAShapeLayer alloc] init];
        layer.strokeColor = self.signatureColor.CGColor;
        layer.fillColor = self.signatureColor.CGColor;
        layer;
    });
    [self.view.layer addSublayer:self.bezierPathLayer];
    
    // Constraints
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:@[
                           [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0],
                           [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0],
                           [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0],
                           [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0]
                           ]];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.presetImage) {
        [self.view layoutIfNeeded];
        [self.model addImageToSignature:self.presetImage];
        [self _updateViewFromModel];
        
        self.presetImage = nil;
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.model.imageSize = self.view.bounds.size;
    [self _updateViewFromModel];
}

#pragma mark - UIResponder
//
//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    [super touchesBegan:touches withEvent:event];
//
//    [self _updateModelWithTouches:touches endContinuousLine:YES];
//}





//- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    [super touchesMoved:touches withEvent:event];
//
//    [self _updateModelWithTouches:touches endContinuousLine:NO];
//}

#pragma mark - Private

//- (void)_updateModelWithTouches:(NSSet<UITouch *> *)touches endContinuousLine:(BOOL)endContinuousLine
//{
//    CGPoint touchPoint = [self.class _touchPointFromTouches:touches];
//
//    if (endContinuousLine) {
//        [self.model asyncEndContinuousLine];
//    }
//    [self.model asyncUpdateWithPoint:touchPoint];
//
//    [self _updateViewFromModel];
//}

- (void)_updateViewFromModel
{
    __weak UBSignatureDrawingViewController *weakSelf = self;
    
    // block回调作为异步任务交给主队列处理，会在主线程最后执行
    [self.model asyncGetOutputWithBlock:^(UIImage *signatureImage, UIBezierPath *temporarySignatureBezierPath) {
        
        
        
        if (self.imageView.image != signatureImage) {
            self.imageView.image = signatureImage;
        }
        if (!CGPathEqualToPath(self.bezierPathLayer.path, temporarySignatureBezierPath.CGPath)) {
            self.bezierPathLayer.path = temporarySignatureBezierPath.CGPath;
        }
        
        self.isEmpty = (self.bezierPathLayer.path == nil && self.imageView.image == nil);
        
        // TUDO
        /// drawTimes 在block执行前，已经是所有绘制点的数量了
        /// 那么为什么block第一次执行，drawTimes为0呢，因为 viewDidLayoutSubviews()方法中调用了一次 _updateViewFromModel ，此时 drawTimes 
        blockTimes ++;
        if(blockTimes == (drawTimes+1) && drawTimes!=0){
            if(weakSelf.delegate &&[weakSelf.delegate respondsToSelector:@selector(getSignImage:)]){
                [weakSelf.delegate getSignImage:signatureImage];
            }
        }
        // TUDO
    }];
    
    
}

#pragma mark - Helpers

+ (CGPoint)_touchPointFromTouches:(NSSet<UITouch *> *)touches
{
    UITouch *touch = [touches anyObject];
    
    return [touch locationInView:touch.view];
}

-(void)dealloc{
    
}
@end
