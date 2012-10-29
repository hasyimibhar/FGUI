/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2011 Zhengrong Zang
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 *
 * Use any of these editors to generate BMFonts:
 *   http://glyphdesigner.71squared.com/ (Commercial, Mac OS X)
 *   http://www.n4te.com/hiero/hiero.jnlp (Free, Java)
 *   http://slick.cokeandcode.com/demos/hiero.jnlp (Free, Java)
 *   http://www.angelcode.com/products/bmfont/ (Free, Windows only)
 */

#import "CCLabelBNFont.h"

// Equal function for targetSet.
typedef struct _KerningHashElement
{
	int				key;		// key for the hash. 16-bit for 1st element, 16-bit for 2nd element
	int				amount;
	UT_hash_handle	hh;
} tKerningHashElement;

@interface CCLabelBNFont ()

- (void)setupWithString:(NSString *)theString width:(float)width alignment:(CCTextAlignment)alignment;
-(int) kerningAmountForFirst:(unichar)first second:(unichar)second;
-(void) updateLabel;
-(void) setString:(NSString*) newString updateLabel:(BOOL)update;

@end

#pragma mark -
#pragma mark CCLabelBNFont
@implementation CCLabelBNFont

@synthesize alignment = alignment_;
@synthesize width = width_;

#pragma mark -
#pragma mark LabelBNFont - Purge Cache
+(void) purgeCachedData
{
	FNTConfigRemoveCache();
}

#pragma mark -
#pragma mark BitmapFontConfiguration

typedef struct _FontDefHashElement
{
	NSUInteger		key;		// key. Font Unicode value
	ccBMFontDef		fontDef;	// font definition
	UT_hash_handle	hh;
} tFontDefHashElement;

#pragma mark -
#pragma mark LabelBNFont - Creation & Init
+(id)spriteWithTexture:(CCTexture2D*)texture {
    NSAssert(NO, @"Invalid init, you have to use labelWithString");
	return nil;
}

+(id)spriteWithTexture:(CCTexture2D*)texture rect:(CGRect)rect {
    NSAssert(NO, @"Invalid init, you have to use labelWithString");
	return nil;
}

+(id)spriteWithFile:(NSString*)filename {
    NSAssert(NO, @"Invalid init, you have to use labelWithString");
	return nil;
}

+(id)spriteWithFile:(NSString*)filename rect:(CGRect)rect {
    NSAssert(NO, @"Invalid init, you have to use labelWithString");
	return nil;
}

+(id)spriteWithSpriteFrame:(CCSpriteFrame*)spriteFrame {
    NSAssert(NO, @"Invalid init, you have to use labelWithString");
	return nil;
}

+(id)spriteWithSpriteFrameName:(NSString*)spriteFrameName {
    NSAssert(NO, @"Invalid init, you have to use labelWithString");
	return nil;
}

+(id)spriteWithCGImage:(CGImageRef)image key:(NSString*)key {
    NSAssert(NO, @"Invalid init, you have to use labelWithString");
	return nil;
}

+(id) spriteWithBatchNode:(CCSpriteBatchNode*)batchNode rect:(CGRect)rect {
    NSAssert(NO, @"Invalid init, you have to use labelWithString");
	return nil;
}

-(id) initWithTexture:(CCTexture2D*)texture {
    NSAssert(NO, @"Invalid init, you have to use labelWithString");
	return nil;
}

-(id) initWithFile:(NSString*)filename {
    NSAssert(NO, @"Invalid init, you have to use labelWithString");
	return nil;
}

-(id) initWithFile:(NSString*)filename rect:(CGRect)rect {
    NSAssert(NO, @"Invalid init, you have to use labelWithString");
	return nil;
}

- (id) initWithSpriteFrame:(CCSpriteFrame*)spriteFrame {
    NSAssert(NO, @"Invalid init, you have to use labelWithString");
	return nil;
}

-(id)initWithSpriteFrameName:(NSString*)spriteFrameName {
    NSAssert(NO, @"Invalid init, you have to use labelWithString");
	return nil;
}

- (id) initWithCGImage:(CGImageRef)image key:(NSString*)key {
    NSAssert(NO, @"Invalid init, you have to use labelWithString");
	return nil;
}

-(id) initWithBatchNode:(CCSpriteBatchNode*)batchNode rect:(CGRect)rect {
    NSAssert(NO, @"Invalid init, you have to use labelWithString");
	return nil;
}

