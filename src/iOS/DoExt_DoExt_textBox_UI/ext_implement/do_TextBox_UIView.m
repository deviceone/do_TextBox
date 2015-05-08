//
//  TYPEID_View.m
//  DoExt_UI
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import "do_TextBox_UIView.h"

#import "doInvokeResult.h"
#import "doIPage.h"
#import "doIScriptEngine.h"
#import "doUIModuleHelper.h"
#import "doScriptEngineHelper.h"
#import "doTextHelper.h"
#import "doIPage.h"
#import "doDefines.h"

@implementation do_TextBox_UIView
{
    NSString *_myFontStyle;
    NSString *_oldFontStyel;
}
#pragma mark - doIUIModuleView协议方法（必须）
//引用Model对象
- (void) LoadView: (doUIModule *) _doUIModule
{
    _model = (typeof(_model)) _doUIModule;
    
    self.delegate =self;
    //提示内容
    maxLength = -1;
    _placeholderTextView = [[UITextView alloc] init];
    _placeholderTextView.userInteractionEnabled = FALSE;//由于默认不带默认提示消息，这个控件是在原来的控件上进行覆盖的，所以必须设置为false
    _placeholderTextView.layer.borderColor = [UIColor clearColor].CGColor;
    _placeholderTextView.layer.borderWidth = 2;
    _placeholderTextView.backgroundColor = [UIColor clearColor];
    _placeholderTextView.frame = CGRectMake(0, 0,[[doTextHelper Instance] StrToDouble:[_model GetPropertyValue:@"width"]:0],[[doTextHelper Instance] StrToDouble:[_model GetPropertyValue:@"height"]:0]);
    _placeholderTextView.textColor = [UIColor grayColor];
    [self change_fontSize:[_model GetProperty:@"fontSize"].DefaultValue];
    [self addSubview:_placeholderTextView];
    self.backgroundColor = [UIColor clearColor];
}
//销毁所有的全局对象
- (void) OnDispose
{
    _myFontStyle = nil;
}
//实现布局
- (void) OnRedraw
{
    //实现布局相关的修改
    
    //重新调整视图的x,y,w,h
    [doUIModuleHelper OnRedraw:_model];
}

#pragma mark - TYPEID_IView协议方法（必须）
#pragma mark - Changed_属性
/*
 如果在Model及父类中注册过 "属性"，可用这种方法获取
 NSString *属性名 = [(doUIModule *)_model GetPropertyValue:@"属性名"];
 
 获取属性最初的默认值
 NSString *属性名 = [(doUIModule *)_model GetProperty:@"属性名"].DefaultValue;
 */
- (void)change_text:(NSString *)newValue{
    [self setText:newValue];
    if(_myFontStyle)
        [self change_fontStyle:_myFontStyle];
}
- (void)change_fontColor:(NSString *)newValue{
    [self setTextColor:[doUIModuleHelper GetColorFromString:newValue :[UIColor blackColor]]];
}
- (void)change_fontSize:(NSString *)newValue{
    UIFont * font = self.font;
    if (font == nil) {
        font = [UIFont systemFontOfSize:[[_model GetProperty:@"fontSize"].DefaultValue intValue]];
    }
    int _intFontSize = [doUIModuleHelper GetDeviceFontSize:[[doTextHelper Instance] StrToInt:newValue :[[_model GetProperty:@"fontSize"].DefaultValue intValue]] :_model.XZoom :_model.YZoom];
    self.font = [font fontWithSize:_intFontSize];//z012
    _placeholderTextView.font = self.font;
}
- (void)change_fontStyle:(NSString *)newValue{
    _myFontStyle = [NSString stringWithFormat:@"%@",newValue];
    if (self.text==nil || [self.text isEqualToString:@""]) return;
    NSRange range = {0,[self.text length]};
    NSMutableAttributedString *str = [self.attributedText mutableCopy];
    [str removeAttribute:NSUnderlineStyleAttributeName range:range];
    self.attributedText = str;
    
    float fontSize = self.font.pointSize;
    if([newValue isEqualToString:@"normal"])
        [self setFont:[UIFont systemFontOfSize:fontSize]];
    else if([newValue isEqualToString:@"bold"])
    {
        if([_oldFontStyel isEqualToString:@"italic"])
            [self setFont:[UIFont fontWithName:@"Helvetica-BoldOblique" size:fontSize]];
        else
            [self setFont:[UIFont boldSystemFontOfSize:fontSize]];
    }
    else if([newValue isEqualToString:@"italic"])
    {
        if([_oldFontStyel isEqualToString:@"bold"])
            [self setFont:[UIFont fontWithName:@"Helvetica-BoldOblique" size:fontSize]];
        else
            [self setFont:[UIFont italicSystemFontOfSize:fontSize]];
    }
    else if([newValue isEqualToString:@"underline"])
    {
        NSMutableAttributedString *content = [self.attributedText mutableCopy];
        NSRange contentRange = {0,[content length]};
        [content addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:contentRange];
        self.attributedText = content;
        [content endEditing];
    }
    else
    {
        NSString *mesg = [NSString stringWithFormat:@"不支持字体:%@",newValue];
        [NSException raise:@"do_TextBox" format:mesg,@""];
    }
    _oldFontStyel = newValue;
}

