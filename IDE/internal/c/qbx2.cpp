#include "audio.h"
#include "bitops.h"
#include "clipboard.h"
#include "command.h"
#include "common.h"
#include "compression.h"
#include "datetime.h"
#include "encoding.h"
#include "environ.h"
#include "error_handle.h"
#include "event.h"
#include "extended_math.h"
#include "file-fields.h"
#include "filepath.h"
#include "filesystem.h"
#include "font.h"
#include "game_controller.h"
#include "graphics.h"
#include "gui.h"
#include "hashing.h"
#include "hexoctbin.h"
#include "image.h"
#include "libqb.h"
#include "logging.h"
#include "mem.h"
#include "qbmath.h"
#include "qbs-mk-cv.h"
#include "qbs.h"
#include "rounding.h"
#include "shell.h"

extern int32 func__cinp(int32 toggle, int32 passed); // Console INP scan code reader
extern int func__capslock();
extern int func__scrolllock();
extern int func__numlock();
extern void sub__capslock(int32 options);
extern void sub__scrolllock(int32 options);
extern void sub__numlock(int32 options);
extern void sub__consolefont(qbs *FontName, int FontSize);
extern void sub__console_cursor(int32 visible, int32 cursorsize, int32 passed);
extern int32 func__getconsoleinput();

extern void unlockvWatchHandle();
extern int32 vWatchHandle();

#ifdef QB64_MACOSX
#    include <ApplicationServices/ApplicationServices.h>
#endif

/* testing only
    #ifdef QB64_WINDOWS

    HWND FindMyTopMostWindow()
    {
    DWORD dwProcID = GetCurrentProcessId();
    HWND hWnd = GetTopWindow(GetDesktopWindow());
    while(hWnd)
    {
    DWORD dwWndProcID = 0;
    GetWindowThreadProcessId(hWnd, &dwWndProcID);
    if(dwWndProcID == dwProcID)
    return hWnd;
    hWnd = GetNextWindow(hWnd, GW_HWNDNEXT);
    }
    return NULL;
    }

    void SetMidiVolume(int32 vol){
    //DWORD vol = MAKELONG(((volume*65535L)/100), ((volume*65535L)/100));
    MIDIOUTCAPS midiCaps;
    midiOutGetDevCaps(0, &midiCaps, sizeof(midiCaps));
    if (midiCaps.dwSupport & MIDICAPS_VOLUME)
    midiOutSetVolume(0, vol);
    }

    #endif
*/

#ifdef QB64_WINDOWS
int _CRT_glob = -1; // enable globbing on llvm-mingw by default
#endif

extern int32 sub_gl_called;

#ifdef QB64_GUI
#    ifdef DEPENDENCY_GL

#        include "parts/core/gl_header_for_parsing/temp/gl_helper_code.h"

double pi_as_double = 3.14159265358979;

void gluPerspective(double fovy, double aspect, double zNear, double zFar) {
    double xmin, xmax, ymin, ymax;
    ymax = zNear * std::tan(fovy * pi_as_double / 360.0);
    ymin = -ymax;
    xmin = ymin * aspect;
    xmax = ymax * aspect;
    glFrustum(xmin, xmax, ymin, ymax, zNear, zFar);
}

#    endif
#endif

// forward references
void QBMAIN(void *);
void TIMERTHREAD(void *);

extern int32 requestedKeyboardOverlayImage;

void requestKeyboardOverlayImage(int32 handle) {
    requestedKeyboardOverlayImage = handle;
}

// extern functions

extern int32 func__scaledwidth();
extern int32 func__scaledheight();

extern void sub__fps(double fps, int32 passed);

extern void sub__resize(int32 on_off, int32 stretch_smooth);
extern int32 func__resize();
extern int32 func__resizewidth();
extern int32 func__resizeheight();

extern void sub__title(qbs *title);
extern void sub__echo(qbs *message);
extern qbs *func__readfile(qbs *filespec);
extern void sub__writefile(qbs *filespec, qbs *contents);
extern void sub__assert(int32 expression, qbs *assert_message, int32 passed);
extern void sub__finishdrop();
extern int32 func__filedrop();
extern void sub__filedrop(int32 on_off = NULL);
extern int32 func__totaldroppedfiles();
extern qbs *func__droppedfile(int32 fileIndex, int32 passed);

extern qbs *func__embedded(qbs *handle);

extern void sub__glrender(int32 method);
extern void sub__displayorder(int32 method1, int32 method2, int32 method3, int32 method4);

extern int64 GetTicks();

extern mem_block func__memimage(int32, int32);

extern void sub__consoletitle(qbs *);
extern void sub__screenshow();
extern void sub__screenhide();
extern int32 func__screenhide();
extern int32 func_windowexists();
extern int32 func_screenicon();
extern int32 func_screenwidth();
extern int32 func_screenheight();
extern void sub_screenicon();
extern void sub__console(int32);
extern int32 func__console();
extern void sub__controlchr(int32);
extern int32 func__controlchr();
extern void sub__blink(int32);
extern int32 func__blink();
extern int32 func__hasfocus();
extern void set_foreground_window(ptrszint i);
extern qbs *func__title();
extern int32 func__handle();
extern int32 func_stick(int32 i, int32 axis_group, int32 passed);
extern int32 func_strig(int32 i, int32 controller, int32 passed);
extern void sub_paletteusing(void *element, int32 bits);
extern int64 func_read_int64(uint8 *data, ptrszint *data_offset, ptrszint data_size);
extern int64 func_read_uint64(uint8 *data, ptrszint *data_offset, ptrszint data_size);
extern void key_on();
extern void key_off();
extern void key_list();
extern void key_assign(int32 i, qbs *str);
extern int32 func__screeny();
extern int32 func__screenx();
extern void sub__screenmove(int32 x, int32 y, int32 passed);
extern void sub__mousemove(float x, float y);
extern qbs *func__os();
extern void sub__mapunicode(int32 unicode_code, int32 ascii_code);
extern int32 func__mapunicode(int32 ascii_code);
extern int32 func__keydown(int32 x);
extern int32 func__keyhit();
extern int32 func_lpos(int32);
extern float func__mousemovementx();
extern float func__mousemovementy();
extern void sub__screenprint(qbs *txt);
extern void sub__screenclick(int32 x, int32 y, int32 button, int32 passed);
extern int32 func__screenimage(int32 x1, int32 y1, int32 x2, int32 y2, int32 passed);
extern void sub_lock(int32 i, int64 start, int64 end, int32 passed);
extern void sub_unlock(int32 i, int64 start, int64 end, int32 passed);
void chain_restorescreenstate(int32);
void chain_savescreenstate(int32);
extern void sub__fullscreen(int32 method, int32 passed);
extern void sub__allowfullscreen(int32 method, int32 smooth);
extern int32 func__fullscreen();
extern int32 func__fullscreensmooth();
extern int32 func__exit();
extern void revert_input_check();
extern int32 func__openhost(qbs *);
extern int32 func__openconnection(int32);
extern int32 func__openclient(qbs *);
extern int32 func__connected(int32);
extern qbs *func__connectionaddress(int32);
extern void sub_draw(qbs *);
extern void qbs_maketmp(qbs *);
extern void sub_run(qbs *);
extern void sub_run_init();
extern void freeallimages();
extern void call_interrupt(int32, void *, void *);
extern void call_interruptx(int32, void *, void *);
extern void restorepalette(img_struct *im);
extern void pset(int32 x, int32 y, uint32 col);
extern uint32 newimg();
extern int32 freeimg(uint32);
extern void imgrevert(int32);
extern int32 imgframe(uint8 *o, int32 x, int32 y, int32 bpp);
extern int32 imgnew(int32 x, int32 y, int32 bpp);
extern void sub__putimage(double f_dx1, double f_dy1, double f_dx2, double f_dy2, int32 src, int32 dst, double f_sx1, double f_sy1, double f_sx2, double f_sy2,
                          int32 passed);