-(id) initWithBatchNode:(CCSpriteBatchNode*)batchNode rectInPixels:(CGRect)rect {
    NSAssert(NO, @"Invalid init, you have to use labelWithString");
	return nil;
}

+(id) labelWithString:(NSString *)string fntFile:(NSString *)fntFile {
	return [[[self alloc] initWithString:string fntFile:fntFile] autorelease];
}

+(id) labelWithString:(NSString*)string fntFile:(NSString*)fntFile width:(float)width alignment:(CCTextAlignment)alignment
{
    return [[[self alloc] initWithString:string fntFile:fntFile width:width alignment:alignment imageOffset:CGPointZero] autorelease];
}

-(id) initWithString:(NSString*)theString fntFile:(NSString*)fntFile {
    
	return [self initWithString:theString fntFile:fntFile width:kCCLabelAutomaticWidth alignment:kCCTextAlignmentLeft];
}

-(id) initWithString:(NSString*)theString fntFile:(NSString*)fntFile width:(float)width alignment:(CCTextAlignment)alignment
{
	[configuration_ release]; // allow re-init
	configuration_ = FNTConfigLoadFile(fntFile);
	[configuration_ retain];
    
	NSAssert(configuration_, @"Error creating config for LabelBNFont");
    
	CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:configuration_.atlasName];
    
    if (frame) {
        if ((self = [super initWithSpriteFrame:frame])) {
            [self setupWithString:theString width:width alignment:alignment];
        }
    }
	else if ((self = [super initWithFile:configuration_.atlasName])) {
    	[self setupWithString:theString width:width alignment:alignment];
    }
    
	return self;
}

-(void) dealloc {
	[string_ release];
	[configuration_ release];
	[super dealloc];
}

- (void)setupWithString:(NSString *)theString width:(float)width alignment:(CCTextAlignment)alignment
{
    width_ = width;
    alignment_ = alignment;
    opacity_ = 255;
    color_ = ccWHITE;
    
    contentSize_ = CGSizeZero;
    
    opacityModifyRGB_ = YES;
    anchorPoint_ = ccp(0.5f, 0.5f);
    
    [self setString:theString updateLabel:YES];
}

