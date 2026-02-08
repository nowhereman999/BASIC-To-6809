Check$ = "BACKUP": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
BACKUP_CMD = ii
Check$ = "CASE": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
CASE_CMD = ii
Check$ = "DO": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
DO_CMD = ii
Check$ = "END": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
END_CMD = ii
Check$ = "FOR": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
FOR_CMD = ii
Check$ = "GOSUB": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
GOSUB_CMD = ii
Check$ = "GOTO": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
GOTO_CMD = ii
Check$ = "LET": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
LET_CMD = ii
Check$ = "WHILE": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
WHILE_CMD = ii
Check$ = "UNTIL": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
UNTIL_CMD = ii
Check$ = "EVERYCASE": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
EVERYCASE_CMD = ii
Check$ = "IF": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
IF_CMD = ii
Check$ = "IS": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
IS_CMD = ii
Check$ = "ELSE": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
ELSE_CMD = ii
Check$ = "ERASE": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
ERASE_CMD = ii
Check$ = "LOCATE": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
LOCATE_CMD = ii
Check$ = "LOOP": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
LOOP_CMD = ii
Check$ = "MOVE": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
MOVE_CMD = ii
Check$ = "OFF": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
OFF_CMD = ii
Check$ = "ON": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
ON_CMD = ii
Check$ = "SELECT": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
SELECT_CMD = ii
Check$ = "SHOW": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
SHOW_CMD = ii
Check$ = "SINGLE": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
SINGLE_CMD = ii
Check$ = "STEP": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
STEP_CMD = ii
Check$ = "THEN": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
THEN_CMD = ii
Check$ = "TIMER": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
TIMER_CMD = ii
Check$ = "TO": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
TO_CMD = ii
Check$ = "VBL": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
VBL_CMD = ii

Check$ = "REM": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
REM_CMD = ii
Check$ = "'": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
REM_Apostraphe_CMD = ii

