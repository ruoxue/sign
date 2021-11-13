//
//  PointUtil.h
//  AA
//
//  Created by mi on 2021/11/12.
//


#import <UIKit/UIKit.h> 
/**
 A view controller that allows the user to draw a signature and provides additional functionality.
 */
@interface PointUtil: NSObject
-(UIImage*) getImageByPointStr:(UIColor *)color size:(CGSize)size str:(NSString *)str  scale:(float) scale x:(int)x y:(int)y;
- (UIImage *)getImagewithColor:(UIColor *)color size:(CGSize)size str:(NSString *)str  scale:(float) scale x:(int)x y:(int)y ;
@end