- (void)updateLabel
{
    [self setString:initialString_ updateLabel:NO];
	
    if (width_ != kCCLabelAutomaticWidth){
        //Step 1: Make multiline
		
        NSString *multilineString = @"", *lastWord = @"";
        int line = 1, i = 0;
        NSUInteger stringLength = [self.string length];
        float startOfLine = -1, startOfWord = -1;
        int skip = 0;
        //Go through each character and insert line breaks as necessary
        for (int j = 0; j < [children_ count]; j++) {
            CCSprite *characterSprite;
			
            while(!(characterSprite = (CCSprite *)[self getChildByTag:j+skip]))
                skip++;
			
            if (!characterSprite.visible) continue;
			
            if (i >= stringLength || i < 0)
                break;
			
            unichar character = [self.string characterAtIndex:i];
			
            if (startOfWord == -1)
                startOfWord = characterSprite.position.x - characterSprite.contentSize.width/2;
            if (startOfLine == -1)
                startOfLine = startOfWord;
			
            //Character is a line break
            //Put lastWord on the current line and start a new line
            //Reset lastWord
            if ([[NSCharacterSet newlineCharacterSet] characterIsMember:character]) {
                lastWord = [[lastWord stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] stringByAppendingFormat:@"%C", character];
                multilineString = [multilineString stringByAppendingString:lastWord];
                lastWord = @"";
                startOfWord = -1;
                line++;
                startOfLine = -1;
                i++;
				
                //CCLabelBMFont do not have a character for new lines, so do NOT "continue;" in the for loop. Process the next character
                if (i >= stringLength || i < 0)
                    break;
                character = [self.string characterAtIndex:i];
				
                if (startOfWord == -1)
                    startOfWord = characterSprite.position.x - characterSprite.contentSize.width/2;
                if (startOfLine == -1)
                    startOfLine = startOfWord;
            }
			
            //Character is a whitespace
            //Put lastWord on current line and continue on current line
            //Reset lastWord
            if ([[NSCharacterSet whitespaceCharacterSet] characterIsMember:character]) {
                lastWord = [lastWord stringByAppendingFormat:@"%C", character];
                multilineString = [multilineString stringByAppendingString:lastWord];
                lastWord = @"";
                startOfWord = -1;
                i++;
                continue;
            }
			
            //Character is out of bounds
            //Do not put lastWord on current line. Add "\n" to current line to start a new line
            //Append to lastWord
            if (characterSprite.position.x + characterSprite.contentSize.width/2 - startOfLine >  width_) {
                lastWord = [lastWord stringByAppendingFormat:@"%C", character];
                NSString *trimmedString = [multilineString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                multilineString = [trimmedString stringByAppendingString:@"\n"];
                line++;
                startOfLine = -1;
                i++;
                continue;
            } else {
                //Character is normal
                //Append to lastWord
                lastWord = [lastWord stringByAppendingFormat:@"%C", character];
                i++;
                continue;
            }
        }
		
        multilineString = [multilineString stringByAppendingFormat:@"%@", lastWord];
		
        [self setString:multilineString updateLabel:NO];
    }
	
    //Step 2: Make alignment
	
    if (self.alignment != kCCTextAlignmentLeft) {
		
        int i = 0;
        //Number of spaces skipped
        int lineNumber = 0;
        //Go through line by line
        for (NSString *lineString in [string_ componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]]) {
            int lineWidth = 0;
			
            //Find index of last character in this line
            NSInteger index = i + [lineString length] - 1 + lineNumber;
            if (index < 0)
                continue;
			
            //Find position of last character on the line
            CCSprite *lastChar = (CCSprite *)[self getChildByTag:index];
			
            lineWidth = lastChar.position.x + lastChar.contentSize.width/2;
			
            //Figure out how much to shift each character in this line horizontally
            float shift = 0;
            switch (self.alignment) {
                case kCCTextAlignmentCenter:
                    shift = self.contentSize.width/2 - lineWidth/2;
                    break;
                case kCCTextAlignmentRight:
                    shift = self.contentSize.width - lineWidth;
                default:
                    break;
            }
			
            if (shift != 0) {
                int j = 0;
                //For each character, shift it so that the line is center aligned
                for (j = 0; j < [lineString length]; j++) {
                    index = i + j + lineNumber;
                    if (index < 0)
                        continue;
                    CCSprite *characterSprite = (CCSprite *)[self getChildByTag:index];
                    characterSprite.position = ccpAdd(characterSprite.position, ccp(shift, 0));
                }
            }
            i += [lineString length];
            lineNumber++;
        }
    }
}

#pragma mark -
#pragma mark LabelBNFont - Atlas generation
-(int) kerningAmountForFirst:(unichar)first second:(unichar)second {
	int ret = 0;
	unsigned int key = (first<<16) | (second & 0xffff);
    
	if (configuration_->kerningDictionary_) {
		tKerningHashElement *element = NULL;
		HASH_FIND_INT(configuration_->kerningDictionary_, &key, element);
        
		if (element) {
			ret = element->amount;
        }
	}
    
	return ret;
}

