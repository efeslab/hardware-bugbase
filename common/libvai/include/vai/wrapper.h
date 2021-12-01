#ifndef __WRAPPER_H__
#define __WRAPPER_H__

#include <vai/fpga.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
    uint8_t major;
    uint8_t minor;
    uint16_t patch;
} fpga_version;

typedef enum {
	FPGA_DEVICE = 0,
	FPGA_ACCELERATOR
} fpga_objtype;

enum fpga_buffer_flags {
	FPGA_BUF_PREALLOCATED = (1u << 0),
	FPGA_BUF_QUIET = (1u << 1)
};

enum fpga_open_flags {
	FPGA_OPEN_SHARED = (1u << 0)
};


typedef uint64_t *fpga_token;
typedef uint64_t *fpga_properties;
typedef void *fpga_handle;
typedef uint8_t fpga_guid[16];
typedef int fpga_object;

/* enumerate */
fpga_result fpgaEnumerate(const fpga_properties *filters,
			  uint32_t num_filters, fpga_token *tokens,
			  uint32_t max_tokens, uint32_t *num_matches);
fpga_result fpgaDestroyToken(fpga_token *token);
static inline fpga_result fpgaGetProperties(fpga_token token, fpga_properties *prop) {
    UNUSED_PARAM(token);
    UNUSED_PARAM(prop);
    return FPGA_OK;
}
static inline fpga_result fpgaPropertiesSetGUID(const fpga_properties prop, fpga_guid guid) {
    UNUSED_PARAM(prop);
    UNUSED_PARAM(guid);
    return FPGA_OK;
}
static inline fpga_result fpgaPropertiesSetObjectType(const fpga_properties prop, fpga_object objtype) {
    UNUSED_PARAM(prop);
    UNUSED_PARAM(objtype);
    return FPGA_OK;
}
static inline fpga_result fpgaDestroyProperties(fpga_properties *prop) {
    *prop = 0;
    return FPGA_OK;
}

/* open */
fpga_result fpgaOpen(fpga_token token, fpga_handle *handle, int flags);
fpga_result fpgaClose(fpga_handle handle);
fpga_result fpgaReset(fpga_handle handle);

/* buffer */
fpga_result fpgaPrepareBuffer(fpga_handle handle,
			      uint64_t len,
			      void **buf_addr, uint64_t *wsid, int flags);
fpga_result fpgaReleaseBuffer(fpga_handle handle, uint64_t wsid);
fpga_result fpgaGetIOAddress(fpga_handle handle, uint64_t wsid,
			     uint64_t *ioaddr);

/* mmio */
fpga_result fpgaWriteMMIO64(fpga_handle handle,
            uint32_t mmio_num, uint64_t offset,
            uint64_t value);
fpga_result fpgaReadMMIO64(fpga_handle handle,
            uint32_t mmio_num, uint64_t offset,
            uint64_t *value);

#ifdef __cplusplus
}
#endif

#endif
