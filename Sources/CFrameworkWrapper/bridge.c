#include "bridge.h"

#import "ecdsa.h"
#import "pedersen_hash.h"

int verifyWrapped(const char* publicKey, const char* hash, const char* r, const char* s) {
    return Verify(publicKey, hash, r, s);
}
