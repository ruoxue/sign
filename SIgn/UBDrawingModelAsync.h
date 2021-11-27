//
//  UBDrawingModelAsync.h
//  AA
//
//  Created by mi on 2021/11/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 An async wrapper for @c UBSignatureDrawingModel.
 Runs the models complex and expensive operations on a background thread.
 Abstracts the asynchronous code around the model for ease of use.
 
 Simply use the async methods to update points and get the output UI elements.
 */
@interface UBDrawingModelAsync : NSObject

/**
 Initializes the model with an image size.
 @param imageSize The size (in points) for the backing image.
 @return An instance.
 */
- (instancetype)initWithImageSize:(CGSize)imageSize NS_DESIGNATED_INITIALIZER;


#pragma mark - Async

/**
 Updates the object with a new point in the signature.
 @param point A @c CGPoint for a new point in the signature.
 */
- (void)asyncUpdateWithPoint:(CGPoint)point weight:(float)weight;

/**
 Ends the current continuous signature line (equivilent to lifting your finger off the screen)
 */
- (void)asyncEndContinuousLine;

/**
 Gets the signature image and temporarySignatureBezierPath of the model.
 Call this after @c asyncUpdateWithPoint: to asynchronously get the updated elements.
 @note block will be executed on the thread this method was called on.
 */
- (void)asyncGetOutputWithBlock:(void (^)( UIImage  * _Nullable signatureImage, UIBezierPath * _Nullable temporarySignatureBezierPath))block;

 

#pragma mark - Sync
// NOTE: The following methods are synchronous and will block the thread they are called on until they can be completed.

/// Resets the whole model, clears current signature.
- (void)reset;

- (void)clear;
/**
 Add an image into the signature image.
 Useful for instantiating the model with a previous signature.
 */
- (void)addImageToSignature:(UIImage *)image;

/// Generates a @c UIImage of the @c signatureImage including the @c temporarySignatureBezierPath.
- (UIImage *)fullSignatureImage;
  

/**
 The color of the signature.
 @note Defaults to black.
 */
@property (nonatomic) UIColor *signatureColor;

/**
 The size (in points) of the @c UIImage backing the signature.
 This should be set to match the size of the view a signature is being recorded in.
 */
@property (nonatomic) CGSize imageSize;

@end

NS_ASSUME_NONNULL_END
