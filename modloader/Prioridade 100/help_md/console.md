Console
          
      
        
        
          
          
            

The console is used for switching of  the Sanny Builder advanced options. Mostly it concern the decompiler features  and you can see the changes when decompile. The console window is called by  pressing Ctrl + ~. In the edit line you may write the commands and the  parameters. After the typing press Enter to input the command. The console will  display the processing result.

All commands are case-insensitive.

The list of the commands:

**help ** shows the help information about  the console 

            
            

**clear  **clears the console

            
            

**list  **shows in the console the  list of all commands

            

The parameter (optional):

              list **options  **after  input *list options the console  will display all possible options to toggle. *

            
            

**toggle  **the major  command to enable or disable the program options

            

The  parameter: 

toggle **<****option ****name> [on/off] **

**The options **list can be different in other version. To get all  possible options, type *list options*. 

At the end of the command  there may be either word **ON** (the option will be enabled) or word **OFF** (the  option will be disabled), or nothing (the option will be toggled from ON to OFF  or from OFF to ON).

            
              
                toggle CODE_OFFSETS 
                

 the decompiler will  print the offsets of every opcode

              
              
                
              
              
                
              
              
                
              
              
                toggle VAR_COUNTER
                

 after the compilation the  console will contain the list of the global variables used once in the code. It  is very useful to search the useless variables.

              
              
                
              
              
                
              
              
                
              
              
                
              
              
                
              
              
                
              
              
                toggle IGNORE_UNKNOWN 
                

makes the decompiler  work in advanced way. It allows decompile almost every file, ignoring the  missing opcodes, the incorrect parameters and so on. It may help you to crack  the protected files (or the files which were compiled incorrectly). 

              
              
                
              
              
                
              
              
                
              
              
                
              
              
                toggle CONSTANT_INDEXES
                

allows to decompile  arrays elements with the constant index, if possible. It's available for San  Andreas (enabled by default), LCS, VCS. For example,

              
              
                
              
              
                
              
              
              
                 
                **was **
                **became**
              
              
              
                 
                $10
                $10[0]
              
              
                 
                $11
                $10[1]
              
              
                 
                $12
                $10[2] 
              
              
              
              
                
                 
              
              
                 
              
              
                toggle SKIP_SCM_HEADER
                

Makes  the decompiler skip the scm header while processing. Allows to decompile the  external scms from the script.img separately. 

                  Also makes the compiler not to compile the scm  header.
              
              
                
              
            		    
		    

Usage of the parameter  \debug is an alternate way to switch advanced SB options. Run Sanny with the  parameter \debug=X, where X is a 32-bit number (in decimal format). Its bits  values mean which debug option is enabled/disabled.

To calculate the necessary  value, run WinCalc, toggle it into the **BINARY MODE**. Write the numbers sequence. Count goes from right to left.  Convert it to the decimal format. Use as X in \debug=X

Example: write 10 in the calculator.

		    

 First digit digit 0 will disable "code_offsets" option, second digit will enable "ignore_unknown" mode. A binary number 10 is equal to a decimal number 2.

		    

 So, run Sanny with \debug=2 to enable the  features listed above.

		    

 
		    Note: The  debug mode should be enabled before using of the other options!

		    
              
                **#**
                **Sanny Builder Option**

                   
                **#**
                **Sanny Builder Option 

                   **
              
              
                0
                   toggle code offsets
                16
                 
              
              
                1
                   toggle ignore_unknown
                17
                 
              
              
                2
                   toggle var_counter
                18
                 
              
              
                3
                   toggle constant_indexes
                19
                 
              
              
                4
                   toggle skip_scm_header 
                20
                 
              
              
                5
                 
                21
                 
              
              
                6
                 
                22
                 
              
              
                7
                 
                23
                 
              
              
                8
                 
                24
                 
              
              
                9
                 
                25
                 
              
              
                10
                 
                26
                 
              
              
                11
                 
                27
                 
              
              
                12
                 
                28
                 
              
              
                13
                 
                29
                 
              
              
                14
                 
                30
                 
              
              
                15
                 
                31