extern int32 selectfont(int32 f, img_struct *im);
extern uint32 sib();
extern uint32 sib_mod0();
extern uint8 *rm8();
extern uint16 *rm16();
extern uint32 *rm32();
extern void cpu_call();
extern int64 build_int64(uint32 val2, uint32 val1);
extern uint64 build_uint64(uint32 val2, uint32 val1);
extern char *human_error(int32 errorcode);
extern void end();
extern int32 stop_program_state();
extern uint8 *mem_static_malloc(uint32 size);
extern void mem_static_restore(uint8 *restore_point);
extern uint8 *cmem_dynamic_malloc(uint32 size);
extern void cmem_dynamic_free(uint8 *block);
extern void sub_defseg(int32 segment, int32 passed);
extern int32 func_peek(int32 offset);
extern void sub_poke(int32 offset, int32 value);
extern void more_return_points();
extern qbs *func_varptr_helper(uint8 type, uint16 offset);
extern qbs *qbs_inkey();
extern void sub__keyclear(int32 buf, int32 passed);
extern void lineclip(int32 x1, int32 y1, int32 x2, int32 y2, int32 xmin, int32 ymin, int32 xmax, int32 ymax);
extern void qbg_palette(uint32 attribute, uint32 col, int32 passed);
extern void qbg_sub_color(uint32 col1, uint32 col2, uint32 bordercolor, int32 passed);
extern void defaultcolors();
extern void qbg_screen(int32 mode, int32 color_switch, int32 active_page, int32 visual_page, int32 refresh, int32 passed);
extern void sub_pcopy(int32 src, int32 dst);
extern void qbsub_width(int32 option, int32 value1, int32 value2, int32 value3, int32 value4, int32 passed);
extern void pset(int32 x, int32 y, uint32 col);
extern void pset_and_clip(int32 x, int32 y, uint32 col);
extern void qb32_boxfill(float x1f, float y1f, float x2f, float y2f, uint32 col);
extern void fast_boxfill(int32 x1, int32 y1, int32 x2, int32 y2, uint32 col);
extern void fast_line(int32 x1, int32 y1, int32 x2, int32 y2, uint32 col);
extern void qb32_line(float x1f, float y1f, float x2f, float y2f, uint32 col, uint32 style);
extern void sub_line(float x1, float y1, float x2, float y2, uint32 col, int32 bf, uint32 style, int32 passed);
extern void sub_paint32(float x, float y, uint32 fillcol, uint32 bordercol, int32 passed);
extern void sub_paint32x(float x, float y, uint32 fillcol, uint32 bordercol, int32 passed);
extern void sub_paint(float x, float y, uint32 fillcol, uint32 bordercol, qbs *backgroundstr, int32 passed);
extern void sub_paint(float x, float y, qbs *fillstr, uint32 bordercol, qbs *backgroundstr, int32 passed);
extern void sub_circle(double x, double y, double r, uint32 col, double start, double end, double aspect, int32 passed);
extern uint32 point(int32 x, int32 y);
extern double func_point(float x, float y, int32 passed);
extern void sub_pset(float x, float y, uint32 col, int32 passed);
extern void sub_preset(float x, float y, uint32 col, int32 passed);
extern void printchr(int32 character);
extern int32_t chrwidth(uint32_t character);
extern void newline();
extern void lprint_makefit(qbs *text);
extern void tab();
extern void qbs_lprint(qbs *str, int32 finish_on_new_line);
extern void qbg_sub_view(int32 x1, int32 y1, int32 x2, int32 y2, int32 fillcolor, int32 bordercolor, int32 passed);
extern void qbg_sub_locate(int32 row, int32 column, int32 cursor, int32 start, int32 stop, int32 passed);
extern int32 hexoct2uint64(qbs *h);
extern void qbs_input(int32 numvariables, uint8 newline);
extern long double func_val(qbs *s);
extern void sub_out(int32 port, int32 data);
extern void sub_randomize(double seed, int32 passed);
extern float func_rnd(float n, int32 passed);
// following are declared below to allow for inlining
// extern double func_abs(double d);
// extern long double func_abs(long double d);
// extern float func_abs(float d);

// extern void sub_open(qbs *name,int32 type,int32 access,int32 sharing,int32
// i,int32 record_length,int32 passed);
extern void sub_open(qbs *name, int32 type, int32 access, int32 sharing, int32 i, int64 record_length, int32 passed);
extern void sub_open_gwbasic(qbs *typestr, int32 i, qbs *name, int64 record_length, int32 passed);

extern void sub_close(int32 i2, int32 passed);
extern int32 file_input_chr(int32 i);
extern void file_input_nextitem(int32 i, int32 lastc);
extern void sub_file_print(int32 i, qbs *str, int32 extraspace, int32 tab, int32 newline);
extern int32 n_roundincrement();
extern int32 n_float();
extern int32 n_int64();
extern int32 n_uint64();
extern int32 n_inputnumberfromdata(uint8 *data, ptrszint *data_offset, ptrszint data_size);
extern int32 n_inputnumberfromfile(int32 fileno);
extern void sub_file_line_input_string(int32 fileno, qbs *deststr);
extern void sub_file_input_string(int32 fileno, qbs *deststr);
extern int64 func_file_input_int64(int32 fileno);
extern uint64 func_file_input_uint64(int32 fileno);
extern void sub_read_string(uint8 *data, ptrszint *data_offset, ptrszint data_size, qbs *deststr);
extern long double func_read_float(uint8 *data, ptrszint *data_offset, ptrszint data_size, int32 typ);
extern long double func_file_input_float(int32 fileno, int32 typ);
extern void *byte_element(uint64 offset, int32 length);
extern void *byte_element(uint64 offset, int32 length, byte_element_struct *info);
extern void sub_get(int32 i, int64 offset, void *element, int32 passed);
extern void sub_get2(int32 i, int64 offset, qbs *str, int32 passed);

extern void sub_put(int32 i, int64 offset, void *element, int32 passed);
extern void sub_put2(int32 i, int64 offset, void *element, int32 passed);
extern void sub_graphics_get(float x1f, float y1f, float x2f, float y2f, void *element, uint32 mask, int32 passed);
extern void sub_graphics_put(float x1f, float y1f, void *element, int32 option, uint32 mask, int32 passed);
extern int32 func_csrlin();
extern void sub_sleep(int32 seconds, int32 passed);
extern ptrszint func_lbound(ptrszint *array, int32 index, int32 num_indexes);
extern ptrszint func_ubound(ptrszint *array, int32 index, int32 num_indexes);

extern int32 func_inp(int32 port);
extern void sub_wait(int32 port, int32 andexpression, int32 xorexpression, int32 passed);
extern qbs *func_tab(int32 pos);
extern qbs *func_spc(int32 spaces);
extern float func_pmap(float val, int32 option);
extern uint32 func_screen(int32 y, int32 x, int32 returncol, int32 passed);
extern void sub_bsave(qbs *filename, int32 offset, int32 size);
extern void sub_bload(qbs *filename, int32 offset, int32 passed);

extern int64 func_lof(int32 i);
extern int32 func_eof(int32 i);
extern void sub_seek(int32 i, int64 pos);
extern int64 func_seek(int32 i);
extern int64 func_loc(int32 i);
extern qbs *func_input(int32 n, int32 i, int32 passed);
extern int32 func__statusCode(int32 handle);

extern int32 func_freefile();
extern void sub__mousehide();
extern void sub__mouseshow(qbs *style, int32 passed);
extern int32 func__mousehidden();
extern float func__mousex();
extern float func__mousey();
extern int32 func__mouseinput();
extern int32 func__mousebutton(int32 i);
extern int32 func__mousewheel();

