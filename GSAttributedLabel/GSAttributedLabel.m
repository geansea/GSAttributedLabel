//
//  GSAttributedLabel.m
//  GSAttributedLabel
//
//  Created by geansea on 2017/8/18.
//
//

#import "GSAttributedLabel.h"

NSString * const GSALLinkAttributeName = @"GSALLinkAttributeName";

@interface GSALViewAttachment : NSTextAttachment

@property (nonatomic, strong) UIView *view;

@end

@implementation GSALViewAttachment

@end

@interface GSAttributedLabel ()

// Layout core
@property (nonatomic, strong) NSMutableAttributedString *attributedString;
@property (nonatomic, strong) NSTextStorage *textStorage;
@property (nonatomic, strong) NSLayoutManager *layoutManager;
@property (nonatomic, strong) NSTextContainer *textContainer;

// Layout result
@property (nonatomic, assign) CGRect resultRect;
@property (nonatomic, assign) NSRange resultGlyphRange;
@property (nonatomic, assign) NSRange resultRange;
@property (nonatomic, assign) CGPoint drawPoint;
@property (nonatomic, strong) NSMutableArray<UIView *> *attachmentViews;

@end

@implementation GSAttributedLabel

- (instancetype)init {
    if (self = [super init]) {
        [self innerInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self innerInit];
    }
    return self;
}

- (CGSize)fitSize {
    [self layoutIfNeeded];
    CGSize fitSize = CGSizeMake(CGRectGetMaxX(_resultRect), CGRectGetMaxY(_resultRect));
    fitSize.width += _edgeInsets.left + _edgeInsets.right;
    fitSize.height += _edgeInsets.top + _edgeInsets.bottom;
    return fitSize;
}

- (BOOL)layoutFinished {
    [self layoutIfNeeded];
    return (NSMaxRange(_resultRange) == _attributedString.length);
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    if (!attributedText) {
        attributedText = [[NSAttributedString alloc] initWithString:@""];
    }
    [_attributedString setAttributedString:attributedText];
    [self setNeedsLayout];
}

- (void)appendAttributedText:(NSAttributedString *)attributedText {
    if (0 == attributedText.length) {
        return;
    }
    [_attributedString appendAttributedString:attributedText];
    [self setNeedsLayout];
}

#pragma mark Layout settings

- (void)setFont:(UIFont *)font {
    if (font && ![_font isEqual:font]) {
        _font = font;
        [self setNeedsLayout];
    }
}

- (void)setTextColor:(UIColor *)textColor {
    if (textColor && ![_textColor isEqual:textColor]) {
        _textColor = textColor;
        [self setNeedsLayout];
    }
}

- (void)setLineSpacing:(CGFloat)lineSpacing {
    if (_lineSpacing != lineSpacing) {
        _lineSpacing = lineSpacing;
        [self setNeedsLayout];
    }
}

- (void)setParagraphSpacing:(CGFloat)paragraphSpacing {
    if (_paragraphSpacing != paragraphSpacing) {
        _paragraphSpacing = paragraphSpacing;
        [self setNeedsLayout];
    }
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    if (_textAlignment != textAlignment) {
        _textAlignment = textAlignment;
        [self setNeedsLayout];
    }
}

- (void)setFirstLineIndent:(CGFloat)firstLineIndent {
    if (_firstLineIndent != firstLineIndent) {
        _firstLineIndent = firstLineIndent;
        [self setNeedsLayout];
    }
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode {
    if (_lineBreakMode != lineBreakMode) {
        _lineBreakMode = lineBreakMode;
        [self setNeedsLayout];
    }
}

- (void)setNumberOfLines:(NSInteger)numberOfLines {
    if (_numberOfLines != numberOfLines) {
        _numberOfLines = numberOfLines;
        [self setNeedsLayout];
    }
}

- (void)setShadowColor:(UIColor *)shadowColor {
    if (![_shadowColor isEqual:shadowColor]) {
        _shadowColor = shadowColor;
        [self setNeedsLayout];
    }
}

- (void)setShadowOffset:(CGSize)shadowOffset {
    if (!CGSizeEqualToSize(_shadowOffset, shadowOffset)) {
        _shadowOffset = shadowOffset;
        [self setNeedsLayout];
    }
}

- (void)setLinkTextAttributes:(NSDictionary<NSString *,id> *)linkTextAttributes {
    if (![_linkTextAttributes isEqualToDictionary:linkTextAttributes]) {
        _linkTextAttributes = [linkTextAttributes copy];
        [self setNeedsLayout];
    }
}

- (void)setVerticalAlignment:(GSALVerticalAlignment)verticalAlignment {
    if (_verticalAlignment != verticalAlignment) {
        _verticalAlignment = verticalAlignment;
        [self setNeedsLayout];
    }
}

- (void)setEdgeInsets:(UIEdgeInsets)edgeInsets {
    if (!UIEdgeInsetsEqualToEdgeInsets(_edgeInsets, edgeInsets)) {
        _edgeInsets = edgeInsets;
        [self setNeedsLayout];
    }
}

#pragma mark Private

- (void)innerInit {
    self.backgroundColor = [UIColor whiteColor];
    [self initLayoutSettings];
    [self initLayoutCore];
    [self initLayoutResult];
    self.delegate = nil;
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:tapRecognizer];
}

