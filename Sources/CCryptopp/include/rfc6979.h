//
//  rfc6979.h
//  
//
//  Created by Bartosz Rybarski on 02/12/2022.
//

#ifndef rfc6979_h
#define rfc6979_h

#ifdef __cplusplus
extern "C" {
#endif

int generate_rfc6979_k(const unsigned char* privateKey, const unsigned char* subgroupGenerator, const unsigned char* hash, const int attempt, unsigned char* outBuffer);
    
#ifdef __cplusplus
}
#endif

#endif /* rfc6979_h */
