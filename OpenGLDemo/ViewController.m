//
//  ViewController.m
//  OpenCVExample
//
//  Created by wuliqun on 2020/1/7.
//  Copyright © 2020 wuliqun. All rights reserved.
//

#import "ViewController.h"
#import "GLTriangleViewController.h"
#import "GLUseShaderTriangleViewController.h"
#import "GLUseTextureViewController.h"

@interface ViewController () <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView * baseTableView;
@property (nonatomic, strong) NSArray * dataArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initData];
    
    [self initUI];
    
    [self layoutUI];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void) initData {
    self.dataArray = @[@"hello,world",@"use shader",@"use texture",@"",@""];
}

- (void) initUI {
    [self.view addSubview:self.baseTableView];
}

- (void) layoutUI {
    self.baseTableView.frame = self.view.bounds;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = [self.dataArray count];
    
    return numberOfRows;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier: NSStringFromClass([UITableViewCell class])];
    
    cell.textLabel.text = [self.dataArray objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case 0:
        {
            GLTriangleViewController * controller = [[GLTriangleViewController alloc]init];
            
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
        case 1:
        {
            GLUseShaderTriangleViewController * controller = [[GLUseShaderTriangleViewController alloc]init];
            
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
        case 2:
        {
            GLUseTextureViewController * controller = [[GLUseTextureViewController alloc]init];
            
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
        case 3:
        {
            //            MosaicViewController * controller = [[MosaicViewController alloc]init];
            //
            //            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
        default:
            break;
    }
}


#pragma mark - getters/setters

- (UITableView *) baseTableView {
    if(!_baseTableView){
        _baseTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _baseTableView.delegate = self;
        _baseTableView.dataSource = self;
    }
    
    return _baseTableView;
}

@end