extern void call_absolute(int32 args, uint16 offset);
extern void sub__blend(int32 i, int32 passed);
extern void sub__dontblend(int32 i, int32 passed);
extern void sub__clearcolor(uint32 c, int32 i, int32 passed);
extern void sub__setalpha(int32 a, uint32 c, uint32 c2, int32 i, int32 passed);
extern int32 func__width(int32 i, int32 passed);
extern int32 func__height(int32 i, int32 passed);
extern int32 func__pixelsize(int32 i, int32 passed);
extern int32 func__clearcolor(int32 i, int32 passed);
extern int32 func__blend(int32 i, int32 passed);
extern uint32 func__defaultcolor(int32 i, int32 passed);
extern uint32 func__backgroundcolor(int32 i, int32 passed);
extern uint32 func__palettecolor(int32 n, int32 i, int32 passed);
extern void sub__palettecolor(int32 n, uint32 c, int32 i, int32 passed);
extern void sub__copypalette(int32 i, int32 i2, int32 passed);
extern void sub__printstring(float x, float y, qbs *text, int32 i, int32 passed);
extern int32_t func__loadfont(const qbs *qbsFileName, int32_t size, const qbs *qbsRequirements, int32_t font_index, int32_t passed);
extern void sub__font(int32 f, int32 i, int32 passed);
extern int32 func__fontwidth(int32 f, int32 passed);
extern int32 func__fontheight(int32 f, int32 passed);
extern int32 func__font(int32 i, int32 passed);
extern void sub__freefont(int32 f);
extern void sub__printmode(int32 mode, int32 i, int32 passed);
extern int32 func__printmode(int32 i, int32 passed);
extern uint32 matchcol(int32 r, int32 g, int32 b);
extern uint32 matchcol(int32 r, int32 g, int32 b, int32 i);
extern uint32 func__rgb(int32 r, int32 g, int32 b, int32 i, int32 passed);
extern uint32 func__rgba(int32 r, int32 g, int32 b, int32 a, int32 i, int32 passed);
extern int32 func__alpha(uint32 col, int32 i, int32 passed);
extern int32 func__red(uint32 col, int32 i, int32 passed);
extern int32 func__green(uint32 col, int32 i, int32 passed);
extern int32 func__blue(uint32 col, int32 i, int32 passed);
extern void sub_end();
extern int32 print_using(qbs *f, int32 s2, qbs *dest, qbs *pu_str);
extern int32 print_using_integer64(qbs *format, int64 value, int32 start, qbs *output);
extern int32 print_using_uinteger64(qbs *format, uint64 value, int32 start, qbs *output);
extern int32 print_using_single(qbs *format, float value, int32 start, qbs *output);
extern int32 print_using_double(qbs *format, double value, int32 start, qbs *output);
extern int32 print_using_float(qbs *format, long double value, int32 start, qbs *output);

// shared global variables
extern int32 sleep_break;
extern int64 exit_code;
extern int32 lock_mainloop; // 0=unlocked, 1=lock requested, 2=locked
extern int64 device_event_index;
extern int32 exit_ok;
int32 timer_event_occurred = 0; // inc/dec as each GOSUB to QBMAIN ()
                                // begins/ends
int32 timer_event_id = 0;
int32 key_event_occurred = 0; // inc/dec as each GOSUB to QBMAIN () begins/ends
int32 key_event_id = 0;
int32 strig_event_occurred = 0; // inc/dec as each GOSUB to QBMAIN ()
                                // begins/ends
int32 strig_event_id = 0;
uint16 call_absolute_offsets[256];
uint32 dbgline;
uint32 qbs_cmem_sp = 256;
uint32 cmem_sp = 65536;
intptr_t dblock; // 32bit offset of dblock
uint8 close_program = 0;
int32 tab_spc_cr_size = 1; // 1=PRINT(default), 2=FILE
int32 tab_fileno = 0;      // only valid if tab_spc_cr_size=2
int32 tab_LPRINT = 0;      // 1=dest is LPRINT image

uint64 *nothingvalue; // a pointer to 8 empty bytes in dblock
uint32 bkp_new_error = 0;
qbs *nothingstring;
uint32 qbevent = 0;
uint8 suspend_program = 0;
uint8 stop_program = 0;
uint8_t cmem[1114099]; // 16*65535+65535+3 (enough for highest referenceable dword in conv memory)
uint8 *cmem_static_pointer = &cmem[0] + 1280 + 65536;
uint8 *cmem_dynamic_base = &cmem[0] + 655360;
uint8 *mem_static;
uint8 *mem_static_pointer;
uint8 *mem_static_limit;
double last_line = 0;

uint32 next_return_point = 0;
uint32 *return_point = (uint32 *)malloc(4 * 16384);
uint32 return_points = 16384;
void *qbs_input_variableoffsets[257];
int32 qbs_input_variabletypes[257];

// qbmain specific global variables
char g_tmp_char;
uint8 g_tmp_uchar;
int16 g_tmp_short;
uint16 g_tmp_ushort;
int32 g_tmp_long;
uint32 g_tmp_ulong;

int8 g_tmp_int8;
uint8 g_tmp_uint8;
int16 g_tmp_int16;
uint16 g_tmp_uint16;
int32 g_tmp_int32;
uint32 g_tmp_uint32;
int64 g_tmp_int64;
uint64 g_tmp_uint64;
float g_tmp_float;
double g_tmp_double;
long double g_tmp_longdouble;

qbs *g_tmp_str;
qbs *g_swap_str;
qbs *pass_str;
ptrszint data_offset = 0;

// inline functions
inline void swap_8(void *a, void *b) {
    uint8 x;
    x = *(uint8 *)a;
    *(uint8 *)a = *(uint8 *)b;
    *(uint8 *)b = x;
}

inline void swap_16(void *a, void *b) {
    uint16 x;
    x = *(uint16 *)a;
    *(uint16 *)a = *(uint16 *)b;
    *(uint16 *)b = x;
}

inline void swap_32(void *a, void *b) {
    uint32 x;
    x = *(uint32 *)a;
    *(uint32 *)a = *(uint32 *)b;
    *(uint32 *)b = x;
}

inline void swap_64(void *a, void *b) {
    uint64 x;
    x = *(uint64 *)a;
    *(uint64 *)a = *(uint64 *)b;
    *(uint64 *)b = x;
}

inline void swap_longdouble(void *a, void *b) {
    long double x;
    x = *(long double *)a;
    *(long double *)a = *(long double *)b;
    *(long double *)b = x;
}

void swap_string(qbs *a, qbs *b) {
    static qbs *c;
    c = qbs_new(a->len, 0);
    memcpy(c->chr, a->chr, a->len);
    qbs_set(a, b);
    qbs_set(b, c);
    qbs_free(c);
}

void swap_block(void *a, void *b, uint32 bytes) {
    static uint32 quads;
    quads = bytes >> 2;
    static uint32 *a32, *b32;
    a32 = (uint32 *)a;
    b32 = (uint32 *)b;
    while (quads--) {
        static uint32 c;
        c = *a32;
        *a32++ = *b32;
        *b32++ = c;
    }
    bytes &= 3;
    static uint8 *a8, *b8;
    a8 = (uint8 *)a32;
    b8 = (uint8 *)b32;
    while (bytes--) {
        static uint8 c;
        c = *a8;
        *a8++ = *b8;
        *b8++ = c;
    }
}

extern int32 disableEvents;

ptrszint check_lbound(ptrszint *array, int32 index, int32 num_indexes) {
    static ptrszint ret;
    disableEvents = 1;
    ret = func_lbound((ptrszint *)(*array), index, num_indexes);
    clear_error();
    disableEvents = 0;
    return ret;
}

