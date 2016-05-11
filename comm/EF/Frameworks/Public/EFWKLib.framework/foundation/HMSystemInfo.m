//
//  HMSystemInfo.m
//  CarAssistant
//
//  Created by Eric on 14-3-2.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMSystemInfo.h"
#import "OpenUDID.h"

#include <sys/socket.h>
#include <sys/sysctl.h>


// cpu & memory
#import <sys/stat.h>
#import <mach/mach.h>

// network
#include <arpa/inet.h>
#include <net/if.h>
#include <ifaddrs.h>
#include <net/if_dl.h>

@implementation HMMemoryInfo

@end


@implementation HMNetworkInfo

- (void)reset {
    self.wifiSent = 0;
    self.wiFiReceived = 0;
    self.wwanSent = 0;
    self.wwanReceived = 0;
}

- (void)updateWithNetworkInfo:(HMNetworkInfo *)netInfo {
    self.wifiSent = netInfo.wifiSent;
    self.wiFiReceived = netInfo.wiFiReceived;
    self.wwanSent = netInfo.wwanSent;
    self.wwanReceived = netInfo.wwanReceived;
}

@end

@implementation HMSystemInfo

+ (NSString *)OSVersion
{
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
	return [NSString stringWithFormat:@"%@ %@", [UIDevice currentDevice].systemName, [UIDevice currentDevice].systemVersion];
#else	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
	return nil;
#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
}

+ (NSString *)appVersion
{
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR || TARGET_OS_MAC)
	NSString * value = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	if ( nil == value || 0 == value.length )
	{
		value = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersion"];
	}
	return value;
#else	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
	return nil;
#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
}

+ (NSString *)appIdentifier
{
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
	static NSString * __identifier = nil;
	if ( nil == __identifier )
	{
#if  __has_feature(objc_arc)
        __identifier = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
#else
		__identifier = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"] retain];
#endif
	}
	return __identifier;
#else	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
	return @"";
#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
}

+ (NSString *)deviceModel
{
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
	return [UIDevice currentDevice].model;
#else	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
	return nil;
#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
}

+ (NSString *)deviceUUID
{
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR || TARGET_OS_MAC)
	Class openUDID = NSClassFromString( @"OpenUDID" );
	if ( openUDID )
	{
        NSString *udid = [self keychainRead:@"openUDID_openUDID"];
        if (udid==nil) {
            udid = [openUDID value];
            [self keychainWrite:udid forKey:@"openUDID_openUDID"];
        }
		return udid;
	}
	else
	{
		return nil; // [UIDevice currentDevice].uniqueIdentifier;
	}
#else	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
	return @"SIMULATERUUID";
#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
}

+(NSString *) macaddress
{
    int                    mib[6];
    size_t                len;
    char                *buf;
    unsigned char        *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl    *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error/n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1/n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!/n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        free(buf);
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    // NSString *outstring = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    NSString *outstring = [NSString stringWithFormat:@"000%02x%02x%02x%02x%02x%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    return [outstring uppercaseString];
}

+ (NSString *)appShortVersion NS_AVAILABLE_IOS(4_0)
{
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
#else	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
	return @"";
#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
}

+(NSString *)appName{
    NSString *name = NSLocalizedStringFromTable(@"CFBundleDisplayName", @"InfoPlist", nil);
    if (name.length&&![name isEqualToString:@"CFBundleDisplayName"]) {
        return name;
    }
    NSDictionary *dic =[[NSBundle mainBundle] infoDictionary];
    NSString *ret = [dic valueForKey:@"CFBundleDisplayName"];
    if (ret.length==0){
        ret = [dic valueForKey:@"CFBundleName"];
    }
    return ret;
}

+ (NSString *)anyScheme{
    NSDictionary *dic =[[NSBundle mainBundle] infoDictionary];
    NSArray *CFBundleURLTypes = [dic objectForKey:@"CFBundleURLTypes"];
    NSArray *backScheme = [[CFBundleURLTypes lastObject] objectForKey:@"CFBundleURLSchemes"];
    return [backScheme firstObject];
}

+ (NSString *)anySchemeForIdentifier:(NSString*)identifier{
    
    NSDictionary *dic =[[NSBundle mainBundle] infoDictionary];
    NSArray *CFBundleURLTypes = [dic objectForKey:@"CFBundleURLTypes"];
    for (NSDictionary *scheme in CFBundleURLTypes) {
        if ([[scheme valueForKey:@"CFBundleURLName"] isEqualToString:identifier]) {
            return [[scheme objectForKey:@"CFBundleURLSchemes"] firstObject];
        }
    }
    INFO(@"your identifier for scheme is nil. anyScheme insteaded");
    return [self anyScheme];
}

