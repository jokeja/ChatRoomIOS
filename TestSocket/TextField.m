//
//  TextField.m
//  TestSocket
//
//  Created by jasuho on 23/02/2017.
//  Copyright © 2017 jiaxuhui. All rights reserved.
//

#import "TextField.h"


@interface TextField()<UITextFieldDelegate>

@end

@implementation TextField


-(id)initWithFrame:(CGRect)frame{
    if(self=[super initWithFrame:frame]){
        self.delegate=self;
        self.returnKeyType=UIReturnKeySend;
        
    }
    return self;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(self.sendBlock){
        self.sendBlock(self.text);
        self.text=@"";
    }
    return NO;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
