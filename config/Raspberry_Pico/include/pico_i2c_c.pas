unit pico_i2c_c;
(*
 * Copyright (c) 2020 Raspberry Pi (Trading) Ltd.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 *)

{$mode objfpc}{$H+}
{$WARN 3187 off : C arrays are passed by reference}
{$WARN 5023 off : Unit "$1" not used in $2}
interface
uses
  pico_time_c,
  pico_c;

{$IF DEFINED(DEBUG) or DEFINED(DEBUG_I2C)}
{$L i2c.c-debug.obj}
{$L __noinline__i2c.c-debug.obj}
{$ELSE}
{$L i2c.c.obj}
{$L __noinline__i2c.c.obj}
{$ENDIF}

type Ti2c_inst = record
  hw : ^TI2C_Registers;
  restart_on_next : boolean;
end;

(*
  Initialise the I2C HW block
  Put the I2C hardware into a known state, and enable it. Must be called
  before other functions. By default, the I2C is configured to operate as a master.
  The I2C bus frequency is set as close as possible to requested, and
  the return actual rate set is returned
param
  i2c Either \ref i2c0 or \ref i2c1
  baudrate Baudrate in Hz (e.g. 100kHz is 100000)
return
  Actual set baudrate
*)
function i2c_init(var i2c : TI2C_Inst;baudrate:longWord):longWord; cdecl; external;

(*
  Disable the I2C HW block
param
  i2c Either \ref i2c0 or \ref i2c1
  Disable the I2C again if it is no longer used. Must be reinitialised before
  being used again.
*)
procedure i2c_deinit(var i2c : TI2C_Inst); cdecl; external;

(*
  Set I2C baudrate
  Set I2C bus frequency as close as possible to requested, and return actual rate set.
  Baudrate may not be as exactly requested due to clocking limitations.
param
  i2c Either \ref i2c0 or \ref i2c1
  baudrate Baudrate in Hz (e.g. 100kHz is 100000)
return
  Actual set baudrate
*)
function i2c_set_baudrate(var i2c : TI2C_Inst; baudrate:longWord):longWord; cdecl; external;

(*
  Set I2C port to slave mode
param
  i2c Either \ref i2c0 or \ref i2c1
  slave true to use slave mode, false to use master mode
  addr If \p slave is true, set the slave address to this value
*)
procedure i2c_set_slave_mode(var i2c : TI2C_Inst; slave:boolean; addr:byte); cdecl ; external;

(*! \brief Convert I2C instance to hardware instance number
 *  \ingroup hardware_i2c
 *
 * \param i2c I2C instance
 * \return Number of I2C, 0 or 1.
 *)
function i2c_hw_index(var i2c:Ti2c_inst ):longWord; cdecl ; external name '__noinline__i2c_hw_index';

function i2c_get_hw(var i2c :Ti2c_inst) : Ti2c_registers;  cdecl ; external name '__noinline__i2c_get_hw';

function i2c_get_instance(instance : longWord):Ti2c_inst;  cdecl ; external name '__noinline__i2c_get_instance';

(*
  Attempt to write specified number of bytes to address, blocking until the specified absolute time is reached.
param
  i2c Either \ref i2c0 or \ref i2c1
  addr Address of device to write to
   src Pointer to data to send
  len Length of data in bytes to send
  nostop  If true, master retains control of the bus at the end of the transfer (no Stop is issued),
  and the next transfer will begin with a Restart rather than a Start.
  until The absolute time that the block will wait until the entire transaction is complete. Note, an individual timeout of
  this value divided by the length of data is applied for each byte transfer, so if the first or subsequent
  bytes fails to transfer within that sub timeout, the function will return with an error.
return
  Number of bytes written, or PICO_ERROR_GENERIC if address not acknowledged, no device present, or PICO_ERROR_TIMEOUT if a timeout occurred.
*)
function i2c_write_blocking_until(var i2c : TI2C_Inst; addr : byte; const src : array of byte; len : word; nostop:boolean; &until : Tabsolute_time):longInt; cdecl; external;

