#include "stdafx.h"
//include CLEO header
#include "CLEO.h"


//initial opcodes
#define OPCODE_INIFILE_GET_INT		0x0AF0
#define OPCODE_INIFILE_WRITE_INT	0x0AF1  
#define OPCODE_INIFILE_GET_FLOAT	0x0AF2  
#define	OPCODE_INIFILE_WRITE_FLOAT	0x0AF3 
#define	OPCODE_INIFILE_READ_STRING	0x0AF4 
#define	OPCODE_INIFILE_WRITE_STRING	0x0AF5


//declare opcode callbacks
OpcodeResult WINAPI Script_InifileGetInt(CScriptThread* thread);
OpcodeResult WINAPI Script_InifileWriteInt(CScriptThread* thread);
OpcodeResult WINAPI Script_InifileGetFloat(CScriptThread* thread);
OpcodeResult WINAPI Script_InifileWriteFloat(CScriptThread* thread);
OpcodeResult WINAPI Script_InifileReadString(CScriptThread* thread);
OpcodeResult WINAPI Script_InifileWriteString(CScriptThread* thread);

BOOL InitOpcodes()
{
	BOOL result = FALSE;

	//check cleo version
	if (CLEO_GetVersion() < CLEO_VERSION)
	{	
		MessageBox(HWND_DESKTOP, "An incorrect version of CLEO was loaded.", "IniFiles.cleo", MB_ICONERROR);
		return FALSE;
	}

	//register opcodes
	if (CLEO_RegisterOpcode(OPCODE_INIFILE_GET_INT, &Script_InifileGetInt)) 
		result = TRUE;

	if (CLEO_RegisterOpcode(OPCODE_INIFILE_WRITE_INT, &Script_InifileWriteInt)) 
		result = TRUE;

	if (CLEO_RegisterOpcode(OPCODE_INIFILE_GET_FLOAT, &Script_InifileGetFloat)) 
		result = TRUE;

	if (CLEO_RegisterOpcode(OPCODE_INIFILE_WRITE_FLOAT, &Script_InifileWriteFloat)) 
		result = TRUE;

	if (CLEO_RegisterOpcode(OPCODE_INIFILE_READ_STRING, &Script_InifileReadString)) 
		result = TRUE;

	if (CLEO_RegisterOpcode(OPCODE_INIFILE_WRITE_STRING, &Script_InifileWriteString)) 
		result = TRUE;

	return result;
}

char* MakeFullPath(char *path, char *dst)
{
	if (path[1] != ':')
	{
		//get current working directory
		GetCurrentDirectory(MAX_PATH, dst);
		strcat(dst, "\\");
		strcat(dst, path);
	}
	else
	{
		strcpy(dst, path);
	}
	return dst;
}

OpcodeResult WINAPI Script_InifileGetInt(CScriptThread* thread)
/****************************************************************
						Opcode Format
0AF0=4,%4d% = get_int_from_ini_file %1s% section %2s% key %3s%
****************************************************************/
{
	char iniPath[MAX_PATH];
	char path[100];
	char sectionName[100];
	char key[100];
	int result;

	CLEO_ReadStringOpcodeParam(thread, path, sizeof(path));
	CLEO_ReadStringOpcodeParam(thread, sectionName, sizeof(sectionName));
	CLEO_ReadStringOpcodeParam(thread, key, sizeof(key));

	//if path is short, GetPrivateProfileInt() searches for the file in the Windows directory
	MakeFullPath(path, iniPath);

	result = GetPrivateProfileInt(sectionName, key, 0x80000000, iniPath);
	CLEO_SetIntOpcodeParam(thread, result);
	CLEO_SetThreadCondResult(thread, result != 0x80000000);

	return OR_CONTINUE;
}

OpcodeResult WINAPI Script_InifileWriteInt(CScriptThread* thread)
/****************************************************************
						Opcode Format
0AF1=4,write_int %1d% to_ini_file %2s% section %3s% key %4s%
****************************************************************/
{
	char iniPath[MAX_PATH];
	char path[100];
	char sectionName[100];
	char key[100];
	DWORD value;
	char strValue[100];
	BOOL result;

	value = CLEO_GetIntOpcodeParam(thread);
	CLEO_ReadStringOpcodeParam(thread, path, sizeof(path));
	CLEO_ReadStringOpcodeParam(thread, sectionName, sizeof(sectionName));
	CLEO_ReadStringOpcodeParam(thread, key, sizeof(key));

	//if path is short, WritePrivateProfileString() searches for the file in the Windows directory
	MakeFullPath(path, iniPath);

	result = WritePrivateProfileString(sectionName, key, _itoa(value, strValue, 10), iniPath);
	CLEO_SetThreadCondResult(thread, result);

	return OR_CONTINUE;
}