ptrszint check_ubound(ptrszint *array, int32 index, int32 num_indexes) {
    static ptrszint ret;
    disableEvents = 1;
    ret = func_ubound((ptrszint *)(*array), index, num_indexes);
    clear_error();
    disableEvents = 0;
    return ret;
}

uint64 call_getubits(uint32 bsize, ptrszint *array, ptrszint i) {
    return getubits(bsize, (uint8 *)(*array), i);
}

int64 call_getbits(uint32 bsize, ptrszint *array, ptrszint i) {
    return getbits(bsize, (uint8 *)(*array), i);
}

void call_setbits(uint32 bsize, ptrszint *array, ptrszint i, int64 val) {
    setbits(bsize, (uint8 *)(*array), i, val);
}

int32 logical_drives() {
#ifdef QB64_WINDOWS
    return GetLogicalDrives();
#else
    return 0;
#endif
}

inline ptrszint array_check(uptrszint index, uptrszint limit) {
    // nb. forces signed index into an unsigned variable for quicker comparison
    if (index < limit)
        return index;
    error(9);
    return 0;
}

inline uint16 varptr_dblock_check(uint8 *off) {
    // note: 66816 is the top of DBLOCK (SEG:80+OFF:65536)
    if (off < (&cmem[66816])) { // in DBLOCK?
        return ((uint16)(off - &cmem[1280]));
    } else {
        return ((uint32)(off - cmem)) & 15;
    }
}

inline uint16 varseg_dblock_check(uint8 *off) {
    // note: 66816 is the top of DBLOCK (SEG:80+OFF:65536)
    if (off < (&cmem[66816])) { // in DBLOCK?
        return 80;
    } else {
        return ((uint32)(off - cmem)) / 16;
    }
}

#include "../temp2/global.txt"
#include "../temp2/regsf.txt"

extern int32 ScreenResize;
extern int32 ScreenResizeScale;

// set_dynamic_info is called immediately when
// main() begins, to set global, static variables
// controlling app init
void set_dynamic_info() {
#include "../temp2/dyninfo.txt"
}

void sub_clear(int32 ignore, int32 ignore2, int32 stack, int32 passed) {
    static ptrszint tmp_long;
// note: stack can be ignored
#include "../temp2/clear.txt"
    // reset DATA read offset
    data_offset = 0;
    // close open files
    sub_close(NULL, NULL); // closes all open files
    // free images
    freeallimages();
    // stop & free sounds (note: QB also stops any sound from the PLAY command)
    // invalidate RETURN location(s)
    next_return_point = 0;
    // reset error goto location to 'unhandled'
    error_goto_line = 0;
    uint32 qbs_tmp_base = qbs_tmp_list_nexti;
    qbs_set(error_handler_history, qbs_new_txt_len("", 0));
    qbs_cleanup(qbs_tmp_base, 0);
    // invalidate RESUME
    error_handling = 0;
    return;
}

int32 run_from_line = 0;
// run_from_line's value is an index in a list of possible "run from" locations
// when 0, the program runs from the beginning

void sub__icon(int32 i, int32 i2, int32 passed);

void sub__display();
void sub__autodisplay();
int32 func__autodisplay();

void chain_input() {
    // note: common data or not, every program must check for chained data,
    //      it could be sharing files or screen state

    // check if command$ contains a tmp chain directive
    int32 FF;

    if ((func_command(0, 0))->len >= 32) {
        if (qbs_equal(qbs_right(func_command(0, 0), 4), qbs_new_txt_len(".tmp", 4))) {
            if (qbs_equal(func_mid(func_command(0, 0), (func_command(0, 0))->len - 31, 25, 1), qbs_new_txt_len("(unique-tag:=/@*$+-)chain", 25))) {
                FF = func_freefile();
                sub_open(func_mid(func_command(0, 0), (func_command(0, 0))->len - 11, 12, 1), 2, NULL, NULL, FF, NULL, 0);

                static int32 int32val, int32val2;
                static int64 int64val, int64val2;
                static int64 bytes, bytei;
                static qbs *tqbs;
                static ptrszint tmp_long;

                // CHDIR directive
                static uint8 chdir_data[4096];
                sub_get(FF, NULL, byte_element((uint64)&int32val, 4),
                        0); // assume CHDIR directive 512
                sub_get(FF, NULL, byte_element((uint64)&int32val, 4),
                        0); // assume len
                sub_get(FF, NULL, byte_element((uint64)chdir_data, int32val),
                        0); // data
                chdir_data[int32val] = 0;

                chain_restorescreenstate(FF);

                // get first command
                sub_get(FF, NULL, byte_element((uint64)&int32val, 4), 0);

// read COMMON data
#include "../temp2/inpchain.txt"

                sub_close(FF, 1);

                sub_kill(func_mid(func_command(0, 0), (func_command(0, 0))->len - 11, 12, 1));

                chdir((char *)chdir_data);

                // remove chain tag from COMMAND$
                func_command_str->len -= 32;
                // remove trailing space (if any)
                if (func_command_str->len)
                    func_command_str->len--;
            }
        }
    }
}

