unit ST7735S_spi_c;
{$mode objfpc}
{$H+}
{$modeswitch advancedrecords}
{$SCOPEDENUMS ON}


interface
uses
  CustomDisplay,
  CustomDisplay16Bits,
  pico_timer_c,
  pico_gpio_c,
  pico_spi_c,
  pico_c;

type
  TST7735S_SPI = object(TCustomDisplay16Bits)
    private
      FpSPI : ^TSPI_Registers;
      FPinDC : TPinIdentifier;
      FPinRST : TPinIdentifier;
      //FInTransaction : boolean;
    protected
      procedure WriteCommand(const command : byte); virtual;
      procedure WriteCommandBytes(const command : byte; constref data : array of byte; Count:longInt=-1); virtual;
      procedure WriteCommandWords(const command : byte; constref data : array of word; Count:longInt=-1); virtual;
      procedure WriteData(const data: byte); virtual;
      procedure WriteDataBytes(constref data : array of byte; Count:longInt=-1); virtual;
      procedure WriteDataWords(constref data : array of word; Count:longInt=-1); virtual;
      procedure InitSequence; virtual;
    public
      const
        // Physical Width is up to 128 Pixel Physical Height goes up to 160 Pixel
        ScreenSize80x160x16: TPhysicalScreenInfo =
          (Width:  80; Height: 160; Depth: TDisplayBitDepth.SixteenBits;ColorOrder: TDisplayColorOrder.BGR;ColStart : (26,1,26,1); RowStart : (1,26,1,26));
        ScreenSize128x128x16: TPhysicalScreenInfo =
          (Width: 128; Height: 128; Depth: TDisplayBitDepth.SixteenBits;ColorOrder: TDisplayColorOrder.BGR;ColStart : (3,2,1,2); RowStart : (2,3,2,1));
        ScreenSize128x160x16RGB: TPhysicalScreenInfo =
          (Width: 128; Height: 160; Depth: TDisplayBitDepth.SixteenBits;ColorOrder: TDisplayColorOrder.RGB;ColStart : (0,0,0,0); RowStart : (0,0,0,0));

    (*
      Initializes the display
    param
      SPI     The SPI Interface to use
      aPinDC  Pin used for switching between Communication between Data and Command Mode
      aPinRST Pin used to reset the display, not needed by all displays, pass TNativePin.None when not needed
      aPhysicalScreenInfo Information about Width/Height and Bitdepth of the connected screen
    note
      The SPI interface needs to be pre-initialized to required Parameters
      The extra Pins do not need to be initialized
    *)
    constructor Initialize(var SPI : TSpi_Registers;const aPinDC : TPinIdentifier;const aPinRST : TPinIdentifier;aPhysicalScreenInfo : TPhysicalScreenInfo);

    (*
      Sets the rotation of a display in steps of 90 Degrees.
      Usefull when you have no control on how the display is mounted.
    param:
      displayRotation
    *)
    procedure setRotation(const DisplayRotation : TDisplayRotation); virtual;

    (*
      Sets the active drawing area and switches to data mode
    param:
      X,Y Top Left coordinate of paint Area
      Width, Height: Width and Height of Drawing Area
    return:
      Returns the number of Pixels that are included in the Area
    *)
    function setDrawArea(const X,Y,Width,Height : word):longWord; virtual;

    (*
      Sets a single Pixel on the display by drawing currently selected ForegroundColor or provided color
    param:
      x,y : Position of the pixel
      color: Color of the Pixel
    note:
      Drawing single pixel creates a relatively high overhead, so do not overdo single pixel paining
    *)
    procedure drawPixel(const x,y : word; const fgColor : TColor = clForeground); virtual;
  end;

implementation
const
  ST7735_MADCTL_MY =  $80;
  ST7735_MADCTL_MX =  $40;
  ST7735_MADCTL_MV =  $20;
  ST7735_MADCTL_ML =  $10;
  ST7735_MADCTL_MH =  $04;
  ST7735_MADCTL_RGB = $00;
  ST7735_MADCTL_BGR = $08;

  ST7735_NOP     =$00;
  ST7735_SWRESET =$01;
  ST7735_RDDID   =$04;
  ST7735_RDDST   =$09;

  ST7735_SLPIN   =$10;
  ST7735_SLPOUT  =$11;
  ST7735_PTLON   =$12;
  ST7735_NORON   =$13;

  ST7735_INVOFF  =$20;
  ST7735_INVON   =$21;
  ST7735_DISPOFF =$28;
  ST7735_DISPON  =$29;
  ST7735_CASET   =$2A;
  ST7735_RASET   =$2B;
  ST7735_RAMWR   =$2C;
  ST7735_RAMRD   =$2E;

  ST7735_PTLAR   =$30;
  ST7735_COLMOD  =$3A;
  ST7735_MADCTL  =$36;

  ST7735_FRMCTR1 =$B1;
  ST7735_FRMCTR2 =$B2;
  ST7735_FRMCTR3 =$B3;
  ST7735_INVCTR  =$B4;
  ST7735_DISSET5 =$B6;

  ST7735_PWCTR1  =$C0;
  ST7735_PWCTR2  =$C1;
  ST7735_PWCTR3  =$C2;
  ST7735_PWCTR4  =$C3;
  ST7735_PWCTR5  =$C4;
  ST7735_VMCTR1  =$C5;

  ST7735_RDID1   =$DA;
  ST7735_RDID2   =$DB;
  ST7735_RDID3   =$DC;
  ST7735_RDID4   =$DD;
  ST7735_PWCTR6  =$FC;

  ST7735_GMCTRP1 =$E0;
  ST7735_GMCTRN1 =$E1;