OpcodeResult WINAPI Script_InifileGetFloat(CScriptThread* thread)
/****************************************************************
						Opcode Format
0AF2=4,%4d% = get_float_from_ini_file %1s% section %2s% key %3s%
****************************************************************/
{
	char iniPath[MAX_PATH];
	char path[100];
	char sectionName[100];
	char key[100];
	float value = 0.0f;
	char strValue[100];
	BOOL result;

	CLEO_ReadStringOpcodeParam(thread, path, sizeof(path));
	CLEO_ReadStringOpcodeParam(thread, sectionName, sizeof(sectionName));
	CLEO_ReadStringOpcodeParam(thread, key, sizeof(key));

	//if path is short, GetPrivateProfileString() searches for the file in the Windows directory
	MakeFullPath(path, iniPath);

	result = GetPrivateProfileString(sectionName, key, NULL, strValue, sizeof(strValue), iniPath);
	if (result)
	{
		value = (float)atof(strValue);
		CLEO_SetFloatOpcodeParam(thread, value);
	}
	else
		CLEO_SkipOpcodeParams(thread, 1);

	CLEO_SetThreadCondResult(thread, result);

	return OR_CONTINUE;
}

OpcodeResult WINAPI Script_InifileWriteFloat(CScriptThread* thread)
/****************************************************************
						Opcode Format
0AF3=4,write_float %1d% to_ini_file %2s% section %3s% key %4s%
****************************************************************/
{
	char iniPath[MAX_PATH];
	char path[100];
	char sectionName[100];
	char key[100];
	float value;
	char strValue[100];
	BOOL result;

	value = CLEO_GetFloatOpcodeParam(thread);
	CLEO_ReadStringOpcodeParam(thread, path, sizeof(path));
	CLEO_ReadStringOpcodeParam(thread, sectionName, sizeof(sectionName));
	CLEO_ReadStringOpcodeParam(thread, key, sizeof(key));

	//if path is short, WritePrivateProfileString() searches for the file in the Windows directory
	MakeFullPath(path, iniPath);

	sprintf(strValue, "%g", value);

	result = WritePrivateProfileString(sectionName, key, strValue, iniPath);
	CLEO_SetThreadCondResult(thread, result);

	return OR_CONTINUE;
}

OpcodeResult WINAPI Script_InifileReadString(CScriptThread* thread)
/****************************************************************
						Opcode Format
0AF4=4,%4d% = read_string_from_ini_file %1s% section %2s% key %3s%
****************************************************************/
{
	char iniPath[MAX_PATH];
	char path[100];
	char sectionName[100];
	char key[100];
	char strValue[100];
	char *strptr;
	BOOL result;

	CLEO_ReadStringOpcodeParam(thread, path, sizeof(path));
	CLEO_ReadStringOpcodeParam(thread, sectionName, sizeof(sectionName));
	CLEO_ReadStringOpcodeParam(thread, key, sizeof(key));

	//if path is short, GetPrivateProfileString() searches for the file in the Windows directory
	MakeFullPath(path, iniPath);

	result = GetPrivateProfileString(sectionName, key, NULL, strValue, sizeof(strValue), iniPath);
	if (result)
	{
		switch (CLEO_GetOperandType(thread))
		{
		case globalVarVString:
		case localVarVString:
		case globalVarSString:
		case localVarSString:
			CLEO_WriteStringOpcodeParam(thread, strValue);
			break;
		default:
			strptr = (char *)CLEO_GetIntOpcodeParam(thread);
			strcpy(strptr, strValue);
		}
	}
	else
		CLEO_SkipOpcodeParams(thread, 1);

	CLEO_SetThreadCondResult(thread, result);

	return OR_CONTINUE;
}

OpcodeResult WINAPI Script_InifileWriteString(CScriptThread* thread)
/****************************************************************
						Opcode Format
0AF5=4,write_string %1s% to_ini_file %2s% section %3s% key %4s%
****************************************************************/
{
	char iniPath[MAX_PATH];
	char path[100];
	char sectionName[100];
	char key[100];
	char strValue[100];
	char *strptr;
	BOOL result;

	switch (CLEO_GetOperandType(thread))
	{
	case globalVarVString:
	case localVarVString:
	case globalVarSString:
	case localVarSString:
		CLEO_ReadStringOpcodeParam(thread, strValue, sizeof(strValue));
		break;
	default:
		strptr = (char *)CLEO_GetIntOpcodeParam(thread);
		strcpy(strValue, strptr);
	}
	CLEO_ReadStringOpcodeParam(thread, path, sizeof(path));
	CLEO_ReadStringOpcodeParam(thread, sectionName, sizeof(sectionName));
	CLEO_ReadStringOpcodeParam(thread, key, sizeof(key));

	//if path is short, WritePrivateProfileString() searches for the file in the Windows directory
	MakeFullPath(path, iniPath);

	result = WritePrivateProfileString(sectionName, key, strValue, iniPath);

	CLEO_SetThreadCondResult(thread, result);

	return OR_CONTINUE;
}
