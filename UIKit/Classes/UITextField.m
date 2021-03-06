/*
 * Copyright (c) 2011, The Iconfactory. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * 3. Neither the name of The Iconfactory nor the names of its contributors may
 *    be used to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE ICONFACTORY BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "UITextField.h"
#import "UITextLayer.h"
#import "UIColor.h"
#import "UIFont.h"
#import "UIImage.h"
#import "UIImage+UIPrivate.h"
#import "UIBezierPath.h"
#import "UIGraphics.h"
#import <AppKit/NSCursor.h>

NSString *const UITextFieldTextDidBeginEditingNotification = @"UITextFieldTextDidBeginEditingNotification";
NSString *const UITextFieldTextDidChangeNotification = @"UITextFieldTextDidChangeNotification";
NSString *const UITextFieldTextDidEndEditingNotification = @"UITextFieldTextDidEndEditingNotification";


static NSString* const kUIPlaceholderKey = @"UIPlaceholder";
static NSString* const kUITextAlignmentKey = @"UITextAlignment";
static NSString* const kUITextKey = @"UIText";
static NSString* const kUITextFieldBackgroundKey = @"UITextFieldBackground";
static NSString* const kUITextFieldDisabledBackgroundKey = @"UITextFieldDisabledBackground";
static NSString* const kUIBorderStyleKey = @"UIBorderStyle";
static NSString* const kUIClearsOnBeginEditingKey = @"UIClearsOnBeginEditing";
static NSString* const kUIMinimumFontSizeKey = @"UIMinimumFontSize";
static NSString* const kUIFontKey = @"UIFont";
static NSString* const kUIClearButtonModeKey = @"UIClearButtonMode";
static NSString* const kUIClearButtonOffsetKey = @"UIClearButtonOffset";
static NSString* const kUIAutocorrectionTypeKey = @"UIAutocorrectionType";
static NSString* const kUISpellCheckingTypeKey = @"UISpellCheckingType";
static NSString* const kUIKeyboardAppearanceKey = @"UIKeyboardAppearance";
static NSString* const kUIKeyboardTypeKey = @"UIKeyboardType";
static NSString* const kUIReturnKeyTypeKey = @"UIReturnKeyType";
static NSString* const kUIEnablesReturnKeyAutomaticallyKey = @"UIEnablesReturnKeyAutomatically";
static NSString* const kUISecureTextEntryKey = @"UISecureTextEntry";


@interface UIControl () <UITextLayerContainerViewProtocol>
@end

@interface UITextField () <UITextLayerTextDelegate>
@end

@interface NSObject (UITextFieldDelegate)
- (BOOL)textField:(UITextField *)textField doCommandBySelector:(SEL)selector;
@end

@implementation UITextField
@synthesize delegate = _delegate;
@synthesize background = _background;
@synthesize disabledBackground = _disabledBackground;
@synthesize editing = _editing;
@synthesize clearsOnBeginEditing = _clearsOnBeginEditing;
@synthesize adjustsFontSizeToFitWidth = _adjustsFontSizeToFitWidth;
@synthesize clearButtonMode = _clearButtonMode;
@synthesize leftView = _leftView;
@synthesize rightView = _rightView;
@synthesize leftViewMode = _leftViewMode;
@synthesize rightViewMode = _rightViewMode;
@synthesize borderStyle = _borderStyle;
@synthesize inputAccessoryView = _inputAccessoryView;
@synthesize inputView = _inputView;
@synthesize minimumFontSize = _minimumFontSize;

- (void)dealloc
{
	[_placeholderTextLayer removeFromSuperlayer];
	[_placeholderTextLayer release];
    [_textLayer removeFromSuperlayer];
    [_textLayer release];
    [_leftView release];
    [_rightView release];
    [_background release];
    [_disabledBackground release];
    [_placeholder release];
    [_inputAccessoryView release];
    [_inputView release];
    [super dealloc];
}

- (void) _commonInitForUITextField
{
    _placeholderTextLayer = [[UITextLayer alloc] initWithContainer:self isField:NO];
    _placeholderTextLayer.textColor = [UIColor colorWithWhite:0.6f alpha:1.0f];
    [self.layer addSublayer:_placeholderTextLayer];
    
    _textLayer = [[UITextLayer alloc] initWithContainer:self isField:YES];
    [self.layer addSublayer:_textLayer];
    
    self.textAlignment = UITextAlignmentLeft;
    self.font = [UIFont systemFontOfSize:17];
    self.borderStyle = UITextBorderStyleNone;
    self.textColor = [UIColor blackColor];
    self.clearButtonMode = UITextFieldViewModeNever;
    self.leftViewMode = UITextFieldViewModeNever;
    self.rightViewMode = UITextFieldViewModeNever;
    self.opaque = NO;
}

- (id)initWithFrame:(CGRect)frame
{
    if (nil != (self = [super initWithFrame:frame])) {
        [self _commonInitForUITextField];
    }
    return self;
}

- (id) initWithCoder:(NSCoder*)coder
{
    if (nil != (self = [super initWithCoder:coder])) {
        [self _commonInitForUITextField];
        if ([coder containsValueForKey:kUIPlaceholderKey]) {
            self.placeholder = [coder decodeObjectForKey:kUIPlaceholderKey];
        }
        if ([coder containsValueForKey:kUITextAlignmentKey]) {
            self.textAlignment = (UITextAlignment)[coder decodeIntegerForKey:kUITextAlignmentKey];
        }
        if ([coder containsValueForKey:kUITextKey]) {
            self.text = [coder decodeObjectForKey:kUITextKey];
        }
        if ([coder containsValueForKey:kUITextFieldBackgroundKey]) {
            self.background = [coder decodeObjectForKey:kUITextFieldBackgroundKey];
        }
        if ([coder containsValueForKey:kUITextFieldDisabledBackgroundKey]) {
            self.disabledBackground = [coder decodeObjectForKey:kUITextFieldDisabledBackgroundKey];
        }
        if ([coder containsValueForKey:kUIBorderStyleKey]) {
            self.borderStyle = (UITextBorderStyle)[coder decodeIntegerForKey:kUIBorderStyleKey];
        }
        if ([coder containsValueForKey:kUIClearsOnBeginEditingKey]) {
            self.clearsOnBeginEditing = [coder decodeBoolForKey:kUIClearsOnBeginEditingKey];
        }
        if ([coder containsValueForKey:kUIMinimumFontSizeKey]) {
            self.minimumFontSize = [coder decodeDoubleForKey:kUIMinimumFontSizeKey];
        }
        if ([coder containsValueForKey:kUIFontKey]) {
            self.font = [coder decodeObjectForKey:kUIFontKey];
        }
        if ([coder containsValueForKey:kUIClearButtonModeKey]) {
            self.clearButtonMode = (UITextFieldViewMode)[coder decodeIntegerForKey:kUIClearButtonModeKey];
        }
        if ([coder containsValueForKey:kUIAutocorrectionTypeKey]) {
            self.autocorrectionType = (UITextAutocorrectionType)[coder decodeIntegerForKey:kUIAutocorrectionTypeKey];
        }
        if ([coder containsValueForKey:kUIClearButtonOffsetKey]) {
            /* XXX: Implement Me */
        }
        if ([coder containsValueForKey:kUISpellCheckingTypeKey]) {
            /* XXX: Implement Me */
        }
        if ([coder containsValueForKey:kUIKeyboardAppearanceKey]) {
            /* XXX: Implement Me */
        }
        if ([coder containsValueForKey:kUIKeyboardTypeKey]) {
            /* XXX: Implement Me */
        }
        if ([coder containsValueForKey:kUIReturnKeyTypeKey]) {
            /* XXX: Implement Me */
        }
        if ([coder containsValueForKey:kUIEnablesReturnKeyAutomaticallyKey]) {
            /* XXX: Implement Me */
        }
        if ([coder containsValueForKey:kUISecureTextEntryKey]) {
            /* XXX: Implement Me */
        }
    }
    return self;
}

