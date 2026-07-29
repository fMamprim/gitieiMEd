CLEO 3 Code Library 
          
      
        
        
          
          
	  
CLEO 3 

What is CLEO 3? -------

CLEO 3 is the next step in the CLEO project development that extends coding possibilities in San Andreas. After installing CLEO 3, you get everything that CLEO 2 can, plus some new features.

  

1. [New opcodes](Cleo_OP.htm).

CLEO 3 has 40 useful  opcodes in store, such as file management, game memory handling, ability to  call exe functions and much more. The third version [adds such opcodes](Cleo_OP.htm) as a call of a SCM function, creating a thread or starting a mission  from an external file and more.

2. [Plugins](#PLUGIN).

Read more about them below.

3.** **[Custom scripts](Cleo_SCRIPT.htm).

CLEO 3 allows adding the  custom scripts to the game written in Sanny Builder without need for starting  of a new game. All you need is to write a script, place it in the CLEO folder  and run the game (new or saved). 

What game versions are supported? -------

CLEO 3 supports SA  versions 1.0 and 1.01. It was tested with the US 1.0 and EUR 1.01 versions. If you have another version, please, let me  know if CLEO 3 works or does not for you.

 
How to install CLEO 3? -------

 To install CLEO 3 run Sanny  Builder 3. You will see word CLEO in the status bar outlined in red. Click it,  read the license agreement and press the button Install.

Physically, CLEO 3 uses 3 files in work: vorbisFile.dll,  vorbishooked.dll, cleo.asi.  You always can find latest versions of these files on the  website [cleo.sannybuilder.com](http://cleo.sannybuilder.com/" target="_blank).

If you used CLEO 2 or CLEO 1, delete it manually to avoid conflicts with  new version. If you used the cleo.asi of version 2, replace it with the new  one. If you used the cleo.dll running from the main.scm, you must delete the cleo.dll  and remove its loading code from the main.scm.

The libraries CLEO 2 and CLEO 3 are fully compatible. All mods/plugins  written for CLEO 2 should work with the new version.

Should I  change my SASCM.INI? -------

Sanny Builder 3 has the files SASCM.INI and  OPCODES.TXT already up to date. Future updates of the CLEO library may require  some changes of these files. You will get all instructions along with the  updates on [cleo.sannybuilder.com](http://cleo.sannybuilder.com/" target="_blank).

What about plugins? -------

The plugins are the DLL  files having an extension .CLEO. At startup, the CLEO library scans the folder  GTASA\CLEO for the files with that extension and tries to load them. If  successful, the plugin begins to work and complete the functions it was made  for.

The plugin installation is  very simple: just copy the plugin file to the folder GTASA\CLEO. TO cancel the  plugin usage, delete proper file.

You may find the list of available plugins on [cleo.sannybuilder.com](http://cleo.sannybuilder.com/" target="_blank).

Is CLEO 3 redistributable? -------

If you wrote a script  using the CLEO library and (or) its plugins, you may distribute needed files  along with that script. You also may direct the script users on [cleo.sannybuilder.com](http://cleo.sannybuilder.com/" target="_blank) to inform them how to use CLEO.

Credits? -------

The  author of the CLEO library is [Seemann](http://www.gtaforums.com/index.php?showuser=49411" target="_blank). The author has no liability for any negative  consequences caused by using this product. Use it at your own risk.

  

If  you want to help in developing of the library or its plugins, contact me by  forum or e-mail.

Also thanks to [Stanislav Golovin (aka listener)](http://www.gtaforums.com/index.php?showuser=236130" target="_blank) for his support and useful information.