

#import "HMMacros.h"
#import "HMCacheProtocol.h"

#pragma mark -

/**
 *  获取文件的MD5值
 *
 *   path 文件的完整路径
 *
 *   return
 */
HM_EXTERN NSString* getFileMD5WithPath(NSString* path);

/**
 *  验证文件的MD5值是否正确
 *
 *   path     文件的完整路径
 *   md5      md5 description
 *   ^Checked 移步回调
 */
HM_EXTERN void checkFileMD5With(NSString* path,NSString *md5,void(^Checked)(BOOL ok,NSString *fileMd5));

@interface NSData(MD5Extension)

@property (nonatomic, readonly) NSData *	MD5;
@property (nonatomic, readonly) NSString *	MD5String;

@end

@interface NSString(MD5Extension)

@property (nonatomic, readonly) NSData *	MD5;
@property (nonatomic, readonly) NSString *	MD5String;

@end

/**
 *  文件存储主要目录
 */
@interface HMFileCache : NSObject<HMCacheProtocol>

@property (nonatomic, copy) NSString *	cachePath;///[HMSandbox libCachePath]/Cache/
@property (nonatomic, copy) NSString *  userDir;//在cachePath下用户自定义的文件夹
@property (nonatomic, copy) NSString *  webApiCachePath;//webApi缓存路径
@property (nonatomic, copy) NSString *  imagesCachePath;//图片缓存路径

AS_SINGLETON( HMFileCache );

/**
 *  获取文件或文件夹的大小
 *
 *   path 绝对路径
 *
 *   return
 */
- (unsigned long long)fileSizeForPath:(NSString *)path;
- (unsigned long long)fileSizeForDirectory:(NSString *)dic;
/**
 *  获取在cache+branch目录下某个文件的大小
 *
 *   key  文件名
 *   branch 文件夹名
 *
 *   return 
 */
- (unsigned long long)fileSizeForKey:(NSString *)key branch:(NSString *)branch;

- (NSString *)fileNameForKey:(NSString *)key;
- (NSString *)fileNameForKey:(NSString *)key branch:(NSString *)branch;

/**
 *  文件转移
 *
 *   key 文件名
 *   at  被转移的文件夹名
 *   to  需转移的文件夹名
 *
 *   return 是否成功
 */
- (BOOL)moveItemForKey:(NSString *)key atBranch:(NSString *)at toBranch:(NSString *)to;

- (BOOL)hasObjectForKey:(id)key branch:(NSString *)branch;

- (id)objectForKey:(id)key branch:(NSString *)branch;
- (void)setObject:(id)object forKey:(id)key branch:(NSString *)branch;

- (void)removeObjectForKey:(id)key branch:(NSString *)branch;
- (void)removeAllObjectsForBranch:(NSString *)branch;

/**
 *  移除所有存储在images文件夹中的文件，文件夹用于image图片数据的存储
 */
+ (void)removeAllImageCaches;
/**
 *  移除所有存储在HMWebAPI文件夹中的文件，文件夹用于HMWebAPI网络数据的存储
 */
+ (void)removeAllWebApiCaches;

/**
 *  移除所有存储在fsCachedData文件夹中的文件，文件夹用于UIWebView网络数据的存储
 */
+ (void)removeAllWebViewCaches;

/**
 *  数据序列化成Data
 *
 *   obj
 *
 *   return 
 */
- (NSData *)serialize:(id)obj;

/**
 *  数据反序列化成json对象
 *
 *   data
 *
 *   return
 */
- (id)unserialize:(id)data;

@end
