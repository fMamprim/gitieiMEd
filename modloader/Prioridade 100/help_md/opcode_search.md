Opcode Search Tool
          
      
        
        
          
          

You can call this function  by pressing Ctrl + Alt +  2 or by selecting the menu item: Tools -> IDE  Tools -> Opcode Search.

  

To find the needed opcode, type your search term(s) in the top field. For example: actor car. The tool displays  opcodes that contain these words. You may also use  the special search operators.

When OST is called, it checks if there is a  selected word in the editor. If the selected word is found, it will be pasted into the search field. 

    

**Copying**

  

  After you've found the needed opcode, select it in the  list and press ENTER. Now your selected opcode will be copied onto your clipboard.  If you want to copy another opcode, press  SHIFT + ENTER.  The opcode will be ADDED to your clipboard  content. F2 copies  all opcodes from the results list.

**Hotkeys**

 
   
     ENTER 
     copy selected opcode onto clipboard 
   
   
     SHIFT + ENTER 
     add selected opcode to the clipboard 
   
   
     SCROLL LOCK 
     switch on/off search (when param "extra_search" (in settings.ini) is equal to 1) 
   
   
     F1
     call help
   
   
     F2
     copy all opcodes from the results list onto the clipboard 
   
   
     F3
     sort the list by opcodes 
   
   
     F4
     sort the list alphabetically 
   
   
     F11
     clean up the search    edit, show all opcodes 
   
   
     ESC
     close window 
   
  

   
**Search Operators:**

 
       

    		**LOGIC**
    
    

    
    	AND operator 

        

    
    In the program this function is carried out with a SINGLE SPACE between the words. 

    
	Example: @ player

    
     will show opcodes that have both symbol '@' and word 'player'

  

  

    

    
    	OR operator 

        

    
     In the program this function is carried out with a symbol | between the words. 

    
  Example: @ | player

    
    will show opcodes that have EITHER symbol '@' OR word 'player'

   
    If you write | as the FIRST char in the line, the program will connect all words
    by operator OR.

    	Example: | actor player car

    
      will show opcodes that have EVEN ONE of these words.

  

   
 
    	 NOT operator (NOT)

         

    
     For all cases it is carried out with two minuses before of an excluded word

    
    		 Example: car --car2

    
     will show opcodes that HAVE a word 'car' AND HAVE NO word 'car2'

     For words and symbols '$' and  '@' it is possible to use one minus. This is to avoid mixing the exclusion during a search of negative  numbers:

  
    		Example: -10 -@ -car -3

  will show opcodes that have a number -10, NO symbol '@', word  'car' and number '3'

  

    
    
**
    
    		OTHER OPERATORS 
    
**

  
    ^
    shows all conditions in the list
  
  
    ^word
    finds the word in the conditional opcodes
  

    		 Example: ^car ==    

    will show conditional opcodes that have a word 'car' and a sign '=='

    
  
    -^
    excludes all conditions from the list
  

    
    
    	  

    		Example: player -^  

      will show all  non-conditional opcodes that have a word 'player'

    

    
      
        -^word
        to exclude the conditions containing the word 
      
    
    

    	
    		Example: player -^actor
    	

    
    will show all opcodes that have a word 'player', except the 
    conditional opcodes with a word 'actor'.

    

      
          %
        searches in the given order 
      
    
    

    	

    		Example: % @ = @

    
    will show all opcodes where these symbols go in the given order.