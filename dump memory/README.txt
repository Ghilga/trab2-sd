autor: faguiar@parks

* Instruções e exemplo de uso do módulo de dump de memória no arquivo "processor_mem.vhd"



               ---------------------------------------------------
(50MHz)	mclk   - input 					                  output -  addr
			   -												 -
		rst    - input									  output -  an, segment
			   -                 MEMORY DUMPER    				 -
		button - input									  output -  HSYNC, VSYNC
			   -												 -
		dout   - input									  output -  OutRed, OutGreen, OutBlue
			   -												 -
			   ---------------------------------------------------
