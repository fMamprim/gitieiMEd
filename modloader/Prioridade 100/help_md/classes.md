Classes
          
      
        
        
          
          **Basic Concepts**

Sanny Builder allows you to use classes in the  code.  Class is a group of opcodes applied to in-game objects: player,  actor, object, etc.

   Each class has a set of commands (class members). They can be split
	into the following groups:

	 conditional opcodes
	regular opcodes (methods)
	properties

**
		Conditional Commands**

Conditional commands are marked with the word 'Check' in the resizable 
	window that is displayed when you press Ctrl+Space. Many of these have only the parameter:  the class owner handle (name).

	Example:

if
Player.Defined($PLAYER_CHAR)
jf @anywhere

  Player - class name

	Defined - class member

	$PLAYER_CHAR - class owner

		**	Regular Commands (methods)**
        

Regular (procedural) commands are used to complete  a single in-game action: move an object, destroy this one and so on.  A special kind of these commands is the  constructor that creates an object (an actor, a car) and stores its handle to a  variable.

 
	In SB the constructor can be used either as method or property:

Player.Create($PLAYER_CHAR, #NULL, 2488.5601, -1666.84, 13.38) - procedure
$PLAYER_CHAR = Player.Create(#NULL, 2488.5601, -1666.84, 13.38) - constructor
These create the same effect.

		**Properties**

Property allows you to read/write values to the class fields.

	Example: 

	Property 'Money' of the class 'Player' allows to operate with the
	following opcodes:

0109: player $PLAYER_CHAR money += 1000000
010A:   player $PLAYER_CHAR money > 461@
010B: 4@ = player $PLAYER_CHAR money

   With the property you can use the following commands without any opcodes:

player($PLAYER_CHAR).Money += 1000000
player($PLAYER_CHAR).Money > 461@
4@ = player($PLAYER_CHAR).Money

Note: that you make DIFFERENT actions using the ONLY command.

		**Class Members**
        

There is a possibility of initializing the variables  as class members to use them instead of class names.

          

Example:

var
$PLAYER_CHAR: Player
end

It declares the variable $PLAYER_CHAR as member of the class 'Player'. 

	So, the variable can be used instead of the class name Player:

if
$PLAYER_CHAR.Defined
jf @anywhere
Pay attention that such variables are compiled as the first parameter and therefore, do not duplicate them.

Player.SetClothes($PLAYER_CHAR, "PLAYER_FACE", "HEAD", Head)
=
$PLAYER_CHAR.SetClothes("PLAYER_FACE", "HEAD", Head))

   These variables can be redeclared with another type.

		**'Model' Class**
        

The model identifiers are always the members of the 'Model' class. 

You can reference this class using their names:

#AK47.Load
  
:loop
wait 0
if
#AK47.Available
jf @loop 
	It is the same as:

Model.Load(#AK47)

:loop
wait 0
if

Model.Available(#AK47)
jf @loop

		**Extended Parameters (class constants)**
        Some classes use parameters with special  names.  This possibility makes the source  code more readable.

	
	Example:

 

Player.SetClothes($PLAYER_CHAR, "VEST", "VEST", Torso)
Last parameter (Torso) is the class constant that will be  replaced with  the number 0 at compilation.

  These parameters are defined in the file 'classes.db'.

  

For convenience, a list of extended parameters are displayed when you press  Ctrl+Space.  Simply place the cursor where there  should be an extended parameter,   press ctrl+space and the parameters list will be displayed. 

You can then select a name from it and insert this into your code.