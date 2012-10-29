//
//  FGUILabel.h
//  FGUISample
//
//  Created by Hasyimi Bahrudin on 10/29/12.
//
//

#import "FGUIElement.h"
#import "CCLabelBNFont.h"
#import "CCProtocols.h"

@interface FGUILabel : FGUIElement<CCLabelProtocol>
{
    CCLabelBNFont *label;
}

+ (id)labelWithString:(NSString *)aString file:(NSString *)aFile;
+ (id)labelWithString:(NSString *)aString file:(NSString *)aFile width:(float)aWidth alignment:(CCTextAlignment)aAlignment;

- (id)initWithString:(NSString *)aString file:(NSString *)aFile;
- (id)initWithString:(NSString *)aString file:(NSString *)aFile width:(float)aWidth alignment:(CCTextAlignment)aAlignment;

@property (readwrite, copy, nonatomic) NSString * string;
@property (readwrite, nonatomic) float width;
@property (readwrite, nonatomic) CCTextAlignment alignment;
@property (readwrite, nonatomic) ccColor3B color;
@property (readwrite, nonatomic) GLubyte opacity;

@end