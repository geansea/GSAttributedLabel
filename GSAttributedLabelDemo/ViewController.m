//
//  ViewController.m
//  GSAttributedLabelDemo
//
//  Created by geansea on 2017/8/18.
//
//

#import "ViewController.h"
#import "GSAttributedLabel.h"

#define GSALTag 1024
#define ROW_HEIGHT 60

@interface ViewController () <GSAttributedLabelDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setTextForLabel:(GSAttributedLabel *)label atRow:(NSInteger)row {
    [label setText:@""];
    label.numberOfLines = 0;
    switch (row) {
        case 0:
            [label appendText:@"Use like UILabel, and support "];
            [label appendText:@"attributed " attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:20], NSForegroundColorAttributeName: [UIColor redColor]}];
            [label appendText:@"text." attributes:@{NSFontAttributeName: [UIFont italicSystemFontOfSize:20]}];
            break;
        case 1:
            label.shadowColor = [UIColor lightGrayColor];
            label.shadowOffset = CGSizeMake(1, 1);
            [label appendText:@"Set shadow properties like UILable."];
            break;
        case 2:
            label.lineSpacing = 8;
            label.textAlignment = NSTextAlignmentCenter;
            [label appendText:@"Easy to set line spacing as property, which is set to 8 now."];
            break;
        case 3:
            label.paragraphSpacing = 12;
            label.textAlignment = NSTextAlignmentRight;
            [label appendText:@"Also for the paragraph spacing, \nwhich is set to 12 now."];
            break;
        case 4:
            label.edgeInsets = UIEdgeInsetsMake(0, 24, 0, 64);
            [label appendText:@"Directly set edge insets, left = 24, right = 48."];
            break;
        case 5:
            [label appendText:@"Support "];
            [label appendText:@"link" attributes:@{NSLinkAttributeName: @"https://bing.com"}];
            [label appendText:@" tap, and handle it in delegate."];
            break;
        case 6:
            label.linkTextAttributes = @{NSForegroundColorAttributeName: [UIColor greenColor], NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
            [label appendText:@"And can use custom "];
            [label appendText:@"link" attributes:@{NSLinkAttributeName: @"https://bing.com"}];
            [label appendText:@" style like UITextView."];
            break;
        case 7:
            [label appendText:@"You can easily add image "];
            [label appendImage:[UIImage imageNamed:@"TestImage"] bounds:CGRectMake(0, -4, 16, 16)];
            [label appendText:@" with append method."];
            break;
        case 8: {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.backgroundColor = [UIColor blueColor];
            button.layer.cornerRadius = 4;
            [button setTitle:@"button" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor orangeColor] forState:UIControlStateHighlighted];
            [label appendText:@"So does the custom view "];
            [label appendView:button bounds:CGRectMake(0, -4, 64, 24)];
            break;
        }
        default:
            break;
    }
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ROW_HEIGHT;
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GSMarkupCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GSMarkupCell"];
    } else {
        UIView *oldLabel = [cell.contentView viewWithTag:GSALTag];
        [oldLabel removeFromSuperview];
    }
    GSAttributedLabel *label = [[GSAttributedLabel alloc] initWithFrame:cell.contentView.bounds];
    label.tag = GSALTag;
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    label.delegate = self;
    [self setTextForLabel:label atRow:indexPath.row];
    if (0 == indexPath.row % 2) {
        label.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3];
    } else {
        label.backgroundColor = [UIColor whiteColor];
    }
    [cell.contentView addSubview:label];
    return cell;
}

#pragma mark GSAttributedLabelDelegate

- (void)attributedLabel:(GSAttributedLabel *)label interactWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    [[UIApplication sharedApplication] openURL:URL options:@{} completionHandler:nil];
}

@end
