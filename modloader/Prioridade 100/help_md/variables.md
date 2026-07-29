Variables
          
      
        
        
          
          

Variables (vars) maintain values and read/rewrite many times.  There are a number of variable types:

	- Global variables. They are denoted by a $ (dollar sign, before an identifier).
 
	Their values are available from any place of a code.

	- Local variables. They are denoted by a @ (AT sign, after an identifier).

	Their values are available only within the current thread.  

	Each thread (external scripts are threads too) has its own  
	local variables set (0@..33@ in SA, 0@..17@ in GTA3,VC).

	

	SA missions have a bigger set than usual. SA missions uses locals in range 
	of 0@..1023@

	

	
	The variables can be used as expression operands.  Sanny Builder allows usage of no opcode for the 
expressions where one of the operands is a number constant.  For ex.

$var = 0

$myarray($index, 10i) >= 150 

If both operands are  variables, the compiler can not detect what the  opcode is needed for because the vars may be either an integer or float.  In order to define a variable type, there is a  specific contruct.

  

  VAR..END contruct allows to declare variables and their types for advanced use.

	For example, write the following code:

var
$1stIntVar : Integer
$2ndIntVar : Integer
end

and you can use these variables in the expressions without opcodes

$1stIntVar = $2ndIntVar
$1stIntVar *= $2ndIntVar

and so on.

	The following types are supported:

Integer, Int  - integer values

	Float  - floating-points values

	String, ShortString  - fixed length string variable

	

	(only for the arrays, use s$, @s for the variables)

	

	LongString  - Variable length string variable

	(only for the arrays, use v$, @v for the variables)

A local variable can be declared. Take note that one  will have the same type in every thread.

So, you can redeclare this local variable to set a new type for it:

Thread 'Food'
Var
10@ : Float
$Var : Float
End
$var = 1
10@ = $Var
end_thread

Thread 'Loop'
Var
10@ : Int
$Var : Int
End
$var = 1
10@ = $Var
end_thread

In the thread Food 10@ is the floating-point  variable.

Loop 10@ is the integer variable.

	You can redeclare any variables as many times as you need.

	Also you can set an initial value for the variable when declaring it.

	For this purpose write symbol = and after that,  the initial value:

var
$fVar: float = 1.0
end

Variable $fVar will be remembered as Float and also the compiler will write an opcode in the SCM.

0005: $fVar = 1.0

Initialization is allowed for the variables only.