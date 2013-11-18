//
//  TRIProtocol.h
//  Presentation
//
//  Created by Adrian on 7/9/13.
//  Copyright (c) 2013 Trifork GmbH. All rights reserved.
//

// Used by the remote control (iPhone app) to talk to the presenter (iPad app)
extern NSString *const REMOTE_CONTROL_SERVICE_UUID;
extern NSString *const REMOTE_CONTROL_CHARACTERISTIC_UUID;
extern NSString *const MESSAGE_RESET;
extern NSString *const MESSAGE_NEXT;
extern NSString *const MESSAGE_PREVIOUS;
extern NSString *const MESSAGE_SHOW_SOURCE;
extern NSString *const MESSAGE_HIDE_SOURCE;
extern NSString *const MESSAGE_TOGGLE_MENU;
extern NSString *const MESSAGE_EXECUTE;

// Used by the presenter (iPad app) to talk to the remote control (iPhone app)
extern NSString *const PRESENTER_SERVICE_UUID;
extern NSString *const PRESENTER_CHARACTERISTIC_UUID;
