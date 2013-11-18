//
//  TRISpeechScreen.m
//  Presentation
//
//  Created by Adrian on 13/11/13.
//  Copyright (c) 2013 Trifork GmbH. All rights reserved.
//

@import AVFoundation;

#import "TRISpeechScreen.h"

static NSString *CELL_REUSE_IDENTIFIER = @"CELL_REUSE_IDENTIFIER";

@interface TRISpeechScreen () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITextView *inputText;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *speechVoices;
@property (nonatomic) float speechRate;
@property (nonatomic, copy) NSString *speechLanguage;

@end

@implementation TRISpeechScreen



#pragma mark - Speech methods


- (void)say:(NSString *)text withVoice:(AVSpeechSynthesisVoice *)voice
{
    AVSpeechUtterance *utterance = nil;
    utterance = [[AVSpeechUtterance alloc] initWithString:text];
    utterance.voice = voice;
    utterance.preUtteranceDelay = 0.3;
    utterance.rate = self.speechRate;
    
    AVSpeechSynthesizer *synth = [[AVSpeechSynthesizer alloc] init];
    [synth speakUtterance:utterance];
}





- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Get a sorted list of voices
    NSArray *voices = [AVSpeechSynthesisVoice speechVoices];
    NSComparisonResult (^cmp) (id, id) = ^NSComparisonResult (id obj1, id obj2) {
        return ([[obj1 language] compare:[obj2 language]]);
    };
    self.speechVoices = [voices sortedArrayUsingComparator:cmp];

    // Register a table view cell
    [self.tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:CELL_REUSE_IDENTIFIER];
    
    self.speechRate = AVSpeechUtteranceDefaultSpeechRate;
    self.speechLanguage = @"en-EN";
}

- (void)performMainScreenAction
{
    [self speak:nil];
}

#pragma mark - IBActions

- (IBAction)speak:(id)sender
{
    NSString *text = self.inputText.text;
    AVSpeechSynthesisVoice *voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-EN"];
    [self say:text withVoice:voice];
}

- (IBAction)speakAtMinimumRate:(id)sender
{
    self.speechRate = AVSpeechUtteranceMinimumSpeechRate;
    AVSpeechSynthesisVoice *voice = nil;
    voice = [AVSpeechSynthesisVoice voiceWithLanguage:self.speechLanguage];
    NSString *text = self.inputText.text;
    [self say:text withVoice:voice];
}

- (IBAction)speakAtDefaultRate:(id)sender
{
    self.speechRate = AVSpeechUtteranceDefaultSpeechRate;
    AVSpeechSynthesisVoice *voice = nil;
    voice = [AVSpeechSynthesisVoice voiceWithLanguage:self.speechLanguage];
    NSString *text = self.inputText.text;
    [self say:text withVoice:voice];
}

- (IBAction)speakAtMaximumRate:(id)sender
{
    self.speechRate = AVSpeechUtteranceMaximumSpeechRate;
    AVSpeechSynthesisVoice *voice = nil;
    voice = [AVSpeechSynthesisVoice voiceWithLanguage:self.speechLanguage];
    NSString *text = self.inputText.text;
    [self say:text withVoice:voice];
}

#pragma mark - Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [self.speechVoices count];
}

-    (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    return @"Available voices:";
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:CELL_REUSE_IDENTIFIER
                                           forIndexPath:indexPath];
    cell.textLabel.font = [UIFont systemFontOfSize:26.0];
    AVSpeechSynthesisVoice *voice = self.speechVoices[indexPath.row];
    cell.textLabel.text = voice.language;
    return cell;
}

-       (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *text = self.inputText.text;
    AVSpeechSynthesisVoice *voice = self.speechVoices[indexPath.row];
    self.speechLanguage = voice.language;
    [self say:text withVoice:voice];
}

@end
