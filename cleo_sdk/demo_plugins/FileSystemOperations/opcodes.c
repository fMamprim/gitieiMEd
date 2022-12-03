#include "stdafx.h"
//include CLEO header
#include "CLEO.h"


//initial opcodes
#define OPCODE_FS_DELETEFILE		0x0B00
#define OPCODE_FS_DELETEDIR			0x0B01
#define OPCODE_FS_MOVEFILE			0x0B02
#define OPCODE_FS_MOVEDIR			0x0B03
#define OPCODE_FS_COPYFILE			0x0B04
#define OPCODE_FS_COPYDIR			0x0B05

//declare opcode callbacks
OpcodeResult WINAPI Script_FS_DeleteFile(CScriptThread* thread);
OpcodeResult WINAPI Script_FS_DeleteDirectory(CScriptThread* thread);
OpcodeResult WINAPI Script_FS_MoveFile(CScriptThread* thread);
OpcodeResult WINAPI Script_FS_MoveDir(CScriptThread* thread);
OpcodeResult WINAPI Script_FS_CopyFile(CScriptThread* thread);
OpcodeResult WINAPI Script_FS_CopyDir(CScriptThread* thread);

BOOL InitOpcodes()
{
	BOOL result = FALSE;

	//check cleo version
	if (CLEO_GetVersion() < CLEO_VERSION)
	{	
		MessageBox(HWND_DESKTOP, "An incorrect version of CLEO was loaded.", "FileSystemOperations.cleo", MB_ICONERROR);
		return FALSE;
	}

	//register opcodes
	if (CLEO_RegisterOpcode(OPCODE_FS_DELETEFILE, &Script_FS_DeleteFile)) 
		result = TRUE;
	if (CLEO_RegisterOpcode(OPCODE_FS_DELETEDIR, &Script_FS_DeleteDirectory)) 
		result = TRUE;
	if (CLEO_RegisterOpcode(OPCODE_FS_MOVEFILE, &Script_FS_MoveFile)) 
		result = TRUE;
	if (CLEO_RegisterOpcode(OPCODE_FS_MOVEDIR, &Script_FS_MoveDir)) 
		result = TRUE;
	if (CLEO_RegisterOpcode(OPCODE_FS_COPYFILE, &Script_FS_CopyFile)) 
		result = TRUE;
	if (CLEO_RegisterOpcode(OPCODE_FS_COPYDIR, &Script_FS_CopyDir)) 
		result = TRUE;

	return result;
}

OpcodeResult WINAPI Script_FS_DeleteFile(CScriptThread* thread)
/****************************************************************
						Opcode Format
0B00=1,delete_file %1d% //IF and SET
****************************************************************/
{
	char FilePath[MAX_PATH];

	CLEO_ReadStringOpcodeParam(thread, FilePath, sizeof(FilePath));
	CLEO_SetThreadCondResult(thread, DeleteFile(FilePath));

	return OR_CONTINUE;
}

BOOL DeleteDir(const char *path)
{
	char mask[MAX_PATH];
	HANDLE hSearch = NULL;
	WIN32_FIND_DATA wfd;
	char subPath[MAX_PATH];

	memset(&wfd, 0, sizeof(wfd));
	//search mask
	sprintf(mask, "%s\\*", path);

	//try to delete all inside first
	if ((hSearch = FindFirstFile(mask, &wfd)) != INVALID_HANDLE_VALUE)
	{
		do
		{
			//recursively delete subdirectories
			if (wfd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)
			{
				if ((strcmp(wfd.cFileName, "..") != 0) && (strcmp(wfd.cFileName, ".") != 0))
				{
					sprintf(subPath, "%s\\%s", path, wfd.cFileName);
					if (!DeleteDir(subPath))
						return FALSE;
				}
			}
			else
			{
				//remove read-only, system, hidden flags
				sprintf(subPath, "%s\\%s", path, wfd.cFileName);
				SetFileAttributes(subPath, FILE_ATTRIBUTE_NORMAL);
				//delete file
				if (!DeleteFile(subPath))
					return FALSE;
			}


		} while (FindNextFile(hSearch, &wfd));
		FindClose(hSearch);
	}

	//delete empty directory
	return RemoveDirectory(path);
}

OpcodeResult WINAPI Script_FS_DeleteDirectory(CScriptThread* thread)
/****************************************************************
						Opcode Format
0B01=1,delete_directory %1d% with_all_files_and_subdirectories %2d% //IF and SET
****************************************************************/
{
	char DirPath[MAX_PATH];
	int DeleteAllInsideFlag;
	BOOL result;

	CLEO_ReadStringOpcodeParam(thread, DirPath, sizeof(DirPath));
	DeleteAllInsideFlag = CLEO_GetIntOpcodeParam(thread);

	if (DeleteAllInsideFlag)
	{
		//remove directory with all files and subdirectories
		result = DeleteDir(DirPath);
	}
	else
	{
		//try to remove as empty directory
		result = RemoveDirectory(DirPath);
	}

	CLEO_SetThreadCondResult(thread, result);

	return OR_CONTINUE;
}

