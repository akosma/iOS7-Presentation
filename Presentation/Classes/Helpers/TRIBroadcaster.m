//
//  TRIBroadcaster.m
//  Presentation
//
//  Created by Adrian on 7/5/13.
//  Copyright (c) 2013 Trifork GmbH. All rights reserved.
//

#import "TRIBroadcaster.h"
#import "TRIProtocol.h"

static const NSInteger NOTIFY_MTU = 20;


@interface TRIBroadcaster () <CBPeripheralManagerDelegate>

@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) CBMutableCharacteristic *transferCharacteristic;
@property (nonatomic, strong) NSData *dataToSend;
@property (nonatomic, readwrite) NSInteger sendDataIndex;
@property (nonatomic, getter = isReady) BOOL ready;

@end


@implementation TRIBroadcaster

+ (TRIBroadcaster *)broadcaster
{
    static dispatch_once_t pred = 0;
    __strong static id singleton = nil;
    dispatch_once(&pred, ^{
        singleton = [[self alloc] init];
    });
    return singleton;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self
                                                                     queue:nil];
        _ready = NO;
    }
    return self;
}

- (void)dealloc
{
    [self.peripheralManager stopAdvertising];
}

#pragma mark - CBPeripheralManagerDelegate Methods

/** Required protocol method.  A full app should take care of all the possible states,
 *  but we're just waiting for  to know when the CBPeripheralManager is ready
 */
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    // Opt out from any other state
    if (peripheral.state != CBPeripheralManagerStatePoweredOn)
    {
        return;
    }
    
    // We're in CBPeripheralManagerStatePoweredOn state...
    NSLog(@"self.peripheralManager powered on.");
    
    // ... so build our service.
    
    // Start with the CBMutableCharacteristic
    self.transferCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]
                                                                     properties:CBCharacteristicPropertyNotify
                                                                          value:nil
                                                                    permissions:CBAttributePermissionsReadable];
    
    // Then the service
    CBMutableService *transferService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]
                                                                       primary:YES];
    
    // Add the characteristic to the service
    transferService.characteristics = @[self.transferCharacteristic];
    
    // And add it to the peripheral manager
    [self.peripheralManager addService:transferService];
}


/** Catch when someone subscribes to our characteristic, then start sending them data
 */
-    (void)peripheralManager:(CBPeripheralManager *)peripheral
                     central:(CBCentral *)central
didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"Central subscribed to characteristic");
    
    self.ready = YES;
    
    // Reset the index
    self.sendDataIndex = 0;
    
    // Start sending
    [self sendData];
}


/** Recognise when the central unsubscribes
 */
-        (void)peripheralManager:(CBPeripheralManager *)peripheral
                         central:(CBCentral *)central
didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"Central unsubscribed from characteristic");
    self.ready = NO;
}

/** This callback comes in when the PeripheralManager is ready to send the next chunk of data.
 *  This is to ensure that packets will arrive in the order they are sent
 */
- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    // Start sending again
    [self sendData];
}

#pragma mark - Public methods

- (void)startAdvertising
{
    [self.peripheralManager startAdvertising:@{
         CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]
     }];
}

- (void)stopAdvertising
{
    [self.peripheralManager stopAdvertising];
}

- (void)send:(NSString *)string
{
    if (self.isReady)
    {
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        self.dataToSend = data;
        self.sendDataIndex = 0;
        [self sendData];
    }
}

- (void)sendReset
{
    [self send:MESSAGE_RESET];
}

- (void)sendNext
{
    [self send:MESSAGE_NEXT];
}

- (void)sendPrevious
{
    [self send:MESSAGE_PREVIOUS];
}

- (void)sendShowSource
{
    [self send:MESSAGE_SHOW_SOURCE];
}

- (void)sendHideSource
{
    [self send:MESSAGE_HIDE_SOURCE];
}

- (void)sendToggleMenu
{
    [self send:MESSAGE_TOGGLE_MENU];
}

#pragma mark - Private methods


/** Sends the next amount of data to the connected central
 */
- (void)sendData
{
    // First up, check if we're meant to be sending an EOM
    static BOOL sendingEOM = NO;
    
    if (sendingEOM)
    {
        // send it
        BOOL didSend = [self.peripheralManager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding]
                                         forCharacteristic:self.transferCharacteristic
                                      onSubscribedCentrals:nil];
        
        // Did it send?
        if (didSend)
        {
            // It did, so mark it as sent
            sendingEOM = NO;
            
            NSLog(@"Sent: EOM");
        }
        
        // It didn't send, so we'll exit and wait for peripheralManagerIsReadyToUpdateSubscribers
        // to call sendData again
        return;
    }
    
    // We're not sending an EOM, so we're sending data
    
    // Is there any left to send?
    
    if (self.sendDataIndex >= self.dataToSend.length)
    {
        // No data left.  Do nothing
        return;
    }
    
    // There's data left, so send until the callback fails, or we're done.
    
    BOOL didSend = YES;
    
    while (didSend)
    {
        // Make the next chunk
        
        // Work out how big it should be
        NSInteger amountToSend = self.dataToSend.length - self.sendDataIndex;
        
        // Can't be longer than 20 bytes
        if (amountToSend > NOTIFY_MTU)
        {
            amountToSend = NOTIFY_MTU;
        }
        
        // Copy out the data we want
        NSData *chunk = [NSData dataWithBytes:self.dataToSend.bytes + self.sendDataIndex
                                       length:amountToSend];
        
        // Send it
        didSend = [self.peripheralManager updateValue:chunk
                                    forCharacteristic:self.transferCharacteristic
                                 onSubscribedCentrals:nil];
        
        // If it didn't work, drop out and wait for the callback
        if (!didSend)
        {
            return;
        }
        
        NSString *stringFromData = [[NSString alloc] initWithData:chunk encoding:NSUTF8StringEncoding];
        NSLog(@"Sent: %@", stringFromData);
        
        // It did send, so update our index
        self.sendDataIndex += amountToSend;
        
        // Was it the last one?
        if (self.sendDataIndex >= self.dataToSend.length)
        {
            // It was - send an EOM
            
            // Set this so if the send fails, we'll send it next time
            sendingEOM = YES;
            
            // Send it
            BOOL eomSent = [self.peripheralManager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding]
                                             forCharacteristic:self.transferCharacteristic
                                          onSubscribedCentrals:nil];
            
            if (eomSent)
            {
                // It sent, we're all done
                sendingEOM = NO;
                
                NSLog(@"Sent: EOM");
            }
            
            return;
        }
    }
}

@end
