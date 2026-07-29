Constants
          
      
        
        
          
          
		 

A constant  is an identifier with a predefined value. As against a variable the value of the  constant cant be changed in run-time. At compilation the name of the constant is  replaced with the value set to it. The constants can be numeric (*numerals*) and string (*string literals*), and contain an  expression.

		 

To define  new constant use the construct **CONST..END**. It syntax looks like this:

		 CONST

		   <constant name> = <constant value>

END

The  constant name is any allowed identifier (letters, numbers and _). There are  reserved names that cant be used, as *Continue,  True, And* and so on. 

The  constant value may be a number (a model identifier, a label); a string; an  expression (for example class or variable); another constant.

Example:
    

const
MoneyRequired = 30
PlayerMoney = $PLAYER_CHAR.Money
end

if
PlayerMoney > MoneyRequired
then
PlayerMoney += -1
end
At  compilation the constant MoneyRequired will be replaced with a number 30 and  PlayerMoney with $PLAYER_CHAR.Money.

The  compiler also uses 2 internal constants True and False which values are equals  to 1 and 0 accordingly.

You can use  the constant elsewhere except the case:

const
VarName = $Var
IndexName = 25
end

VarName[IndexName] = 0

To comple  such expression you must write the opcode, for example:

0004: VarName[IndexName] = 0

Also there  are the limits with using of a complex expression as a constant.

The list of the constants could be called at any place  of the code by pressing Ctrl + [space].