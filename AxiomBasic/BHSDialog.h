//
//  BHSDialog.h
//  Food
//
//  Created by Dave Sferra on 2012-09-07.
//  Copyright (c) 2012 Blue Hawk Solutions inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BHSDialog : NSObject{
    IBOutlet NSTextField *status;
    IBOutlet NSTextField *title;
    IBOutlet NSButton *statusImage;
    IBOutlet NSWindow *dialogWindow;

}

@property(assign) IBOutlet NSWindow *dialogWindow;
@property(nonatomic, retain) IBOutlet NSTextField *title;
@property(nonatomic, retain) IBOutlet NSTextField *status;
@property(nonatomic, retain) IBOutlet NSButton *statusImage;


-(void)imageForEvent:(NSString*)isSuccess;

@end
