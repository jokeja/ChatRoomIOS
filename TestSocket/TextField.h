//
//  TextField.h
//  TestSocket
//
//  Created by jasuho on 23/02/2017.
//  Copyright © 2017 jiaxuhui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextField : UITextField

@property(nonatomic,copy)void(^sendBlock)(NSString* content);


@end
