

#ifndef _TPG_CONFIG_H_
#define _TPG_CONFIG_H_

#define SAMPLES_PER_CLOCK       1		// 1, 2, 4
#define NR_COMPONENTS			3   	// 3 can handle RGB, YUV 444, 422, 420, 2 can handle 422 and 420 only
#define BITS_PER_COMPONENT		8   	// 8, 10, 12, 16
#define BITS_PER_SAMPLE         (NR_COMPONENTS*BITS_PER_COMPONENT)

#define BITS_PER_CLOCK			(BITS_PER_SAMPLE*SAMPLES_PER_CLOCK)

#define MAX_WIDTH			1280	
#define MAX_HEIGHT			720

#define ENABLE_AXI4S_SLAVE		0
#define REDUCE_RESOURCES		0

#endif
