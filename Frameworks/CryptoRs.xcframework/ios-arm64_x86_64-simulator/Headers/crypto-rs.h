#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

int32_t generate_k(const uint8_t *p_message_hash,
                   const uint8_t *p_private_key,
                   const uint8_t *p_seed,
                   uint8_t *out_buffer);