- (void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
    [_textLayer setHidden:hidden];
}

- (void) encodeWithCoder:(NSCoder*)coder
{
    [self doesNotRecognizeSelector:_cmd];
}

- (BOOL)_isLeftViewVisible
{
    return _leftView && (_leftViewMode == UITextFieldViewModeAlways
                         || (_editing && _leftViewMode == UITextFieldViewModeWhileEditing)
                         || (!_editing && _leftViewMode == UITextFieldViewModeUnlessEditing));
}

- (BOOL)_isRightViewVisible
{
    return _rightView && (_rightViewMode == UITextFieldViewModeAlways
                          || (_editing && _rightViewMode == UITextFieldViewModeWhileEditing)
                          || (!_editing && _rightViewMode == UITextFieldViewModeUnlessEditing));
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    const CGRect bounds = self.bounds;
    _textLayer.frame = [self textRectForBounds:bounds];
	_placeholderTextLayer.frame = [self textRectForBounds:bounds];
    
    if ([self _isLeftViewVisible]) {
        _leftView.hidden = NO;
        _leftView.frame = [self leftViewRectForBounds:bounds];
    } else {
        _leftView.hidden = YES;
    }
    
    if ([self _isRightViewVisible]) {
        _rightView.hidden = NO;
        _rightView.frame = [self rightViewRectForBounds:bounds];
    } else {
        _rightView.hidden = YES;
    }
}

