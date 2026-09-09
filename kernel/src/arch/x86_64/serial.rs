use core::fmt::Write;
use spin::Mutex;
use x86_64::instructions::port::Port;

const COM1: u16 = 0x3F8;

static SERIAL: Mutex<Option<SerialPort>> = Mutex::new(None);

struct SerialPort {
    data: Port<u8>,
    lsr: Port<u8>,
}

impl SerialPort {
    fn new() -> Self {
        let mut port = SerialPort {
            data: Port::new(COM1),
            lsr: Port::new(COM1 + 5),
        };
        port.init();
        port
    }

    fn init(&mut self) {
        unsafe {
            // Disable interrupts
            Port::new(COM1 + 1).write(0x00);
            // Enable DLAB
            Port::new(COM1 + 3).write(0x80);
            // Set baud rate to 115200 (divisor = 1)
            Port::new(COM1 + 0).write(0x01);
            Port::new(COM1 + 1).write(0x00);
            // 8 bits, no parity, 1 stop bit
            Port::new(COM1 + 3).write(0x03);
            // Enable FIFO, clear, 14-byte threshold
            Port::new(COM1 + 2).write(0xC7);
            // Enable interrupts
            Port::new(COM1 + 1).write(0x01);
        }
    }

    fn send(&mut self, byte: u8) {
        unsafe {
            while self.lsr.read() & 0x20 == 0 {}
            self.data.write(byte);
        }
    }

    fn write_str(&mut self, s: &str) {
        for byte in s.bytes() {
            if byte == b'\n' {
                self.send(b'\r');
            }
            self.send(byte);
        }
    }
}

pub fn init() {
    *SERIAL.lock() = Some(SerialPort::new());
}

pub fn println!(args: core::fmt::Arguments) {
    if let Some(serial) = SERIAL.lock().as_mut() {
        serial.write_fmt(args).unwrap();
        serial.write_str("\n");
    }
}

#[macro_export]
macro_rules! println {
    () => ($crate::arch::x86_64::serial::println!(core::format_args!()));
    ($($arg:tt)*) => ($crate::arch::x86_64::serial::println!(core::format_args!($($arg)*)));
}