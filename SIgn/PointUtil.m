//
//  PointUtil.m
//  AA
//
//  Created by mi on 2021/11/12.
//

#import "PointUtil.h"
#import "UBDrawingModelAsync.h"
@interface PointUtil ()
{
      NSInteger x;
      NSInteger y;
      NSInteger scale;
      int preX;
      int preY;
      UIColor *uiColor;
    
}

//@property (retain, readonly) UBSignatureDrawingModel *model;
@property (retain,readonly) UBDrawingModelAsync *model;
 
@property (retain) UIImage *uiImage;

@end
 

@implementation PointUtil
@synthesize signDelegate;


- (instancetype)initWithImageSize:(CGSize)imageSize color:(UIColor*)color1 scale:(float)scale1 x:(int)x1 y:(int)y1
{
    if (self = [super init]) {
        _model = [[UBDrawingModelAsync alloc] initWithImageSize:imageSize];
        x=x1;
        y=y1;
        scale=scale1;
        uiColor=color1;
       
    }
   
    
    
    return self;
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

-(void) getImageByPointStr:(NSString *)str   {
    
    
    NSLog(@"start");
    
    NSRange range = [str rangeOfString:@"("];
    NSString *ret=NULL;
    if (range.location != NSNotFound) {
        
        ret= [str substringFromIndex:range.location];
        
    }else{
        ret=str;
        NSLog(@"Not Found");
        
    }
    
    NSArray *array0 = [ret componentsSeparatedByString:@")"];
    
    
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
            
            if(array.count==1||array.count==2){
                continue;
            }
            
        }
        
        for(int j=0;j< array.count ;j++){
            
            NSString *strItem=array[j];
            
            if([strItem isEqualToString:@""]){
                
                [self.model  asyncEndContinuousLine];
                continue;
            }
            
            
            NSString *strItem0 = [strItem stringByReplacingOccurrencesOfString:@"(" withString:@""]; // 去掉空格
            if([strItem0 isEqualToString:@""]){
                
                [self.model  asyncEndContinuousLine];
                continue;
            }
            
            
            NSArray *arrayItem = [strItem0 componentsSeparatedByString:@","];
            
            if (i==0||i==count-1||i==count-2) {
               
                // 这里判断一下点位字符串，如果不包含';'，那么应该是多余点位
                if(arrayItem.count==1||arrayItem.count==2){
                    continue;
                } 
            }
            
            
            
            if (preX==[arrayItem[0] intValue]&&preY==[arrayItem[1] intValue]) {
                
                continue;
            }
            preY=[arrayItem[1] intValue];
            preX=[arrayItem[0] intValue];
            
            
            int solid=[arrayItem[2] intValue];
            if(solid==0){
                [self.model  asyncEndContinuousLine];
                [self _updateViewFromModel:NO  close:YES];
                continue;
            }
            if (solid>512) {
                solid=512;
            }
            
            if(j<array.count-1&&solid!=0){
                if (j%5!=0) {
                    continue;
                }
            }
            
            
            CGPoint point = {[arrayItem[0] intValue]*scale+x,[arrayItem[1] intValue]*scale + y};
             
            
            float press=1;//solid*0.002;
            
            [self.model  asyncUpdateWithPoint:point weight:press];
            
        }
        [self.model  asyncEndContinuousLine];
    }
    NSLog(@"end");
    [self _updateViewFromModel:YES close:YES];
  
    
}

-(void)setDelegate:(id<SignatureDelegate>)delegate{
    if (!delegate) {
        return;
    }
    self.signDelegate = delegate;
}
/*
 加载图片代理
 */
 
- (void)_updateViewFromModel:(Boolean)end close:(Boolean)close
{
    [self.model  asyncGetOutputWithBlock:^(UIImage *signImage, UIBezierPath *temporarySignatureBezierPath) {
        if(close){
            if(self.uiImage==nil){
                self.uiImage=signImage;
            }else{
             self.uiImage= [self addImage:self.uiImage toImage:signImage];
            }
            [self clear];
             
        }
        if(end&&self.signDelegate &&[self.signDelegate respondsToSelector:@selector(getSignImage:)]){
            
            UIImage *bg=[self.class imageWithColor:UIColor.whiteColor size:self.model.imageSize];
            self.uiImage=[self addImage:bg  toImage:self.uiImage];
            [self.signDelegate getSignImage:self.uiImage];
            NSData * imageData = UIImageJPEGRepresentation(self.uiImage,1);
            float  length = [imageData length]/1000;
            NSLog(@"获取第一个---img成功%f",length);
            [self reset];
           }
    }];


}


- (UIImage *)addImage:(UIImage *)image1 toImage:(UIImage *)image2 {
    UIGraphicsBeginImageContext(image1.size);
    
    // Draw image1
    [image1 drawInRect:CGRectMake(0, 0, image1.size.width, image1.size.height)];
    
    // Draw image2
    [image2 drawInRect:CGRectMake(0, 0, image2.size.width, image2.size.height)];
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultingImage;
}






-(void) getImageByPointStr2:(NSString *)str   end:(Boolean)end{
  
     NSString *ret1= [str stringByReplacingOccurrencesOfString:@"(" withString:@""];
   
    NSString *ret2=  [ret1 stringByReplacingOccurrencesOfString:@")" withString:@""];
   
        NSArray *array = [ret2 componentsSeparatedByString:@";"];
        
        for(int j=0;j< array.count ;j++){
            
            NSString *strItem=array[j];
           
           
            
            if([strItem isEqualToString:@""]){
                
                [self.model  asyncEndContinuousLine];
                [self _updateViewFromModel:NO  close:YES];
                continue;
            }
            NSString *strItem0 = [strItem stringByReplacingOccurrencesOfString:@"(" withString:@""]; // 去掉空格
            if([strItem0 isEqualToString:@""]){
                [self.model  asyncEndContinuousLine];
                [self _updateViewFromModel:NO  close:YES];
                continue;
            }
            
            
            NSArray *arrayItem = [strItem0 componentsSeparatedByString:@","];
            
            if (arrayItem.count<4) {
                continue;
            }
            
           
            
            
            if (preX==[arrayItem[0] intValue]&&preY==[arrayItem[1] intValue]) {
                continue;
            }
            
            int solid=[arrayItem[2] intValue];
            if(solid==0){
                [self.model  asyncEndContinuousLine];
                [self _updateViewFromModel:NO  close:YES];
                continue;
            }
            if (solid>512) {
                solid=512;
            }
            
            if(j<array.count-1&&solid!=0){
                if (j%5!=0) {
                    continue;
                }
            }
            
            preY=[arrayItem[1] intValue];
            preX=[arrayItem[0] intValue];
            CGPoint point = {[arrayItem[0] intValue]*scale+x,[arrayItem[1] intValue]*scale + y};
            
      
            
        
            
            float press=1;//solid*0.002;
            [self.model  asyncUpdateWithPoint:point weight:press];
            [self _updateViewFromModel:NO  close:NO];
        } 
        [self _updateViewFromModel:end  close:YES];
 
}



- (void)reset
{
     
//    self.uiImage=nil;
    self.uiImage=nil;
    [self.model reset];
//    [self _updateViewFromModel:self.model.imageSize];
}
 
-(void) clear{
    [self.model clear];
  
}

@end
