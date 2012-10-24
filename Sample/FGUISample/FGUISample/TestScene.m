//
//  TestScene.m
//  FGUISample
//
//  Created by Hasyimi Bahrudin on 10/24/12.
//
//

#import "TestScene.h"

@implementation TestScene

- (id)init
{
	if ((self = [super init]))
	{
        guiRoot = nil;
	}
	
	return self;
}

- (void)dealloc
{
    [guiRoot release];
	[super dealloc];
}

@end
