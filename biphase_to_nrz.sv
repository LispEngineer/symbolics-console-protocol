// Copyright 2022 Douglas P. Fields, Jr. All Rights Reserved
// Originally from c5g_symdec project, transferred on 2022-05-14

// Biphase to NRZ decoder
//
// Parameters:
// * Short pulse length in system clocks
// * Ignore pulse length in system clocks
//
// Inputs:
// * System clock
// * System reset
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
// Handle reset.
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

// TODO: We could count glitches and give a framing error if we get more
// than N, if we care.

module biphase_to_nrz #(
  parameter SHORT_PULSE = 300, // 6 microseconds at 50MHz
  parameter IGNORE_PULSE = 25  // 0.5 microseconds at 50MHz
) (
  input logic clk,
  input logic rst,

  input logic biphase_in_raw,

  output logic nrz_out, // NRZ data output
  output logic clock_out,
  output logic data_received,
  output logic framing_error,
  output logic glitch_ignored,

  // Debugging outputs
  output logic counter_overflow
);

// Derived parameters
localparam LONG_PULSE = SHORT_PULSE * 2;
localparam TOO_LONG_PULSE = SHORT_PULSE * 3;
localparam COUNTER_SIZE = $clog2(TOO_LONG_PULSE);
localparam COUNTER_1 = { {(COUNTER_SIZE-1){1'b0}}, 1'b1};

// Our counter and if it overflowed
logic [COUNTER_SIZE-1:0] counter = '0;
// logic counter_overflow = '0;

// Synchronizer and comparison of biphase data
logic biphase_in_1, biphase_in;
logic biphase_last;

// Did we already see a short pulse?
logic short_seen;

// Two flop synchronizer for incoming data.
// Plus remembering of the last biphase data.
always_ff @(posedge clk) begin
  {biphase_last, biphase_in, biphase_in_1} <= {biphase_in, biphase_in_1, biphase_in_raw};
end // synchronizer


// See above for details on our algorithm
always_ff @(posedge clk) begin
  if (rst) begin ///////////////////////////////////////////////////////////////////
    // Synchronous reset handling
    counter <= '0;
    counter_overflow <= '0;
    data_received <= '0;
    framing_error <= '0;
    glitch_ignored <= '0;
    // Data and clock_out are irrelevant, but...
    // clock_out has to be reset for simulation
    clock_out <= '0;

  end else if (biphase_last == biphase_in) begin ///////////////////////////////////
    // Handle no transition

    // deal with our counter (see above)
    // (I wonder if I can do {overflow, counter} <= counter + COUNTER_1;?)
    counter <= counter + COUNTER_1;

    if (&counter == 1'b1)
      // Handle overflow - it never gets cleared if it keeps overflowing
      counter_overflow <= '1;
    
    // deal with our output flags
    data_received <= '0;
    framing_error <= '0;
    glitch_ignored <= '0;

  end else begin ///////////////////////////////////////////////////////////////////
    // Handle transition (the meat of the algorithm - see above)
    counter <= '0;
    counter_overflow <= '0;

    if (counter > TOO_LONG_PULSE || counter_overflow) begin
      // Erroneously long pulse
      framing_error <= '1;
      short_seen <= '0;

    end else if (counter > LONG_PULSE) begin
      data_received <= '1;
      nrz_out <= '1;
      short_seen <= '0;
      clock_out <= ~clock_out;

      if (short_seen)
        framing_error <= '1;

    end else if (counter > SHORT_PULSE) begin

      if (short_seen) begin
        // Got two short pulses in a row
        data_received <= '1;
        nrz_out <= '0;
        short_seen <= '0;
        clock_out <= ~clock_out;

      end else begin
        // Got the first short pulse
        short_seen <= '1;
      end

    end else if (counter < IGNORE_PULSE) begin
      // Short glitch/runt pulse, perhaps a dirty signal
      glitch_ignored <= '1;

    end else begin
      // Mid-length pulse, yuck
      framing_error <= '1;
      short_seen <= '0;

    end // do different things based on pulse length
  
  end // reset or transition seen?
end // always_ff - our whole algorithm


endmodule
