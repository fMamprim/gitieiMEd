Version History
          
      
        
        
          
          

	

Previous Releases:

    

01.01.2007 v. 2.99e - 

  
-  fixed disappearing code parts within the HEX..END contruction in the debug_mode   decompiling
   the [hex..end](hex_end.htm) statement could accept the aDMA type
  the FOR statement could accept the model identifiers  as the counter values 
  the hex..end statement could accept the [strings](hex_end.htm#strings)

    03.12.2006    v. 2.99d - 

    
- Memory Hacker became a separate tool. Now  downloadable at:   [http://sannybuilder.com/downloads](http://sannybuilder.com/downloads" target="_blank)
     fixed decompiler bug 

	30.11.2006	v. 2.99c - 

 added the Memory Hacker plug-in
possibility to decompile the main.scm of Liberty City Stories
support the number of constants as the global [array](arrays.htm) indexes
the global variables are decompiled with the type aDMA (&) if not a multiple to 4
at compilation the default values for the segments are used when the file header is not    present
possibility to open a file using Drag&Drop
new preprocessor [directives](directives.htm): {$VERSION}, {$VERSION_RESTORE} 

(!) If you get a compiler error message like "Unknown directive xxxx"

	when compiling the sources from v2.99, replace the line {$VERSION xxxx}

	to any place after the header, for instance before the comment 

	//-------------MAIN---------------

	27.09.2006	v. 2.99 -
Major changes:
 added new commands WriteMem and ReadMem
	 support hexadimal numbers 
	 HEX..END statement can accept labels and global variables 
	 full support of &-datatype (ADMA)
	 opportunity to give custom names to labels 
	 opportunity to choose a different case for custom names and strings (Options->Format)
	 added the console in order to switch the special options of SB
	 decompiler supports the GXT-files of GTA III & GTA VC
	 added special symbol constants in the long strings

Minor changes:
	 information about an INI file (version, author, date)
	 classes support an original order of the parameters 
	  (like in SASCM.INI from PLPynton).
    In order to support such order 
	  there should be a line {$VERSION x.0.xxxx}, 
    see comments in the INI about this
	 added option to confirm exit program 
	 quick switching of the Edit Mode
	 converting of the selected piece of code
	 opportunity to pass the current file name to the external tool
	 corrected some mistakes in the configuration files
	 removed auto-casting of an integer number to a float one 
	  when the variable was declared    as Float. Now the compiler chooses an opcode 
	  depending on the number type 
   only (in math expressions without opcodes)
	 reading/writing of the player's z_angle in Coord Manager; 
	  quick insertion of this one in a    script by pressing Ctrl+Shift+E (for SA) 

Other notes:

	(!) The following opcodes were changed in SASCM.INI: 0181, 00c3, 00c4 in order 
	to support the commands WriteMem and ReadMem. In original files these opcodes 
	are not used and the games do not support them so there should be no problem.

	(!) The class member Car.SetSpeedInstantly was named incorrectly (with wrong 
	opcode) in the file classes.db for SA. If you get the error message about 
	this method at compilation, rename it in Actor.DrivingPlane manually. We apologize.

04.08.2006	v. 2.98 -

	  Sanny Builder became multilingual 
	  added menu for external applications
	  the special version of Opcode Search Tool is built in SB
	 Details in a file 'OST Readme.txt'
	  checking of the math expressions while decompiling when the option "Write opcodes"
	   is    disabled (to sure that all the opcodes were used correctly)
	  an opportunity to choose an IMG-file manually if the last one 
	   is not found in a folder with    the SCM-file (an option "Manual IMG opening")
	  an opportunity to add new macros directly from the editor;
	   added macros descriptions
	  the list of models can be sorted alphabetically/by value
	   (Alt+S when the list is active)
	  minor corrections and changes

	11.06.2006	v. 2.97 -

	 new data type: & that denotes direct byte address (ADMA).
	 minor updates

	01.04.2006	v. 2.96 -

	 improved the option jump to label
	 added an opportunity to call macros list of macros
	 added an option of replacement of mission numbers with their names
	 fixed some bugs

v 2.9f -

 model names is added to the DEFINE OBJECT list by the compiler (this list may be not presented in the source file at all)
 block comments support {}
 macrorecording
 minor changes

		 v 2.9 -

 5.11.05 - some bugs fixed, update
	 additional commands (see by item 2.5) are added
	 operator IN is added
	 construction IF..THEN..ELSE..END is added
	 loops WHILE, REPEAT are added
	 the opportunity of use of the enclosed loops is added.
	 function alloc() is added, allowing to specify for a variable the specific address in memory
	 new comment style: //
	 positions of markers and the cursor are remembered for the closed files
	 

	05.11.2005	release #8	v. 2.6 -

	  full support of formats of Vice City and GTA3 is added
	  the opportunity of initialization of variables and files as members of a class is added
	  display of the list of variables and labels is added
	 
-  support of loops (FOR operator) is added
	 
-  minor changes:
	  
-  missions can be started on their name (start_mission MYMISSION), where
	     MYMISSION is a name of a starting label (DEFINE MISSION 100 at @MYMISSION)
	 
-  the list of imported models (defined objects) on Ctrl+Space is accessible
	 
-  the new pseudo-operator <>
	 
-  if at decompiling it is not found script.img, it is used original
	  
-  for arrays the type handle is added
	 
-  an opportunity of switching-off of the warning of use IMG by game

	10.10.2005	release #7	v. 2.5 -

	
-  added "properties" support
	
-  added macroes support
	
-  added construction VAR...END for variables management
	
-  all math commands can be used without opcodes [0004..008B]
	
-  new pseudo operators 

	18.09.2005	release #6	v. 2.0 -

	
-  added classes support
	
-  added keywords support
	
-  added a capability to write some math commands without 
	opcodes (now such capability exists for opcodes 0004,0005,0006,0007,0038,0039,0042,0043)
	
-  for opcode 00D6 the default parameter is 0 (if = if 0)
	
-  added the option of a choice of various kinds of labels (Formats-> Labels Format)
	
-  added keywords True and False which designate 1 and 0 accordingly
	
-  added construction HEX...END for writing hexadecimal values directly in SCM

	07.09.2005	release #5	v. 1.1 -

	
-  added coords manager
	
-  some bugs fixed

	04.08.2005	release #4	v. 1.0 -

	
-  new format of labels
	
-  added convertor from BW''s SA Mission Builder syntax
	
-  at decompiling names of models and texts from american.gxt are added in source
	
-  added new options
	
-  some bugs fixed

	20.08.2005 	 release #3	v. 0.8 -

	
-  added the capability to associate SCM-files with the program
	
-  after decompilling the outputfile name now changes if file with
	such name already exists. E.g, if already exists main.scm.txt, the 
	new file will be main.scm[0].txt 
	
-  error messages becames more informative
	
-  added check of label redeclaring
	
-  some bugs fixed

	10.08.2005 	 release #2	v. 0.7 -

	
-  added new options for text manipulation
	
-  added a capability to work with several files simultaneously
	
-  added a opcodes search function through F1 (beta)

	04.08.2005 	 release #1	v. 0.6 -

	
-  full decompiling of GTA SA *.scm-files
	
-  compilation source in the SA SCM-file and IMG-file.
	
-  minimum options of text manipulation