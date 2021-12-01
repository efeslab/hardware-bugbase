#ifndef _LIBVAI_H_
#define _LIBVAI_H_

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#define CL_SIZE 64
#define CL(x) CL_SIZE*(x)

#define VAI_PAGE_SIZE 4096
#define VAI_PAGE_SHIFT 12
#define VAI_IS_PAGE_ALIGNED(x) (!((x)&((1<<VAI_PAGE_SHIFT)-1)))

#define VAI_MAGIC 0xBB
#define VAI_BASE 0x0
#define UNUSED_PARAM(x) ((void)x)
typedef struct {
    uint8_t data[16];
} afu_id_t;

typedef enum {
    VAI_AFU_HW,
    VAI_AFU_SIM
} afu_type_t;

struct vai_afu_conn {
    afu_type_t type;
    afu_id_t afu_id;

    union {
        struct {
            int fd;
            char *desc;
            void *mp;
            volatile uint64_t *bar;
        } hw;
        struct {
            int payload;
        } sim;
    };
};

typedef enum {
	FPGA_OK = 0,         /**< Operation completed successfully */
	FPGA_INVALID_PARAM,  /**< Invalid parameter supplied */
	FPGA_BUSY,           /**< Resource is busy */
	FPGA_EXCEPTION,      /**< An exception occurred */
	FPGA_NOT_FOUND,      /**< A required resource was not found */
	FPGA_NO_MEMORY,      /**< Not enough memory to complete operation */
	FPGA_NOT_SUPPORTED,  /**< Requested operation is not supported */
	FPGA_NO_DRIVER,      /**< Driver is not loaded */
	FPGA_NO_DAEMON,      /**< FPGA Daemon (fpgad) is not running */
	FPGA_NO_ACCESS,      /**< Insufficient privileges or permissions */
	FPGA_RECONF_ERROR    /**< Error while reconfiguring FPGA */
} fpga_result;

struct vai_afu_conn *vai_afu_connect(void);
fpga_result vai_afu_disconnect(struct vai_afu_conn *conn);
fpga_result vai_afu_alloc_region(struct vai_afu_conn *conn, void **buf_addr,
            uint64_t prefered_addr, uint64_t length);
fpga_result vai_afu_free_region(struct vai_afu_conn *conn, void *buf_addr);

volatile void *vai_afu_malloc(struct vai_afu_conn *conn, uint64_t size);
fpga_result vai_afu_free(struct vai_afu_conn *conn, volatile void *p);

fpga_result vai_afu_mmio_read(struct vai_afu_conn *conn, uint64_t offset, uint64_t *value);
fpga_result vai_afu_mmio_write(struct vai_afu_conn *conn, uint64_t offset, uint64_t value);

fpga_result vai_afu_reset(struct vai_afu_conn *conn);

#ifdef __cplusplus
}
#endif

#endif
