#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#include "NSUserDefaults+appDefaults.h"
#include "common.h"

int main(int argc, char * argv[]) {

    if(argc >= 2)
    {
        @try {
            SYSLOG("Bootstrap cmd %s", argv[1]);
            ASSERT(getuid() == 0);
            
            if(strcmp(argv[1], "bootstrap")==0) {
                int bootstrap();
                exit(bootstrap());
            } else if(strcmp(argv[1], "unbootstrap")==0) {
                int unbootstrap();
                exit(unbootstrap());
            } else if(strcmp(argv[1], "enableapp")==0) {
                int enableForApp(NSString* bundlePath);
                exit(enableForApp(@(argv[2])));
            } else if(strcmp(argv[1], "disableapp")==0) {
                int disableForApp(NSString* bundlePath);
                exit(disableForApp(@(argv[2])));
            } else if(strcmp(argv[1], "rebuildiconcache")==0) {
                int rebuildIconCache();
                exit(rebuildIconCache());
            } else if(strcmp(argv[1], "reboot")==0) {
                sync();
                sleep(1);
                reboot(0);
                sleep(5);
                exit(-1);
            } else if(strcmp(argv[1], "testprefs")==0) {
                SYSLOG("locale=%@", [NSUserDefaults.appDefaults valueForKey:@"locale"]);
                [NSUserDefaults.appDefaults setValue:@"CA" forKey:@"locale"];
                [NSUserDefaults.appDefaults synchronize];
                SYSLOG("locale=%@", [NSUserDefaults.appDefaults valueForKey:@"locale"]);
                exit(0);
            } else if (strcmp(argv[1], "roothide") == 0) {
                if (argc >= 3) {
                    // If no operation runs we return an error; it's probably because of an invalid argument
                    BOOL status = false;
                    NSError *error;

                    if (strcmp(argv[2], "start") == 0) {
                        status = [NSFileManager.defaultManager removeItemAtPath:@"/var/jb" error:&error];
                    } else if (strcmp(argv[2], "stop") == 0) {
                        status = [NSFileManager.defaultManager createSymbolicLinkAtPath:@"/var/jb" withDestinationPath:find_jbroot() error:&error];
                    } else {
                        STRAPLOG("Invalid argument to subcommand roothide: '%@'.", argv[2]);
                    }

                    if (!status) {
                        STRAPLOG("Error: %@", error.localizedDescription);
                    } else {
                        exit(0);
                    }
                } else {
                    STRAPLOG("Incorrect number of arguments for subcommand roothide.");
                }
            }
            
            SYSLOG("unknown cmd: %s", argv[1]);
            ABORT();
        }
        @catch (NSException *exception)
        {
            STRAPLOG("***exception: %@", exception);
            exit(-1);
        }
    }

    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