+ (NSArray *)anySchemesForIdentifier:(NSString*)identifier{
    
    NSDictionary *dic =[[NSBundle mainBundle] infoDictionary];
    NSArray *CFBundleURLTypes = [dic objectForKey:@"CFBundleURLTypes"];
    for (NSDictionary *scheme in CFBundleURLTypes) {
        if ([[scheme valueForKey:@"CFBundleURLName"] isEqualToString:identifier]) {
            return [scheme objectForKey:@"CFBundleURLSchemes"];
        }
    }
    INFO(@"your identifier for scheme is nil.");
    return nil;
}

// 获取当前设备可用内存(单位：B）
- (int64_t)availableMemory
{
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(),
                                               HOST_VM_INFO,
                                               (host_info_t)&vmStats,
                                               &infoCount);
    
    if (kernReturn != KERN_SUCCESS) {
        return NSNotFound;
    }
    
    return (vm_page_size *vmStats.free_count);
}
// 获取当前任务所占用的内存（单位：B）
- (int64_t)usedMemory
{
    task_basic_info_data_t taskInfo;
    mach_msg_type_number_t infoCount = TASK_BASIC_INFO_COUNT;
    kern_return_t kernReturn = task_info(mach_task_self(),
                                         TASK_BASIC_INFO,
                                         (task_info_t)&taskInfo,
                                         &infoCount);
    
    if (kernReturn != KERN_SUCCESS
        ) {
        return NSNotFound;
    }
    
    return taskInfo.resident_size;
}

#pragma mark - CPU 使用率

// http://stackoverflow.com/questions/8223348/ios-get-cpu-usage-from-application?rq=1
+ (double)cpuUsage {
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    
    thread_basic_info_t basic_info_th;
    uint32_t stat_thread = 0; // Mach threads
    
    // get threads in the task
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    if (thread_count > 0) {
        stat_thread += thread_count;
    }
    double totalCpu = 0;
    
    for (int i = 0; i < thread_count; ++ i) {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[i], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            totalCpu += basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
        
    } // for each thread
    
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    
    return totalCpu;
}

#pragma mark - Memory
// https://github.com/Shmoopi/iOS-System-Services/blob/master/System%20Services/Utilities/SSMemoryInfo.m

+ (HMMemoryInfo *)memoryInfo {
    static HMMemoryInfo *info = nil;
    if (!info) {
        info = [HMMemoryInfo new];
        info.total = [[NSProcessInfo processInfo] physicalMemory];
    }
    
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t pagesize;
    host_page_size(host_port, &pagesize);
    
    vm_statistics_data_t vm_stat;
    
    // Check for any system errors
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) == KERN_SUCCESS) {
        // Memory statistics in B
        info.free = (vm_page_size * vm_stat.free_count);
        info.used = [self usedMemory];
        info.active = (vm_stat.active_count * pagesize);
        info.inactive = (vm_stat.inactive_count * pagesize);
        info.wired = (vm_stat.wire_count * pagesize);
        info.purgable = (vm_stat.purgeable_count * pagesize);
    }
    
    return info;
}

// http://stackoverflow.com/questions/7989864/watching-memory-usage-in-ios
+ (vm_size_t)usedMemory {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
    return (kerr == KERN_SUCCESS) ? info.resident_size : 0; // size in bytes
}

#pragma mark - Network

// http://stackoverflow.com/questions/7946699/iphone-data-usage-tracking-monitoring
+ (HMNetworkInfo *)networkInfo {
    static HMNetworkInfo *lastNetInfo = nil;
    static HMNetworkInfo *curentNetInfo = nil;
    static HMNetworkInfo *diffNetInfo = nil;
    if (!curentNetInfo) {
        curentNetInfo = [HMNetworkInfo new];
    } else {
        [curentNetInfo reset];
    }
    
    struct ifaddrs *addrs;
    const struct ifaddrs *cursor;
    
    if (getifaddrs(&addrs) == 0) {
        cursor = addrs;
        while (cursor != NULL) {
            if (cursor->ifa_addr->sa_family == AF_LINK) {
                // name of interfaces:
                // en0 is WiFi
                // pdp_ip0 is WWAN
                // lo0 is total
                NSString *name = [NSString stringWithFormat:@"%s", cursor->ifa_name];
                if ([name hasPrefix:@"en"]) {
                    const struct if_data *ifa_data = (struct if_data *)cursor->ifa_data;
                    if(ifa_data != NULL) {
                        curentNetInfo.wifiSent += ifa_data->ifi_obytes;
                        curentNetInfo.wiFiReceived += ifa_data->ifi_ibytes;
                    }
                }
                
                if ([name hasPrefix:@"pdp_ip"]) {
                    const struct if_data *ifa_data = (struct if_data *)cursor->ifa_data;
                    if(ifa_data != NULL) {
                        curentNetInfo.wwanSent += ifa_data->ifi_obytes;
                        curentNetInfo.wwanReceived += ifa_data->ifi_ibytes;
                    }
                }
            }
            
            cursor = cursor->ifa_next;
        }
        
        freeifaddrs(addrs);
    }
    
    if (!lastNetInfo) {
        lastNetInfo = [HMNetworkInfo new];
        [lastNetInfo updateWithNetworkInfo:curentNetInfo];
        diffNetInfo = [HMNetworkInfo new];
    } else {
        diffNetInfo.wifiSent = curentNetInfo.wifiSent - lastNetInfo.wifiSent;
        diffNetInfo.wiFiReceived = curentNetInfo.wiFiReceived - lastNetInfo.wiFiReceived;
        diffNetInfo.wwanSent = curentNetInfo.wwanSent - lastNetInfo.wwanSent;
        diffNetInfo.wwanReceived = curentNetInfo.wwanReceived - lastNetInfo.wwanReceived;
        
        [lastNetInfo updateWithNetworkInfo:curentNetInfo];
    }
    
    return diffNetInfo;
}

