Opcodes List (INI)
          
      
        
        
          
          

            

The INI file is the  major file providing the (de)compiling process. It contains a list of opcodes:  its own for each game. These lists are located in the Sanny Builders folder  data\game:

	data\gta3  : SCM.INI

	data\vc    : VCSCM.INI

	data\sa    : SASCM.INI

	data\lcs   : LCSSCM.INI

	data\vcs   : VCSSCM.INI

All files have the same  syntax. First, the special parameters could be written in the beginning of the  INI. They are:

  **VERSION**  this line defines a version of  this INI. See [$VERSION  directive](directives.htm#VERSION).

  **PUBLISHER**  the person published this  version. 

  **DATE**  the latest update date.

The decompiler inserts these  values into the source files.

The list of opcodes goes  right after those special parameters. Each opcode line has the following  syntax:

xxxx=N, yyyy 

where **XXXX** is the opcode number, **N**  the number  of parameters,** YYYY**  the opcode description.

First two values cant be  changed in any way, however the description can. Also take note of the part of  the description denoted by the % sign - an opcode parameter is designed in this  way. 

For example,

0001=1,wait  %1d% ms

this line makes the  decompiler when it processing an opcode 0001 write the words wait and ms  and the only parameter between them.

A parameter consists of two  parts: a number and a type. 

The number in parameter  %1d% is its number itself. The point is that some opcodes can have their  parameters to be arranged in the non-numerical order. Its all to make a source  code more readable and looking like the common programming languages. For  instance, 

0053=5,%5d% =  create_player %1o% at %2d% %3d% %4d% 

Pay attention, the  decompiler writes the fifth parameter at first. If the parameters follow their  numeric order, the opcode 0053 will look like:

0053: reate_player #NULL at 2488.562  -1666.865 12.8757 $PLAYER_CHAR 

Its significant that the  numeric order is typical for the gtama and PLPyntons SASCM.INI.

The following letters  denote the parameter type: 

**d** = any values

**p** = label

**o** = model name 

**g** = gxt-entry 

**x** = external script ID

The type changes the  decompiler behavior. For example, it adds a comment with the gxt-key content  for the g-parameter; converts the p-one to the label, the o-parameter to the  model name (like #NULL in the 0053), etc.

Attention!  The parameters order can never  be changed as it will cause the impossibility to compile your scripts correctly  by the other users. The only way to do so is if you **never going to** publish your script.

You  can freely change the description words and the parameters types, if it needed.  The comments are marked with the semicolon at the beginning of the line.

If the INI contains few opcodes with the same  number, the program uses that one located further.