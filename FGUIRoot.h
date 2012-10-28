//
//  FGUIRoot.h
//  FGUISample
//
//  Created by Hasyimi Bahrudin on 10/28/12.
//
//

#import "CCTouchDelegateProtocol.h"
#import "CCSpriteBatchNode.h"
#import "FGUIElement.h"

@interface FGUIRoot : FGUIElement<CCTargetedTouchDelegate>
{
    CCSpriteBatchNode   *batchNode;
}

+ (id)guiWithFile:(NSString *)aFile;

- (id)initWithFile:(NSString *)aFile;

@property (readonly, assign, nonatomic) CCSpriteBatchNode * batchNode;

@end
