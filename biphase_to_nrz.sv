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

module biphase_to_nrz (
);


endmodule;