- (void)change_hint:(NSString *)newValue{
    
    [self setHint:newValue];
}

- (void)change_maxLength:(NSString *)newValue
{
    maxLength = [[doTextHelper Instance] StrToInt:newValue :0];
    NSString *str = self.text;
    if(maxLength < str.length)
        self.text = [str substringToIndex:maxLength];

}
#pragma mark - private mothed
- (void) registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(keyboardWasHidden:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewChanged:) name:UITextViewTextDidChangeNotification object:self];
}

//输入框为空时显示的文字提示信息。灰色文字显示。
-(void)setHint:(NSString *)hint
{
    Hint = [hint copy];
    if (self.text.length == 0) {
        [self showHint];
    }
}

-(void)setText:(NSString *)Text
{
    [super setText:Text];
    if (Text.length == 0) {
        [self showHint];
    }else
    {
        [self dismissHint];
    }
}
#pragma mark -
#pragma mark - textFiled add private
-(void)OnTextChanged:(UITextView *)_textView
{
    if (_textView.text.length == 0) {
        [self showHint];
    }else{
        [self dismissHint];
    }
}
//显示提示内容，调用此方法的前提是内容为空
- (void)showHint
{
    _placeholderTextView.text = Hint;
}
//关闭显示内容
- (void)dismissHint
{
    _placeholderTextView.text = @"";
}

#pragma mark - notification method
- (void) keyboardWasShown:(NSNotification *) notif
{
    NSDictionary *info = [notif userInfo];
    NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGSize keyboardSize = [value CGRectValue].size;
    UIInterfaceOrientation orientation =[UIApplication sharedApplication].statusBarOrientation;
    
    if(orientation == UIDeviceOrientationLandscapeLeft ||orientation == UIDeviceOrientationLandscapeRight)
    {
        if(IOS_8)
        {
            keyBoardHeight = keyboardSize.height;
        }else
        {
            keyBoardHeight = keyboardSize.width;
        }
        if(keyBoardHeight==352)
        {
            keyBoardHeight=416;
        }
    }else
    {
        keyBoardHeight = keyboardSize.height;
    }
    
    UIViewController *curController  = (UIViewController *)_model.CurrentPage.PageView;
    
    CGRect curRect1 = [self.superview convertRect:self.frame toView:curController.view];
    
    //    float keyBoardHeight = 260;
    
    //当一个页面同时存在textBox和textField时, 系统通知中心可能发送多个通知, 如果有bug, 可以考虑动态添加和移除键盘监听者 , 即在shouldBegin中添加, 在didEnd中移除
    //计算需要属性字符串
    NSAttributedString * attrStr = [[NSAttributedString alloc]initWithString:self.text];
    //属性影响的范围
    NSRange range = NSMakeRange(0, attrStr.length);
    //当前文本的字体
    UIFont * textFont = [attrStr attribute:NSFontAttributeName atIndex:0 effectiveRange:&range];
    //属性字符串的属性字典
    //CGSize size0 = [_textbox_control.text sizeWithAttributes:dic];
    //NSStringDrawingUsesLineFragmentOrigin 这样设置,  整个文本将以每行组成的矩形为单位计算整个文本的尺寸
    
    CGSize textSize = [attrStr boundingRectWithSize:curRect1.size options:NSStringDrawingUsesLineFragmentOrigin  context:nil].size;
    
    //这样就能计算出当前文本的CGSize了
    //如果控件的顶部加上当前已编辑文本的高度加上3个行高加上键盘高度小于等于当前视图控制器根视图的高度  的话  那么就不弹
    if(curRect1.origin.y + textSize.height + textFont.lineHeight * 3 + keyBoardHeight <= curController.view.frame.size.height){
        return;
    }
    
    if (curRect1.origin.y+curRect1.size.height+keyBoardHeight >curController.view.frame.size.height) {
        float moveHeight = (curRect1.origin.y+curRect1.size.height+keyBoardHeight - curController.view.frame.size.height);
        [UIView animateWithDuration:0.3 animations:^{
            curController.view.frame = CGRectMake(0, -moveHeight, curController.view.frame.size.width, curController.view.frame.size.height);
        }];
    }
}
- (void) keyboardWasHidden:(NSNotification *) notif
{
    UIViewController *curController  = (UIViewController *)_model.CurrentPage.PageView;
    
    [UIView animateWithDuration:0.3 animations:^{
        curController.view.frame = CGRectMake(0, 0, curController.view.frame.size.width, curController.view.frame.size.height);
    }];
}

