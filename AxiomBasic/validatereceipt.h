//
//  validatereceipt.h
//


#import <Foundation/Foundation.h>


extern NSString *kReceiptBundleIdentifer;
extern NSString *kReceiptBundleIdentiferData;
extern NSString *kReceiptVersion;
extern NSString *kReceiptOpaqueValue;
extern NSString *kReceiptHash;


CFDataRef copy_mac_address(void);

NSDictionary * dictionaryWithAppStoreReceipt(NSString * path);
BOOL validateReceiptAtPath(NSString * path);
NSData * appleRootCert(void);