void sub_chain(qbs *f) {
    if (is_error_pending())
        return;

#ifdef QB64_WINDOWS

    // run program
    static qbs *str = NULL;
    if (str == NULL)
        str = qbs_new(0, 0);
    static qbs *str2 = NULL;
    if (str2 == NULL)
        str2 = qbs_new(0, 0);

    static int32 i, i2, x;
    static qbs *strz = NULL;
    if (!strz)
        strz = qbs_new(0, 0);
    static char *cp;

    if (!f->len) {
        error(53);
        return;
    } // file not found (as in QB)
    qbs_set(str, f);
    qbs_set(str2, qbs_ucase(str));

    static qbs *f_exe = NULL;
    if (!f_exe)
        f_exe = qbs_new(0, 0);
    static qbs *f_bas = NULL;
    if (!f_bas)
        f_bas = qbs_new(0, 0); // no parameters
    static qbs *f_path = NULL;
    if (!f_path)
        f_path = qbs_new(0, 0);
    static int32 path_len;
    static qbs *current_path = NULL;
    if (!current_path)
        current_path = qbs_new(0, 0);
    static qbs *thisexe_path = NULL;
    if (!thisexe_path)
        thisexe_path = qbs_new(0, 0);

    // note: supports arguments after filename

    f_bas->len = 0;
    for (i = 0; i < str->len; i++) {
        if (str->chr[i] == 46) {
            //.bas?
            if ((i + 3) < str->len) {
                if ((str2->chr[i + 1] == 66) && (str2->chr[i + 2] == 65) && (str2->chr[i + 3] == 83)) { //"BAS"
                    qbs_set(f_bas, str);
                    f_bas->len = i + 4;  // arguments truncated
                    qbs_set(f_exe, str); // change .bas to .exe
                    f_exe->chr[i + 1] = 101;
                    f_exe->chr[i + 2] = 120;
                    f_exe->chr[i + 3] = 101; //"exe"
                    goto extensions_ready;
                } //"BAS"
            } // bas
            //.exe?
            if ((i + 3) < str->len) {
                if ((str2->chr[i + 1] == 69) && (str2->chr[i + 2] == 88) && (str2->chr[i + 3] == 69)) { //"EXE"
                    qbs_set(f_bas, str);
                    f_bas->len = i + 4; // arguments truncated, change .exe to .bas
                    f_bas->chr[i + 1] = 98;
                    f_bas->chr[i + 2] = 97;
                    f_exe->chr[i + 3] = 115; //"bas"
                    qbs_set(f_exe, str);     // note: exe kept as is
                    goto extensions_ready;
                } //"EXE"
            } // exe
            break; // no meaningful extension found
        } //"."
    }

    // no extension given!
    // note: It is more 'likely' that the user will want to pass arguments than
    // chain a
    //      filename containing spaces. Therefore, only everything left of
    //      left-most space will be considered the path+filename.
    i2 = str->len; // last character index of filename
    for (i = str->len - 1; i; i--) {
        if (str->chr[i] == 32)
            i2 = i;
    }
    qbs_set(str2, qbs_right(str, str->len - i2)); //[+extension]
    str->len = i2;                                //[path+]file
    qbs_set(f_exe, qbs_add(qbs_add(str, qbs_new_txt(".exe ")), str2));
    qbs_set(f_bas, qbs_add(str, qbs_new_txt(".bas")));

extensions_ready:

    // normalize dir slashes
    filepath_fix_directory(f_exe);
    filepath_fix_directory(f_bas);

    // get path (strip paths from f_exe & f_bas)
    f_path->len = 0;
    for (i = f_bas->len - 1; i >= 0; i--) {
        if ((f_bas->chr[i] == 92) || (f_bas->chr[i] == 47) || (f_bas->chr[i] == 58)) {
            qbs_set(f_path, f_bas);
            f_path->len = i + 1;
            if (f_bas->chr[i] == 58) {
                f_path->chr[i + 1] = 92;
                f_path->len++;
            } // add "\" to ":"
            // strip paths
            memmove(f_exe->chr, &f_exe->chr[i + 1], f_exe->len - (i + 1));
            f_exe->len -= (i + 1);
            memmove(f_bas->chr, &f_bas->chr[i + 1], f_bas->len - (i + 1));
            f_bas->len -= (i + 1);
            break;
        }
    }

    static uint8 path_data[4096];
    static int32 defaultpath;

    defaultpath = 0;
    if (!f_path->len) { // use current path if no path specified
        defaultpath = 1;
        // get current path (add \ if necessary)
        i = GetCurrentDirectoryA(4096, (char *)path_data);
        qbs_set(f_path, func_space(i + 1));
        memcpy(f_path->chr, path_data, i);
        if ((f_path->chr[i - 1] != 92) && (f_path->chr[i - 1] != 47)) {
            f_path->chr[i] = 92;
        } else {
            f_path->len--;
        }
    }

    // get current program's exe's path (including "\")
    GetModuleFileNameA(NULL, (char *)path_data, 4096);
    i = strlen((char *)path_data);
    for (i2 = i - 1; i2 >= 0; i2--) {
        x = path_data[i2];
        if ((x == 92) || (x == 47) || (x == 58)) {
            if (x == 58)
                i2++;
            i2++;
            break;
        }
    }
    qbs_set(thisexe_path, func_space(i2));
    memcpy(thisexe_path->chr, path_data, i2);
    thisexe_path->chr[i2] = 92; //"\"

    // 1. create & open a temporary file to pass information to the chained
    // program
    double TD;
    int32 TL, FF;
    qbs *TS = NULL;
    if (TS == NULL)
        TS = qbs_new(0, 0);
    qbs *TFS = NULL;
    if (TFS == NULL)
        TFS = qbs_new(0, 0);
    TD = func_timer(0.001E+0, 1);
    TL = qbr(std::floor(TD));
    TL = qbr((TD - TL) * 999);
    if (TL < 100)
        TL = 100; // ensure value is a 3 digit number
    qbs_set(TS, qbs_ltrim(qbs_str((int32)(TL))));
    qbs_set(TFS, qbs_add(qbs_add(qbs_new_txt_len("chain", 5), TS), qbs_new_txt_len(".tmp", 4)));
    FF = func_freefile();
    sub_open(TFS, 2, NULL, NULL, FF, NULL, 0); // opened in BINARY mode

    // add common data
    static int32 int32val, int32val2;
    static int64 int64val, int64val2;
    static qbs *tqbs;
    static int64 bytes, bytei;
    static ptrszint tmp_long;

    // CHDIR directive
    int32val = 512;
    sub_put(FF, NULL, byte_element((uint64)&int32val, 4), 0);
    int32val = f_path->len - 1;
    sub_put(FF, NULL, byte_element((uint64)&int32val, 4), 0);
    sub_put(FF, NULL, byte_element((uint64)f_path->chr, f_path->len - 1),
            0); //-1 removes trailing "\"

    chain_savescreenstate(FF);

#    include "../temp2/chain.txt"
    // add "end of commands" value
    int32val = 0;
    sub_put(FF, NULL, byte_element((uint64)&int32val, 4), 0);

    sub_close(FF, 1);

    // move chain???.tmp file to path
    if (!defaultpath) {
        qbs_set(str, qbs_new_txt("move /Y "));
        qbs_set(str, qbs_add(str, qbs_new_txt_len("\x022", 1)));
        qbs_set(str, qbs_add(str, TFS));
        qbs_set(str, qbs_add(str, qbs_new_txt_len("\x022", 1)));
        qbs_set(str, qbs_add(str, qbs_new_txt(" ")));
        qbs_set(str, qbs_add(str, qbs_new_txt_len("\x022", 1)));
        qbs_set(str, qbs_add(str, f_path));
        str->len--; // remove trailing "\" of dest path
        qbs_set(str, qbs_add(str, qbs_new_txt_len("\x022", 1)));
        qbs_set(strz, qbs_add(str, qbs_new_txt_len("\0", 1)));
        WinExec((char *)strz->chr, SW_HIDE);
    }

    static int32 method;
    method = 1;

chain_retry:

    if (method == 1) {
        qbs_set(str, qbs_add(f_path, f_exe));
    }

    if (method == 2) {
        // move chain???.tmp file to 'thisexe_path' path
        qbs_set(str, qbs_new_txt("move /Y "));
        qbs_set(str, qbs_add(str, qbs_new_txt_len("\x022", 1)));
        qbs_set(str, qbs_add(str, f_path));
        qbs_set(str, qbs_add(str, TFS));
        qbs_set(str, qbs_add(str, qbs_new_txt_len("\x022", 1)));
        qbs_set(str, qbs_add(str, qbs_new_txt(" ")));
        qbs_set(str, qbs_add(str, qbs_new_txt_len("\x022", 1)));
        qbs_set(str, qbs_add(str, thisexe_path));
        str->len--; // remove trailing "\" of dest path
        qbs_set(str, qbs_add(str, qbs_new_txt_len("\x022", 1)));
        qbs_set(strz, qbs_add(str, qbs_new_txt_len("\0", 1)));
        sub_shell(str, 1);
        qbs_set(str, qbs_add(thisexe_path, f_exe));
    }

    if (method == 3) {
        // attempt .bas compilation
        qbs_set(str, qbs_new_txt_len("\x022", 1));
        qbs_set(str, qbs_add(str, thisexe_path));
        qbs_set(str, qbs_add(str, qbs_new_txt("qb64pe.exe")));
        qbs_set(str, qbs_add(str, qbs_new_txt_len("\x022", 1)));
        qbs_set(str, qbs_add(str, qbs_new_txt(" -c ")));
        qbs_set(str, qbs_add(str, f_path));
        qbs_set(str, qbs_add(str, f_bas));
        sub_shell(str, 1);
        qbs_set(str, qbs_add(thisexe_path, f_exe));
    }

    // add a space
    qbs_set(str, qbs_add(str, qbs_new_txt(" ")));
    // add chain tag
    qbs_set(str, qbs_add(str, qbs_new_txt_len("(unique-tag:=/@*$+-)", 20)));
    // add chain file name
    qbs_set(str, qbs_add(str, TFS));
    // add NULL terminator
    qbs_set(strz, qbs_add(str, qbs_new_txt_len("\0", 1)));

#    ifdef QB64_WINDOWS

    if (WinExec((char *)strz->chr, SW_SHOWDEFAULT) > 31) {
        goto run_exit;
    } else {
        goto run_failed;
    }

#    else

    system((char *)strz->chr);
    // success?
    goto run_exit;

#    endif

// exit this program
run_exit:
    close_program = 1;
    end();
    exit(99); //<--this line should never actually be executed

// failed
run_failed:

    if (method == 1) {
        method = 2;
        goto chain_retry;
    }
    if (method == 2) {
        method = 3;
        goto chain_retry;
    }

    qbs_set(str, qbs_add(thisexe_path, TFS));
    sub_kill(str); // remove tmp file (chain specific)
    error(53);
    return; // file not found

#endif
}