- (void)textViewChanged:(id)sender
{
    doInvokeResult *_invokeResult = [[doInvokeResult alloc]init:_model.UniqueKey];
    [_model.EventCenter FireEvent:@"textChanged":_invokeResult];
    [self OnTextChanged:self];
    [_invokeResult SetResultText:self.text];
    [_model SetPropertyValue:@"text" :self.text];
}

#pragma mark - uitextViewDelegate
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        
        UIViewController *curController  = (UIViewController *)_model.CurrentPage.PageView;
        [UIView animateWithDuration:0.3 animations:^{
            curController.view.frame = CGRectMake(0, 0, curController.view.frame.size.width, curController.view.frame.size.height);
        }];
        return NO;
    }
    //source 原来的文本
    //newtxt 改变后的文本
    NSMutableString *newtxt = [NSMutableString stringWithString:textView.text];
    NSString *sourceText = textView.text;
    [newtxt replaceCharactersInRange:range withString:text];
    
    if (maxLength >=0) {//只有maxlength是正数，才需要限制输入
        if (maxLength < sourceText.length || maxLength < newtxt.length) {//如果原来的文本比maxlength更长，则只允许删除
            if (sourceText.length < newtxt.length) {
                return NO;
            }
        }
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    UIViewController *curController  = (UIViewController *)_model.CurrentPage.PageView;
    
    CGRect curRect1 = [self.superview convertRect:self.frame toView:curController.view];
    //216
    
    //当一个页面同时存在textBox和textField时, 系统通知中心可能发送多个通知, 如果有bug, 可以考虑动态添加和移除键盘监听者 , 即在shouldBegin中添加, 在didEnd中移除
    //计算需要属性字符串
    NSAttributedString * attrStr = [[NSAttributedString alloc]initWithString:self.text];
    //属性影响的范围
    NSRange range = NSMakeRange(0, attrStr.length);
    //当前文本的字体
    UIFont * textFont = [attrStr attribute:NSFontAttributeName atIndex:0 effectiveRange:&range];
    //属性字符串的属性字典
    
    //CGSize size0 = [_textbox_control.text sizeWithAttributes:dic];
    //NSStringDrawingUsesLineFragmentOrigin 这样设置,  整个文本将以每行组成的矩形为单位计算整个文本的尺寸
    
    CGSize textSize = [attrStr boundingRectWithSize:curRect1.size options:NSStringDrawingUsesLineFragmentOrigin  context:nil].size;
    
    //这样就能计算出当前文本的CGSize了
    //如果控件的顶部加上当前已编辑文本的高度加上3个行高加上键盘高度小于等于当前视图控制器根视图的高度  的话  那么就不弹
    if(curRect1.origin.y + textSize.height + textFont.lineHeight * 3 + keyBoardHeight <= curController.view.frame.size.height){
        return;
    }
    
    if (curRect1.origin.y+curRect1.size.height+keyBoardHeight >curController.view.frame.size.height) {
        float moveHeight = (curRect1.origin.y+curRect1.size.height+keyBoardHeight - curController.view.frame.size.height+20);
        [UIView animateWithDuration:0.3 animations:^{
            curController.view.frame = CGRectMake(0, -moveHeight, curController.view.frame.size.width, curController.view.frame.size.height);
        }];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (textView.text.length == 0)
    {
        [self showHint];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self registerForKeyboardNotifications];
    return YES;
}

#pragma mark - doIUIModuleView协议方法（必须）<大部分情况不需修改>
- (BOOL) OnPropertiesChanging: (NSMutableDictionary *) _changedValues
{
    //属性改变时,返回NO，将不会执行Changed方法
    return YES;
}
- (void) OnPropertiesChanged: (NSMutableDictionary*) _changedValues
{
    //_model的属性进行修改，同时调用self的对应的属性方法，修改视图
    [doUIModuleHelper HandleViewProperChanged: self :_model : _changedValues ];
}
- (BOOL) InvokeSyncMethod: (NSString *) _methodName : (NSDictionary *)_dicParas :(id<doIScriptEngine>)_scriptEngine : (doInvokeResult *) _invokeResult
{
    //同步消息
    return [doScriptEngineHelper InvokeSyncSelector:self : _methodName :_dicParas :_scriptEngine :_invokeResult];
}
- (BOOL) InvokeAsyncMethod: (NSString *) _methodName : (NSDictionary *) _dicParas :(id<doIScriptEngine>) _scriptEngine : (NSString *) _callbackFuncName
{
    //异步消息
    return [doScriptEngineHelper InvokeASyncSelector:self : _methodName :_dicParas :_scriptEngine: _callbackFuncName];
}
- (doUIModule *) GetModel
{
    //获取model对象
    return _model;
}
@end
