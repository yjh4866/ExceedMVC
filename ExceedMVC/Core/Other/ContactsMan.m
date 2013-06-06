//
//  ContactsMan.m
//  Sprite
//
//  Created by yjh4866 on 12-11-5.
//
//

#import "ContactsMan.h"
#import "UIDevice+Custom.h"
#import "NSString+Tool.h"
#import "PinyinQuery.h"

@interface ContactsMan () {
    
    NSThread *_threadForScan;
    
    NSMutableArray *_marrayPerson;
    NSMutableArray *_marrayGroupPerson;
    NSMutableDictionary *_mdicPhoneName;
    NSMutableArray *_marrayPersonForThread;
    NSMutableArray *_marrayGroupPersonForThread;
    NSMutableDictionary *_mdicPhoneNameForThread;
}

@end

@implementation ContactsMan

- (id)init
{
    self = [super init];
    if (self) {
        //
        _marrayPerson = [[NSMutableArray alloc] init];
        _marrayGroupPerson = [[NSMutableArray alloc] init];
        _mdicPhoneName = [[NSMutableDictionary alloc] init];
        _marrayPersonForThread = [[NSMutableArray alloc] init];
        _marrayGroupPersonForThread = [[NSMutableArray alloc] init];
        _mdicPhoneNameForThread = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_threadForScan cancel];
    [_threadForScan release];
    //
    [_marrayPerson release];
    [_marrayGroupPerson release];
    [_mdicPhoneName release];
    [_marrayPersonForThread release];
    [_marrayGroupPersonForThread release];
    [_mdicPhoneNameForThread release];
    
    [super dealloc];
}


#pragma mark - Public

// 扫描通讯录
// 异步扫描，扫描完成会触发通知LocalContactsScanFinish
- (void)scanContacts
{
    //起线程扫描通讯录
    if (_threadForScan) {
        [_threadForScan cancel];
        [_threadForScan release];
    }
    _threadForScan = [[NSThread alloc] initWithTarget:self selector:@selector(threadForScanContacts) object:nil];
    [_threadForScan start];
}

// 加载所有联系人
// NSDictionary:ABRecordID,name,phones
- (void)loadAllContacts:(NSMutableArray *)marrayPerson
{
    [marrayPerson addObjectsFromArray:_marrayPerson];
}

// 获取联系人数量
- (NSUInteger)countOfContacts
{
    return _marrayPerson.count;
}

// 获取指定序号的联系人的电话号码数量
- (NSUInteger)phoneCountWithIndex:(NSUInteger)index
{
    if (index >= _marrayPerson.count) {
        return 0;
    }
    //
    NSDictionary *dicContactInfo = [_marrayPerson objectAtIndex:index];
    NSArray *arrayPhone = [dicContactInfo objectForKey:@"phones"];
    return arrayPhone.count;
}

// 加载指定序号的联系人信息
- (void)loadContactInfo:(NSMutableDictionary *)mdicContactInfo withIndex:(NSUInteger)index
{
    if (index >= _marrayPerson.count) {
        return;
    }
    //
    NSDictionary *dicContactInfo = [_marrayPerson objectAtIndex:index];
    [mdicContactInfo setDictionary:dicContactInfo];
}

// 获取指定分组的联系人数量
- (NSUInteger)countOfContactsGroup:(NSUInteger)group
{
    if (group >= _marrayGroupPerson.count) {
        return 0;
    }
    NSArray *arrayPerson = [_marrayGroupPerson objectAtIndex:group];
    return arrayPerson.count;
}

// 获取指定分组指定序号的联系人的电话号码数量
- (NSUInteger)phoneCountWithGroup:(NSUInteger)group andIndex:(NSUInteger)index
{
    if (group >= _marrayGroupPerson.count) {
        return 0;
    }
    NSArray *arrayPerson = [_marrayGroupPerson objectAtIndex:group];
    if (index >= arrayPerson.count) {
        return 0;
    }
    //
    NSDictionary *dicContactInfo = [arrayPerson objectAtIndex:index];
    NSArray *arrayPhone = [dicContactInfo objectForKey:@"phones"];
    return arrayPhone.count;
}

// 加载指定分组指定序号的联系人数量
- (void)loadContactInfo:(NSMutableDictionary *)mdicContactInfo
              withGroup:(NSUInteger)group andIndex:(NSUInteger)index
{
    if (group >= _marrayGroupPerson.count) {
        return;
    }
    NSArray *arrayPerson = [_marrayGroupPerson objectAtIndex:group];
    if (index >= arrayPerson.count) {
        return;
    }
    //
    NSDictionary *dicContactInfo = [arrayPerson objectAtIndex:index];
    [mdicContactInfo setDictionary:dicContactInfo];
}

// 根据手机号查询联系人姓名
- (NSString *)queryNameWithPhone:(NSString *)phone
{
    if (phone.length == 0) {
        return @"";
    }
    return [_mdicPhoneName objectForKey:phone];
}

