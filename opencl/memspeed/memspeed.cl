// Read/write test - Make sure host and kernels can access global memory
// $Header: $
#define V 16
#define REQD_WG_SIZE (1024 * 1024 * 32)

// Pass arguments arg=1 and arg2=0 to get the intended lsu with ideal access
// pattern

__kernel void 
__attribute((reqd_work_group_size(REQD_WG_SIZE,1,1)))
__attribute((num_simd_work_items(V)))
mem_stream (__global uint * restrict src, __global uint * restrict dst, uint arg, uint arg2)
{
  int gid = get_global_id(0);
  dst[gid]=src[gid];
}

__kernel void 
__attribute((reqd_work_group_size(REQD_WG_SIZE,1,1)))
__attribute((num_simd_work_items(V)))
mem_writestream (__global uint * restrict src, __global uint * restrict dst, uint arg, uint arg2)
{
  int gid = get_global_id(0);
  dst[gid]=gid;
  src[gid]=gid;
}

__kernel void 
__attribute((reqd_work_group_size(8,1,1)))
mem_readstream_v16 (__global uint16 *restrict src1, __global uint16 *restrict src2, __global uint16 *restrict dst)
{
  int gid = get_global_id(0);
  uint16 sum = src1[gid] + src2[gid];
  barrier(CLK_LOCAL_MEM_FENCE);
  if (gid == 212000000) dst[gid] = sum;
}

__kernel void 
__attribute((reqd_work_group_size(REQD_WG_SIZE,1,1)))
__attribute((num_simd_work_items(V)))
mem_burstcoalesced (__global uint *src, __global uint *dst, uint arg, uint arg2)
{
  int gid = get_global_id(0);
  dst[gid+arg2*arg]=src[gid+arg2*arg];
}

__kernel void 
__attribute((reqd_work_group_size(REQD_WG_SIZE,1,1)))
__attribute((num_simd_work_items(V)))
mem_nonaligned_burstcoalesced (__global uint *src, __global uint *dst, uint arg, uint arg2)
{
  int gid = get_global_id(0);
  dst[gid+arg2]=src[gid + arg2];
}

__kernel void 
__attribute((reqd_work_group_size(8,1,1)))
mem_writeack_burstcoalesced (__global uint16 *restrict src1, __global uint16 *restrict src2, __global uint16 *restrict dst)
{
  int gid = get_global_id(0);
  src1[gid]=gid;
  src2[gid]=gid;
  if (gid == 212000000) 
  {
    barrier(CLK_LOCAL_MEM_FENCE);
    dst[0]=src1[5] + src2[7];
  }
}

__kernel void 
mem_random (__global uint16 * restrict src, __global uint16 * restrict dst, __global uint16 *restrict dst2)
{
  int gid = get_global_id(0);
  int offset = 0;
  if ( gid & 1  ) offset += 17389;
  if ( gid & 2  ) offset += 791;
  if ( gid & 4  ) offset += 7777;
  if ( gid & 8  ) offset += 35;
  if ( gid & 16 ) offset += 411;
  if ( gid & 32 ) offset += 5971;

  int addr;
  if ( gid < REQD_WG_SIZE/2 )
    addr = gid + offset;
  else
    addr = gid - offset;
  dst[addr]=src[addr];
}

__kernel void 
__attribute((reqd_work_group_size(8,1,1)))
mem_random_read (__global uint16 * restrict src1, __global uint16 * restrict src2, __global uint16 *restrict dst)
{
  int gid = get_global_id(0);
  int offset = 0;
  if ( gid & 1  ) offset += 17389;
  if ( gid & 2  ) offset += 791;
  if ( gid & 4  ) offset += 7777;
  if ( gid & 8  ) offset += 35;
  if ( gid & 16 ) offset += 411;
  if ( gid & 32 ) offset += 5971;

  int addr;
  if ( gid < REQD_WG_SIZE/2 )
    addr = gid + offset;
  else
    addr = gid - offset;
  uint16 val=src1[addr];
  uint16 val2=src2[addr];
  barrier(CLK_LOCAL_MEM_FENCE);
  if (gid == 212000000) dst[gid] = val+val2;
}

__kernel void 
__attribute((reqd_work_group_size(REQD_WG_SIZE,1,1)))
__attribute((num_simd_work_items(V)))
kclk (__global uint *src, __global uint *dst, uint arg, uint arg2)
{
}

