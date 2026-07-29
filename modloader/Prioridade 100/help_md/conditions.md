Conditions
          
      
        
        
          
          

There is the operator IF to evaluate the condition.

	Two kinds of syntax of this statement are permitted: 

	[ low-level](#low-level)
	 [high-level.](#high-level)

	1. The following syntax is used:

	00d6: if <N>

	... <condition 1>

	... <condition 2>

	...

	... <condition n+1>

	004d: jump_if_false <label>

	**<N>** - the parameter means total number of conditions.

0 	 - 1 condition
	1..8	 - 2 and more conditions (9 max) connected by logic operator **AND**.
 
	The check return true if ALL conditions within this return true.

	21..28 	 - 2 and more conditions (9 max), connected by logic operator **OR**. 

	The check return true, if even ONE condition within this return true.

      **<label>** - a name of a label where script jumps if the check is false.

      

      Sanny Builder allows not to use parameter for single conditions.  (meaning, **if** is the same as **if 0**)

      

	Also you can use keywords **AND** or **OR** instead of the condition's number*.

	The compiler will calculate the necessary value itself.

	For example:

if and 
$var > 0
$var2 == 10.0
jf @anywhere

	The compiler will write number 1 instead of 'and'.

	* Option 'Conditions check' has to be enabled.

	**IF AND** - conditions connected with the logic operator AND (1..8)

	**IF OR** - conditions connected with the logic operator OR (21..28)

	2. Sanny Builder supports high-level constructions

	IF..THEN..END

	IF..THEN..ELSE..END*

	Condition is created by the rules described above.

	After the word THEN, you have to specify the command(-s) that are executed
	if the condition is true.
 
	After the word ELSE, you have to specify the command(-s) that are executed
	if the condition is false. 

	The IF statement is closed by word End.

if $var == 5

then
Inc($var)
else
Dec($var)
end

	* Option 'Conditions check' has to be enabled.

	** Nested IF statements are supported.

	

	You can use the following relational operators*:

	a == b   a is equal to b 

	a >= b  	 a is greater than or equal to b 

	a  > b   	 a is greater than b 

	a  < b   	 a is less than b 

	a <= b  	 a is less than or equal to b 

	a <> b   a is inequal to b

	*If there is no opcode in the line. Otherwise these sign will be
	ignores like any other words.