// note: index 0 is unused
int32 device_last = 0;   // last used device
int32 device_max = 1000; // number of allocated indexes
device_struct *devices = (device_struct *)calloc(1000 + 1, sizeof(device_struct));

// device_struct helper functions
uint8 getDeviceEventButtonValue(device_struct *device, int32 eventIndex, int32 objectIndex) {
    return *(device->events + eventIndex * device->event_size + device->lastaxis * 4 + device->lastwheel * 4 + objectIndex);
}

void setDeviceEventButtonValue(device_struct *device, int32 eventIndex, int32 objectIndex, uint8 value) {
    *(device->events + eventIndex * device->event_size + device->lastaxis * 4 + device->lastwheel * 4 + objectIndex) = value;
}

float getDeviceEventAxisValue(device_struct *device, int32 eventIndex, int32 objectIndex) {
    return *(float *)(device->events + eventIndex * device->event_size + objectIndex * 4);
}

void setDeviceEventAxisValue(device_struct *device, int32 eventIndex, int32 objectIndex, float value) {
    *(float *)(device->events + eventIndex * device->event_size + objectIndex * 4) = value;
}

float getDeviceEventWheelValue(device_struct *device, int32 eventIndex, int32 objectIndex) {
    return *(float *)(device->events + eventIndex * device->event_size + device->lastaxis * 4 + objectIndex * 4);
}

void setDeviceEventWheelValue(device_struct *device, int32 eventIndex, int32 objectIndex, float value) {
    *(float *)(device->events + eventIndex * device->event_size + device->lastaxis * 4 + objectIndex * 4) = value;
}

void setupDevice(device_struct *device) {
    int32 size = device->lastaxis * 4 + device->lastwheel * 4 + device->lastbutton;
    size += 8; // for appended ordering index
    size += 7;
    size = size - (size & 7); // align to closest 8-byte boundary
    device->event_size = size;
    device->events = (uint8 *)calloc(2, device->event_size); // create initial 'current' and 'previous' events
    device->max_events = 2;
    device->queued_events = 2;
    device->connected = 1;
    device->used = 1;
}

int32 createDeviceEvent(device_struct *device) {
    uint8 *cp, *cp2;
    if (device->queued_events == device->max_events) { // expand/shift event buffer
        if (device->max_events >= QUEUED_EVENTS_LIMIT) {
            // discard base message
            memmove(device->events, device->events + device->event_size, (device->queued_events - 1) * device->event_size);
            device->queued_events--;
        } else {
            cp = (uint8 *)calloc(device->max_events * 2, device->event_size);       // create new buffer
            memcpy(cp, device->events, device->queued_events * device->event_size); // copy events from old buffer into
                                                                                    // new buffer
            cp2 = device->events;
            device->events = cp;
            device->max_events *= 2;
            free(cp2);
        }
    }
    // copy previous event data into new event
    memmove(device->events + device->queued_events * device->event_size, device->events + (device->queued_events - 1) * device->event_size, device->event_size);
    *(int64 *)(device->events + (device->queued_events * device->event_size) + (device->event_size - 8)) = device_event_index++; // set global event index
    int32 eventIndex = device->queued_events;
    return eventIndex;
}

void commitDeviceEvent(device_struct *device) {
    device->queued_events++;
}

int32 func__devices() {
    return device_last;
}

int32 device_selected = 0;

qbs *func__device(int32 i, int32 passed) {
    if (!passed)
        i = device_selected;
    if (i < 1 || i > device_last) {
        error(5);
        return qbs_new(0, 1);
    }
    return qbs_new_txt(devices[i].name);
}

int32 func__deviceinput(int32 i, int32 passed) {
    static device_struct *d;
    static int32 retval;
    retval = -1;
    device_selected = -1;

    if (!passed) {
        // find oldest event across all devices
        static int32 i2;
        static int64 index, lowest_index;
        i2 = -1;
        for (i = 1; i <= device_last; i++) {
            d = &devices[i];
            if (d->queued_events > 2) {
                index = *(int64 *)((d->events + d->event_size * 2) + (d->event_size - 8));
                if ((i2 == -1) || (index < lowest_index)) {
                    i2 = i;
                    lowest_index = index;
                    retval = i2;
                } // first/lower
            } // queued_events>2
        } // i
        if (i2 != -1)
            i = i2;
        else
            return 0;
    }

    if (i < 1 || i > device_last)
        error(5);
    d = &devices[i];

    device_selected = i;

    if (d->queued_events > 2) {
        memmove(d->events, ((uint8 *)d->events) + d->event_size, (d->queued_events - 1) * d->event_size);
        d->queued_events--;
        return retval;
    }

    return 0;
}

int32 func__button(int32 i, int32 passed) {
    if (device_selected < 1 || device_selected > device_last) {
        error(5);
        return 0;
    }
    static device_struct *d;
    d = &devices[device_selected];
    if (!passed)
        i = 1;
    if (i < 1 || i > d->lastbutton) {
        error(5);
        return 0;
    }
    if (getDeviceEventButtonValue(d, 1, i - 1))
        return -1;
    return 0;
}

int32 func__buttonchange(int32 i, int32 passed) {
    if (device_selected < 1 || device_selected > device_last) {
        error(5);
        return 0;
    }
    static device_struct *d;
    d = &devices[device_selected];
    if (!passed)
        i = 1;
    if (i < 1 || i > d->lastbutton) {
        error(5);
        return 0;
    }
    static int32 old_value, value;
    value = getDeviceEventButtonValue(d, 1, i - 1);
    old_value = getDeviceEventButtonValue(d, 0, i - 1);
    if (value > old_value)
        return -1;
    if (value < old_value)
        return 1;
    return 0;
}

float func__axis(int32 i, int32 passed) {
    if (device_selected < 1 || device_selected > device_last) {
        error(5);
        return 0;
    }
    static device_struct *d;
    d = &devices[device_selected];
    if (!passed)
        i = 1;
    if (i < 1 || i > d->lastaxis) {
        error(5);
        return 0;
    }
    return getDeviceEventAxisValue(d, 1, i - 1);
}

float func__wheel(int32 i, int32 passed) {
    if (device_selected < 1 || device_selected > device_last) {
        error(5);
        return 0;
    }
    static device_struct *d;
    d = &devices[device_selected];
    if (!passed)
        i = 1;
    if (i < 1 || i > d->lastwheel) {
        error(5);
        return 0;
    }
    return getDeviceEventWheelValue(d, 1, i - 1);
}

int32 func__lastbutton(int32 di, int32 passed) {
    if (!passed)
        di = device_selected;
    if (di < 1 || di > device_last)
        error(5);
    static device_struct *d;
    d = &devices[di];
    return d->lastbutton;
}

int32 func__lastaxis(int32 di, int32 passed) {
    if (!passed)
        di = device_selected;
    if (di < 1 || di > device_last)
        error(5);
    static device_struct *d;
    d = &devices[di];
    return d->lastaxis;
}

int32 func__lastwheel(int32 di, int32 passed) {
    if (!passed)
        di = device_selected;
    if (di < 1 || di > device_last)
        error(5);
    static device_struct *d;
    d = &devices[di];
    return d->lastwheel;
}

onstrig_struct *onstrig = (onstrig_struct *)calloc(65536, sizeof(onstrig_struct)); // note: up to 256 controllers with up to
                                                                                   // 256 buttons each supported
