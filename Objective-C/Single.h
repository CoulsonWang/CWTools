
#define SingleH(ClassName) + (instancetype)shared##ClassName;


#define SingleM(ClassName) static id _instance;\
\
+ (instancetype)allocWithZone:(struct _NSZone *)zone {\
    static dispatch_once_t onceToken;\
    dispatch_once(&onceToken, ^{\
        _instance = [super allocWithZone:zone];\
    });\
    return _instance;\
}\
\
+ (instancetype)shared##ClassName {\
    return [[self alloc] init];\
}\
\
- (id)copyWithZone:(NSZone *)zone {\
    return _instance;\
}\
\
- (id)mutableCopyWithZone:(NSZone *)zone {\
    return _instance;\
}

