//
//  ViewController.m
//  TestSocket
//
//  Created by jasuho on 23/02/2017.
//  Copyright © 2017 jiaxuhui. All rights reserved.
//

#import "ViewController.h"
#import "ChatViewController.h"

@interface ViewController ()<NSNetServiceBrowserDelegate,UITableViewDelegate,UITableViewDataSource>


@property(nonatomic,strong)NSMutableArray<NSNetService*> *services;
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSNetServiceBrowser *serviceBrowser;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.serviceBrowser=[[NSNetServiceBrowser alloc] init];
    self.serviceBrowser.delegate = self;
    [self.serviceBrowser searchForServicesOfType:@"_chatty._tcp." inDomain:@""];
    
    self.tableView=[[UITableView alloc] initWithFrame:self.view.frame];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [self.view addSubview:self.tableView];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.services.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"xxxxxxxxxxx"];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"xxxxxxxxxxx"];
    }
    
    cell.textLabel.text=self.services[indexPath.row].name;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ChatViewController *chatController=[ChatViewController new];
    chatController.service=self.services[indexPath.row];
    [self.navigationController pushViewController:chatController animated:YES];
}



#pragma -mark getter

-(NSMutableArray *)services{
    if(_services==nil){
        _services=[NSMutableArray new];
    }
    return _services;
}


#pragma -mark NSNetServiceBrowser
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing{
    [self.services addObject:service];
    if(moreComing)
        return;
    [self.tableView reloadData];
}

-(void)netServiceBrowser:(NSNetServiceBrowser *)browser didRemoveService:(NSNetService *)service moreComing:(BOOL)moreComing{
    [self.services removeObject:service];
    if(moreComing)
        return;
    [self.tableView reloadData];
}


@end
