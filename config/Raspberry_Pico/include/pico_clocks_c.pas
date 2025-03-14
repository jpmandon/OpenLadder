unit pico_clocks_c;

{$mode ObjFPC}{$H+}

interface

uses
  pico_gpio_c;

{$IF DEFINED(DEBUG) or DEFINED(DEBUG_CLOCKS)}
{$L clocks.c-debug.obj}
{$L __noinline__clocks.c-debug.obj}
{$ELSE}
{$L clocks.c.obj}
{$L __noinline__clocks.c.obj}
{$ENDIF}

(** \file hardware/clocks.h
 *  \defgroup hardware_clocks hardware_clocks
 *
 * Clock Management API
 *
 * This API provides a high level interface to the clock functions.
 *
 * The clocks block provides independent clocks to on-chip and external components. It takes inputs from a variety of clock
 * sources allowing the user to trade off performance against cost, board area and power consumption. From these sources
 * it uses multiple clock generators to provide the required clocks. This architecture allows the user flexibility to start and
 * stop clocks independently and to vary some clock frequencies whilst maintaining others at their optimum frequencies
 *
 * Please refer to the datasheet for more details on the RP2040 clocks.
 *
 * The clock source depends on which clock you are attempting to configure. The first table below shows main clock sources. If
 * you are not setting the Reference clock or the System clock, or you are specifying that one of those two will be using an auxiliary
 * clock source, then you will need to use one of the entries from the subsequent tables.
 *
 * **Main Clock Sources**
 *
 * Source | Reference Clock | System Clock
 * -------|-----------------|---------
 * ROSC      | CLOCKS_CLK_REF_CTRL_SRC_VALUE_ROSC_CLKSRC_PH     |  |
 * Auxiliary | CLOCKS_CLK_REF_CTRL_SRC_VALUE_CLKSRC_CLK_REF_AUX | CLOCKS_CLK_SYS_CTRL_SRC_VALUE_CLKSRC_CLK_SYS_AUX
 * XOSC      | CLOCKS_CLK_REF_CTRL_SRC_VALUE_XOSC_CLKSRC        |  |
 * Reference |                                                  | CLOCKS_CLK_SYS_CTRL_SRC_VALUE_CLK_REF
 *
 * **Auxiliary Clock Sources**
 *
 * The auxiliary clock sources available for use in the configure function depend on which clock is being configured. The following table
 * describes the available values that can be used. Note that for clk_gpout[x], x can be 0-3.
 *
 *
 * Aux Source | clk_gpout[x] | clk_ref | clk_sys
 * -----------|------------|---------|--------
 * System PLL | CLOCKS_CLK_GPOUTx_CTRL_AUXSRC_VALUE_CLKSRC_PLL_SYS |                                                | CLOCKS_CLK_SYS_CTRL_AUXSRC_VALUE_CLKSRC_PLL_SYS
 * GPIO in 0  | CLOCKS_CLK_GPOUTx_CTRL_AUXSRC_VALUE_CLKSRC_GPIN0   | CLOCKS_CLK_REF_CTRL_AUXSRC_VALUE_CLKSRC_GPIN0  | CLOCKS_CLK_SYS_CTRL_AUXSRC_VALUE_CLKSRC_GPIN0
 * GPIO in 1  | CLOCKS_CLK_GPOUTx_CTRL_AUXSRC_VALUE_CLKSRC_GPIN1   | CLOCKS_CLK_REF_CTRL_AUXSRC_VALUE_CLKSRC_GPIN1  | CLOCKS_CLK_SYS_CTRL_AUXSRC_VALUE_CLKSRC_GPIN1
 * USB PLL    | CLOCKS_CLK_GPOUTx_CTRL_AUXSRC_VALUE_CLKSRC_PLL_USB | CLOCKS_CLK_REF_CTRL_AUXSRC_VALUE_CLKSRC_PLL_USB| CLOCKS_CLK_SYS_CTRL_AUXSRC_VALUE_CLKSRC_PLL_USB
 * ROSC       | CLOCKS_CLK_GPOUTx_CTRL_AUXSRC_VALUE_ROSC_CLKSRC    |                                                | CLOCKS_CLK_SYS_CTRL_AUXSRC_VALUE_ROSC_CLKSRC
 * XOSC       | CLOCKS_CLK_GPOUTx_CTRL_AUXSRC_VALUE_XOSC_CLKSRC    |                                                | CLOCKS_CLK_SYS_CTRL_AUXSRC_VALUE_ROSC_CLKSRC
 * System clock | CLOCKS_CLK_GPOUTx_CTRL_AUXSRC_VALUE_CLK_SYS      | | |
 * USB Clock  | CLOCKS_CLK_GPOUTx_CTRL_AUXSRC_VALUE_CLK_USB        | | |
 * ADC clock  | CLOCKS_CLK_GPOUTx_CTRL_AUXSRC_VALUE_CLK_ADC        | | |
 * RTC Clock  | CLOCKS_CLK_GPOUTx_CTRL_AUXSRC_VALUE_CLK_RTC        | | |
 * Ref clock  | CLOCKS_CLK_GPOUTx_CTRL_AUXSRC_VALUE_CLK_REF        | | |
 *
 * Aux Source |  clk_peri | clk_usb | clk_adc
 * -----------|-----------|---------|--------
 * System PLL | CLOCKS_CLK_PERI_CTRL_AUXSRC_VALUE_CLKSRC_PLL_SYS    | CLOCKS_CLK_USB_CTRL_AUXSRC_VALUE_CLKSRC_PLL_SYS | CLOCKS_CLK_ADC_CTRL_AUXSRC_VALUE_CLKSRC_PLL_SYS
 * GPIO in 0  | CLOCKS_CLK_PERI_CTRL_AUXSRC_VALUE_CLKSRC_GPIN0      | CLOCKS_CLK_USB_CTRL_AUXSRC_VALUE_CLKSRC_GPIN0   | CLOCKS_CLK_ADC_CTRL_AUXSRC_VALUE_CLKSRC_GPIN0
 * GPIO in 1  | CLOCKS_CLK_PERI_CTRL_AUXSRC_VALUE_CLKSRC_GPIN1      | CLOCKS_CLK_USB_CTRL_AUXSRC_VALUE_CLKSRC_GPIN1   | CLOCKS_CLK_ADC_CTRL_AUXSRC_VALUE_CLKSRC_GPIN1
 * USB PLL    | CLOCKS_CLK_PERI_CTRL_AUXSRC_VALUE_CLKSRC_PLL_USB    | CLOCKS_CLK_USB_CTRL_AUXSRC_VALUE_CLKSRC_PLL_USB | CLOCKS_CLK_ADC_CTRL_AUXSRC_VALUE_CLKSRC_PLL_USB
 * ROSC       | CLOCKS_CLK_PERI_CTRL_AUXSRC_VALUE_ROSC_CLKSRC_PH    | CLOCKS_CLK_USB_CTRL_AUXSRC_VALUE_ROSC_CLKSRC_PH | CLOCKS_CLK_ADC_CTRL_AUXSRC_VALUE_ROSC_CLKSRC_PH
 * XOSC       | CLOCKS_CLK_PERI_CTRL_AUXSRC_VALUE_XOSC_CLKSRC       | CLOCKS_CLK_USB_CTRL_AUXSRC_VALUE_XOSC_CLKSRC    | CLOCKS_CLK_ADC_CTRL_AUXSRC_VALUE_XOSC_CLKSRC
 * System clock | CLOCKS_CLK_PERI_CTRL_AUXSRC_VALUE_CLK_SYS         | | |
 *
 * Aux Source | clk_rtc
 * -----------|----------
 * System PLL |  CLOCKS_CLK_RTC_CTRL_AUXSRC_VALUE_CLKSRC_PLL_SYS
 * GPIO in 0  |  CLOCKS_CLK_RTC_CTRL_AUXSRC_VALUE_CLKSRC_GPIN0
 * GPIO in 1  |  CLOCKS_CLK_RTC_CTRL_AUXSRC_VALUE_CLKSRC_GPIN1
 * USB PLL    |  CLOCKS_CLK_RTC_CTRL_AUXSRC_VALUE_CLKSRC_PLL_USB
 * ROSC       |  CLOCKS_CLK_RTC_CTRL_AUXSRC_VALUE_ROSC_CLKSRC_PH
 * XOSC       |  CLOCKS_CLK_RTC_CTRL_AUXSRC_VALUE_XOSC_CLKSRC

 *
 * \section clock_example Example
 * \addtogroup hardware_clocks
 * \include hello_48MHz.c
 *)