// 根据ABRecordRef获取联系人姓名
- (NSString *)personName:(ABRecordRef)person
{
    //读取姓名
    NSString *personName = @"";
    NSString *firstName = (NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString *lastName = (NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
    if (lastName && firstName) {
        personName = [NSString stringWithFormat:@"%@ %@", lastName, firstName];
    }
    else if(lastName && !firstName){
        personName = lastName;
    }
    else if(!lastName && firstName){
        personName = firstName;
    }
    [firstName release];
    [lastName release];
    
    return personName;
}

// 根据部分手机号加载联系人
// NSDictionary:name,phone
- (void)loadContacts:(NSMutableArray *)marrayContact withPartPhone:(NSString *)partPhone
{
    if (partPhone.length == 0) {
        return;
    }
    //遍历查询
    for (NSString *phone in _mdicPhoneName.allKeys) {
        if ([phone rangeOfString:partPhone].location != NSNotFound) {
            NSString *personName = [_mdicPhoneName objectForKey:phone];
            NSDictionary *dicContact = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        personName, @"name", phone, @"phone", nil];
            [marrayContact addObject:dicContact];
            [dicContact release];
            //最多10个
            if (marrayContact.count >= 10) {
                break;
            }
        }
    }
}

// 根据ABRecordRef获取电话列表
// NSString
- (void)loadPhones:(NSMutableArray *)marrayPhone from:(ABRecordRef)person
{
    //读取电话多值
    ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
    for (int k = 0; k<ABMultiValueGetCount(phones); k++)
    {
        //获取該Label下的电话值
        NSString *phone = (NSString*)ABMultiValueCopyValueAtIndex(phones, k);
        NSMutableString *mstrPhone = [[NSMutableString alloc] init];
        for (int i = 0; i < phone.length; i++) {
            char ch = [phone characterAtIndex:i];
            if (ch >= '0' && ch <= '9') {
                [mstrPhone appendFormat:@"%c", ch];
            }
        }
        //必须是有效的手机号码或固定号码
        if (mstrPhone.length > 0 && [mstrPhone validateMobilePhone] &&
            [mstrPhone validateTelePhone]) {
            [marrayPhone addObject:mstrPhone];
        }
        [mstrPhone release];
        [phone release];
    }
    CFRelease(phones);
}


#pragma mark - Private

//起线程扫描通讯录
- (void)threadForScanContacts
{
    [_marrayGroupPersonForThread removeAllObjects];
    [_marrayPersonForThread removeAllObjects];
    [_mdicPhoneNameForThread removeAllObjects];
    ContactsManLOG(@"起线程扫描通讯录");
    //获取ABAddressBookRef，IOS6与旧版本获取方式不同
    ABAddressBookRef addressBook = NULL;
    if ([UIDevice systemVersionID] >= __IPHONE_6_0) {
        addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        //等待同意后向下执行
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error){dispatch_semaphore_signal(sema);});
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        dispatch_release(sema);
    }
    else {
        addressBook = ABAddressBookCreate();
    }
    //27个分组
    for (int i = 0; i < ALPHA.length; i++) {
        NSMutableArray *marray = [[NSMutableArray alloc] init];
        [_marrayGroupPersonForThread addObject:marray];
        [marray release];
    }
    //遍历通讯录
    CFArrayRef results = ABAddressBookCopyArrayOfAllPeople(addressBook);
    for(int i = 0; i < CFArrayGetCount(results); i++)
    {
        ABRecordRef person = CFArrayGetValueAtIndex(results, i);
        ABRecordID recordID = ABRecordGetRecordID(person);
        //读取姓名
        NSString *personName = [self personName:person];
        //读取电话号码列表
        NSMutableArray *marrayPhone = [[NSMutableArray alloc] init];
        [self loadPhones:marrayPhone from:person];
        //遍历电话号码
        for (NSString *phone in marrayPhone) {
            [_mdicPhoneNameForThread setObject:personName forKey:phone];
        }
        
        //没有手机号的不作处理
        if (marrayPhone.count > 0) {
            //保存到数组
            NSDictionary *dicPerson = [[NSDictionary alloc] initWithObjectsAndKeys:
                                       [NSNumber numberWithInt:recordID], @"ABRecordID",
                                       personName, @"name", marrayPhone, @"phones", nil];
            [_marrayPersonForThread addObject:dicPerson];
            //首字母
            char firstLetter = [PinyinQuery firstLetterOfName:personName];
            NSMutableArray *marray = [_marrayGroupPersonForThread lastObject];
            if ('#' != firstLetter) {
                marray = [_marrayGroupPersonForThread objectAtIndex:firstLetter-'a'];
            }
            [marray addObject:dicPerson];
            [dicPerson release];
        }
        [marrayPhone release];
    }
    CFRelease(results);
    CFRelease(addressBook);
    ContactsManLOG(@"通讯录扫描完成");
    
    //回到主线程，通知主线程任务完成
    [self performSelectorOnMainThread:@selector(mainThreadForScanFinished) withObject:nil waitUntilDone:NO];
}

//扫描完成后回到线程
- (void)mainThreadForScanFinished
{
    [_marrayPerson setArray:_marrayPersonForThread];
    [_marrayPersonForThread removeAllObjects];
    [_marrayGroupPerson setArray:_marrayGroupPersonForThread];
    [_marrayGroupPersonForThread removeAllObjects];
    [_mdicPhoneName setDictionary:_mdicPhoneNameForThread];
    [_mdicPhoneNameForThread removeAllObjects];
    //排序
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *arraySort = [NSArray arrayWithObject:sort];
    [sort release];
    [_marrayPerson sortUsingDescriptors:arraySort];
    for (NSMutableArray *marray in _marrayGroupPerson) {
        [marray sortUsingDescriptors:arraySort];
    }
    
    //扫描完毕
    if ([self.delegate respondsToSelector:@selector(contactsManScanContactsFinished:)]) {
        [self.delegate contactsManScanContactsFinished:self];
    }
}

@end
