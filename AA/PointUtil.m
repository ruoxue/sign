//
//  PointUtil.m
//  AA
//
//  Created by mi on 2021/11/12.
//

#import "PointUtil.h"
#import "ViewController.h"
#import "UBSignatureDrawingModel.h"

@interface PointUtil ()
{
    
}

@property (atomic, readonly) UBSignatureDrawingModel *model;

@end

@implementation PointUtil


 

-(UIImage*) getImageByPointStr:(UIColor *)color size:(CGSize)size str:(NSString *)str  scale:(float) scale x:(int)x y:(int)y{
    _model = [[UBSignatureDrawingModel alloc] initWithImageSize:size];
    
    
    [self.model setImageSize:size];
    
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
        }
        
        for(NSString* strItem in array){
            
            if([strItem isEqualToString:@""]){
                
               [self.model endContinuousLine];
                continue;
            }
           
            
            NSString *strItem0 = [strItem stringByReplacingOccurrencesOfString:@"(" withString:@""]; // 去掉空格
            if([strItem0 isEqualToString:@""]){
                
               [self.model endContinuousLine];
                continue;
            }
            
            
            NSArray *arrayItem = [strItem0 componentsSeparatedByString:@","];
           
            CGPoint point = {[arrayItem[0] intValue]*scale+x,[arrayItem[1] intValue]*scale + y};
            
            
            int solid=[arrayItem[2] intValue];
            if(solid==0){
                [self.model endContinuousLine];
                continue;
            }
  
            
            if (solid>512) {
                solid=512;
            }
            
            float press=solid*0.002;
            
           [self.model updateWithPoint:point weight:press];
            
        }
        [self.model endContinuousLine];
    }
    
  UIImage  *img=   [self.model fullSignatureImage];
        
      
       return img;
    
    
}




// 根据透明度绘制一个图片
- (UIImage *)getImagewithColor:(UIColor *)color size:(CGSize)size str:(NSString *)str  scale:(float) scale x:(int)x y:(int)y  {

    _model = [[UBSignatureDrawingModel alloc] initWithImageSize:size];
    
    
    [self.model setImageSize:size];
    NSArray  *array = [str componentsSeparatedByString:@")"];
    UIImage *img=nil;
    for(int i=0;i<array.count;i++){
        NSString *item=array[i];
     NSArray *arr=   [item componentsSeparatedByString:@";"];
        if (arr.count<2) {
//            uiPath=nil;
            continue;
        }
        
        for(int j=0;j<arr.count;j++){
            
           NSString *end= arr[j];
            NSArray *endArr=  [[end stringByReplacingOccurrencesOfString:@"(" withString:@""] componentsSeparatedByString:@","];
            
            if (endArr.count<4) {
                continue;
            }
 
            int x=[endArr[0] intValue];
            int y=[endArr[1] intValue];
            int z=[endArr[2] intValue];
          
            CGPoint point=CGPointMake(x,y);
          
            
            if (z>512) {
                z=512;
            }
            
            float press=z*0.002;
         
            
            if (z==0) {
                [self.model endContinuousLine];
            }else{
                [self.model updateWithPoint:point weight:press];
            }
          
        }
      
        [self.model endContinuousLine];
        
    }
   
 img=   [self.model fullSignatureImage];
     
    NSLog(@"124");
    return img;
}
 


@end
