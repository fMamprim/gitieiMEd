Loop statements
          
      
        
        
          
          

   Sanny Builder has three kinds of controls loops: 

	Repeat, While, For statements.

	[ FOR..END](#FOR..END)
	[ WHILE..END](#WHILE..END)
	[ REPEAT..UNTIL](#REPEAT..UNTIL)

   Loops can be nested (i.e. one loop inside another).

   

	
	Do not forget to use the delay (wait) in the loops!

		**FOR..END statement**

   This operator sets the loop with a strictly certain number of iterations.

	The following syntax is used:

FOR <counter> = <initial value> TO/DOWNTO <final value> [step <int> = 1]

...

END

**<counter>** - variable that is used as the loop iterations (repeats) 
	counter.

	

    **<initial value>** - starting value of the counter (any value 
    including the model identifiers).

  **TO/DOWNTO **- at **TO** the counter is increased, at **DOWNTO** - is decreased.

  

   **<final value>** - - final value of the loop when finished.

    (any value including the model identifiers).

   **<step>** - value of an increment or reduction of the counter after iteration.

	(optional). By default its value is equal to 1.

	Example:

var
$value: int = 0
$final: int = 100
end

FOR $MyCounter = 1 to $final step 2
$value += $mycounter
end

		**WHILE..END operator**

Syntax:

	WHILE <condition>

	 ...

	 END

Loop WHILE is working until the condition returns True. The condition is 
	evaluated before the loop iterations. Hence, if the condition is false, 
	the statement sequence is never executed.

$var = 10

while $var > 11
inc($var)
end

As the condition is false, the command Inc($var) will be never executed

while not #AK47.Available
wait 0
end

  Operator WHILE may accept the logic constants True and False:

	While True..End - loop executes infinitely until the 
	loop stopped by command Break.

	

	While False .. End - loop is ignored by the compiler.

	In the current version the only condition is accessible within the loop but you can check out more conditions inside loop  statement and use the commands Break and Continue.

		**REPEAT..UNTIL statement**

Syntax:

	REPEAT
 
	 ...

	 UNTIL <condition>

   This loop executes until the condition returns False. 

	The condition is evaluated after iterations therefore loop has 
	one iteration minimum.

	Operator Repeat can accept the logic constants True and False:

	Repeat .. Until True - loop has the only iteration

	Repeat .. Until False - loop executes infinitely until it's 
	stopped by Break.

	In the current version, the only condition is  accessible within the loop but you can check out more conditions inside  loop statement and use the commands Break and Continue.

		**Continue and Break**

  If you want to skip the current iteration and  proceed to the next, 
	use the command Continue. 

	

	It can be used as the parameter (jf continue) or separate command.

if
$currentactor.dead
jf continue // uses instead of a label

if
not $currentactor.dead
then
Continue // uses as a jump to the next iteration
The useful command, Break, causes the  flow of loop to exit.  It can be used  both as a separate command or parameter (jf break).