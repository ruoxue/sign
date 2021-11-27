//
//  UBDrawingModelAsync.m
//  AA
//
//  Created by mi on 2021/11/26.
//


#import "UBDrawingModelAsync.h"
#import "UBSignatureDrawingModel.h"

@interface UBDrawingModelAsync ()

/// self.model is atomic, to prevent access by multiple threads at same time
@property (atomic, readonly) UBSignatureDrawingModel *model;
@property (nonatomic, readonly) NSOperationQueue *operationQueue;

@end

@implementation UBDrawingModelAsync

- (instancetype)init
{
    return [self initWithImageSize:CGSizeZero];
}

- (instancetype)initWithImageSize:(CGSize)imageSize
{
    if (self = [super init]) {
        _model = [[UBSignatureDrawingModel alloc] initWithImageSize:imageSize];
        
        _operationQueue = ({
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            queue.maxConcurrentOperationCount = 1;
            queue;
        });
    }
    
    return self;
}

#pragma mark - Async

- (void)asyncUpdateWithPoint:(CGPoint)point weight:(float)weight
{
    [self.operationQueue addOperationWithBlock:^{
        [self.model updateWithPoint:point weight:weight];
    }];
}

- (void)asyncEndContinuousLine
{
    [self.operationQueue addOperationWithBlock:^{
        [self.model endContinuousLine];
    }];
}

- (void)asyncGetOutputWithBlock:(void (^)(UIImage *signatureImage, UIBezierPath *temporarySignatureBezierPath))block
{
    NSOperationQueue *currentQueue = [NSOperationQueue currentQueue];
    
    [self.operationQueue addOperationWithBlock:^{
        UIImage *signatureImage = self.model.signatureImage;
       
        UIBezierPath *temporaryBezierPath = self.model.temporarySignatureBezierPath;
            [currentQueue addOperationWithBlock:^{
                block(signatureImage, temporaryBezierPath);
            }];
    }];
}



#pragma mark - Sync

- (void)reset
{
    [self.operationQueue cancelAllOperations];
    [self.model reset];
    
}

- (void)clear
{
    [self.model reset];
    
     
}

- (void)addImageToSignature:(UIImage *)image
{
    [self.model addImageToSignature:image];
}

- (UIImage *)fullSignatureImage
{
    return [self.model fullSignatureImage];
}

- (CGSize)imageSize
{
    return self.model.imageSize;
}

- (void)setImageSize:(CGSize)imageSize
{
    self.model.imageSize = imageSize;
}

- (UIColor *)signatureColor
{
    return self.model.signatureColor;
}

- (void)setSignatureColor:(UIColor *)signatureColor
{
    self.model.signatureColor = signatureColor;
}

@end
