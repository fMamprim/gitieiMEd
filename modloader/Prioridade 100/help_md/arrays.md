Arrays
          
      
        
        
          
          

An array represents an indexed collection of elements of the same 
	type (called the base type). You can work with any element directly 
	via its	index. An index numeration begins with a zero.

	These arrays are supported by SA and LCS, VCS.

	

	Syntax:

	San Andreas:

**<array name>(<index var name>,<size><type>)**

	Liberty City Stories, Vice City Stories:

**<array name>(<index var name>,<size>)**

**<array name>:** local or global variable.

**	
	<index var name>**: any variable containing an index value.

	

**
	<size>**: any value greater than 0.

	

**
	<type>**: chars i f s v denote one of the array types:

**
	i:** integer 4 bytes

**f:** float,  4 bytes

**s:** shortstring, 8 bytes

**v:** longstring, 16 bytes

In LCS, VCS, the array elements are only 4 bytes in length.  Therefore, there is no need for  declaring its type.

	An array could contain the elements of same type only.

	Example:

$index = 0
$array($index,10i) = 1
Sanny Builder can work with the arrays in  two easier ways:

	1) declare an array using VAR..END construct

	The following syntax is used:

	var

	 <array name>: array <size> of <type>

	 end

	

	e.g.:

var
$FloatArray: array 10 of Float
end
You can operate this array without specifying its type and size:

$FloatArray[$RndIndex] += 100.0
	2) use a constant number as an index

	For instance, you have the array $strings, containing 10 elements of 
	type s. You can use a constant number to work with the specified element:

s$strings[0] = 'str1'
s$strings[1] = 'str2'
	...
s$strings[9] = 'str10'
	These variables could be used as the class name when declared:

$players[0].Build
By default in SA mode, the array elements decompile with the number of indexes. You can turn this feature off through the [Console](console.htm) using the command
	toggle constant_indexes off. 
	The possibility of decompiling with the number of  indexes is allowed in LCS, VCS but is disabled by default.  You can enable this  through the Console.