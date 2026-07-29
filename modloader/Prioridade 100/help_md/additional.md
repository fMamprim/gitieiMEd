Additional commands
          
      
        
        
          
          

   **INC** 

 Increments the first parameter by the second one.  First parameter is a variable.

Inc($IntVariable, $Value)
=
$IntVariable += $Value

Inc(1@)
=
1@ += 1

   **DEC** 

 Decreases the first parameter by the second one.  First parameter is a variable.

Dec($IntVariable, $Value)
=
$IntVariable -= $Value

Second parameter is equal to 1 if isn't  specified.

Dec(1@)
=
1@ -= 1

	**MUL** 

	Multiplies the first parameter by the second one.  First parameter is a variable.

Mul($IntVariable, $Value)
=
$IntVariable = $IntVariable * $Value
Second parameter is equal to 2 if isn't  specified.

Mul(1@)
=
1@ = 1@ * 2

**DIV**

Divides the first parameter by the second one.  First parameter is a variable.

Div($IntVariable, $Value)
=
$IntVariable = $IntVariable / $Value
Second parameter is equal to 2 if isn't  specified. 

Div(1@)
=
1@ = 1@ / 2

  **(internal) ALLOC*** 

This  function sets the memory address for the global variable.  It has to be used only for the ones with  custom names (i.e. $text).  For others, the memory address is set by name: the  variable $40 is always addressed at memory address #40.

Alloc($MyVar, 40) - the variable $MyVar will be compiled as $40

(!) See also 'help\examples\alloc.txt'

**SQR** 

Calculates the square of a variable passed as a parameter*.  It can be used as procedure only.

sqr($var) 
=
$var *= $var

* variable type has to be defined. See item: [ (The multilingual interface)](features.htm#The multilingual interface)

**RANDOM** 

  This  function generates a random number within a range specified by the parameters. 

$rnd = random(1, $high)
This function can be used for both  integers and floats.  The opcode  is chosen in accordance with the type of a  result variable 
($rnd in this case)