OpcodeResult WINAPI Script_FS_MoveFile(CScriptThread* thread)
/****************************************************************
						Opcode Format
0B02=2,move_file %1d% to %2d% //IF and SET
****************************************************************/
{
	char FilePath[MAX_PATH];
	char NewFilePath[MAX_PATH];
	BOOL result;

	CLEO_ReadStringOpcodeParam(thread, FilePath, sizeof(FilePath));
	CLEO_ReadStringOpcodeParam(thread, NewFilePath, sizeof(NewFilePath));

	result = GetFileAttributes(FilePath) & FILE_ATTRIBUTE_DIRECTORY;
	if (!result)
		result = MoveFile(FilePath, NewFilePath);

	CLEO_SetThreadCondResult(thread, result);

	return OR_CONTINUE;
}

OpcodeResult WINAPI Script_FS_MoveDir(CScriptThread* thread)
/****************************************************************
						Opcode Format
0B03=2,move_directory %1d% to %2d% //IF and SET
****************************************************************/
{
	char FilePath[MAX_PATH];
	char NewFilePath[MAX_PATH];
	BOOL result;

	CLEO_ReadStringOpcodeParam(thread, FilePath, sizeof(FilePath));
	CLEO_ReadStringOpcodeParam(thread, NewFilePath, sizeof(NewFilePath));

	result = GetFileAttributes(FilePath) & FILE_ATTRIBUTE_DIRECTORY;
	if (result)
		result = MoveFile(FilePath, NewFilePath);

	CLEO_SetThreadCondResult(thread, result);

	return OR_CONTINUE;
}

OpcodeResult WINAPI Script_FS_CopyFile(CScriptThread* thread)
/****************************************************************
						Opcode Format
0B04=2,copy_file %1d% to %2d% //IF and SET
****************************************************************/
{
	char FilePath[MAX_PATH];
	char NewFilePath[MAX_PATH];
	BOOL result;
	DWORD fattr;

	CLEO_ReadStringOpcodeParam(thread, FilePath, sizeof(FilePath));
	CLEO_ReadStringOpcodeParam(thread, NewFilePath, sizeof(NewFilePath));

	if (result = CopyFile(FilePath, NewFilePath, FALSE))
	{
		//copy file attributes
		fattr = GetFileAttributes(FilePath);
		SetFileAttributes(NewFilePath, fattr);
	}
	CLEO_SetThreadCondResult(thread, result);

	return OR_CONTINUE;
}

BOOL CopyDir(const char *path, const char *newPath)
{
	char mask[MAX_PATH];
	HANDLE hSearch = NULL;
	WIN32_FIND_DATA wfd;
	char subPath[MAX_PATH], newSubPath[MAX_PATH];
	DWORD fattr;

	//create parent directory
	if (!CreateDirectory(newPath, NULL))
		return FALSE;

	memset(&wfd, 0, sizeof(wfd));
	//search mask
	sprintf(mask, "%s\\*", path);

	//copy all files and folders into new directory
	if ((hSearch = FindFirstFile(mask, &wfd)) != INVALID_HANDLE_VALUE)
	{
		do
		{
			sprintf(subPath, "%s\\%s", path, wfd.cFileName);
			sprintf(newSubPath, "%s\\%s", newPath, wfd.cFileName);
			//copy subdirectories
			if (wfd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)
			{
				if ((strcmp(wfd.cFileName, "..") != 0) && (strcmp(wfd.cFileName, ".") != 0))
				{
					if (!CopyDir(subPath, newSubPath))
						return FALSE;
				}
			}
			else
			{
				//copy file into new directory
				if (CopyFile(subPath, newSubPath, FALSE))
				{
					fattr = GetFileAttributes(subPath);
					SetFileAttributes(newSubPath, fattr);
				}
				else	return FALSE;
			}


		} while (FindNextFile(hSearch, &wfd));
		FindClose(hSearch);
	}

	//return success
	return TRUE;
}

OpcodeResult WINAPI Script_FS_CopyDir(CScriptThread* thread)
/****************************************************************
						Opcode Format
0B05=2,copy_directory %1d% to %2d% //IF and SET
****************************************************************/
{
	char FilePath[MAX_PATH];
	char NewFilePath[MAX_PATH];

	CLEO_ReadStringOpcodeParam(thread, FilePath, sizeof(FilePath));
	CLEO_ReadStringOpcodeParam(thread, NewFilePath, sizeof(NewFilePath));
	CLEO_SetThreadCondResult(thread, CopyDir(FilePath, NewFilePath));

	return OR_CONTINUE;
}
