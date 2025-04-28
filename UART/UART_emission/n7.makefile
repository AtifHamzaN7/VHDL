
SRC = ../clkUnit/clkUnit.vhd             \
      ../clkUnit/diviseurClkgn.vhd \
      ../TxUnit/TxUnit.vhd \
      echoUnit.vhd \
      ctrlUnit.vhd \
      RxUnit.vhd \
      diviseurClk.vhd \
      Compteur16.vhd \
      ControledeReception.vhd \
      UART.vhd \
      RxUnittest.vhd \
      UART_FPGA_N4.vhd 
      

# for simulation:
TEST = RxUnittest
# duration (to adjust if necessary)
TIME = 8000ns
PLOT = output

# for synthesis:
UNIT = UART_FPGA_N4
ARCH = synthesis
UCF  = UART_FPGA_N4_DDR.ucf
