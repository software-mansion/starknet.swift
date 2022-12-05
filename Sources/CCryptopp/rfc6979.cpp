//
//  rfc6979.cpp
//  
//
//  Created by Bartosz Rybarski on 02/12/2022.
//

#include "rfc6979.h"

#include "eccrypto.h"
#include "gfpcrypt.h"

int generate_rfc6979_k(const unsigned char* privateKey, const unsigned char* subgroupGenerator, const unsigned char* hash, const int attempt, unsigned char* outBuffer) {
    using namespace CryptoPP;
    
    auto dsaKCalculator = DL_Algorithm_DSA_RFC6979<ECP, SHA256>();
    
    auto privateKeyInt = Integer(privateKey, 32);
    auto subgroupGeneratorInt = Integer(subgroupGenerator, 32);
    auto hashInt = Integer(hash, 32);
    
    Integer k;
    
    for (int i = 0; i <= attempt; i++) {
        k = dsaKCalculator.GenerateRandom(privateKeyInt, subgroupGeneratorInt, hashInt);
    }
    
    k.Encode(outBuffer, 32);
    
    return 0;
}
