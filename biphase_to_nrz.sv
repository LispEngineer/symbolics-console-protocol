// Copyright 2022 Douglas P. Fields, Jr. All Rights Reserved

// Biphase to NRZ decoder
//
// Parameters:
// * Short pulse length in system clocks
// * Ignore pulse length in system clocks
//
// Inputs:
// * System clock
// * Biphase (logic level) input
//
// Outputs:
// * NRZ data
// * Derived clock
// * Data received pulse (at system clock rate) - when
// * Glitch pulse (at system clock rate) - for short, runt pulses (can be ignored)
// * Framing error pluse (at system clock rate)
//   - When really long pulses are seen, or a single short pulse is seen
//
// NRZ data could be used as a UART input for further decoding, for example.

// The algorithm:
//
// Whenever the input changes:
//   1. Reset a counter to zero; reset counter_overflow
//   2. Check the counter's (previous) value:
//      a. > 3x short pulse length OR counter_overflow
//               SET framing_error
//               CLEAR short_seen
//      b. > 2x short pulse length - long pulse
//               SET data_received
//               SET data 1 (marking)
//               IF short_seen SET framing_error
//               CLEAR short_seen
//               TOGGLE clock_out
//      c. > short & NOT short_seen
//               SET short_seen
//      d. > short & short_seen
//               SET data_received
//               SET data 0 (spacing)
//               CLEAR short_seen
//               TOGGLE clock_out
//      e. < ignore pulse length
//               SET glitch_seen
//      f. OTHERWISE (> ignore, < short)
//               SET framing_error
//               CLEAR short_seen
//
// Whenever the input doesn't change:
//   1. Increment the counter
//           SET counter_overflow if the counter overflows
//   2. Reset the pulses
//           CLEAR framing_error
//           CLEAR data_received
//           CLEAR glitch_seen

// Feed the input through a synchronizer as it is likely
// coming from the outside world and not aligned with our system clock.

module biphase_to_nrz (
);


endmodule