- (void)setDelegate:(id<UITextFieldDelegate>)theDelegate
{
    if (theDelegate != _delegate) {
        _delegate = theDelegate;
        _delegateHas.shouldBeginEditing = [_delegate respondsToSelector:@selector(textFieldShouldBeginEditing:)];
        _delegateHas.didBeginEditing = [_delegate respondsToSelector:@selector(textFieldDidBeginEditing:)];
        _delegateHas.shouldEndEditing = [_delegate respondsToSelector:@selector(textFieldShouldEndEditing:)];
        _delegateHas.didEndEditing = [_delegate respondsToSelector:@selector(textFieldDidEndEditing:)];
        _delegateHas.shouldChangeCharacters = [_delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)];
        _delegateHas.shouldClear = [_delegate respondsToSelector:@selector(textFieldShouldClear:)];
        _delegateHas.shouldReturn = [_delegate respondsToSelector:@selector(textFieldShouldReturn:)];
		_delegateHas.doCommandBySelector = [_delegate respondsToSelector:@selector(textField:doCommandBySelector:)];
    }
}

- (void)setPlaceholder:(NSString *)thePlaceholder
{
    _placeholderTextLayer.text = thePlaceholder;
}

- (NSString *)placeholder {
	return _placeholderTextLayer.text;
}

- (void)setBorderStyle:(UITextBorderStyle)style
{
    if (style != _borderStyle) {
        _borderStyle = style;
        [self setNeedsDisplay];
    }
}

- (void)setBackground:(UIImage *)aBackground
{
    if (aBackground != _background) {
        [_background release];
        _background = [aBackground retain];
        [self setNeedsDisplay];
    }
}

- (void)setDisabledBackground:(UIImage *)aBackground
{
    if (aBackground != _disabledBackground) {
        [_disabledBackground release];
        _disabledBackground = [aBackground retain];
        [self setNeedsDisplay];
    }
}

- (void)setLeftView:(UIView *)leftView
{
    if (leftView != _leftView) {
        [_leftView removeFromSuperview];
        [_leftView release];
        _leftView = [leftView retain];
        [self addSubview:_leftView];
    }
}

- (void)setRightView:(UIView *)rightView
{
    if (rightView != _rightView) {
        [_rightView removeFromSuperview];
        [_rightView release];
        _rightView = [rightView retain];
        [self addSubview:_rightView];
    }
}

- (void)setFrame:(CGRect)frame
{
    if (!CGRectEqualToRect(frame,self.frame)) {
        [super setFrame:frame];
        [self setNeedsDisplay];
    }
}


- (CGRect)borderRectForBounds:(CGRect)bounds
{
	CGRect borderRect = bounds;
	
	if(self.borderStyle == UITextBorderStyleRoundedRect) {
		UIImage *image = [UIImage _textFieldRoundedRectBackground];
		borderRect = CGRectMake(4.0f, self.bounds.size.height/2 - image.size.height/2, self.bounds.size.width - 8.0f, image.size.height);
    }
    
    return CGRectIntegral(borderRect);
}

