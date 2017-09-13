//
//  GSAttributedLabel.h
//  GSAttributedLabel
//
//  Created by geansea on 2017/8/18.
//
//

#import <UIKit/UIKit.h>

@class GSAttributedLabel;

@protocol GSAttributedLabelDelegate <NSObject>

- (void)attributedLabel:(GSAttributedLabel *)label interactWithURL:(NSURL *)URL inRange:(NSRange)characterRange;

@end

typedef NS_ENUM(NSInteger, GSALVerticalAlignment) {
    GSALVerticalAlignmentTop,
    GSALVerticalAlignmentCenter,
    GSALVerticalAlignmentBottom,
};

@interface GSAttributedLabel : UIView

@property (nonatomic, strong) UIFont *                       font;
@property (nonatomic, strong) UIColor *                      textColor;
@property (nonatomic, assign) CGFloat                        lineSpacing;
@property (nonatomic, assign) CGFloat                        paragraphSpacing;
@property (nonatomic, assign) NSTextAlignment                textAlignment;
@property (nonatomic, assign) CGFloat                        firstLineIndent;
@property (nonatomic, assign) NSLineBreakMode                lineBreakMode;
@property (nonatomic, assign) NSLineBreakMode                lastLineBreakMode;
@property (nonatomic, assign) NSInteger                      numberOfLines;
@property (nonatomic, strong) UIColor *                      shadowColor;
@property (nonatomic, assign) CGSize                         shadowOffset;
@property (nonatomic, copy)   NSDictionary<NSString *, id> * linkTextAttributes;
@property (nonatomic, assign) GSALVerticalAlignment          verticalAlignment;
@property (nonatomic, assign) UIEdgeInsets                   edgeInsets;

@property (nonatomic, weak)   id<GSAttributedLabelDelegate>  delegate;

- (instancetype)init;
- (instancetype)initWithFrame:(CGRect)frame;
- (CGSize)fitSize;
- (BOOL)layoutFinished;

- (void)setAttributedText:(NSAttributedString *)attributedText;
- (void)appendAttributedText:(NSAttributedString *)attributedText;

@end

@interface GSAttributedLabel (PureText)

- (void)setText:(NSString *)text;
- (void)setText:(NSString *)text attributes:(NSDictionary<NSString *, id> *)attributes;

- (void)appendText:(NSString *)text;
- (void)appendText:(NSString *)text attributes:(NSDictionary<NSString *, id> *)attributes;

@end

@interface GSAttributedLabel (Attachment)

- (void)appendImage:(UIImage *)image bounds:(CGRect)bounds;
- (void)appendView:(UIView *)view bounds:(CGRect)bounds;

@end