const
  KHZ=1000;
  MHZ=1000000;
type
  Tclock_index = (
    clk_gpout0 = 0,     ///< GPIO Muxing 0
    clk_gpout1,         ///< GPIO Muxing 1
    clk_gpout2,         ///< GPIO Muxing 2
    clk_gpout3,         ///< GPIO Muxing 3
    clk_ref,            ///< Watchdog and timers reference clock
    clk_sys,            ///< Processors, bus fabric, memory, memory mapped registers
    clk_peri,           ///< Peripheral clock for UART and SPI
    clk_usb,            ///< USB clock
    clk_adc,            ///< ADC clock
    clk_rtc,            ///< Real time clock
    CLK_COUNT
  );

(*
  Initialise the clock hardware
  Must be called before any other clock function.
 *)
procedure clocks_init; cdecl; external;

(*
  Configure the specified clock
  See the tables in the description for details on the possible values for clock sources.
param
  clk_index The clock to configure
  src The main clock source, can be 0.
  auxsrc The auxiliary clock source, which depends on which clock is being set. Can be 0
  src_freq Frequency of the input clock source
  freq Requested frequency
 *)
function clock_configure(clk_index: Tclock_index; src : longWord; auxsrc : longWord; src_freq : longWord; freq : longWord):boolean; cdecl; external;

