HEX..END
          
      
        
        
          
          

Sanny supports writing hex values directly in  the SCM file*

	For example:

hex
04 00 02 0800 04 01
end

	It will be compiled as 0004: $2 = 1

	

	This construct can accept labels and global variables.

They will be compiled as numbers (their hex representation as after a compilation) without the  data type.

:get_offset
hex
04 00 02 $PLAYER_CHAR 01 @get_offset
end

     It will be compiled as 0004: $PLAYER_CHAR = @get_offset

    Also you can use the aDMA data type within this statement. It's very
    handy when you need to write the numbers.

    The number after the & sign  can  be both positive and negative;

    in decimal format or in hexadimal one.

hex
&1000 &-0xA33500 
end

Also you can compile the strings using this statement. In order to do this enclose the word with double quotes and write a single space before and after them.

Example

hex
09 "Word1" 20 "Word2"
end
The only word is allowed to enclose.  To compile the phrase  (a number of words) enclose each word separately and put a single space between  them.  To compile  a space char, write the number 20 (ascii code of space char).
 
* Recommended for advanced users only.   Any mistakes will make the file incapable of  being decompiled &/or render it unreadable by the game.