Directives
          
      
        
        
          
          

Preprocessing directives are the special words that make the compiler function  in different ways.

They are denoted with the symbol $ and located between brackets {}.

	Directives list:

	 [$VERSION](#VERSION)
	 [$VERSION_RESTORE](#RESTORE_VERSION)
	 [$INCLUDE](#INCLUDE)
	 [$External](#External)
	 [$CLEO](#CLEO)

	1. **$VERSION**

 

This directive sets what version of the opcodes should be used at  compilation.  Now, the ini files contain only the  opcodes list.   Therefore, this directive is useless for  now.

Syntax:

	 $VERSION x.y.zzzz

	x - game ID. 

   1 - gta3; 

   2 - vc; 

   3 - sa;

   4 - lcs;

		y - parameters order.
 
   0 - original, numeric

   1 - custom order

	zzzz - opcodes version

By default the compiler uses the version
 
    	<current edit mode>.1.0000

	2. **$VERSION_RESTORE**

This directive sets the version to its previous value  prior to using $VERSION.  Now, the  ini files contain only  the opcodes list.  Therefore, this directive is useless for now.

  

The main purpose is to permit compiling pieces  of code written with different opcodes list versions simultaneously by nesting  them into the pair of the directives $VERSION..$VERSION_RESTORE.

	{$VERSION 3.1.0001}

	

	...	<code, written in version 0001>	....

	{$VERSION 3.1.0000}

	...	<code, written in version 0000>	....

	{$VERSION_RESTORE} // restore version 0001

	...	<the rest of code, written in version 0001>	....

	2. **$INCLUDE**

This directive allows to insert the external text  files in the source file. When the compiler find this directive it opens the  file by the path passing as the directives parameter and continues a  compilation from the code written in the included file. When it reaches the end  of the file it returns back to the previous file. 

Syntax:

{$INCLUDE file_path}

or

{$I file_path}

Example,

{$I loadwav.txt}

or

{$I C:\dev\getarrayindex.txt}

If the file path is relative  the compiler searches the file in the following order

  

1. the folder, where the file contained the directive is located 

2. Sanny Builder\data\<game>

3. Sanny Builder root folder

4. game root folder

	

It any of these folders  contains no such a file the compiler throws an exception.

  You can use this directive unlimited number of times. The included files  can contain this directive as well. 

3. **$EXTERNAL**

This directive makes the compiler to process the file like external script. Meaning, the outputfile will be without header and with local label offsets, so it will be the same as an .scm file from the script.img. Using this directive requires that the file will contain only one thread (also without missions and other scripts).

The alternative way to get such file is debug option [SKIP_SCM_HEADER](console.htm#SKIP_SCM). This option could be enabled via console or from the list on the main panel.

The short variant of this directive is $E.

Syntax:

{$EXTERNAL}

or

 

{$E}

 

$CLEO

This directive is an  analogue of the $E one, but the output file is copied into the game\CLEO  directory automatically. It also has a specified file extension.

Syntax:

{$CLEO 
 <file extension>}

Example

{$CLEO .cm}

 or

{$CLEO} // a file will get the default extension .cs

So this directive is  perfect solution to write a [CLEO script](Cleo_SCRIPT.htm) quickly.