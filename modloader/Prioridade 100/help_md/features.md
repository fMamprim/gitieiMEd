Features
          
      
        
        
          
          

Sanny Builder IDE grants the end-user the  following possibilities:

		
		 

     ** Syntax Highlighting ** 

You may highlight the parameters of opcodes, comments and keywords.  Words that can be highlighted are defined in the file; 'keywords.ini'. They are highlighted as the keywords.

		** Fast Movement Through Code **

Sanny offers you two ways of accomplishing this. First, you can bookmark the line by pressing Ctrl +  Shift + <0..9> and then to pass to this one by pressing Ctrl +  <0..9>.  To delete all bookmarks, use option Edit -> Clear All Bookmarks.  The second method is via an option 'Go To Line'.  It is invoked by pressing Ctrl + G.  Enter a sequence number of the necessary line  and the editor will move the cursor to it.

		**Jump To Label **

    Place the  cursor on any label, for example @MyLabel. 
	Press Ctrl + Num2 and the editor will move the cursor to the line 
	with this label (:MyLabel). To go back press Ctrl + Num8.

	You can also locate jumps to the needed  label.  Place  the cursor on the label then press Ctrl + Num4 to go to the line above where this label is present.  Alternatively, press Ctrl + Num6  to go to the line below.  If there are no such lines, the cursor position will not change.

		

**Displaying  Different Opcode Information** ** **

		

    SB displays a needed parameters number, a digital value of the 
	model under the cursor in the statusbar when the option 'Show opcode 
	info' is enabled.

		**SAMB Source Code Converter **

Sanny supports SAMB 0.33 syntax.  **To use the converter**, open the source file in Sanny Builder and select menu  item: 'Tools -> Code converter -> MB -> SB'.   Note the convertor uses the file 'MB.ini' from  the SB directory which contains the variables used by SAMB and their  memory addresses.  If you added your own  variables in the file variables.ini (from the SAMB 0.33), copy them into the file MB.ini. 

		**Opcode search **

	
	Type search terms that the needed opcode may contain (for example, 'fade') and press F1.  The line will be changed to the first line from file 'opcodes.txt' containing this word (0169: set_fade_color 0 0 0).  If you need another opcode with this word, press F1 again.  The chars '_' and '.' between words are ignored.  If you want to find words with these symbols press Ctrl + F1.  If you type '_thread' and press Ctrl + F1 the line with '_thread' will be found instead of 'thread'.  ([See clause 4 for more info](opcode_search.htm))

		**Player Coordinates Management **

Press F4 when SA is running and the  Coords Manager window will appear.  Here, you can set new player coords and copy the  current ones.  In the upper edit line, you can input  all three coordinates XYZ, delimited by a single space or ",".  Additionally,  you can insert CJ's  current coords in the text by pressing Ctrl + Shift + C. To insert the player's  angle, press Ctrl + Shift  + E.

		** Macroes Support**
        

