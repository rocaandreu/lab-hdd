// High-Level Digital Design (HDD)
//
// Lab evolved from Catapult Online Training (Copyright 2018-2021 Siemens)
// 

// Modified from fir_filter.cpp
//

#include "lpf_AC.h" 
#include "stdio.h"

#pragma hls_design top // To set the Catapult top design block

void lpf_ac (const X_TYPE i_sample, COEFF_TYPE b[], Y_TYPE &y)                 
{
Y_TYPE filter_out; 

// Functions
lpf(i_sample, b, filter_out);

// For debug
//  printf("%f \n", filter_out.to_double());


y = filter_out; 
}

// Low-pass filter function

void lpf(const X_TYPE i_sample, COEFF_TYPE b[], Y_TYPE &y) 
  {
  static Y_TYPE peaks[AVERAGED_PEAKS];
  static ac_fixed<14,6,true,AC_RND,AC_SAT_SYM> peak_avg = 0;
  static Y_TYPE peak;
  static ac_fixed<10,10,true> counter;
  static ac_fixed<12,2,false> gain = 1;

  // previous input history, remember across calls
  static X_TYPE x[TAP_COUNT];
  SHIFT_LOOP: for (int n=TAP_COUNT-1; n>0; n--) {
    x[n] = x[n-1];
  }
  x[0] = i_sample;

  SUM_TYPE sum = 0;
  MAC_LOOP: for (unsigned n=0; n<TAP_COUNT; n++) {
    sum += x[n] * b[n];
  }
  // round & saturate according to Y_TYPE

  sum *= gain;

  SUM_TYPE sum_abs = 0;
  if (sum<0) {
      sum_abs = -sum;
  }
  else {
      sum_abs = sum;
  }
  
  if (counter.to_int() == peak_det_samples) {
    // Store found peak and calculate average
    counter  = 0;
    peak_avg = 0;

    std::cout << "NEW PEAK: " << peak.to_double() << std::endl;
   
    for (int i = AVERAGED_PEAKS-1; i > 0; i--) {
    	peaks[i] = peaks[i-1];
    	peak_avg += peaks[i];
	std::cout << "PEAK_LIST: " << peaks[i].to_double() << std::endl;
        std::cout << "PEAKS_SUM: " << peak_avg.to_double() << std::endl;
    }
    peaks[0] = peak;
    peak_avg += peak;
    std::cout << "PEAKS_SUM: " << peak_avg.to_double() << std::endl;
    peak_avg /= AVERAGED_PEAKS;
    peak = 0;
    
    // Calculate new gain
    if (peak_avg.to_double() > x_high.to_double()) {
    	// Reduce gain
    	gain -= gain_delta;
    }
    else if (peak_avg.to_double() < x_low.to_double()) {	
    	// Increase gain
    	gain += gain_delta;
    }

    std::cout << "GAIN = " << gain.to_double() << std::endl;
    std::cout << "PEAK AVG = " << peak_avg.to_double() << std::endl << std::endl;
  } 

  if (sum_abs > peak) peak = sum_abs;
  counter++;

  y = sum;
}
