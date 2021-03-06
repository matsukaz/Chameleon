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

#import "UIToolbarButton.h"
#import "UIBarButtonItem.h"
#import "UIBarButtonItem+UIPrivate.h"
#import "UIImage+UIPrivate.h"
#import "UILabel.h"
#import "UIFont.h"
#import "UIToolbarItem.h"

// I don't like most of this... the real toolbar button lays things out different than a default button.
// It also seems to have some padding built into it around the whole thing (even the background)
// It centers images vertical and horizontal if not bordered, but it appears to be top-aligned if it's bordered
// If you specify both an image and a title, these buttons stack them vertically which is unlike default UIButton behavior
// This is all a pain in the ass and wrong, but good enough for now, I guess


__attribute__((annotate("returns_localized_nsstring")))
static inline NSString *LocalizationNotNeeded(NSString *s) {
    return s;
}


static UIEdgeInsets UIToolbarButtonInset = {0,4,0,4};

@implementation UIToolbarButton

- (id)initWithBarButtonItem:(UIBarButtonItem *)item
{
    NSAssert(item != nil, @"bar button item must not be nil");
    CGRect frame = CGRectMake(0,0,24,24);
    
    if ((self=[super initWithFrame:frame])) {
        UIImage *image = nil;
        NSString *title = nil;
        
        if (item->_isSystemItem) {
            switch (item->_systemItem) {
                case UIBarButtonSystemItemDone:
                    title = @"Done";
                    break;
                case UIBarButtonSystemItemSave:
                    title = @"Save";
                    break;
                case UIBarButtonSystemItemCancel:
                    title = @"Cancel";
                    break;
                case UIBarButtonSystemItemEdit:
                    title = @"Edit";
                    break;
                case UIBarButtonSystemItemUndo:
                    title = @"Undo";
                    break;
                case UIBarButtonSystemItemRedo:
                    title = @"Redo";
                    break;
                case UIBarButtonSystemItemAdd:
                    self.imageEdgeInsets = UIEdgeInsetsMake(2,0,0,0);
                    image = [UIImage _buttonBarSystemItemAdd];
                    break;
                case UIBarButtonSystemItemReply:
                    image = [UIImage _buttonBarSystemItemReply];
                    break;
                case UIBarButtonSystemItemAction:
                    image = [UIImage _buttonBarSystemItemAction];
                    break;
                case UIBarButtonSystemItemCompose:
                    image = [UIImage _buttonBarSystemItemCompose];
                    break;
                case UIBarButtonSystemItemOrganize:
                    image = [UIImage _buttonBarSystemItemOrganize];
                    break;
                case UIBarButtonSystemItemBookmarks:
                    image = [UIImage _buttonBarSystemItemBookmarks];
                    break;
                case UIBarButtonSystemItemSearch:
                    image = [UIImage _buttonBarSystemItemSearch];
                    break;
                case UIBarButtonSystemItemRefresh:
                    image = [UIImage _buttonBarSystemItemRefresh];
                    break;
                case UIBarButtonSystemItemStop:
                    image = [UIImage _buttonBarSystemItemStop];
                    break;
                case UIBarButtonSystemItemCamera:
                    image = [UIImage _buttonBarSystemItemCamera];
                    break;
                case UIBarButtonSystemItemTrash:
                    image = [UIImage _buttonBarSystemItemTrash];
                    break;
                case UIBarButtonSystemItemPlay:
                    image = [UIImage _buttonBarSystemItemPlay];
                    break;
                case UIBarButtonSystemItemPause:
                    image = [UIImage _buttonBarSystemItemPause];
                    break;
                case UIBarButtonSystemItemRewind:
                    image = [UIImage _buttonBarSystemItemRewind];
                    break;
                case UIBarButtonSystemItemFastForward:
                    image = [UIImage _buttonBarSystemItemFastForward];
                    break;
                case UIBarButtonSystemItemFixedSpace:
                    // TODO: Implement these.
                    break;
                default:
                    break;
            }
            //item.width = image.size.width;
        } else {
            image = [item.image _toolbarImage];
            title = item.title;

            if (item.style == UIBarButtonItemStyleBordered) {
                self.titleLabel.font = [UIFont systemFontOfSize:11];
                [self setBackgroundImage:[UIImage _toolbarButtonImage] forState:UIControlStateNormal];
                [self setBackgroundImage:[UIImage _highlightedToolbarButtonImage] forState:UIControlStateHighlighted];
                self.contentEdgeInsets = UIEdgeInsetsMake(0,7,0,7);
                self.titleEdgeInsets = UIEdgeInsetsMake(4,0,0,0);
                self.clipsToBounds = YES;
                self.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
            }
        }
        
        [self setImage:image forState:UIControlStateNormal];
        [self setTitle:LocalizationNotNeeded(title) forState:UIControlStateNormal];
        [self addTarget:item.target action:item.action forControlEvents:UIControlEventTouchUpInside];
        
        // resize the view to fit according to the rules, which appear to be that if the width is set directly in the item, use that
        // value, otherwise size to fit - but cap the total height, I guess?
        CGSize fitToSize = frame.size;

        if (item.width > 0) {
            frame.size.width = item.width;
        } else {
            frame.size.width = [self sizeThatFits:fitToSize].width;
        }
        
        self.frame = frame;
    }
    return self;
}

#pragma mark NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"_toolbarItem.item.image"]) {
        [self setImage:[_toolbarItem.item.image _toolbarImage] forState:UIControlStateNormal];
        [self setNeedsDisplay];
        return;
    }
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (CGRect)backgroundRectForBounds:(CGRect)bounds
{
    return UIEdgeInsetsInsetRect(bounds, UIToolbarButtonInset);
}

- (CGRect)contentRectForBounds:(CGRect)bounds
{
    return UIEdgeInsetsInsetRect(bounds, UIToolbarButtonInset);
}

- (CGSize)sizeThatFits:(CGSize)fitSize
{
    fitSize = [super sizeThatFits:fitSize];
    fitSize.width += UIToolbarButtonInset.left + UIToolbarButtonInset.right;
    fitSize.height += UIToolbarButtonInset.top + UIToolbarButtonInset.bottom;
    return fitSize;
}

- (UIToolbarItem*) _getToolbarItem
{
    return _toolbarItem;
}

- (void) _setToolbarItem:(UIToolbarItem*) item
{
    if(_toolbarItem) {
        [self removeObserver:self forKeyPath:@"_toolbarItem.item.image"];
        [item release];
    }
    _toolbarItem = [item retain];
    [self addObserver:self forKeyPath:@"_toolbarItem.item.image" options:NSKeyValueObservingOptionNew context:nil];
}

- (void) dealloc {
    if(_toolbarItem) {
        [self removeObserver:self forKeyPath:@"_toolbarItem.item.image"];
    }
    [_toolbarItem release];
    [super dealloc];
}

@end