#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
static const char * __jb_app = NULL;
#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

+ (BOOL)isJailBroken NS_AVAILABLE_IOS(4_0)
{
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
	static const char * __jb_apps[] =
	{
		"/Application/Cydia.app",
		"/Application/limera1n.app",
		"/Application/greenpois0n.app",
		"/Application/blackra1n.app",
		"/Application/blacksn0w.app",
		"/Application/redsn0w.app",
		NULL
	};
    
	__jb_app = NULL;
    
	// method 1
    for ( int i = 0; __jb_apps[i]; ++i )
    {
        if ( [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithUTF8String:__jb_apps[i]]] )
        {
			__jb_app = __jb_apps[i];
			return YES;
        }
    }
	
    // method 2
	if ( [[NSFileManager defaultManager] fileExistsAtPath:@"/private/var/lib/apt/"] )
	{
		return YES;
	}
	
	// method 3
	if ( 0 == system("ls") )
	{
		return YES;
	}
#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
	
    return NO;
}

+ (NSString *)jailBreaker NS_AVAILABLE_IOS(4_0)
{
#if (TARGET_OS_IPHONE)
	if ( __jb_app )
	{
		return [NSString stringWithUTF8String:__jb_app];
	}
#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
    
	return @"";
}

+ (BOOL)isDevicePhone
{
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
	NSString * deviceType = [UIDevice currentDevice].model;
	
	if ( [deviceType rangeOfString:@"iPhone" options:NSCaseInsensitiveSearch].length > 0 ||
		[deviceType rangeOfString:@"iPod" options:NSCaseInsensitiveSearch].length > 0 ||
		[deviceType rangeOfString:@"iTouch" options:NSCaseInsensitiveSearch].length > 0 )
	{
		return YES;
	}
#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
	
	return NO;
}

+ (BOOL)isDevicePad
{
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
	NSString * deviceType = [UIDevice currentDevice].model;
	
	if ( [deviceType rangeOfString:@"iPad" options:NSCaseInsensitiveSearch].length > 0 )
	{
		return YES;
	}
#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
	
	return NO;
}

+ (BOOL)isPhone35
{
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
	return [HMSystemInfo isScreenSize:CGSizeMake(320, 480)];
#else	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
	return NO;
#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
}

+ (BOOL)isPhoneRetina35
{
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
	return [HMSystemInfo isScreenSize:CGSizeMake(640, 960)];
#else	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
	return NO;
#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
}

+ (BOOL)isPhoneRetina4
{
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
	return [HMSystemInfo isScreenSize:CGSizeMake(640, 1136)];
#else	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
	return NO;
#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
}

+ (BOOL)isPhoneRetina47
{
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
    return [HMSystemInfo isScreenSize:CGSizeMake(750, 1334)];
#else	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
    return NO;
#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
}

+ (BOOL)isPhoneRetina55
{
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
    return [HMSystemInfo isScreenSize:CGSizeMake(1242, 2208)];
#else	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
    return NO;
#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
}

+ (BOOL)isPad
{
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
	return [HMSystemInfo isScreenSize:CGSizeMake(768, 1024)];
#else	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
	return NO;
#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
}

+ (BOOL)isPadRetina
{
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
	return [HMSystemInfo isScreenSize:CGSizeMake(1536, 2048)];
#else	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
	return NO;
#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
}

+ (BOOL)isScreenSize:(CGSize)size
{
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
	if ( [UIScreen instancesRespondToSelector:@selector(currentMode)] )
	{
		CGSize screenSize = [UIScreen mainScreen].currentMode.size;
		CGSize size2 = CGSizeMake( size.height, size.width );
        
		if ( CGSizeEqualToSize(size, screenSize) || CGSizeEqualToSize(size2, screenSize) )
		{
			return YES;
		}
	}
	
	return NO;
#else	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
	return NO;
#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
}

+ (NSString*)currentLanguage
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    NSString *currentLang = [languages firstObject];
    return currentLang;
}

@end
