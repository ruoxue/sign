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
@protocol  SignatureDelegate <NSObject>
@optional
/// 获取最终绘制图片
-(void)getSignImage:(UIImage*)img;
@end
@interface PointUtil: NSObject

@property (nonatomic , retain) id<SignatureDelegate> signDelegate;
-(void) getImageByPointStr:  (NSString *)str;
-(void) getImageByPointStr2:(NSString *)str  end:(Boolean)end;

- (instancetype)initWithImageSize:(CGSize)imageSize  color:(UIColor*)color1  scale:(float) scale x:(int)x y:(int)y ;
- (void)reset;
-(void)setDelegate:(id<SignatureDelegate>)delegate;
@end