- (void)initLayoutSettings {
    self.font = [UIFont systemFontOfSize:UIFont.labelFontSize];
    self.textColor = [UIColor blackColor];
    self.lineSpacing = 0;
    self.paragraphSpacing = 0;
    self.textAlignment = NSTextAlignmentLeft;
    self.firstLineIndent = 0;
    self.lineBreakMode = NSLineBreakByWordWrapping;
    self.lastLineBreakMode = NSLineBreakByTruncatingTail;
    self.shadowColor = nil;
    self.shadowOffset = CGSizeZero;
    self.numberOfLines = 1;
    self.verticalAlignment = GSALVerticalAlignmentCenter;
}

- (void)initLayoutCore {
    self.attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
    self.textStorage = [[NSTextStorage alloc] initWithString:@""];
    self.layoutManager = [[NSLayoutManager alloc] init];
    self.textContainer = [[NSTextContainer alloc] initWithSize:CGSizeZero];
    
    [_layoutManager addTextContainer:_textContainer];
    [_textStorage addLayoutManager:_layoutManager];
}

- (void)initLayoutResult {
    self.resultRect = CGRectZero;
    self.resultGlyphRange = NSMakeRange(0, 0);
    self.resultRange = NSMakeRange(0, 0);
    self.drawPoint = CGPointZero;
    self.attachmentViews = [NSMutableArray array];
}

#pragma mark Override

- (void)layoutSubviews {
    //
    // Clean additional views
    //
    for (UIView *subview in _attachmentViews) {
        if (subview.superview == self) {
            [subview removeFromSuperview];
        }
    }
    [_attachmentViews removeAllObjects];
    [super layoutSubviews];
    //
    // Text container
    //
    CGRect layoutRect = UIEdgeInsetsInsetRect(self.bounds, _edgeInsets);
    _textContainer.size = layoutRect.size;
    _textContainer.lineBreakMode = _lastLineBreakMode;
    _textContainer.maximumNumberOfLines = _numberOfLines;
    //
    // Text storage
    //
    NSMutableAttributedString *layoutString = [[NSMutableAttributedString alloc] initWithString:_attributedString.string];
    NSRange layoutRange = NSMakeRange(0, _attributedString.length);
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = _lineSpacing;
    paragraphStyle.paragraphSpacing = _paragraphSpacing;
    paragraphStyle.alignment = _textAlignment;
    paragraphStyle.firstLineHeadIndent = _firstLineIndent;
    paragraphStyle.lineBreakMode = _lineBreakMode;
    [layoutString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:layoutRange];
    [layoutString addAttribute:NSFontAttributeName value:_font range:layoutRange];
    [layoutString addAttribute:NSForegroundColorAttributeName value:_textColor range:layoutRange];
    if (_shadowColor && !CGSizeEqualToSize(_shadowOffset, CGSizeZero)) {
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowColor = _shadowColor;
        shadow.shadowOffset = _shadowOffset;
        [layoutString addAttribute:NSShadowAttributeName value:shadow range:layoutRange];
    }
    [_attributedString enumerateAttributesInRange:NSMakeRange(0, _attributedString.length) options:0 usingBlock:^(NSDictionary<NSString *,id> *attrs, NSRange range, BOOL *stop) {
        id linkValue = attrs[NSLinkAttributeName];
        if (linkValue && _linkTextAttributes) {
            NSMutableDictionary<NSString *,id> *newAttrs = [NSMutableDictionary dictionaryWithDictionary:attrs];
            [newAttrs removeObjectForKey:NSLinkAttributeName];
            [newAttrs setObject:linkValue forKey:GSALLinkAttributeName];
            [newAttrs addEntriesFromDictionary:_linkTextAttributes];
            attrs = newAttrs;
        }
        [layoutString addAttributes:attrs range:range];
    }];
    [_textStorage setAttributedString:layoutString];
    //
    // Collect results
    //
    self.resultRect = [_layoutManager usedRectForTextContainer:_textContainer];
    self.drawPoint = CGPointMake(_edgeInsets.left, _edgeInsets.top);
    CGFloat heightRemain = _textContainer.size.height - CGRectGetHeight(_resultRect);
    switch (_verticalAlignment) {
        case GSALVerticalAlignmentTop:
            break;
        case GSALVerticalAlignmentCenter:
            _drawPoint.y += heightRemain / 2;
            break;
        case GSALVerticalAlignmentBottom:
            _drawPoint.y += heightRemain;
            break;
        default:
            break;
    }
    _resultGlyphRange = [_layoutManager glyphRangeForTextContainer:_textContainer];
    _resultRange = [_layoutManager characterRangeForGlyphRange:_resultGlyphRange actualGlyphRange:NULL];
    //
    // Collect views
    //
    [_textStorage enumerateAttribute:NSAttachmentAttributeName inRange:_resultRange options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
        if ([value isKindOfClass:[GSALViewAttachment class]]) {
            GSALViewAttachment *attachment = value;
            CGRect lineRect = [_layoutManager lineFragmentRectForGlyphAtIndex:range.location effectiveRange:NULL];
            CGPoint location = [_layoutManager locationForGlyphAtIndex:range.location];
            location.x += _drawPoint.x + _resultRect.origin.x + lineRect.origin.x;
            location.y += _drawPoint.y + _resultRect.origin.y + lineRect.origin.y;
            CGRect viewFrame = attachment.bounds;
            viewFrame.origin.x = floor(location.x);
            viewFrame.origin.y = floor(location.y - CGRectGetHeight(attachment.bounds));
            attachment.view.frame = viewFrame;
            [_attachmentViews addObject:attachment.view];
            [self addSubview:attachment.view];
        }
    }];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [_layoutManager drawBackgroundForGlyphRange:_resultGlyphRange atPoint:_drawPoint];
    [_layoutManager drawGlyphsForGlyphRange:_resultGlyphRange atPoint:_drawPoint];
}

