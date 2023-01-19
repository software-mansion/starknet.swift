#ifndef bridge_h
#define bridge_h

//#ifdef __OBJC__

#import "ecdsa.h"
#import "pedersen_hash.h"

#import "crypto-rs.h"

//#endif

//#include <stdio.h>

int verifyWrapped(const char* publicKey, const char* hash, const char* r, const char* s);

#endif /* bridge_h */
