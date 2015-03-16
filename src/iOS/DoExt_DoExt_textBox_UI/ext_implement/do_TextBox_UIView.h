//
//  TYPEID_View.h
//  DoExt_UI
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "do_TextBox_IView.h"
#import "do_TextBox_UIModel.h"
#import "doIUIModuleView.h"

@interface do_TextBox_UIView : UITextView<do_TextBox_IView,doIUIModuleView,UITextViewDelegate>
//可根据具体实现替换UIView
{
    @private
    __weak do_TextBox_UIModel *_model;
    
    float keyBoardHeight;
    UITextView *_placeholderTextView;//默认提示框
    int maxLength;//设置文本可以显示的最大长度
    NSString *Hint;
}

@end