-(void) createFontChars {
	NSInteger nextFontPositionX = 0;
	NSInteger nextFontPositionY = 0;
	unichar prev = -1;
	NSInteger kerningAmount = 0;
    
	CGSize tmpSize = CGSizeZero;
    
	NSInteger longestLine = 0;
	NSUInteger totalHeight = 0;
	NSUInteger quantityOfLines = 1;
	NSUInteger stringLen = [string_ length];
    
    if (!stringLen) {
		return;
    }
    
	// quantity of lines NEEDS to be calculated before parsing the lines,
	// since the Y position needs to be calcualted before hand
	for(NSUInteger i = 0; i < stringLen - 1; i++) {
		unichar c = [string_ characterAtIndex:i];
        
		if (c == '\n') {
			quantityOfLines++;
        }
	}
    
	totalHeight = configuration_->commonHeight_ * quantityOfLines;
	nextFontPositionY = -(configuration_->commonHeight_ - configuration_->commonHeight_ * quantityOfLines);
    
	for(NSUInteger i = 0; i < stringLen; i++) {
		unichar c = [string_ characterAtIndex:i];
		//NSAssert( c < kCCBMFontMaxChars, @"LabelBMFont: character outside bounds");
        
		if (c == '\n') {
			nextFontPositionX = 0;
			nextFontPositionY -= configuration_->commonHeight_;
			continue;
		}
        
		kerningAmount = [self kerningAmountForFirst:prev second:c];
        
		tFontDefHashElement *element = NULL;
        
		// unichar is a short, and an int is needed on HASH_FIND_INT
		NSUInteger key = (NSUInteger)c;
		HASH_FIND_INT(configuration_->fontDefDictionary_ , &key, element);
//		NSAssert(element, @"FontDefinition could not be found!");
        
        if (element == nil)
            continue;
        
		ccBMFontDef fontDef = element->fontDef;
        
        CGRect rect1 = CC_RECT_POINTS_TO_PIXELS(self.textureRect);
		CGRect rect2 = (fontDef.rect);
        rect2.origin.x += rect1.origin.x;
        rect2.origin.y += rect1.origin.y;
        CGRect rect3 = CC_RECT_PIXELS_TO_POINTS(rect2);
        
		CCSprite *fontChar = (CCSprite*) [self getChildByTag:i];
        
		if (!fontChar) {
			fontChar = [[CCSprite alloc] initWithTexture:self.texture rect:rect3];
			[self addChild:fontChar z:0 tag:i];
			[fontChar release];
		}
		else {
			// reusing fonts
            CGRect tmpRect = CC_RECT_PIXELS_TO_POINTS(rect2);
			[fontChar setTextureRect:tmpRect rotated:NO untrimmedSize:tmpRect.size];
			// restore to default in case they were modified
			fontChar.visible = YES;
			fontChar.opacity = 255;
		}
        
		float yOffset = configuration_->commonHeight_ - fontDef.yOffset;
		CGPoint fontPos = ccp(
                              (float)nextFontPositionX +
                              fontDef.xOffset +
                              fontDef.rect.size.width * 0.5f +
                              kerningAmount,
                              (float)nextFontPositionY +
                              yOffset -
                              rect3.size.height * 0.5f * CC_CONTENT_SCALE_FACTOR());
        
        fontChar.position = CC_POINT_PIXELS_TO_POINTS(fontPos);
        
		// update kerning
		nextFontPositionX += element->fontDef.xAdvance + kerningAmount;
		prev = c;
        
		// Apply label properties
		[fontChar setOpacityModifyRGB:opacityModifyRGB_];
        
		// Color MUST be set before opacity, since opacity might change color if OpacityModifyRGB is on
		[fontChar setColor:color_];
        
		// only apply opacity if it is different than 255 )
		// to prevent modifying the color too (issue #610)
		if (opacity_ != 255 && opacity_ != 0) {
			[fontChar setOpacity: opacity_];
        }
        
		if (longestLine < nextFontPositionX) {
			longestLine = nextFontPositionX;
        }
	}
    
    tmpSize.width = longestLine;
	tmpSize.height = totalHeight;
    
    [self setContentSize:CC_SIZE_PIXELS_TO_POINTS(tmpSize)];
    
    [super setOpacity:0];
    [super setDirty:NO];
}

#pragma mark -
#pragma mark LabelBNFont - CCLabelProtocol protocol
- (void) setString:(NSString*)newString
{
	[self setString:newString updateLabel:YES];
}

- (void) setString:(NSString*) newString updateLabel:(BOOL)update
{
    if( !update ) {
        [string_ release];
        string_ = [newString copy];
    } else {
        [initialString_ release];
        initialString_ = [newString copy];
    }
	
    CCSprite *child;
    CCARRAY_FOREACH(children_, child)
	child.visible = NO;
	
	[self createFontChars];
	
    if (update)
        [self updateLabel];
}

-(NSString*) string {
	return string_;
}

-(void) setCString:(char*)label {
	[self setString:[NSString stringWithUTF8String:label]];
}

#pragma mark -
#pragma mark LabelBNFont - RGBA protocol
// don't show parent of LabelBNFont
-(void) setOpacity:(GLubyte) anOpacity {
    [super setOpacity:0];
    CCSprite *child;
    CCARRAY_FOREACH(children_, child) {
        [child setOpacity:anOpacity];
    }
}

-(void) setColor:(ccColor3B)color3 {
    [super setColor:color3];
    
	CCSprite *child;
	CCARRAY_FOREACH(children_, child) {
    	[child setColor:color3];
    }
}

#pragma mark LabelBMFont - Alignment
- (void)setWidth:(float)width {
    width_ = width;
    [self updateLabel];
}

- (void)setAlignment:(CCTextAlignment)alignment {
    alignment_ = alignment;
    [self updateLabel];
}

@end