//
//  XGViewController.m
//  LuaStudy
//
//  Created by admin on 5/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "XGViewController.h"

#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"

#include <stdio.h>
#include <unistd.h>

@interface XGViewController ()

@end

@implementation XGViewController

- (void)TLog:(NSString*)str{
    if (str == nil) {
        outputTextView.text = nil;
    }else {
        outputTextView.text = [NSString stringWithFormat:@"%@%@", outputTextView.text, str];
    }
}

- (void)studyLua{
    const char *str = "io.write(\"write lua std to file...\");";
    int error;
    
    lua_State *L = luaL_newstate(); //创建lua虚拟机
    luaopen_base(L);                //打开lua标准库
    luaopen_io(L);
    luaopen_table(L);
    luaopen_string(L);
    luaopen_math(L);
    
    error = luaL_loadstring(L, str) || lua_pcall(L, 0, 0, 0);
    if (error) {
        NSLog(@"lua load error: %s", lua_tostring(L, -1));
        lua_pop(L, 1);
    }
    
    lua_close(L);
}

- (void)testPipe{
    NSPipe *pipe = [NSPipe pipe];
}

- (IBAction)didRunButtonPressed:(id)sender{
    [inputTextView resignFirstResponder];
    
    [self studyLua];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    outputTextView.text = nil;
    
//    [self redirectSTD:STDOUT_FILENO];
//    [self redirectSTD:STDERR_FILENO];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(printNotification:) name:kLuaPrintNotification object:nil];
}

- (void)printNotification:(NSNotification *)notification{
    NSDictionary *userDict = [notification userInfo];
    [self TLog:[userDict objectForKey:@"str"]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [inputTextView release];
    [outputTextView release];
    
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)redirectNotificationHandle:(NSNotification *)nf{
    NSData *data = [[nf userInfo] objectForKey:NSFileHandleNotificationDataItem];
    NSString *str = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    outputTextView.text = [NSString stringWithFormat:@"%@\n%@", outputTextView.text, str];
    NSRange range;
    range.location = [outputTextView.text length] - 1;
    range.length = 0;
    [outputTextView scrollRangeToVisible:range];
    
    [[nf object] readInBackgroundAndNotify];
}

- (void)redirectSTD:(int )fd{
    NSPipe * pipe = [NSPipe pipe] ;
    NSFileHandle *pipeReadHandle = [pipe fileHandleForReading] ;
    dup2([[pipe fileHandleForWriting] fileDescriptor], fd) ;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(redirectNotificationHandle:)
                                                 name:NSFileHandleReadCompletionNotification
                                               object:pipeReadHandle] ;
    [pipeReadHandle readInBackgroundAndNotify];
}

@end
