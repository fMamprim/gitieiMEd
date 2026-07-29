Data types
          
      
        
        
          
          

		

$ - global variables.

0004: $MyVar = 100 

	@ - (in the beginning): of a label. The text directly after is used to reference the label in jumps

0002: jump @MyLabel

 (in the end): a local variable. Number BEFORE denotes a variable 

 0006: 100@ = 10 

 

 

	'...' - short string (15 chars max).

 
	
03A4: name_thread 'MAIN'

Empty string is also allowed: '  ' 

	
"..." - long string (maximum length is determined by the opcode it uses)

Single quotes do not need anything  special, but to use double quotes you must  specify slash char \ before a quote.

   

Empty string is also allowed: "  " 

	 

0662: write_debug_message "Hello, \"world\"! \n 'Here we go!'"

s$ - global string variable	

05A9: s$MyString = 'GLOBAL'

	@s - local string variable 

05AA: 1@s = 'LOCAL'

	v$ - global long string variable

06D1: v$MyString = "LONG_GLOBAL"

@v - local long string variable

06D2: 1@v = "LONG_LOCAL"

	# - model identifier from '.ide' files 

0247: request_model #CELLPHONE

	& - ADMA (Advanced Direct Memory Access).
 
	Reads/writes the values within the SCM even not in the variables block.

	Does not affect the second segment size. 

ADMA can be used the same as a global  variable. 

&57 += &120(&231,4i) 

  0x - a hexadimal number

	-0x - a negative hexadimal number

0004: $var = -0xBB08

	A number has to be within -80000000..7FFFFFFF range.