- (CGRect)clearButtonRectForBounds:(CGRect)bounds
{
    return CGRectZero;
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return [self textRectForBounds:bounds];
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds
{
    if (_leftView) {
        const CGRect frame = _leftView.frame;
        bounds.origin.x = 0;
        bounds.origin.y = (bounds.size.height / 2.f) - (frame.size.height/2.f);
        bounds.size = frame.size;
        return CGRectIntegral(bounds);
    } else {
        return CGRectZero;
    }
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds
{
    return [self textRectForBounds:bounds];
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds
{
    if (_rightView) {
        const CGRect frame = _rightView.frame;
        bounds.origin.x = bounds.size.width - frame.size.width;
        bounds.origin.y = (bounds.size.height / 2.f) - (frame.size.height/2.f);
        bounds.size = frame.size;
        return CGRectIntegral(bounds);
    } else {
        return CGRectZero;
    }
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    // Docs say:
    // The default implementation of this method returns a rectangle that is derived from the control’s original bounds,
    // but which does not include the area occupied by the receiver’s border or overlay views.
    
    // It appears what happens is something like this:
    // check border type:
    //   if no border, skip to next major step
    //   if has border, set textRect = borderBounds, then inset textRect according to border style
    // check if textRect overlaps with leftViewRect, if it does, make it smaller
    // check if textRect overlaps with rightViewRect, if it does, make it smaller
    // check if textRect overlaps with clearButtonRect (if currently needed?), if it does, make it smaller
    
    CGRect textRect = bounds;
    
    if (_borderStyle != UITextBorderStyleNone) {
        textRect = [self borderRectForBounds:bounds];
		if(self.borderStyle == UITextBorderStyleRoundedRect) {
			textRect = CGRectOffset(CGRectInset(textRect, 2.0f, 2.0f), 4.0f, 1.0f);
		} else if(self.borderStyle == UITextBorderStyleBezel) {
			textRect = CGRectOffset(CGRectInset(textRect, 2.0f, 2.0f), 2.0f, 3.0f);
		} else if(self.borderStyle == UITextBorderStyleLine) {
            //			textRect = CGRectOffset(CGRectInset(textRect, 2.0f, 2.0f), 2.0f, 3.0f);
        }
	}
    
    // Going to go ahead and assume that the left view is on the left, the right view is on the right, and there's space between..
    // I imagine this is a dangerous assumption...
    if ([self _isLeftViewVisible]) {
        CGRect overlap = CGRectIntersection(textRect,[self leftViewRectForBounds:bounds]);
        if (!CGRectIsNull(overlap)) {
            textRect = CGRectOffset(textRect, overlap.size.width, 0);
            textRect.size.width -= overlap.size.width;
        }
    }
    
    if ([self _isRightViewVisible]) {
        CGRect overlap = CGRectIntersection(textRect,[self rightViewRectForBounds:bounds]);
        if (!CGRectIsNull(overlap)) {
            textRect = CGRectOffset(textRect, -overlap.size.width, 0);
            textRect.size.width -= overlap.size.width;
        }
    }
    
    return CGRectIntegral(textRect);
}



- (void)drawPlaceholderInRect:(CGRect)rect
{
}

- (void)drawTextInRect:(CGRect)rect
{
}

- (void)drawRect:(CGRect)rect
{
    UIImage *currentBackgroundImage = nil;
	if(self.borderStyle == UITextBorderStyleRoundedRect) {
		currentBackgroundImage = [UIImage _textFieldRoundedRectBackground];
	} else {
		currentBackgroundImage = self.enabled? _background : _disabledBackground;
    }
    
	CGRect borderFrame = [self borderRectForBounds:self.bounds];
	if(currentBackgroundImage != nil) {
		[currentBackgroundImage drawInRect:borderFrame];
	} else {
		CGContextRef context = UIGraphicsGetCurrentContext();
        
		// TODO: draw the appropriate background for the borderStyle
		
		if(self.borderStyle == UITextBorderStyleBezel) {
			// bottom white highlight
			CGRect hightlightFrame = CGRectMake(0.0, 10.0, borderFrame.size.width, borderFrame.size.height-10.0);
			[[UIColor colorWithWhite:1.0 alpha:1.0] set];
			[[UIBezierPath bezierPathWithRoundedRect:hightlightFrame cornerRadius:3.6] fill];
			
			// top white highlight
			CGRect topHightlightFrame = CGRectMake(0.0, 0.0, borderFrame.size.width, borderFrame.size.height-10.0);
			[[UIColor colorWithWhite:0.7f alpha:1.0] set];
			[[UIBezierPath bezierPathWithRoundedRect:topHightlightFrame cornerRadius:3.6] fill];
			
			// black outline
			CGRect blackOutlineFrame = CGRectMake(0.0, 1.0, borderFrame.size.width, borderFrame.size.height-2.0);
			
			CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
			CGFloat locations[] = { 1.0f, 0.0f };
			CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef) [NSArray arrayWithObjects:(id) [UIColor colorWithWhite:0.5 alpha:1.0].CGColor, (id) [UIColor colorWithWhite:0.65 alpha:1.0].CGColor, nil], locations);
			
			CGContextSaveGState(context);
			CGContextAddPath(context, [UIBezierPath bezierPathWithRoundedRect:blackOutlineFrame cornerRadius:3.6f].CGPath);
			CGContextClip(context);
			
			CGContextDrawLinearGradient(context, gradient, CGPointMake(0.0f, CGRectGetMinY(blackOutlineFrame)), CGPointMake(0.0f, CGRectGetMaxY(blackOutlineFrame)), 0);
			CFRelease(colorSpace);
			CFRelease(gradient);
			
			CGContextRestoreGState(context);
            
			// top inner shadow
			CGRect shadowFrame = CGRectMake(1, 2, borderFrame.size.width-2.0, 10.0);
			[[UIColor colorWithWhite:0.88 alpha:1.0] set];
			[[UIBezierPath bezierPathWithRoundedRect:shadowFrame cornerRadius:2.9] fill];
			
			// main white area
			CGRect whiteFrame = CGRectMake(1, 3, borderFrame.size.width-2.0, borderFrame.size.height-5.0);
			[[UIColor whiteColor] set];
			[[UIBezierPath bezierPathWithRoundedRect:whiteFrame cornerRadius:2.6] fill];
		} else if(self.borderStyle == UITextBorderStyleLine) {
			[[UIColor colorWithWhite:0.1f alpha:0.8f] set];
			CGContextStrokeRect(context, borderFrame);
			
			[[UIColor colorWithWhite:1.0f alpha:1.0f] set];
			CGContextFillRect(context, CGRectInset(borderFrame, 1.0f, 1.0f));
		}
	}
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize textSize = _placeholderTextLayer.hidden ? [_textLayer.text sizeWithFont:_textLayer.font constrainedToSize:size] : [_placeholderTextLayer.text sizeWithFont:_placeholderTextLayer.font constrainedToSize:size];
    return CGSizeMake(size.width, textSize.height);
}

- (UITextAutocapitalizationType)autocapitalizationType
{
    return UITextAutocapitalizationTypeNone;
}

- (void)setAutocapitalizationType:(UITextAutocapitalizationType)type
{
}

- (UITextAutocorrectionType)autocorrectionType
{
    return UITextAutocorrectionTypeDefault;
}

- (void)setAutocorrectionType:(UITextAutocorrectionType)type
{
}

- (BOOL)enablesReturnKeyAutomatically
{
    return YES;
}

- (void)setEnablesReturnKeyAutomatically:(BOOL)enabled
{
}

- (UIKeyboardAppearance)keyboardAppearance
{
    return UIKeyboardAppearanceDefault;
}

- (void)setKeyboardAppearance:(UIKeyboardAppearance)type
{
}

- (UIKeyboardType)keyboardType
{
    return UIKeyboardTypeDefault;
}

- (void)setKeyboardType:(UIKeyboardType)type
{
}

- (UIReturnKeyType)returnKeyType
{
    return UIReturnKeyDefault;
}

- (void)setReturnKeyType:(UIReturnKeyType)type
{
}

- (BOOL)isSecureTextEntry
{
    return [_textLayer isSecureTextEntry];
}

- (void)setSecureTextEntry:(BOOL)secure
{
    [_textLayer setSecureTextEntry:secure];
}


- (BOOL)canBecomeFirstResponder
{
    return (self.window != nil);
}

- (BOOL)becomeFirstResponder
{
    if ([super becomeFirstResponder]) {
		_placeholderTextLayer.hidden = YES;
        _textLayer.hidden = NO;
        return [_textLayer becomeFirstResponder];
    } else {
        return NO;
    }
}

- (BOOL)resignFirstResponder
{
    if ([super resignFirstResponder]) {
        return [_textLayer resignFirstResponder];
    } else {
        return NO;
    }
}

- (UIFont *)font
{
    return _textLayer.font;
}

- (void)setFont:(UIFont *)newFont
{
    _textLayer.font = newFont;
	_placeholderTextLayer.font = newFont;
}

- (UIColor *)textColor
{
    return _textLayer.textColor;
}

- (void)setTextColor:(UIColor *)newColor
{
    _textLayer.textColor = newColor;
}

- (UITextAlignment)textAlignment
{
    return _textLayer.textAlignment;
}

- (void)setTextAlignment:(UITextAlignment)textAlignment
{
    _textLayer.textAlignment = textAlignment;
	_placeholderTextLayer.textAlignment = textAlignment;
}

- (NSString *)text
{
    return _textLayer.text;
}

- (void)setText:(NSString *)newText
{
    _textLayer.text = newText;
	
	_placeholderTextLayer.hidden = _textLayer.text.length > 0 || _editing;
    _textLayer.hidden = !_placeholderTextLayer.hidden;
}

- (BOOL)_textShouldBeginEditing
{
    return _delegateHas.shouldBeginEditing? [_delegate textFieldShouldBeginEditing:self] : YES;
}

- (void)_textDidBeginEditing
{
    BOOL shouldClear = _clearsOnBeginEditing;
    
    if (shouldClear && _delegateHas.shouldClear) {
        shouldClear = [_delegate textFieldShouldClear:self];
    }
    
    if (shouldClear) {
        // this doesn't work - it can cause an exception to trigger. hrm...
        // so... rather than worry too much about it right now, just gonna delay it :P
        //self.text = @"";
        [self performSelector:@selector(setText:) withObject:@"" afterDelay:0];
    }
    
	_placeholderTextLayer.hidden = YES;
    _textLayer.hidden = NO;
    
    _editing = YES;
    [self setNeedsDisplay];
    [self setNeedsLayout];
    
    if (_delegateHas.didBeginEditing) {
        [_delegate textFieldDidBeginEditing:self];
    }
    
    [self sendActionsForControlEvents:UIControlEventEditingDidBegin];
    [[NSNotificationCenter defaultCenter] postNotificationName:UITextFieldTextDidBeginEditingNotification object:self];
}

- (BOOL)_textShouldEndEditing
{
    return _delegateHas.shouldEndEditing? [_delegate textFieldShouldEndEditing:self] : YES;
}

- (void)_textDidEndEditing
{
    _editing = NO;
    _placeholderTextLayer.hidden = _textLayer.text.length > 0;
    _textLayer.hidden = !_placeholderTextLayer.hidden;
    
    [self setNeedsDisplay];
    [self setNeedsLayout];
    
    if (_delegateHas.didEndEditing) {
        [_delegate textFieldDidEndEditing:self];
    }
    
    [self sendActionsForControlEvents:UIControlEventEditingDidEnd];
    [[NSNotificationCenter defaultCenter] postNotificationName:UITextFieldTextDidEndEditingNotification object:self];
}

- (BOOL)_textShouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return _delegateHas.shouldChangeCharacters? [_delegate textField:self shouldChangeCharactersInRange:range replacementString:text] : YES;
}

