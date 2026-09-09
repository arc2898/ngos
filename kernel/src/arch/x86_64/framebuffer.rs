use core::ptr::NonNull;

#[repr(C)]
#[derive(Debug, Clone, Copy)]
pub struct FramebufferInfo {
    pub addr: *mut u8,
    pub width: u64,
    pub height: u64,
    pub pitch: u64,
    pub bpp: u16,
    pub memory_model: u8,
    pub red_mask: u16,
    pub green_mask: u16,
    pub blue_mask: u16,
}

static mut LIMINE_FB: Option<FramebufferInfo> = None;

pub fn init_from_limine() -> FramebufferInfo {
    // In a real implementation, this would parse the limine bootloader's
    // framebuffer tag from the multiboot2 info structure passed by limine.
    // For now, we return a placeholder that will be filled in by the bootloader.
    
    // TODO: Parse limine framebuffer tag from bootloader
    // The limine bootloader passes a multiboot2-compatible structure
    // with a framebuffer tag containing the framebuffer info.
    
    unsafe {
        if let Some(fb) = LIMINE_FB {
            fb
        } else {
            // Fallback: assume standard VGA text mode or UEFI GOP
            // This will be replaced by actual limine parsing
            FramebufferInfo {
                addr: 0xFFFF_8000_0000_0000 as *mut u8, // Placeholder
                width: 1920,
                height: 1080,
                pitch: 1920 * 4,
                bpp: 32,
                memory_model: 1, // RGB
                red_mask: 0xFF,
                green_mask: 0xFF00,
                blue_mask: 0xFF0000,
            }
        }
    }
}

pub fn set_limine_framebuffer(info: FramebufferInfo) {
    unsafe {
        LIMINE_FB = Some(info);
    }
}

pub fn draw_test_pattern(fb: &FramebufferInfo) {
    let width = fb.width as usize;
    let height = fb.height as usize;
    let pitch = fb.pitch as usize;
    let bpp = fb.bpp as usize / 8;

    unsafe {
        let fb_ptr = fb.addr as *mut u8;
        
        for y in 0..height {
            for x in 0..width {
                let offset = y * pitch + x * bpp;
                let pixel = fb_ptr.add(offset) as *mut u32;
                
                // Colorful gradient pattern
                let r = (x * 255 / width) as u8;
                let g = (y * 255 / height) as u8;
                let b = ((x + y) * 255 / (width + height)) as u8;
                
                *pixel = ((r as u32) << 16) | ((g as u32) << 8) | (b as u32) | 0xFF000000;
            }
        }
        
        // Draw "NGOS" text in the center (simple 8x8 font)
        draw_text(fb_ptr, pitch, bpp, width, height, "NGOS", width / 2 - 16, height / 2 - 4, 0xFFFFFFFF);
    }
}

fn draw_text(
    fb: *mut u8,
    pitch: usize,
    bpp: usize,
    width: usize,
    height: usize,
    text: &str,
    x: usize,
    y: usize,
    color: u32,
) {
    // Simple 8x8 font rendering
    const FONT: [[u8; 8]; 95] = [
        // Space (32)
        [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00],
        // ! (33)
        [0x18, 0x3C, 0x3C, 0x18, 0x18, 0x00, 0x18, 0x00],
        // ... (truncated for brevity - real impl would have full font)
        [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00],
    ];

    for (i, ch) in text.chars().enumerate() {
        if ch.is_ascii() && ch as u32 >= 32 && ch as u32 < 127 {
            let glyph = &FONT[(ch as u32 - 32) as usize];
            for (row, &bits) in glyph.iter().enumerate() {
                for col in 0..8 {
                    if bits & (0x80 >> col) != 0 {
                        let px = x + i * 8 + col;
                        let py = y + row;
                        if px < width && py < height {
                            let offset = py * pitch + px * bpp;
                            let pixel = unsafe { fb.add(offset) as *mut u32 };
                            unsafe { *pixel = color; }
                        }
                    }
                }
            }
        }
    }
}