(*
  Attempt to read specified number of bytes from address, blocking until the specified absolute time is reached.
param
  i2c Either \ref i2c0 or \ref i2c1
  addr Address of device to read from
  dst Pointer to buffer to receive data
  len Length of data in bytes to receive
  nostop  If true, master retains control of the bus at the end of the transfer (no Stop is issued),
          and the next transfer will begin with a Restart rather than a Start.
  until The absolute time that the block will wait until the entire transaction is complete.
return
  Number of bytes read, or PICO_ERROR_GENERIC if address not acknowledged, no device present, or PICO_ERROR_TIMEOUT if a timeout occurred.
*)
function i2c_read_blocking_until(var i2c : TI2C_Inst; addr : byte; out dst : array of byte; len: word; nostop : boolean; &until : Tabsolute_time):longInt; cdecl; external;

(*
  Attempt to write specified number of bytes to address, with timeout
param
  i2c Either i2c0 or i2c1
  addr Address of device to write to
  src Pointer to data to send
  len Length of data in bytes to send
  nostop  If true, master retains control of the bus at the end of the transfer (no Stop is issued),
          and the next transfer will begin with a Restart rather than a Start.
  timeout_us The time that the function will wait for the entire transaction to complete. Note, an individual timeout of
             this value divided by the length of data is applied for each byte transfer, so if the first or subsequent
             bytes fails to transfer within that sub timeout, the function will return with an error.
return
  Number of bytes written, or PICO_ERROR_GENERIC if address not acknowledged, no device present, or PICO_ERROR_TIMEOUT if a timeout occurred.
*)
function i2c_write_timeout_us(var i2c : TI2C_Inst; addr : byte; const src : array of byte; len : word; nostop : boolean; timeout_us:longWord):longInt;  cdecl ; external name '__noinline__i2c_write_timeout_us';

function i2c_write_timeout_per_char_us(var i2c : TI2C_Inst; addr : byte ;  src : array of byte; len : word; nostop : boolean; timeout_per_char_us : longWord):longInt; cdecl; external;

(*
  Attempt to read specified number of bytes from address, with timeout
param
  i2c Either \ref i2c0 or \ref i2c1
  addr Address of device to read from
  dst Pointer to buffer to receive data
  len Length of data in bytes to receive
  nostop  If true, master retains control of the bus at the end of the transfer (no Stop is issued),
          and the next transfer will begin with a Restart rather than a Start.
  timeout_us The time that the function will wait for the entire transaction to complete
return
  Number of bytes read, or PICO_ERROR_GENERIC if address not acknowledged, no device present, or PICO_ERROR_TIMEOUT if a timeout occurred.
*)
function i2c_read_timeout_us(var i2c : TI2C_Inst; addr : byte; out dst : array of byte; len : word; nostop : boolean; timeout_us : longWord):longInt;  cdecl ; external name '__noinline__i2c_read_timeout_us';

function i2c_read_timeout_per_char_us(var i2c : TI2C_Inst; addr : byte; out dst : array of byte; len : word; nostop : boolean; timeout_per_char_us: longWord):longInt; cdecl; external;

(*
  Attempt to write specified number of bytes to address, blocking
param
  i2c Either \ref i2c0 or \ref i2c1
  addr Address of device to write to
  src Pointer to data to send
  len Length of data in bytes to send
  nostop  If true, master retains control of the bus at the end of the transfer (no Stop is issued),
          and the next transfer will begin with a Restart rather than a Start.
return
  Number of bytes written, or PICO_ERROR_GENERIC if address not acknowledged, no device present.
*)
function i2c_write_blocking(var i2c : TI2C_Inst; addr : byte;const src : array of byte;len : word ;nostop : boolean):longInt; cdecl; external;

(*
  Attempt to read specified number of bytes from address, blocking
param
  i2c Either \ref i2c0 or \ref i2c1
  addr Address of device to read from
  dst Pointer to buffer to receive data
  len Length of data in bytes to receive
  nostop  If true, master retains control of the bus at the end of the transfer (no Stop is issued),
          and the next transfer will begin with a Restart rather than a Start.
return
  Number of bytes read, or PICO_ERROR_GENERIC if address not acknowledged, no device present.
*)
function i2c_read_blocking(var i2c : TI2C_Inst; addr : byte; out dst : array of byte; len : word; nostop:boolean):longInt; cdecl; external;