constructor TST7735S_SPI.Initialize(var SPI : TSpi_Registers;const aPinDC : TPinIdentifier;const aPinRST : TPinIdentifier;aPhysicalScreenInfo : TPhysicalScreenInfo);
begin
    FpSPI := @SPI;
    FPinDC := aPinDC;
    FPinRST := aPinRST;
    PhysicalScreenInfo :=  aPhysicalScreenInfo;

    if APinDC > -1 then
    begin
      gpio_init(APinDC);
      gpio_set_dir(APinDC,TGPIO_Direction.GPIO_OUT);
      gpio_put(APinDC,false);
    end;
    if APinRST > -1 then
    begin
      gpio_init(APinRST);
      gpio_set_dir(APinRST,TGPIO_Direction.GPIO_OUT);
      gpio_put(APinRST,true);
    end;
    InitSequence;
end;

procedure TST7735S_SPI.InitSequence;
const
  DELAY=$80;
  display_init_sequence : array of byte = (
    // sw reset
    $01, 0 or DELAY, $96, //150ms
    // SLPOUT and Delay
    $11, 0 or DELAY, $FF, //255ms
    $B1, $03, $01, $2C, $2D,      // _FRMCTR1
    $B3, $06, $01, $2C, $2D, $01, $2C, $2D,     // _FRMCTR3
    $B4, $01, $07, // _INVCTR line inversion
    $C0, $03, $A2, $02, $84, // _PWCTR1 GVDD = 4.7V, 1.0uA
    $C1, $01, $C5, // _PWCTR2 VGH=14.7V, VGL=-7.35V
    $C2, $02, $0A, $00, // _PWCTR3 Opamp current small, Boost frequency
    $C3, $02, $8A, $2A,
    $C4, $02, $8A, $EE,
    $C5, $01, $0E, // _VMCTR1 VCOMH = 4V, VOML = -1.1V
    $20, $00, // _INVOFF
    $36, $01, $18, // _MADCTL bottom to top refresh
    // 1 clk cycle nonoverlap, 2 cycle gate rise, 3 cycle osc equalie,
    // fix on VTL
    $3A, $01, $05, // COLMOD - 16bit color
    $E0, $10, $02, $1C, $07, $12, $37, $32, $29, $2D, $29, $25, $2B, $39, $00, $01, $03, $10, // _GMCTRP1 Gamma
    $E1, $10, $03, $1D, $07, $06, $2E, $2C, $29, $2D, $2E, $2E, $37, $3F, $00, $00, $02, $10, // _GMCTRN1
    $13, 0 or DELAY, $0A, // _NORON
    $29, 0 or DELAY, $64, // _DISPON
    // $36, $01, $C0,  // _MADCTL Default rotation plus BGR encoding
    $36, $01, $C8,      // _MADCTL Default rotation plus RGB encoding
    $21, $00      // _INVON
    );
var
  pos : longword;
  dataCount : longWord;
  hasDelay : boolean;
  command : byte;
begin
  pos := 0;
  repeat
    command := display_init_sequence[pos];
    inc(pos);
    dataCount := display_init_sequence[pos];

    if dataCount >=DELAY then
    begin
      dataCount := datacount and $7f;
      hasDelay := true;
    end
    else
      hasDelay := false;

    if datacount = 0 then
    begin
      WriteCommand(command);
      inc(pos);
    end;
    if dataCount > 0 then
    begin
      inc(pos);
      writeCommandBytes(command,display_init_sequence[pos],datacount);
      pos := pos+datacount;
    end;
    if hasDelay then
    begin
      busy_wait_ms(display_init_sequence[pos]);
      inc(pos);
    end;
  until pos >= longWord(length(display_init_sequence));

  setRotation(TDisplayRotation.None);
  ForegroundColor := clBlack;
  BackgroundColor := clWhite;
end;

procedure TST7735S_SPI.setRotation(const displayRotation : TDisplayRotation);
var
  ColMode : byte;
