#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

int32_t generate_k(const uint8_t *p_message_hash,
                   const uint8_t *p_private_key,
                   const uint8_t *p_seed,
                   uint8_t *out_buffer);

int32_t starknet_keccak(const uint8_t *p_data, uint32_t p_data_size, uint8_t *out_buffer);