(*
  Determine non-blocking write space available
param
  i2c Either \ref i2c0 or \ref i2c1
return
  0 if no space is available in the I2C to write more data. If return is nonzero, at
  least that many bytes can be written without blocking.
*)
function i2c_get_write_available(var i2c : TI2C_Inst): longWord;  cdecl ; external name '__noinline__i2c_get_write_available';

(*
  Determine number of bytes received
param
  i2c Either \ref i2c0 or \ref i2c1
return
  0 if no data available, if return is nonzero at
  least that many bytes can be read without blocking.
*)
function i2c_get_read_available(var i2c : TI2C_Inst):longWord;  cdecl ; external name '__noinline__i2c_get_read_available';

(*
  Write direct to TX FIFO
param
  i2c Either \ref i2c0 or \ref i2c1
  src Data to send
  len Number of bytes to send
  Writes directly to the to I2C TX FIFO which us mainly useful for
  slave-mode operation.
*)
procedure i2c_write_raw_blocking(var i2c : TI2C_Inst; src : array of byte; len : word);  cdecl ; external name '__noinline__i2c_write_raw_blocking';

(*
  Write direct to TX FIFO
param
  i2c Either \ref i2c0 or \ref i2c1
  dst Buffer to accept data
  len Number of bytes to send
  Reads directly from the I2C RX FIFO which us mainly useful for
  slave-mode operation.
*)
procedure i2c_read_raw_blocking(var i2c : TI2C_Inst; out dst : array of byte; len:word);  cdecl ; external name '__noinline__i2c_read_raw_blocking';

(**
 * \brief Pop a byte from I2C Rx FIFO.
 * \ingroup hardware_i2c
 *
 * This function is non-blocking and assumes the Rx FIFO isn't empty.
 *
 * \param i2c I2C instance.
 * \return uint8_t Byte value.
 *)
function i2c_read_byte_raw(var i2c : Ti2c_inst):byte;  cdecl ; external name '__noinline__i2c_read_byte_raw';

(**
 * \brief Push a byte into I2C Tx FIFO.
 * \ingroup hardware_i2c
 *
 * This function is non-blocking and assumes the Tx FIFO isn't full.
 *
 * \param i2c I2C instance.
 * \param value Byte value.
 *)
procedure i2c_write_byte_raw(var i2c : Ti2c_inst; value : byte);  cdecl ; external name '__noinline__i2c_write_byte_raw';

(*! \brief Return the DREQ to use for pacing transfers to/from a particular I2C instance
 *  \ingroup hardware_i2c
 *
 * \param i2c Either \ref i2c0 or \ref i2c1
 * \param is_tx true for sending data to the I2C instance, false for receiving data from the I2C instance
 *)
function i2c_get_dreq(var i2c : Ti2c_inst; is_tx : boolean): longWord;  cdecl ; external name '__noinline__i2c_get_dreq';

var
  I2CInst,
  I2C0Inst,
  I2C1Inst : TI2C_Inst;

implementation

begin
  I2C0Inst.hw := @I2C0;
  I2C0Inst.restart_on_next := False;
  I2C1Inst.hw := @I2C1;
  I2C1Inst.restart_on_next := False;

  {$IF DEFINED(FPC_MCU_TINY_2040)}
    i2cInst.hw := @I2C0;
  {$ELSEIF DEFINED(FPC_MCU_QTPY_RP2040)}
    i2cInst.hw := @I2C0;
  {$ELSEIF DEFINED(FPC_MCU_FEATHER_RP2040)}
    i2cInst.hw := @I2C1;
  {$ELSEIF DEFINED(FPC_MCU_ITZYBITZY_RP2040)}
    i2cInst.hw := @I2C1;
  {$ELSEIF DEFINED(FPC_MCU_RASPI_PICO)}
    i2cInst.hw := @I2C0;
  {$ENDIF}
  i2cInst.restart_on_next := False;
end.
