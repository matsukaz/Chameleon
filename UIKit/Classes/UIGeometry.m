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

#import "UIGeometry.h"

#if CGFLOAT_IS_DOUBLE
#define kUIEdgeInsetsFormat "{%lg, %lg, %lg, %lg}"
#else
#define kUIEdgeInsetsFormat "{%g, %g, %g, %g}"    
#endif


const UIEdgeInsets UIEdgeInsetsZero = {0,0,0,0};
const UIOffset UIOffsetZero = {0,0};

NSString *NSStringFromCGPoint(CGPoint p)
{
    return NSStringFromPoint(NSPointFromCGPoint(p));
}

NSString *NSStringFromCGRect(CGRect r)
{
    return NSStringFromRect(NSRectFromCGRect(r));
}

NSString *NSStringFromCGSize(CGSize s)
{
    return NSStringFromSize(NSSizeFromCGSize(s));
}

NSString *NSStringFromCGAffineTransform(CGAffineTransform transform)
{
    return [NSString stringWithFormat:@"[%g, %g, %g, %g, %g, %g]", transform.a, transform.b, transform.c, transform.d, transform.tx, transform.ty];
}

NSString *NSStringFromUIEdgeInsets(UIEdgeInsets insets)
{
    return [NSString stringWithFormat:@kUIEdgeInsetsFormat, insets.top, insets.left, insets.bottom, insets.right];
}

UIEdgeInsets UIEdgeInsetsFromString(NSString* string)
{
    UIEdgeInsets result = UIEdgeInsetsZero;
    if (string) {
        sscanf([string UTF8String], kUIEdgeInsetsFormat, &result.top, &result.left, &result.bottom, &result.right);
    }
    return result;
}

CGRect CGRectFromString(NSString* string)
{
    return NSRectToCGRect(NSRectFromString(string));
}

CGPoint CGPointFromString(NSString* string)
{
    return NSPointToCGPoint(NSPointFromString(string));
}

NSString *NSStringFromUIOffset(UIOffset offset)
{
    return [NSString stringWithFormat:@"{%g, %g}", offset.horizontal, offset.vertical];
}

@implementation NSValue (NSValueUIGeometryExtensions)
+ (NSValue *)valueWithCGPoint:(CGPoint)point
{
    return [NSValue valueWithPoint:NSPointFromCGPoint(point)];
}

- (CGPoint)CGPointValue
{
    return NSPointToCGPoint([self pointValue]);
}

+ (NSValue *)valueWithCGRect:(CGRect)rect
{
    return [NSValue valueWithRect:NSRectFromCGRect(rect)];
}

- (CGRect)CGRectValue
{
    return NSRectToCGRect([self rectValue]);
}

+ (NSValue *)valueWithCGSize:(CGSize)size
{
    return [NSValue valueWithSize:NSSizeFromCGSize(size)];
}

- (CGSize)CGSizeValue
{
    return NSSizeToCGSize([self sizeValue]);
}

+ (NSValue *)valueWithUIEdgeInsets:(UIEdgeInsets)insets
{
    return [NSValue valueWithBytes: &insets objCType: @encode(UIEdgeInsets)];
}

- (UIEdgeInsets)UIEdgeInsetsValue
{
    if (strcmp([self objCType], @encode(UIEdgeInsets)) == 0) {
        UIEdgeInsets insets;
        [self getValue: &insets];
        return insets;
    }
    return UIEdgeInsetsZero;
}

+ (NSValue *)valueWithUIOffset:(UIOffset)offset
{
    return [NSValue valueWithBytes: &offset objCType: @encode(UIOffset)];
}

- (UIOffset)UIOffsetValue
{
    if(strcmp([self objCType], @encode(UIOffset)) == 0)
    {
        UIOffset offset;
        [self getValue: &offset];
        return offset;
    }
    return UIOffsetZero;
}

@end

@implementation NSCoder (NSCoderUIGeometryExtensions)

- (void)encodeCGPoint:(CGPoint)point forKey:(NSString *)key
{
    [self encodePoint:NSPointFromCGPoint(point) forKey:key];
}

- (CGPoint)decodeCGPointForKey:(NSString *)key
{
    return NSPointToCGPoint([self decodePointForKey:key]);
}

- (void)encodeCGRect:(CGRect)rect forKey:(NSString *)key
{
    [self encodeRect:NSRectFromCGRect(rect) forKey:key];
}

- (CGRect)decodeCGRectForKey:(NSString *)key
{
    return NSRectToCGRect([self decodeRectForKey:key]);
}

- (void)encodeCGSize:(CGSize)size forKey:(NSString *)key
{
    [self encodeSize:NSSizeFromCGSize(size) forKey:key];
}

- (CGSize) decodeCGSizeForKey:(NSString*)key
{
    return NSSizeToCGSize([self decodeSizeForKey:key]);
}

- (void)encodeUIEdgeInsets:(UIEdgeInsets)insets forKey:(NSString *)key
{
    [self encodeObject:NSStringFromUIEdgeInsets(insets) forKey:key];
}


- (UIEdgeInsets) decodeUIEdgeInsetsForKey:(NSString*)key;
{
    return UIEdgeInsetsFromString([self decodeObjectForKey:key]);
}

@end
