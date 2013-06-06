//
//  ContactsMan.h
//  
//
//  Created by yjh4866 on 12-11-5.
//
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>


@protocol ContactsManDelegate;

@interface ContactsMan : NSObject

@property (nonatomic, assign) id <ContactsManDelegate> delegate;

// 扫描通讯录
// 异步扫描，扫描完成会触发通知LocalContactsScanFinish
- (void)scanContacts;

// 加载所有联系人
// NSDictionary:ABRecordID,name,phones
- (void)loadAllContacts:(NSMutableArray *)marrayPerson;

// 获取联系人数量
- (NSUInteger)countOfContacts;

// 获取指定序号的联系人的电话号码数量
- (NSUInteger)phoneCountWithIndex:(NSUInteger)index;

// 加载指定序号的联系人信息
- (void)loadContactInfo:(NSMutableDictionary *)mdicContactInfo withIndex:(NSUInteger)index;

// 获取指定分组的联系人数量
- (NSUInteger)countOfContactsGroup:(NSUInteger)group;

// 获取指定分组指定序号的联系人的电话号码数量
- (NSUInteger)phoneCountWithGroup:(NSUInteger)group andIndex:(NSUInteger)index;

// 加载指定分组指定序号的联系人数量
- (void)loadContactInfo:(NSMutableDictionary *)mdicContactInfo
              withGroup:(NSUInteger)group andIndex:(NSUInteger)index;

// 根据手机号查询联系人姓名
- (NSString *)queryNameWithPhone:(NSString *)phone;

// 根据ABRecordRef获取联系人姓名
- (NSString *)personName:(ABRecordRef)person;

// 根据部分手机号加载联系人
// NSDictionary:name,phone
- (void)loadContacts:(NSMutableArray *)marrayContact withPartPhone:(NSString *)partPhone;

// 根据ABRecordRef获取电话列表
// NSString
- (void)loadPhones:(NSMutableArray *)marrayPhone from:(ABRecordRef)person;

@end


@protocol ContactsManDelegate <NSObject>

@optional

// 通讯录扫描完成
- (void)contactsManScanContactsFinished:(ContactsMan *)contactsMan;

@end


#ifdef DEBUG

#define ContactsManLOG(fmt,...)     NSLog((@"ContactsMan->%s(%d):"fmt),__PRETTY_FUNCTION__,__LINE__,##__VA_ARGS__)

#else

#define ContactsManLOG(fmt,...)     NSLog(fmt,##__VA_ARGS__)

#endif
