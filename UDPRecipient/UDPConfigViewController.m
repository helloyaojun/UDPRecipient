//
//  UDPConfigViewController.m
//  TouchspriteDemo
//
//  Created by 姚君 on 16/3/28.
//  Copyright © 2016年 certus. All rights reserved.
//

#import "UDPConfigViewController.h"
#import "AsyncUdpSocket.h"

@interface UDPConfigViewController () {

    AsyncUdpSocket *asyncUdpSocket;
}


@property (strong, nonatomic) IBOutlet UITextField *serverTextField;
@property (strong, nonatomic) IBOutlet UITextField *portTextField;

@end

#define SERVER_DEFAULT      @"192.168.2.10"
#define PORT_DEFAULT        @"14099"


#define SERVER_CONFIG @"serverConfig"
#define PORT_CONFIG @"portConfig"

@implementation UDPConfigViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *server = [[NSUserDefaults standardUserDefaults] objectForKey:SERVER_CONFIG]?:SERVER_DEFAULT;
    NSString *port = [[NSUserDefaults standardUserDefaults] objectForKey:PORT_CONFIG]?:PORT_DEFAULT;
    _serverTextField.text = server;
    _portTextField.text = port;
    
    NSError *error;
    if (!asyncUdpSocket) {
        asyncUdpSocket = [[AsyncUdpSocket alloc] initIPv4];
    }
    [asyncUdpSocket setDelegate:self];
    [asyncUdpSocket enableBroadcast:YES error:&error];
    if ([asyncUdpSocket bindToPort:14099 error:&error]) {
        [asyncUdpSocket joinMulticastGroup:@"255.255.255.255" error:&error];
    }
    [asyncUdpSocket receiveWithTimeout:-1 tag:2];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sureConfig:(id)sender {
    
    NSString *server = [_serverTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *port = [[_portTextField.text stringByReplacingOccurrencesOfString:@":" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    [[NSUserDefaults standardUserDefaults] setObject:server forKey:SERVER_CONFIG];
    [[NSUserDefaults standardUserDefaults] setObject:port forKey:PORT_CONFIG];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self sendUdp];
    
}

- (void)sendUdp {

    NSString *server = [[NSUserDefaults standardUserDefaults] objectForKey:SERVER_CONFIG]?:SERVER_DEFAULT;
    NSString *port = [[NSUserDefaults standardUserDefaults] objectForKey:PORT_CONFIG]?:PORT_DEFAULT;

    NSData *data = [NSJSONSerialization dataWithJSONObject:@{@"ip":server,@"port":port} options:NSJSONWritingPrettyPrinted error:nil];
    [asyncUdpSocket sendData:data toHost:@"255.255.255.255" port:14099 withTimeout:-1 tag:2];

 }

#pragma mark - AsyncUdpSocketDelegate

//已接收到消息
- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port{
    if(data){
        [asyncUdpSocket receiveWithTimeout:-1 tag:2];

        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dictionary.count > 2) {
            NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:jsonString delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    return YES;
}
//没有接受到消息
-(void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error{
}

//没有发送出消息
-(void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error{
}

//已发送出消息
-(void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
}
//断开连接
-(void)onUdpSocketDidClose:(AsyncUdpSocket *)sock{
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