#pragma mark Gesture recognize

- (void)handleTap:(UITapGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateEnded) {
        return;
    }
    CGPoint point = [sender locationInView:self];
    point.x -= _drawPoint.x;
    point.y -= _drawPoint.y;
    NSUInteger glyphIndex = [_layoutManager glyphIndexForPoint:point inTextContainer:_textContainer];
    if (glyphIndex >= _layoutManager.firstUnlaidGlyphIndex) {
        return;
    }
    CGRect glyphRect = [_layoutManager boundingRectForGlyphRange:NSMakeRange(glyphIndex, 1) inTextContainer:_textContainer];
    if (!CGRectContainsPoint(glyphRect, point)) {
        return;
    }
    NSUInteger charIndex = [_layoutManager characterIndexForGlyphAtIndex:glyphIndex];
    NSRange urlRange = NSMakeRange(0, 0);
    id linkValue = [_textStorage attribute:NSLinkAttributeName atIndex:charIndex effectiveRange:&urlRange];
    if (!linkValue) {
        linkValue = [_textStorage attribute:GSALLinkAttributeName atIndex:charIndex effectiveRange:&urlRange];
        if (!linkValue) {
            return;
        }
    }
    NSURL *url = nil;
    if ([linkValue isKindOfClass:[NSURL class]]) {
        url = linkValue;
    } else if ([linkValue isKindOfClass:[NSString class]]) {
        url = [NSURL URLWithString:linkValue];
    } else {
        return;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(attributedLabel:interactWithURL:inRange:)]) {
        [_delegate attributedLabel:self interactWithURL:url inRange:urlRange];
    }
}

@end

@implementation GSAttributedLabel (PureText)

- (void)setText:(NSString *)text {
    [self setText:text attributes:nil];
}

- (void)setText:(NSString *)text attributes:(NSDictionary<NSString *, id> *)attributes {
    [self setAttributedText:[[NSAttributedString alloc] initWithString:(text ? : @"") attributes:attributes]];
}

- (void)appendText:(NSString *)text {
    [self appendText:text attributes:nil];
}

- (void)appendText:(NSString *)text attributes:(NSDictionary<NSString *, id> *)attributes {
    if (text.length > 0) {
        [self appendAttributedText:[[NSAttributedString alloc] initWithString:text attributes:attributes]];
    }
}

@end

@implementation GSAttributedLabel (Attachment)

- (void)appendImage:(UIImage *)image bounds:(CGRect)bounds {
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = image;
    attachment.bounds = bounds;
    [self appendAttributedText:[NSAttributedString attributedStringWithAttachment:attachment]];
}

- (void)appendView:(UIView *)view bounds:(CGRect)bounds {
    GSALViewAttachment *attachment = [[GSALViewAttachment alloc] init];
    attachment.image = nil;
    attachment.bounds = bounds;
    attachment.view = view;
    [self appendAttributedText:[NSAttributedString attributedStringWithAttachment:attachment]];
}

@end