(*
  Stop the specified clock
param
  clk_index The clock to stop
 *)
procedure clock_stop(clk_index : Tclock_index); cdecl; external;

(*
  Get the current frequency of the specified clock
param
  clk_index Clock
return
  Clock frequency in Hz
 *)
function clock_get_hz(clk_index: Tclock_index ):longWord; cdecl; external;

(*
  Measure a clocks frequency using the Frequency counter.
  Uses the inbuilt frequency counter to measure the specified clocks frequency.
  Currently, this function is accurate to +-1KHz. See the datasheet for more details.
 *)
function frequency_count_khz(src : longWord):longWord; cdecl; external;

(*
  Set the "current frequency" of the clock as reported by clock_get_hz without actually changing the clock
  see clock_get_hz()
 *)
procedure clock_set_reported_hz(clk_index : Tclock_index; hz : longWord); cdecl; external;

function frequency_count_mhz(src : longWord):real; cdecl; external name '__noinline__frequency_count_mhz';

(*
  Resus callback function type.
  User provided callback for a resus event (when clk_sys is stopped by the programmer and is restarted for them).
 *)

type
  Tresus_callback = procedure;

(*
  Enable the resus function. Restarts clk_sys if it is accidentally stopped.
  The resuscitate function will restart the system clock if it falls below a certain speed (or stops). This
  could happen if the clock source the system clock is running from stops. For example if a PLL is stopped.
param
  resus_callback a function pointer provided by the user to call if a resus event happens.
 *)
procedure clocks_enable_resus(resus_callback : Tresus_callback); cdecl; external;

(*! \brief Output an optionally divided clock to the specified gpio pin.
 *  \ingroup hardware_clocks
 *
 * \param gpio The GPIO pin to output the clock to. Valid GPIOs are: 21, 23, 24, 25. These GPIOs are connected to the GPOUT0-3 clock generators.
 * \param src  The source clock. See the register field CLOCKS_CLK_GPOUT0_CTRL_AUXSRC for a full list. The list is the same for each GPOUT clock generator.
 * \param div_int  The integer part of the value to divide the source clock by. This is useful to not overwhelm the GPIO pin with a fast clock. this is in range of 1..2^24-1.
 * \param div_frac The fractional part of the value to divide the source clock by. This is in range of 0..255 (/256).
 *)
procedure clock_gpio_init_int_frac(ugpio : TPinIdentifier; src : longWord; div_int : longWord; div_frac : byte); cdecl; external;

(*
  Output an optionally divided clock to the specified gpio pin.
param
  gpio The GPIO pin to output the clock to. Valid GPIOs are: 21, 23, 24, 25. These GPIOs are connected to the GPOUT0-3 clock generators.
  src  The source clock. See the register field CLOCKS_CLK_GPOUT0_CTRL_AUXSRC for a full list. The list is the same for each GPOUT clock generator.
  div  The amount to divide the source clock by. This is useful to not overwhelm the GPIO pin with a fast clock.
 *)
procedure clock_gpio_init(gpio : TPinIdentifier; src : longWord; &div : longWord); cdecl; external name '__noinline__clock_gpio_init';

(*
  Configure a clock to come from a gpio input
param
  clk_index The clock to configure
  gpio The GPIO pin to run the clock from. Valid GPIOs are: 20 and 22.
  src_freq Frequency of the input clock source
  freq Requested frequency
 *)
function clock_configure_gpin(clk_index : Tclock_index; gpio : TPinIdentifier; src_freq :  longWord; freq : longword):boolean; cdecl; external;

implementation

end.

