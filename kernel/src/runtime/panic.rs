use core::panic::PanicInfo;
use crate::arch::x86_64::serial;

#[panic_handler]
fn panic(info: &PanicInfo) -> ! {
    serial::println!("[KERNEL PANIC] {}", info);
    loop {
        unsafe { core::arch::asm!("hlt") };
    }
}