begin
  colStart := PhysicalScreenInfo.ColStart[byte(displayRotation)];
  rowStart := PhysicalScreenInfo.RowStart[byte(displayRotation)];
  if PhysicalScreenInfo.ColorOrder = TDisplayColorOrder.RGB then
    colMode := ST7735_MADCTL_RGB
  else
    colMode := ST7735_MADCTL_BGR;
  case displayRotation of
    TDisplayRotation.None:
    begin
      FScreenWidth := PhysicalScreenInfo.Width;
      FScreenHeight := PhysicalScreenInfo.Height;
      WriteCommandBytes(ST7735_MADCTL,[ST7735_MADCTL_MX + ST7735_MADCTL_MY + colMode]);
    end;
    TDisplayRotation.Right: begin
      FScreenWidth := PhysicalScreenInfo.Height;
      FScreenHeight := PhysicalScreenInfo.Width;
      WriteCommandBytes(ST7735_MADCTL,[ST7735_MADCTL_MY + ST7735_MADCTL_MV + colMode]);
    end;
    TDisplayRotation.UpsideDown:
    begin
      FScreenWidth := PhysicalScreenInfo.Width;
      FScreenHeight := PhysicalScreenInfo.Height;
      WriteCommandBytes(ST7735_MADCTL,[colMode]);
    end;
    TDisplayRotation.Left: begin
      FScreenWidth := PhysicalScreenInfo.Height;
      FScreenHeight := PhysicalScreenInfo.Width;
      WriteCommandBytes(ST7735_MADCTL,[ST7735_MADCTL_MX + ST7735_MADCTL_MV + colMode]);
    end;
  end;
end;

function TST7735S_SPI.setDrawArea(const X,Y,Width,Height : word):longWord;
begin
  {$PUSH}
  {$WARN 4079 OFF}
  Result := 0;
  WriteCommandWords(ST7735_CASET,[X+rowStart,X+rowStart+Width-1]);
  WriteCommandWords(ST7735_RASET,[Y+colStart,Y+colStart+Height-1]);
  WriteCommand(ST7735_RAMWR);
  Result := Width*Height;
  {$POP}
end;

procedure TST7735S_SPI.drawPixel(const x,y : word; const fgColor : TColor = clForeground);
var
  _fgColor : word;
begin
  if (x >= ScreenWidth) or (y >= ScreenHeight) then
    exit;
  WriteCommandWords(ST7735_CASET,[X+rowStart,X+rowStart]);
  WriteCommandWords(ST7735_RASET,[Y+colStart,Y+colStart]);
  WriteCommand(ST7735_RAMWR);
  _fgColor := color24to16(fgColor);
  WriteData(hi(_fgColor));
  WriteData(lo(_fgColor));
end;

procedure TST7735S_SPI.WriteCommand(const command: Byte);
var
  data: array[0..0] of byte;
begin
  data[0] := command;
  gpio_put(FPinDC,false);
  spi_write_blocking(FpSPI^,data,1);
  gpio_put(FPinDC,true);
end;

procedure TST7735S_SPI.WriteCommandBytes(const command : byte; constref data : array of byte; Count:longInt=-1);
var
  _data : array[0..0] of byte;
begin
  if count = -1 then
    count := High(data)+1;
  _data[0]:= command;
  gpio_put(FPinDC,false);
  spi_write_blocking(FpSPI^,_data,1);
  gpio_put(FPinDC,true);
  spi_write_blocking(FpSPI^,data,count);
end;

procedure TST7735S_SPI.WriteCommandWords(const command : byte; constref data : array of word; Count:longInt=-1);
var
  _data : array[0..0] of byte;
begin
  if count = -1 then
    count := High(data)+1;
  _data[0]:= command;
  gpio_put(FPinDC,false);
  spi_write_blocking(FpSPI^,_data,1);
  gpio_put(FPinDC,true);
  spi_write_blocking_hl(FpSPI^,data,count);
end;

procedure TST7735S_SPI.WriteData(const data: byte);
var
  _data : array[0..0] of byte;
begin
  _data[0] := data;
  gpio_put(FPinDC,true);
  spi_write_blocking(FpSPI^,_data,1);
end;

procedure TST7735S_SPI.WriteDataBytes(constref data: array of byte;Count:longInt=-1);
begin
  if count = -1 then
    count := High(data)+1;
  gpio_put(FPinDC,true);
  spi_write_blocking(FpSPI^,data,count);
end;

procedure TST7735S_SPI.WriteDataWords(constref data: array of word;Count:longInt=-1);
begin
  if count = -1 then
    count := High(data)+1;
  gpio_put(FPinDC,true);
  spi_write_blocking_hl(FpSPI^,data,count);
end;

{$WARN 5028 OFF}
begin
end.
