#![no_std]
#![no_main]

use defmt::{info, unwrap};
use embassy_executor::Spawner;
use embassy_rp::gpio::{Level, Output};
use embassy_sync::blocking_mutex::raw::CriticalSectionRawMutex;
use embassy_sync::channel::{Channel, Sender};
use embassy_time::{Duration, Timer};

// Linked for their side effects: defmt-rtt installs the log transport,
// panic-probe installs the panic handler.
use {defmt_rtt as _, panic_probe as _};

/// How fast the LED task should blink.
#[derive(Debug, Clone, Copy, defmt::Format)]
enum Speed {
    Slow,
    Fast,
}

impl Speed {
    fn period(self) -> Duration {
        match self {
            Speed::Slow => Duration::from_millis(500),
            Speed::Fast => Duration::from_millis(100),
        }
    }
}

/// Channels are how embassy tasks talk to each other. `CriticalSectionRawMutex`
/// is the portable choice; it works from interrupt context too.
static SPEED: Channel<CriticalSectionRawMutex, Speed, 4> = Channel::new();

#[embassy_executor::main]
async fn main(spawner: Spawner) {
    let p = embassy_rp::init(Default::default());
    info!("booted");

    // PIN_25 is the on-board LED on a plain Pico. On a Pico W the LED hangs
    // off the wifi chip instead and needs the cyw43 driver.
    let led = Output::new(p.PIN_25, Level::Low);

    // In embassy-executor 0.10 the task function returns
    // `Result<SpawnToken, SpawnError>` (the pool-exhausted check moved here),
    // and `spawn` itself returns `()` -- so the unwrap goes on the inside.
    spawner.spawn(unwrap!(blink(led, SPEED.receiver())));
    spawner.spawn(unwrap!(metronome(SPEED.sender())));
}

#[embassy_executor::task]
async fn blink(
    mut led: Output<'static>,
    speed: embassy_sync::channel::Receiver<'static, CriticalSectionRawMutex, Speed, 4>,
) {
    let mut current = Speed::Slow;

    loop {
        // Take a new speed if one is waiting, but never block on it.
        if let Ok(next) = speed.try_receive() {
            info!("speed -> {}", next);
            current = next;
        }

        led.toggle();
        Timer::after(current.period()).await;
    }
}

/// Alternates the blink speed every few seconds, so there is something to see
/// without any hardware attached.
#[embassy_executor::task]
async fn metronome(speed: Sender<'static, CriticalSectionRawMutex, Speed, 4>) {
    let mut fast = false;

    loop {
        Timer::after(Duration::from_secs(5)).await;
        fast = !fast;
        speed
            .send(if fast { Speed::Fast } else { Speed::Slow })
            .await;
    }
}
