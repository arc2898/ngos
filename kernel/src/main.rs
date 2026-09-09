#![no_std]
#![no_main]
#![feature(naked_functions)]
#![feature(asm_experimental_arch)]
#![feature(allocator_api)]
#![feature(ptr_metadata)]

extern crate alloc;

use core::arch::asm;
use core::panic::PanicInfo;
use core::ptr::NonNull;

mod runtime;
mod arch;

use arch::x86_64::{serial, framebuffer};
use runtime::alloc::init_heap;

#[no_mangle]
pub extern "C" fn _start() -> ! {
    // Initialize serial early for debugging
    serial::init();
    serial::println!("[NGOS] Root task starting...");

    // Initialize framebuffer from limine bootloader
    let fb_info = framebuffer::init_from_limine();
    serial::println!("[NGOS] Framebuffer: {}x{} @ {}bpp, pitch: {}",
        fb_info.width, fb_info.height, fb_info.bpp, fb_info.pitch);

    // Draw test pattern
    framebuffer::draw_test_pattern(&fb_info);

    // Initialize heap allocator
    init_heap();
    serial::println!("[NGOS] Heap initialized");

    // TODO: Parse limine modules (root task, drivers)
    // TODO: Spawn driver processes
    // TODO: Mount root filesystem
    // TODO: Spawn init process

    serial::println!("[NGOS] Root task initialization complete");
    serial::println!("[NGOS] Entering idle loop...");

    // Idle loop - monitor children, handle crashes
    loop {
        unsafe { asm!("hlt") };
    }
}

#[panic_handler]
fn panic(info: &PanicInfo) -> ! {
    serial::println!("[NGOS] PANIC: {}", info);
    loop {
        unsafe { asm!("hlt") };
    }
}