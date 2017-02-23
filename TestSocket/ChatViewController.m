//
//  ChatViewController.m
//  TestSocket
//
//  Created by jasuho on 23/02/2017.
//  Copyright © 2017 jiaxuhui. All rights reserved.
//

#import "ChatViewController.h"
#import "TextField.h"

@interface ChatViewController ()<NSNetServiceDelegate,NSStreamDelegate>

@property(nonatomic,strong)NSInputStream *inputStream;
@property(nonatomic,strong)NSOutputStream *outputStream;

@property(nonatomic,strong)UITextView* textView;


@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self connect];
    
    TextField *textField=[[TextField alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, 90)];
    textField.textColor=[UIColor whiteColor];
    
    textField.sendBlock=^(NSString *content){
        NSDictionary* packet = [NSDictionary dictionaryWithObjectsAndKeys:content, @"message", @"iphone", @"from", nil];
        [self sendBuffer:packet];
    };
    
    [textField setBackgroundColor:[UIColor redColor]];
    
    [self.view addSubview:textField];
    [self.view addSubview:self.textView];
    
}


-(UITextView*)textView{
    if(_textView==nil){
        _textView=[[UITextView alloc] initWithFrame:CGRectMake(0, 156, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-156)];
    }
    return _textView;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)connect{
    if (self.service.hostName != nil ) {
        CFReadStreamRef readStream;
        CFWriteStreamRef writeStream;
        
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                           (__bridge CFStringRef)self.service.hostName, (UInt32)self.service.port, &readStream, &writeStream);
        //        return [self setupSocketStreams];
        self.inputStream = (__bridge NSInputStream *)(readStream);
        self.outputStream = (__bridge NSOutputStream *)(writeStream);
        
        self.inputStream.delegate=self;
        self.outputStream.delegate=self;
        
        [self.inputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        
        [self.outputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        
        [self.inputStream open];
        [self.outputStream open];
    }
    else{
        // Start resolving
        self.service.delegate = self;
        [self.service resolveWithTimeout:5.0];
    }
    
}



-(void)sendBuffer:(NSDictionary*)packet{
    // Encode packet
    NSData * rawPacket = [NSKeyedArchiver archivedDataWithRootObject:packet];
    
    NSMutableData *data=[NSMutableData new];
    
    // Write header: lengh of raw packet
    NSInteger packetLength = [rawPacket length];
    [data appendBytes:&packetLength length:sizeof(int)];
    
    // Write body: encoded NSDictionary
    [data appendData:rawPacket];
    
    
    if(!self.outputStream.hasSpaceAvailable)
        return;
    [self.outputStream write:[data bytes] maxLength:data.length];
    
}

-(void)readBuffer{
    UInt8 buf[1024];
    
    
    NSMutableData *inputBuffer=[NSMutableData new];
    
    // Try reading while there is data
    while(self.inputStream.hasBytesAvailable) {
        CFIndex len = [self.inputStream read:buf maxLength:sizeof(buf)];
        if ( len <= 0 ) {
            // Either stream was closed or error occurred. Close everything up and treat this as "connection terminated"
//            [self close];
//            [delegate connectionTerminated:self];
            return;
        }
        
        [inputBuffer appendBytes:buf length:len];
    }
    
    int packetBodySize = -1;
    
    // Try to extract packets from the buffer.
    //
    // Protocol: header + body
    //  header: an integer that indicates length of the body
    //  body: bytes that represent encoded NSDictionary
    
    // We might have more than one message in the buffer - that's why we'll be reading it inside the while loop
    while( YES ) {
        // Did we read the header yet?
        if ( packetBodySize == -1 ) {
            // Do we have enough bytes in the buffer to read the header?
            if ( [inputBuffer length] >= sizeof(int) ) {
                // extract length
                memcpy(&packetBodySize, [inputBuffer bytes], sizeof(int));
                
                // remove that chunk from buffer
                NSRange rangeToDelete = {0, sizeof(int)};
                [inputBuffer replaceBytesInRange:rangeToDelete withBytes:NULL length:0];
            }
            else {
                // We don't have enough yet. Will wait for more data.
                break;
            }
        }
        
        // We should now have the header. Time to extract the body.
        if ( [inputBuffer length] >= packetBodySize ) {
            // We now have enough data to extract a meaningful packet.
            NSData* raw = [NSData dataWithBytes:[inputBuffer bytes] length:packetBodySize];
            NSDictionary* packet = [NSKeyedUnarchiver unarchiveObjectWithData:raw];
            
            NSLog(@"packet=======%@",packet);
            
            self.textView.text=[self.textView.text stringByAppendingString:[NSString stringWithFormat:@"%@:%@\n",packet[@"from"],packet[@"message"]]];
            // Tell our delegate about it
//            [delegate receivedNetworkPacket:packet viaConnection:self];
            
            // Remove that chunk from buffer
            NSRange rangeToDelete = {0, packetBodySize};
            [inputBuffer replaceBytesInRange:rangeToDelete withBytes:NULL length:0];
            
            // We have processed the packet. Resetting the state.
            packetBodySize = -1;
        }
        else {
            // Not enough data yet. Will wait.
            break;
        }
    }
}



#pragma -mark StreamDelegate

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode{
    if ( eventCode == NSStreamEventHasBytesAvailable ) {
        // Read as many bytes from the stream as possible and try to extract meaningful packets
        [self readBuffer];
    }
}


#pragma -mark ServiceDelegate

- (void)netServiceDidResolveAddress:(NSNetService *)sender{
    if(self.service!=sender)
        return;
    [self connect];
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
