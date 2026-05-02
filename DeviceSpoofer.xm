#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <sys/sysctl.h>

%ctor {
    NSLog(@"[DeviceSpoofer] Loaded - iPhone X → iPhone 15 Pro Max");
}

// Хук UIDevice для подмены модели
%hook UIDevice

- (NSString *)model {
    return @"iPhone";
}

- (NSString *)localizedModel {
    return @"iPhone";
}

- (NSString *)name {
    return @"iPhone 15 Pro Max";
}

%end

// Хук sysctlbyname для подмены hw.machine и hw.model
%hookf(int, sysctlbyname, const char *name, void *oldp, size_t *oldlenp, void *newp, size_t newlen) {
    if (name) {
        // Подмена hw.machine (основной идентификатор)
        if (strcmp(name, "hw.machine") == 0) {
            if (oldp && oldlenp && *oldlenp > 0) {
                const char *spoofed = "iPhone16,2"; // iPhone 15 Pro Max
                size_t len = strlen(spoofed) + 1;
                if (*oldlenp >= len) {
                    strcpy((char *)oldp, spoofed);
                    *oldlenp = len;
                    return 0;
                }
            }
        }
        // Подмена hw.model
        else if (strcmp(name, "hw.model") == 0) {
            if (oldp && oldlenp && *oldlenp > 0) {
                const char *spoofed = "D84AP"; // iPhone 15 Pro Max internal model
                size_t len = strlen(spoofed) + 1;
                if (*oldlenp >= len) {
                    strcpy((char *)oldp, spoofed);
                    *oldlenp = len;
                    return 0;
                }
            }
        }
    }
    
    return %orig;
}

// Хук uname для подмены machine
%hookf(int, uname, struct utsname *buf) {
    int result = %orig;
    
    if (result == 0 && buf) {
        strcpy(buf->machine, "iPhone16,2");
    }
    
    return result;
}