Check$ = "ABS": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
ABS_CMD = ii
Check$ = "ASC": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
ASC_CMD = ii
Check$ = "ATN": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
ATN_CMD = ii
Check$ = "BUTTON": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
BUTTON_CMD = ii
Check$ = "COCOHARDWARE": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
COCOHARDWARE_CMD = ii
Check$ = "COCOMP3_COMBINATION_PLAY_SETTING": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
COCOMP3_COMBINATION_PLAY_SETTING_CMD = ii
Check$ = "COCOMP3_END_COMBINATION_PLAY": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
COCOMP3_END_COMBINATION_PLAY_CMD = ii
Check$ = "COCOMP3_GET_FOLDER_DIR_TRACK": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
COCOMP3_GET_FOLDER_DIR_TRACK_CMD = ii
Check$ = "COCOMP3_GET_TRACKS_IN_FOLDER": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
COCOMP3_GET_TRACKS_IN_FOLDER_CMD = ii
Check$ = "COCOMP3_GET_NUMBER_OF_TRACKS": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
COCOMP3_GET_NUMBER_OF_TRACKS_CMD = ii
Check$ = "COCOMP3_PLAY_PREVIOUS_FOLDER": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
COCOMP3_PLAY_PREVIOUS_FOLDER_CMD = ii
Check$ = "COCOMP3_SET_TRACK_INTERLUDE": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
COCOMP3_SET_TRACK_INTERLUDE_CMD = ii
Check$ = "COCOMP3_SET_PATH_INTERLUDE": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
COCOMP3_SET_PATH_INTERLUDE_CMD = ii
Check$ = "COCOMP3_CYCLE_MODE_SETTING": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
COCOMP3_CYCLE_MODE_SETTING_CMD = ii
Check$ = "COCOMP3_SELECT_BUT_NO_PLAY": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
COCOMP3_SELECT_BUT_NO_PLAY_CMD = ii
Check$ = "COCOMP3_SELECT_BUT_NO_PLAY": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
COCOMP3_SELECT_BUT_NO_PLAY_CMD = ii
Check$ = "COCOMP3_GET_CURRENT_TRACK": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
COCOMP3_GET_CURRENT_TRACK_CMD = ii
Check$ = "COCOMP3_PLAY_TRACK_NUMBER": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
COCOMP3_PLAY_TRACK_NUMBER_CMD = ii
Check$ = "COCOMP3_GET_DRIVE_STATUS": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
COCOMP3_GET_DRIVE_STATUS_CMD = ii
Check$ = "COCOMP3_PLAY_NEXT_FOLDER": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
COCOMP3_PLAY_NEXT_FOLDER_CMD = ii
Check$ = "COCOMP3_GET_PLAY_STATUS": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
COCOMP3_GET_PLAY_STATUS_CMD = ii
Check$ = "COCOMP3_SET_CYCLE_TIMES": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
COCOMP3_SET_CYCLE_TIMES_CMD = ii
Check$ = "COCOMP3_END_PLAYING": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
COCOMP3_END_PLAYING_CMD = ii
Check$ = "COCOMP3_AUDIO_MODE": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
COCOMP3_AUDIO_MODE_CMD = ii
Check$ = "COCOMP3_PLAY_TRACK": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
COCOMP3_PLAY_TRACK_CMD = ii
Check$ = "COCOMP3_PREVIOUS": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
COCOMP3_PREVIOUS_CMD = ii
Check$ = "COCOMP3_VOL_DOWN": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
COCOMP3_VOL_DOWN_CMD = ii
Check$ = "COCOMP3_VOL_FADE": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
COCOMP3_VOL_FADE_CMD = ii
Check$ = "COCOMP3_SET_VOL": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
COCOMP3_SET_VOL_CMD = ii
Check$ = "COCOMP3_VOL_MAX": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
COCOMP3_VOL_MAX_CMD = ii
Check$ = "COCOMP3_SET_EQ": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
COCOMP3_SET_EQ_CMD = ii
Check$ = "COCOMP3_VOL_UP": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
COCOMP3_VOL_UP_CMD = ii
Check$ = "COCOMP3_PAUSE": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
COCOMP3_PAUSE_CMD = ii
Check$ = "COCOMP3_NEXT": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
COCOMP3_NEXT_CMD = ii
Check$ = "COCOMP3_PLAY": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
COCOMP3_PLAY_CMD = ii
Check$ = "COCOMP3_STOP": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
COCOMP3_STOP_CMD = ii
Check$ = "COCOMP3_TEST": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
COCOMP3_TEST_CMD = ii
Check$ = "COCOMP3_RAW": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
COCOMP3_RAW_CMD = ii
Check$ = "COS": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
COS_CMD = ii
Check$ = "EXP": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
EXP_CMD = ii
Check$ = "FIX": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
FIX_CMD = ii
Check$ = "JOYSTK": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
JOYSTK_CMD = ii
Check$ = "INSTR": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
INSTR_CMD = ii
Check$ = "INT": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
INT_CMD = ii
Check$ = "LEN": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
LEN_CMD = ii
Check$ = "LOG": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
LOG_CMD = ii
Check$ = "PEEK": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
PEEK_CMD = ii
Check$ = "POINT": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
POINT_CMD = ii
Check$ = "POS": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
POS_CMD = ii
Check$ = "RND": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
RND_CMD = ii
Check$ = "SDC_DIRPAGE": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
SDC_DIRPAGE_CMD=ii
Check$ = "SDC_GETBYTE": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
SDC_GETBYTE_CMD=ii
Check$ = "SDC_GETBYTE": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
SDC_GETBYTE_CMD=ii
Check$ = "SDC_INITDIR": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
SDC_INITDIR_CMD=ii
Check$ = "SDC_DELETE": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
SDC_DELETE_CMD=ii
Check$ = "SDC_SETDIR": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
SDC_SETDIR_CMD=ii
Check$ = "SDC_MKDIR": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
SDC_MKDIR_CMD=ii
Check$ = "SGN": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
SGN_CMD = ii
Check$ = "SQR": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
SQR_CMD = ii
Check$ = "SIN": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
SIN_CMD = ii
Check$ = "TAB": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
TAB_CMD = ii
Check$ = "TAN": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
TAN_CMD = ii
Check$ = "VAL": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
VAL_CMD = ii
Check$ = "VARPTR": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
VARPTR_CMD = ii
Check$ = "LPEEK": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
LPEEK_CMD=ii

Check$ = "LEFT$": GoSub FindStrCommandNumber ' Gets the String Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
LEFT_CMD = ii
Check$ = "RIGHT$": GoSub FindStrCommandNumber ' Gets the String Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
RIGHT_CMD = ii
Check$ = "MID$": GoSub FindStrCommandNumber ' Gets the String Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
MID_CMD = ii
Check$ = "TRIM$": GoSub FindStrCommandNumber ' Gets the String Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
TRIM_CMD = ii
Check$ = "LTRIM$": GoSub FindStrCommandNumber ' Gets the String Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
LTRIM_CMD = ii
Check$ = "RTRIM$": GoSub FindStrCommandNumber ' Gets the String Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
RTRIM_CMD = ii
Check$ = "STRING$": GoSub FindStrCommandNumber ' Gets the String Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
STRING_CMD = ii
Check$ = "CHR$": GoSub FindStrCommandNumber ' Gets the String Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
CHR_CMD = ii
Check$ = "HEX$": GoSub FindStrCommandNumber ' Gets the String Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
HEX_CMD = ii
Check$ = "STR$": GoSub FindStrCommandNumber ' Gets the String Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
STR_CMD = ii
Check$ = "INKEY$": GoSub FindStrCommandNumber ' Gets the String Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
INKEY_CMD = ii
Check$ = "SDC_FILEINFO$": GoSub FindStrCommandNumber ' Gets the String Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
SDC_FILEINFO_CMD = ii
Check$ = "SDC_GETCURDIR$": GoSub FindStrCommandNumber ' Gets the String Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
SDC_GETCURDIR_CMD = ii
Check$ = "SDC_DIRLIST$": GoSub FindStrCommandNumber ' Gets the String Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
SDC_DIRLIST_CMD = ii