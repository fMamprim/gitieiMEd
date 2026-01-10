SCRIPT_START
{
    LVAR_INT pFindEnexName bOnlyExterior iIcon bDebugForceEnexAccess bIsDateIcon lDateIcons pEnexEnd
    LVAR_INT i offset pEnex pEnexPool pEnexArray hCleoBlip iFlags iStringLen 
    LVAR_INT pX
    LVAR_FLOAT x y z f
    
    WAIT 0
    WAIT 0

    READ_MEMORY 0x96A7D8 4 FALSE (pEnexPool)
    READ_STRUCT_OFFSET pEnexPool 0x0 4 (pEnexArray)
    READ_STRUCT_OFFSET pEnexPool 0x8 4 (i) //enex count

    i -= 1 // otherwise may crash (original game bug?)

    pEnexEnd = i * 0x3C //size of CEntryExit
    pEnexEnd += pEnexArray

    // this loop is slow, keep it optimized
    pEnex = pEnexArray
    WHILE pEnex < pEnexEnd
        pEnex += 0x3C //size of
        
        GET_STRING_LENGTH $pEnex (iStringLen)

        IF iStringLen >= 6 //all strings are >=6 chars and this loop runs hundreds of times, so use this value for better performance

            IF IS_STRING_EQUAL $pEnex "FDREST1" 8 TRUE "" // name is +0x0

                READ_STRUCT_OFFSET_MULTI pEnex 0x8 2 4 (x y)
                //READ_STRUCT_OFFSET pEnex 0x18 4 (z)
                i = pEnex + 0x18
                READ_MEMORY i 4 FALSE (z)
                
                GET_DISTANCE_BETWEEN_COORDS_3D x y z 452.89 -18.1797 1000.18 (f)
                IF f < 10.0 // don't use small numbers, this isn't the center of enex
                
                    //WRITE_STRUCT_OFFSET pEnex 0x33 1 0 //sky color
                    i = pEnex + 0x33
                    WRITE_MEMORY i 1 0 FALSE //sky color

                ENDIF
            ELSE
                IF IS_STRING_EQUAL $pEnex "AIRPOR2" 8 TRUE ""

                    READ_STRUCT_OFFSET_MULTI pEnex 0x8 2 4 (x y)
                    //READ_STRUCT_OFFSET pEnex 0x18 4 (z)
                    i = pEnex + 0x18
                    READ_MEMORY i 4 FALSE (z)
                    
                    GET_DISTANCE_BETWEEN_COORDS_3D x y z -1861.68 58.8643 1054.2 (f)
                    IF f < 10.0 // don't use small numbers, this isn't the center of enex

                        //WRITE_STRUCT_OFFSET pEnex 0x18 4 1000.0 //z
                        i = pEnex + 0x18
                        WRITE_MEMORY i 4 1000.0 FALSE //z

                    ENDIF
                ELSE
                    IF IS_STRING_EQUAL $pEnex "AMMUN1" 8 TRUE ""

                        READ_STRUCT_OFFSET_MULTI pEnex 0x8 2 4 (x y)
                        //READ_STRUCT_OFFSET pEnex 0x18 4 (z)
                        i = pEnex + 0x18
                        READ_MEMORY i 4 FALSE (z)
                        
                        GET_DISTANCE_BETWEEN_COORDS_3D x y z 1368.35 -1279.06 12.55 (f)
                        IF f < 10.0 // don't use small numbers, this isn't the center of enex

                            //WRITE_STRUCT_OFFSET pEnex 0x18 4 1.0 //z
                            i = pEnex + 0x18
                            WRITE_MEMORY i 4 1.0 FALSE //z

                        ENDIF
                    ENDIF
                ENDIF
            ENDIF

        ENDIF
        
    ENDWHILE
    
}
SCRIPT_END