int32 onstrig_inprogress = 0;

void onstrig_setup(int32 i, int32 controller, int32 controller_passed, uint32 id, int64 pass) {
    // note: pass is ignored by ids not requiring a pass value
    if (is_error_pending())
        return;
    if (i < 0 || i > 65535) {
        error(5);
        return;
    }
    if (controller_passed) {
        if (controller < 1 || controller > 65535) {
            error(5);
            return;
        }
    } else {
        controller = 1;
        if (i & 2) {
            controller = 2;
            i -= 2;
        }
    }
    static int32 button;
    button = (i >> 2) + 1;
    if (i & 1) {
        error(5);
        return;
    } //'currently down' state cannot be used as an ON STRIG event
    if (controller > 256 || button > 256)
        return;                                // error-less exit for (currently) unsupported ranges
    i = (controller - 1) * 256 + (button - 1); // reindex
    onstrig[i].state = 0;
    onstrig[i].pass = pass;
    onstrig[i].id = id; // id must be set last because it is the trigger
                        // variable
    if (device_last == 0)
        func__devices(); // init device interface (if not already setup)
}

void sub_strig(int32 i, int32 controller, int32 option, int32 passed) {
    // ref: "[(?[,?])]{ON|OFF|STOP}"
    if (is_error_pending())
        return;
    // Note: QuickBASIC ignores STRIG ON and STRIG OFF statements--the
    // statements are provided for compatibility with earlier versions,
    //      Reference: http://www.antonis.de/qbebooks/gwbasman/strig.html
    //      QB64 makes STRIG ON/OFF/STOP change the checking status for all
    //      buttons
    static int32 i1, i2;
    if (passed > 0) {
        if (i < 0 || i > 65535) {
            error(5);
            return;
        }
        if (passed & 2) {
            if (controller < 1 || controller > 65535) {
                error(5);
                return;
            }
        } else {
            controller = 1;
            if (i & 2) {
                controller = 2;
                i -= 2;
            }
        }
        static int32 button;
        button = (i >> 2) + 1;
        if (i & 1) {
            error(5);
            return;
        } //'currently down' state cannot be used as an ON STRIG event
        if (controller > 256 || button > 256)
            return;                                // error-less exit for (currently) unsupported ranges
        i = (controller - 1) * 256 + (button - 1); // reindex
        i1 = i;
        i2 = i;
    } else {
        i1 = 0;
        i2 = 65535;
    }
    for (i = i1; i <= i2; i++) {
        // ref: uint8 active;//0=OFF, 1=ON, 2=STOP
        if (option == 1) { // ON
            onstrig[i].active = 1;
            if (onstrig[i].state)
                qbevent = 1;
        }
        if (option == 2) { // OFF
            onstrig[i].active = 0;
            onstrig[i].state = 0;
        }
        if (option == 3) { // STOP
            onstrig[i].active = 2;
            if (onstrig[i].state)
                onstrig[i].state = 1;
        }
    } // i
}

onkey_struct *onkey = (onkey_struct *)calloc(32, sizeof(onkey_struct));
int32 onkey_inprogress = 0;

void onkey_setup(int32 i, uint32 id, int64 pass) {
    // note: pass is ignored by ids not requiring a pass value
    if (is_error_pending())
        return;
    if ((i < 1) || (i > 31)) {
        error(5);
        return;
    }
    onkey[i].state = 0;
    onkey[i].pass = pass;
    onkey[i].id = id; // id must be set last because it is the trigger variable
}

void sub_key(int32 i, int32 option) {
    // ref: "(?){ON|OFF|STOP}"
    if (is_error_pending())
        return;
    if ((i < 0) || (i > 31)) {
        error(5);
        return;
    }
    static int32 i1, i2;
    i1 = i;
    i2 = i;
    if (!i) {
        i1 = i;
        i2 = 31;
    } // set all keys!
    for (i = i1; i <= i2; i++) {
        // ref: uint8 active;//0=OFF, 1=ON, 2=STOP
        if (option == 1) { // ON
            onkey[i].active = 1;
            if (onkey[i].state)
                qbevent = 1;
        }
        if (option == 2) { // OFF
            onkey[i].active = 0;
            onkey[i].state = 0;
        }
        if (option == 3) { // STOP
            onkey[i].active = 2;
            if (onkey[i].state)
                onkey[i].state = 1;
        }
    } // i
}

int32 ontimer_nextfree = 1;
int32 *ontimer_freelist = (int32 *)malloc(32);
uint32 ontimer_freelist_size = 8;      // number of elements in the freelist
uint32 ontimer_freelist_available = 0; // element (if any) which is available)
ontimer_struct *ontimer = (ontimer_struct *)malloc(sizeof(ontimer_struct));
// note: index 0 of the above cannot be allocated/freed

int32 ontimerthread_lock = 0;

void stop_timers() {
    ontimerthread_lock = 1;
    while (ontimerthread_lock != 2)
        ;
}

void start_timers() {
    ontimerthread_lock = 0;
}

int32 func__freetimer() {
    if (is_error_pending())
        return 0;
    static int32 i;
    if (ontimer_freelist_available) {
        i = ontimer_freelist[ontimer_freelist_available--];
    } else {
        ontimerthread_lock = 1;
        while (ontimerthread_lock == 1)
            Sleep(0); // mutex
        ontimer = (ontimer_struct *)realloc(ontimer, sizeof(ontimer_struct) * (ontimer_nextfree + 1));
        if (!ontimer)
            error(257);         // out of memory
        ontimerthread_lock = 0; // mutex
        i = ontimer_nextfree;
        ontimer[i].state = 0; // state is not set to 0 if reusing an existing
                              // index as event could still be in progress
    }
    ontimer[i].active = 0;
    ontimer[i].id = 0;
    ontimer[i].allocated = 1;
    if (i == ontimer_nextfree)
        ontimer_nextfree++;
    return i;
}

void freetimer(int32 i) {
    ontimer[i].allocated = 0;
    ontimer[i].id = 0;
    if (ontimer_freelist_available == ontimer_freelist_size) {
        ontimer_freelist_size *= 2;
        ontimer_freelist = (int32 *)realloc(ontimer_freelist, ontimer_freelist_size * 4);
    }
    ontimer_freelist[++ontimer_freelist_available] = i;
}

void ontimer_setup(int32 i, double sec, uint32 id, int64 pass) {
    // note: pass is ignored by ids not requiring a pass value
    if (is_error_pending())
        return;
    if ((i < 0) || (i >= ontimer_nextfree)) {
        error(5);
        return;
    }
    if (!ontimer[i].allocated) {
        error(5);
        return;
    }
    if (ontimer[i].state == 1)
        ontimer[i].state = 0; // retract prev event if not in progress
    ontimer[i].seconds = sec;
    ontimer[i].pass = pass;
    ontimer[i].last_time = 0;
    ontimer[i].id = id; // id must be set last because it is the trigger
                        // variable
}

void sub_timer(int32 i, int32 option, int32 passed) {
    // ref: "[(?)]{ON|OFF|STOP|FREE}"
    if (is_error_pending())
        return;
    if (!passed)
        i = 0;
    if ((i < 0) || (i >= ontimer_nextfree)) {
        error(5);
        return;
    }
    if (!ontimer[i].allocated) {
        error(5);
        return;
    }
    // ref: uint8 active;//0=OFF, 1=ON, 2=STOP
    if (option == 1) { // ON
        ontimer[i].active = 1;

        // This is necessary so that if a timer triggered while stopped we will run it now.
        qbevent = 1;
        return;
    }
    if (option == 2) { // OFF
        ontimer[i].active = 0;
        if (ontimer[i].state == 1)
            ontimer[i].state = 0; // retract event if not in progress
        ontimer[i].last_time = 0; // when ON is next used, the timer will start over
        return;
    }
    if (option == 3) { // STOP
        ontimer[i].active = 2;
        return;
    }
    if (option == 4) { // FREE
        if (i == 0) {
            error(5);
            return;
        }
        ontimer[i].active = 0;
        if (ontimer[i].state == 1)
            ontimer[i].state = 0; // retract event if not in progress
        freetimer(i);
        // note: if an event is still in progress, it will set state to 0 when
        // it finishes
        //      which may delay the first instance of this index if it is
        //      immediately reused
        return;
    }
}