The macros is the group of lines that are inserted in the editor when you type a special word and press F2.  All macros are  contained in the file 'macroes.txt'.  To  call the macros list,  press [Ctrl + J](hotkeys.htm#Ctrl + J)

	

Macros syntax (in macroes.txt):

The name of a macros (special word) is written as a  simple line.  In that line, you can also add a  short description of the macros. 

Additionally, it's possible to add the macros to  the file 'macroes.txt' directly from the editor.  For this purpose,  select the necessary piece of code (text) and choose "Service -> Add macros".  Then, input  the name of your new macros (description optional) and press OK.  The new macros is  ready to use now.

Each line of the macros is designated by the  symbol =.  The cursor position is  designated by symbol |.

**Macrorecorder**

You can record your key pressing sequence  (macros).   Example code:

$Actor = Actor.Create(CivMale, #MALE01, 100.0, 100.0, 10.0)

$ActorWithGun = Actor.Create(CivMale, #MALE01, 110.0, 100.0, 20.0)

$Gang01 = Actor.Create(CivMale, #MALE01, 120.0, 100.0, 30.0)

$Gang02 = Actor.Create(CivMale, #MALE01, 130.0, 100.0, 40.0)

$Killer = Actor.Create(CivMale, #MALE01, 140.0, 100.0, 50.0)

$ActorWithoutGun = Actor.Create(CivMale, #MALE01, 150.0, 100.0, 60.0) 

Say you need to exchange the actor's  handles in each pair

	(i.e to put $ActorWithGun instead of $Actor)

	

	Place the cursor on the first line and press [Ctrl + M](hotkeys.htm#Ctrl + M).	Immediately, the editor begins logging all keystrokes  - so be careful! 

	- Press and hold [Ctrl] and press once  [Right arrow]

	- Now press [Shift] + [Home] and [Ctrl] + [Ins].
 
	- Press [Down arrow]. The cursor must be on the second line with the global variable  on the clipboard

	- Press [Ctrl] + [Right arrow] and [Shift] + [Ins].

	- Press [Ctrl] + [Left arrow], [Shift] + [Home], [Ctrl] + [Ins] and [Delete]

	- Press [Up arrow]

	- Press [Ctrl] + [Shift] + [Right arrow] and [Shift] + [Ins]

	- Press [Home] button.

	Now the first two lines look like:

 $ActorWithGun = Actor.Create(CivMale, 100.0, 100.0, 10.0)

  $Actor = Actor.Create(CivMale, 110.0, 100.0, 20.0)

and cursor is in the beginning of the first line. Now press Ctrl + M. 

	The macros is recorded. Now you can repeat the recorded keystrokes by 
	pressing Ctrl + P. Put the cursor on the third line, press [Ctrl + P](hotkeys.htm#Ctrl + P)	and the actors handles will be exchanged.

	

	While processing, you can pause the  recording by pressing Ctrl + P.  To continue,  Ctrl + P again.

		

**Replacing  Mission Numbers With Their Names** ** **

		

Sanny Builder can use the mission name  instead of its number.  The mission name  is the label that is defined by DEFINE MISSION.   For example, if you have: 

	DEFINE MISSION 10 AT @MYMISSION
	

Instead of: 

    
	start_mission 10
    

You can use:

	start_mission MYMISSION

In SB, there is also the option:  Replace Mission Numbers.  When it's enabled, the decompiler automatically replaces  all mission numbers.  The compiler  supports both of the variants.

  

To call the mission names list, press Ctrl + Space.  The cursor has to be directly after command  start_mission.

Additionally, you can jump from the mission name  to the mission.  It's  the same as [Jump To Label](#jumpLabel)

		** Multilingual Interface **

Now available - both in the windows texts and the  engine messages.  You  can switch languages via options (F10).   File 'lang\How to translate.txt' contains more information about creating your own translation.

		** All-in-One Editor **

Sanny Builder offers various modes to edit the  scripts of GTA III, GTA VC, GTA SA.   The current edit mode in use is always displayed in the bottom right corner.  To switch to  another edit mode, use  the context menu displayed on-click by  the current mode name.

		**External Tools/Plug-ins Menu**
		

You can add up to 9 tools which can be executed whenever you need them.  Every tool has its  own hotkey for your convenience.  You may also pass  parameters to your tool. As the command line  parameter of the tool, you can specify special  word $SB_FileName.  It references the name of the current open file.

		

**Code Commenting** ****

		

Comments are denoted by a  double slash //, as seen in other scripting languages  (php etc.).  All text placed after // (within that same line) will be  ignored by the compiler.  You can comment  out multiple lines at once by selecting them and pressing Ctrl + Q - repeat to  undo at any time.

          

To comment out multiple lines or part of the line,  use block comments {}:

	0001: wait  {comments here} 0 ms

   Also it is possible to comment out the several lines by selecting them 
	and pressing Ctrl+Q. To uncommenting the code repeat it once again. 

		**Custom Labels**
		

You can give labels custom names that are  not dependent on  decompiler options.  The names are  specified in the file CustomLabels.ini (separately  for each game). File syntax reference:

<label address>=<custom name>

If the decompiler finds the label at the specified address,  it will get the custom name.

  

To find out the label address toggle the label format "Global Offset."   After decompiling, the number in a label  name will become its offset.