- (void)_textDidChange
{
    [[NSNotificationCenter defaultCenter] postNotificationName:UITextFieldTextDidChangeNotification object:self];
}

- (void)_textDidReceiveReturnKey
{
    if (_delegateHas.shouldReturn) {
        [_delegate textFieldShouldReturn:self];
        [self sendActionsForControlEvents:UIControlEventEditingDidEndOnExit];
    }
}

- (BOOL)_textShouldDoCommandBySelector:(SEL)selector {
	if(_delegateHas.doCommandBySelector) {
		return [(id)self.delegate textField:self doCommandBySelector:selector];
	} else {
		if(selector == @selector(insertNewline:) || selector == @selector(insertNewlineIgnoringFieldEditor:)) {
			[self _textDidReceiveReturnKey];
			return YES;
		}
	}
	
	return NO;
}

- (NSString *)description
{
    NSString *textAlignment = @"";
    switch (self.textAlignment) {
        case UITextAlignmentLeft:
            textAlignment = @"Left";
            break;
        case UITextAlignmentCenter:
            textAlignment = @"Center";
            break;
        case UITextAlignmentRight:
            textAlignment = @"Right";
            break;
    }
    return [NSString stringWithFormat:@"<%@: %p; textAlignment = %@; editing = %@; textColor = %@; font = %@; delegate = %@>", [self className], self, textAlignment, (self.editing ? @"YES" : @"NO"), self.textColor, self.font, self.delegate];
}

- (id)mouseCursorForEvent:(UIEvent *)event
{
    return [NSCursor IBeamCursor];
}

@end