void TIMERTHREAD(void *unused) {
    static int32 i;
    static double time_now = 100000;
    while (1) {
    quick_lock:
        if (ontimerthread_lock == 1)
            ontimerthread_lock = 2; // mutex, verify lock
        if (!ontimerthread_lock) {  // mutex
            time_now = ((double)GetTicks()) * 0.001;
            for (i = 0; i < ontimer_nextfree; i++) {
                if (ontimer[i].allocated && ontimer[i].id && ontimer[i].active && !ontimer[i].state) {
                    if (!ontimer[i].last_time) {
                        ontimer[i].last_time = time_now;
                    } else if (time_now - ontimer[i].last_time > ontimer[i].seconds) {
                        // keep measured time for accurate
                        // number of calls overall
                        ontimer[i].last_time += ontimer[i].seconds;

                        // if difference between actual time and
                        // measured time is beyond 'seconds' set
                        // measured to actual
                        if (std::fabs(time_now - ontimer[i].last_time) >= ontimer[i].seconds)
                            ontimer[i].last_time = time_now;
                        ontimer[i].state = 1;
                        qbevent = 1;
                    } // time check
                }
                if (ontimerthread_lock == 1)
                    goto quick_lock;
            } // i
        } // not locked
        Sleep(1);
        if (stop_program) {
            exit_ok |= 2;
            return;
        } // close thread #2
    } // while(1)
    return;
}

void events() {
    int32 i, x, d, di;
    int64 i64;

// onstrig events
onstrig_recheck:
    if (!error_handling) { // no new calls happen whilst error handling
        di = 0;
        for (d = 1; d <= device_last; d++) {
            if (devices[d].type == 1) {
                if (di <= 255) {
                    for (i = 0; i <= 255; i++) {
                        if (onstrig[(di << 8) + i].id) {
                            if (onstrig[(di << 8) + i].active == 1) { // if STOPped, event will be postponed
                                if (onstrig[(di << 8) + i].state) {
                                    if (!onstrig_inprogress) {
                                        onstrig_inprogress = 1;
                                        onstrig[(di << 8) + i].state--;
                                        x = onstrig[(di << 8) + i].id;
                                        i64 = onstrig[(di << 8) + i].pass;
                                        switch (x) {
#include "../temp2/onstrig.txt"
                                        // example.....
                                        // case 1:
                                        //...
                                        // break;
                                        default:
                                            break;
                                        } // switch
                                        onstrig_inprogress = 0;
                                        goto onstrig_recheck;
                                    } //! inprogress
                                } // state
                            } // active==1
                        } // id
                    } // i
                } // di<=255
                di++;
            } // type==1
        } // d
    } //! error_handling

// onkey events
onkey_recheck:
    if (!error_handling) { // no new calls happen whilst error handling
        for (i = 1; i <= 31; i++) {
            if (onkey[i].id) {
                if (onkey[i].active == 1) { // if STOPped, event will be postponed
                    if (onkey[i].state) {
                        if (!onkey_inprogress) {
                            onkey_inprogress = 1;
                            onkey[i].state--;
                            x = onkey[i].id;
                            i64 = onkey[i].pass;
                            switch (x) {
#include "../temp2/onkey.txt"
                            // example.....
                            // case 1:
                            //...
                            // break;
                            default:
                                break;
                            } // switch
                            onkey_inprogress = 0;
                            goto onkey_recheck;
                        } //! inprogress
                    } // state
                } // active==1
            } // id
        } // i
    } //! error_handling

    // ontimer events
    if (!error_handling) { // no new on timer calls happen whilst error handling
        for (i = 0; i < ontimer_nextfree; i++) {
            if (ontimer[i].allocated) {
                if (ontimer[i].id) {
                    if (ontimer[i].active == 1) { // if timer STOPped, event will be postponed
                        if (ontimer[i].state == 1) {
                            ontimer[i].state = 2; // event in progress
                            x = ontimer[i].id;
                            i64 = ontimer[i].pass;
                            switch (x) {
#include "../temp2/ontimer.txt"
                            // example.....
                            // case 1:
                            //...
                            // break;
                            default:
                                break;
                            } // switch
                            ontimer[i].state = 0; // event finished
                            sleep_break = 1;
                        } // state==1
                    } // active==1
                } // id
            } // allocated
        } // i
    } //! error_handling
}

extern int64 display_lock_request;
extern int64 display_lock_confirmed;
extern int64 display_lock_released;

uint32 r;

void evnt(uint32 linenumber, uint32 inclinenumber, const char *incfilename) {
    if (disableEvents)
        return;

    qbevent = 0;

    if (sub_gl_called == 0) {
        if (display_lock_request > display_lock_confirmed) {
            display_lock_confirmed = display_lock_request;
            while ((display_lock_released < display_lock_confirmed) && (!close_program) && (!suspend_program) && (!stop_program))
                Sleep(1);
        }
    }

    r = 0;

    while (suspend_program || stop_program) {
        if (stop_program)
            end();
        Sleep(10);
    }

    if (is_error_pending()) {
        error_set_line(linenumber, inclinenumber, incfilename);
        fix_error();
        if (error_retry) {
            error_retry = 0;
            r = 1;
        }
    } else {
        if (sub_gl_called == 0)
            events();
    }
}

uint8 *redim_preserve_cmem_buffer = (uint8 *)malloc(65536); // used for temporary storage only (move to libqbx?)

void division_by_zero_handler(int ignore) {
    error(11);
}

void segv_handler(int ignore) {
    libqb_log_error("Recieved SIGSEGV! Review below stacktrace:");
    exit(1);
}

// void SIGSEGV_handler(int ignore){
//    error(256);//assume stack overflow? (the most likely cause)
//}

void QBMAIN(void *unused) {
    fpu_reinit();
#ifdef QB64_WINDOWS
    signal(SIGFPE, division_by_zero_handler);
// signal(SIGSEGV, SIGSEGV_handler);
#else
    struct sigaction sig_act;
    sig_act.sa_handler = division_by_zero_handler;
    sigemptyset(&(sig_act.sa_mask));
    sig_act.sa_flags = 0;
    sigaction(SIGFPE, &sig_act, NULL);

    signal(SIGSEGV, segv_handler);
#endif

    ptrszint tmp_long;
    int32 tmp_fileno;
    qbs *tqbs;
    uint32 qbs_tmp_base = qbs_tmp_list_nexti;
    static mem_lock *sf_mem_lock = NULL;
    if (!sf_mem_lock) {
        new_mem_lock();
        sf_mem_lock = mem_lock_tmp;
        sf_mem_lock->type = 3;
    }

#include "../temp2/maindata.txt"
#include "../temp2/mainerr.txt"
#include "../temp2/runline.txt"
    if (timer_event_occurred) {
        timer_event_occurred--;
#include "../temp2/ontimerj.txt"
    }
    if (key_event_occurred) {
        key_event_occurred--;
#include "../temp2/onkeyj.txt"
    }
    if (strig_event_occurred) {
        strig_event_occurred--;
#include "../temp2/onstrigj.txt"
    }
    chain_input();
    libqb_log_info("QB64 code starting.");

#include "../temp2/main.txt"

    //} (closed by main.txt)
