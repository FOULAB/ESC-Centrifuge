#include <libopencm3/stm32/rcc.h>
#include <libopencm3/cm3/systick.h>
#include <libopencm3/stm32/timer.h>
#include <libopencm3/stm32/gpio.h>

#include "systick.h"
#include "pwm.h"

#define STEP 10

// for the status LED on the bluepill on PC13
static void gpio_setup(void)
{
  // Enable GPIOC clock.
  rcc_periph_clock_enable(RCC_GPIOC);
  
  /* Set GPIO13 (in GPIO port C) to 'output push-pull'. */
  gpio_set_mode(GPIOC, GPIO_MODE_OUTPUT_50_MHZ,
		GPIO_CNF_OUTPUT_PUSHPULL, GPIO13);
}

// for user physical input control: one open momentary button
static void init_button(void)
{
  // Enable GPIOA clock.
  rcc_periph_clock_enable(RCC_GPIOA);

  // Set GPIO9 (in GPIO port A) to 'input with pull-up resistor'. PA9 
  gpio_set_mode(GPIOA, GPIO_MODE_INPUT,
		GPIO_CNF_INPUT_PULL_UPDOWN, GPIO9);
  gpio_set(GPIOA, GPIO9);
}


int main(void) {
  
  rcc_clock_setup_in_hse_8mhz_out_72mhz();
  
  init_systick();
  init_pwm_TIM4();
  gpio_setup();
  init_button();
  
  int speed = 1000;
  int climb = 1;
  bool lock = false;
  
  for(;;) {
    
    /* 
      this one is configured to take 10bit value for duty cycle (0-18000).
      the throtle for the ESC is in [1000,2000] (doesn't use the full range of the duty cycle, only about 1/4)
      at 55.55Hz
    */

    if(speed < 1000) {
      speed = 1000;
    }
    
    if(speed > 2000) {
      speed = 2000;
    }
    
    if( speed > 1000 && speed < 2000 ) {
      
      if( climb > 0 && speed > 1100 ) {
	lock = false;
      }
      
      speed = speed + (STEP * climb);
      
    } else if (speed == 1000 || speed == 2000) {
      lock = false;
      gpio_set(GPIOC, GPIO13);
    }
    
    if( !gpio_get(GPIOA, GPIO9))
      {
	if(!lock)
	  {	
	    gpio_clear(GPIOC, GPIO13);
	    
	    lock = true;

	    if(speed > 1000) {
	      climb = -1;
	      speed = speed - STEP;
	    } else if (speed == 1000){
	      climb = 1;
	      speed = speed + STEP;
	    }
	  }
      }
    
    TIM_CCR4(TIM4) = speed;
        
    _systick_delay(75); // milliseconds
  }
    
    return 0;
}
