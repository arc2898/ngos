use alloc::alloc::{GlobalAlloc, Layout};
use buddy_system_allocator::LockedHeap;
use core::ptr::NonNull;

#[global_allocator]
static HEAP: LockedHeap<32> = LockedHeap::empty();

pub fn init_heap() {
    const HEAP_SIZE: usize = 1024 * 1024; // 1 MiB
    static mut HEAP_MEM: [u8; HEAP_SIZE] = [0; HEAP_SIZE];
    unsafe {
        HEAP.lock().init(HEAP_MEM.as_mut_ptr() as usize, HEAP_SIZE);
    }
}