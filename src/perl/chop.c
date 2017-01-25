#ifdef __cplusplus
extern "C" {
#endif

#include "/home/akittel/include/EXTERN.h"
#include "/home/akittel/include/perl.h"

#ifdef __cplusplus
}
#  define EXTERN_C extern "C"
#else
#  define EXTERN_C extern
#endif

/* Workaround for mapstart: the only op which needs a different ppaddr */
#define pp_mapstart pp_grepstart

static void xs_init _((void));
static PerlInterpreter *my_perl;

#ifdef BROKEN_STATIC_REDECL
#define Static extern
#else
#define Static static
#endif /* BROKEN_STATIC_REDECL */

#ifdef BROKEN_UNION_INIT
/*
 * Cribbed from cv.h with ANY (a union) replaced by char *.
 * Some pre-Standard compilers can't cope with initialising unions. Ho hum.
 */
typedef struct {
    char *	xpv_pv;		/* pointer to malloced string */
    STRLEN	xpv_cur;	/* length of xp_pv as a C string */
    STRLEN	xpv_len;	/* allocated size */
    IV		xof_off;	/* integer value */
    double	xnv_nv;		/* numeric value, if any */
    MAGIC*	xmg_magic;	/* magic for scalar array */
    HV*		xmg_stash;	/* class package */

    HV *	xcv_stash;
    OP *	xcv_start;
    OP *	xcv_root;
    void      (*xcv_xsub) _((CV*));
    char *	xcv_xsubany;
    GV *	xcv_gv;
    GV *	xcv_filegv;
    long	xcv_depth;		/* >= 2 indicates recursive call */
    AV *	xcv_padlist;
    CV *	xcv_outside;
    U8		xcv_flags;
} XPVCV_or_similar;
#define Nullany 0
#else
#define XPVCV_or_similar XPVCV
#define Nullany {0}
#endif /* BROKEN_UNION_INIT */

#define UNUSED 0

Static OP op_list[27];
Static UNOP unop_list[56];
Static BINOP binop_list[20];
Static LOGOP logop_list[4];
Static CONDOP condop_list[1];
Static LISTOP listop_list[22];
Static PMOP pmop_list[2];
Static SVOP svop_list[12];
Static GVOP gvop_list[48];
Static LOOP loop_list[2];
Static COP cop_list[34];
Static SV sv_list[39];
Static XPV xpv_list[1];
Static XPVIV xpviv_list[12];
Static XPVBM xpvbm_list[1];
Static XPVAV xpvav_list[3];
Static XPVIO xpvio_list[4];
static GV *gv_list[13];

static HV *hv0;
static char *re0 = "From ";
static char *re1 = "From Mailer-Daemon|From root|From smmtoper|From oper|From akittel";

static OP op_list[27] = {
    { (OP*)&cop_list[0], (OP*)&cop_list[0], pp_enter, 0, 174, 65535, 0x0, 0x0 },
    { (OP*)&gvop_list[0], (OP*)&gvop_list[0], pp_null, 3, 0, 65535, 0x2, 0x0 },
    { (OP*)&gvop_list[1], (OP*)&gvop_list[1], pp_null, 3, 0, 65535, 0x2, 0x0 },
    { (OP*)&gvop_list[2], (OP*)&gvop_list[2], pp_null, 3, 0, 65535, 0x2, 0x0 },
    { (OP*)&gvop_list[3], (OP*)&gvop_list[3], pp_null, 3, 0, 65535, 0x2, 0x0 },
    { (OP*)&gvop_list[4], (OP*)&unop_list[1], pp_pushmark, 0, 3, 65535, 0x2, 0x0 },
    { (OP*)&gvop_list[5], (OP*)&unop_list[3], pp_pushmark, 0, 3, 65535, 0x2, 0x0 },
    { (OP*)&gvop_list[11], (OP*)&gvop_list[11], pp_null, 3, 0, 65535, 0x2, 0x0 },
    { (OP*)&gvop_list[12], (OP*)&binop_list[5], pp_pushmark, 0, 3, 65535, 0x2, 0x0 },
    { (OP*)&gvop_list[9], 0, pp_unstack, 0, 173, 65535, 0x2, 0x0 },
    { &op_list[12], (OP*)&unop_list[23], pp_enter, 0, 174, 65535, 0x2, 0x0 },
    { (OP*)&gvop_list[22], (OP*)&unop_list[25], pp_pushmark, 0, 3, 65535, 0x2, 0x0 },
    { (OP*)&cop_list[17], (OP*)&cop_list[17], pp_enter, 0, 174, 65535, 0x2, 0x0 },
    { &op_list[11], 0, pp_unstack, 0, 173, 65535, 0x2, 0x0 },
    { (OP*)&gvop_list[32], (OP*)&unop_list[39], pp_pushmark, 0, 3, 65535, 0x2, 0x0 },
    { (OP*)&cop_list[21], (OP*)&cop_list[21], pp_enter, 0, 174, 65535, 0x2, 0x0 },
    { (OP*)&gvop_list[34], (OP*)&gvop_list[34], pp_null, 3, 0, 65535, 0x2, 0x0 },
    { (OP*)&gvop_list[35], (OP*)&unop_list[41], pp_pushmark, 0, 3, 65535, 0x2, 0x0 },
    { (OP*)&svop_list[9], (OP*)&svop_list[9], pp_pushmark, 0, 3, 65535, 0x2, 0x0 },
    { (OP*)&gvop_list[36], (OP*)&unop_list[44], pp_pushmark, 0, 3, 65535, 0x2, 0x0 },
    { (OP*)&cop_list[24], (OP*)&cop_list[24], pp_enter, 0, 174, 65535, 0x2, 0x0 },
    { (OP*)&gvop_list[37], (OP*)&gvop_list[37], pp_null, 3, 0, 65535, 0x2, 0x0 },
    { (OP*)&gvop_list[38], (OP*)&unop_list[45], pp_pushmark, 0, 3, 65535, 0x2, 0x0 },
    { (OP*)&svop_list[10], (OP*)&svop_list[10], pp_pushmark, 0, 3, 65535, 0x2, 0x0 },
    { (OP*)&gvop_list[39], (OP*)&unop_list[48], pp_pushmark, 0, 3, 65535, 0x2, 0x0 },
    { (OP*)&gvop_list[40], (OP*)&gvop_list[40], pp_null, 3, 0, 65535, 0x2, 0x0 },
    { (OP*)&gvop_list[19], 0, pp_unstack, 0, 173, 65535, 0x2, 0x0 },
};

static UNOP unop_list[56] = {
    { &op_list[6], (OP*)&unop_list[2], pp_null, 139, 0, 65535, 0x7, 0x0, &op_list[5] },
    { &op_list[6], 0, pp_readline, 2, 26, 65535, 0x7, 0x1, (OP*)&gvop_list[4] },
    { (OP*)&binop_list[0], 0, pp_null, 139, 0, 65535, 0x7, 0x0, &op_list[6] },
    { (OP*)&binop_list[0], 0, pp_rv2av, 1, 123, 65535, 0xb7, 0x1, (OP*)&gvop_list[5] },
    { (OP*)&gvop_list[7], (OP*)&unop_list[5], pp_rv2av, 1, 123, 65535, 0x6, 0x1, (OP*)&gvop_list[6] },
    { (OP*)&binop_list[1], 0, pp_null, 15, 0, 65535, 0xb6, 0x1, (OP*)&gvop_list[7] },
    { (OP*)&binop_list[2], 0, pp_null, 15, 0, 65535, 0xb6, 0x1, (OP*)&gvop_list[8] },
    { (OP*)&binop_list[3], 0, pp_null, 0, 0, 65535, 0x6, 0x41, (OP*)&logop_list[0] },
    { (OP*)&gvop_list[10], (OP*)&unop_list[9], pp_null, 15, 0, 65535, 0x6, 0x1, (OP*)&gvop_list[9] },
    { (OP*)&binop_list[4], 0, pp_null, 15, 0, 65535, 0x6, 0x1, (OP*)&gvop_list[10] },
    { (OP*)&gvop_list[13], (OP*)&unop_list[11], pp_rv2av, 0, 123, 65535, 0x16, 0x1, (OP*)&gvop_list[12] },
    { (OP*)&binop_list[5], 0, pp_null, 15, 0, 65535, 0x6, 0x1, (OP*)&gvop_list[13] },
    { &op_list[9], &op_list[9], pp_preinc, 1, 44, 65535, 0x6, 0x1, (OP*)&unop_list[13] },
    { (OP*)&unop_list[12], 0, pp_null, 15, 0, 65535, 0x36, 0x1, (OP*)&gvop_list[14] },
    { (OP*)&binop_list[6], 0, pp_null, 15, 0, 65535, 0xb6, 0x1, (OP*)&gvop_list[15] },
    { (OP*)&binop_list[7], 0, pp_null, 15, 0, 65535, 0xb6, 0x1, (OP*)&gvop_list[16] },
    { (OP*)&binop_list[8], 0, pp_null, 15, 0, 65535, 0xb6, 0x1, (OP*)&gvop_list[17] },
    { (OP*)&binop_list[9], 0, pp_null, 15, 0, 65535, 0xb6, 0x1, (OP*)&gvop_list[18] },
    { (OP*)&binop_list[10], 0, pp_null, 0, 0, 65535, 0x6, 0x41, (OP*)&logop_list[1] },
    { (OP*)&gvop_list[20], (OP*)&unop_list[20], pp_null, 15, 0, 65535, 0x6, 0x1, (OP*)&gvop_list[19] },
    { (OP*)&binop_list[11], 0, pp_null, 15, 0, 65535, 0x6, 0x1, (OP*)&gvop_list[20] },
    { (OP*)&cop_list[16], (OP*)&cop_list[16], pp_preinc, 3, 44, 65535, 0x6, 0x1, (OP*)&unop_list[22] },
    { (OP*)&unop_list[21], 0, pp_null, 15, 0, 65535, 0x36, 0x1, (OP*)&gvop_list[21] },
    { (OP*)&listop_list[10], 0, pp_null, 0, 0, 65535, 0xe, 0x41, (OP*)&logop_list[2] },
    { (OP*)&logop_list[2], (OP*)&listop_list[12], pp_null, 0, 0, 65535, 0x6, 0x1, (OP*)&logop_list[3] },
    { (OP*)&gvop_list[23], (OP*)&unop_list[26], pp_null, 15, 0, 65535, 0x6, 0x1, (OP*)&gvop_list[22] },
    { (OP*)&listop_list[11], 0, pp_rv2av, 5, 123, 65535, 0x16, 0x1, (OP*)&gvop_list[23] },
    { (OP*)&gvop_list[25], (OP*)&unop_list[28], pp_null, 15, 0, 65535, 0x6, 0x1, (OP*)&gvop_list[24] },
    { (OP*)&binop_list[12], 0, pp_null, 15, 0, 65535, 0x6, 0x1, (OP*)&gvop_list[25] },
    { &op_list[13], &op_list[13], pp_null, 0, 0, 65535, 0x86, 0x41, (OP*)&listop_list[13] },
    { (OP*)&gvop_list[27], (OP*)&unop_list[31], pp_rv2av, 0, 123, 65535, 0x16, 0x1, (OP*)&gvop_list[26] },
    { (OP*)&binop_list[14], 0, pp_null, 15, 0, 65535, 0x6, 0x1, (OP*)&gvop_list[27] },
    { (OP*)&gvop_list[29], (OP*)&unop_list[33], pp_rv2av, 0, 123, 65535, 0x16, 0x1, (OP*)&gvop_list[28] },
    { (OP*)&binop_list[15], 0, pp_null, 15, 0, 65535, 0x6, 0x1, (OP*)&gvop_list[29] },
    { (OP*)&cop_list[19], (OP*)&cop_list[19], pp_preinc, 4, 44, 65535, 0x6, 0x1, (OP*)&unop_list[35] },
    { (OP*)&unop_list[34], 0, pp_null, 15, 0, 65535, 0x36, 0x1, (OP*)&gvop_list[30] },
    { (OP*)&listop_list[13], 0, pp_preinc, 4, 44, 65535, 0x6, 0x1, (OP*)&unop_list[37] },
    { (OP*)&unop_list[36], 0, pp_null, 15, 0, 65535, 0x36, 0x1, (OP*)&gvop_list[31] },
    { (OP*)&cop_list[27], (OP*)&cop_list[27], pp_null, 0, 0, 65535, 0x6, 0x41, (OP*)&condop_list[0] },
    { (OP*)&gvop_list[33], (OP*)&unop_list[40], pp_null, 15, 0, 65535, 0x6, 0x1, (OP*)&gvop_list[32] },
    { (OP*)&listop_list[14], 0, pp_rv2av, 3, 123, 65535, 0x16, 0x1, (OP*)&gvop_list[33] },
    { (OP*)&listop_list[17], 0, pp_rv2av, 4, 123, 65535, 0x7, 0x1, (OP*)&gvop_list[35] },
    { &op_list[19], (OP*)&unop_list[43], pp_null, 139, 0, 65535, 0x7, 0x0, &op_list[18] },
    { (OP*)&binop_list[16], 0, pp_null, 139, 0, 65535, 0x7, 0x0, &op_list[19] },
    { (OP*)&binop_list[16], 0, pp_rv2av, 4, 123, 65535, 0xb7, 0x1, (OP*)&gvop_list[36] },
    { (OP*)&listop_list[20], 0, pp_rv2av, 6, 123, 65535, 0x7, 0x1, (OP*)&gvop_list[38] },
    { &op_list[24], (OP*)&unop_list[47], pp_null, 139, 0, 65535, 0x7, 0x0, &op_list[23] },
    { (OP*)&binop_list[17], 0, pp_null, 139, 0, 65535, 0x7, 0x0, &op_list[24] },
    { (OP*)&binop_list[17], 0, pp_rv2av, 6, 123, 65535, 0xb7, 0x1, (OP*)&gvop_list[39] },
    { (OP*)&gvop_list[42], (OP*)&unop_list[50], pp_null, 15, 0, 65535, 0x6, 0x1, (OP*)&gvop_list[41] },
    { (OP*)&binop_list[18], 0, pp_null, 15, 0, 65535, 0xb6, 0x1, (OP*)&gvop_list[42] },
    { (OP*)&binop_list[19], 0, pp_null, 15, 0, 65535, 0xb6, 0x1, (OP*)&gvop_list[43] },
    { (OP*)&cop_list[31], (OP*)&cop_list[31], pp_close, 0, 189, 65535, 0x6, 0x1, (OP*)&gvop_list[44] },
    { (OP*)&cop_list[32], (OP*)&cop_list[32], pp_close, 0, 189, 65535, 0x6, 0x1, (OP*)&gvop_list[45] },
    { (OP*)&cop_list[33], (OP*)&cop_list[33], pp_close, 0, 189, 65535, 0x6, 0x1, (OP*)&gvop_list[46] },
    { (OP*)&listop_list[0], 0, pp_close, 0, 189, 65535, 0x6, 0x1, (OP*)&gvop_list[47] },
};

static BINOP binop_list[20] = {
    { (OP*)&cop_list[5], (OP*)&cop_list[5], pp_aassign, 3, 35, 65535, 0x46, 0x0, (OP*)&unop_list[0], (OP*)&unop_list[2] },
    { (OP*)&cop_list[6], (OP*)&cop_list[6], pp_sassign, 0, 34, 65535, 0x46, 0x2, (OP*)&unop_list[4], (OP*)&unop_list[5] },
    { (OP*)&cop_list[7], (OP*)&listop_list[5], pp_sassign, 0, 34, 65535, 0x46, 0x2, (OP*)&svop_list[4], (OP*)&unop_list[6] },
    { (OP*)&cop_list[10], 0, pp_leaveloop, 0, 180, 65535, 0x6, 0x42, (OP*)&loop_list[0], (OP*)&unop_list[7] },
    { (OP*)&logop_list[0], (OP*)&listop_list[6], pp_le, 0, 72, 65535, 0x6, 0x2, (OP*)&unop_list[8], (OP*)&unop_list[9] },
    { (OP*)&listop_list[8], 0, pp_aelem, 0, 125, 65535, 0x6, 0x2, (OP*)&unop_list[10], (OP*)&unop_list[11] },
    { (OP*)&cop_list[11], (OP*)&cop_list[11], pp_sassign, 0, 34, 65535, 0x46, 0x2, (OP*)&svop_list[5], (OP*)&unop_list[14] },
    { (OP*)&cop_list[12], (OP*)&cop_list[12], pp_sassign, 0, 34, 65535, 0x46, 0x2, (OP*)&svop_list[6], (OP*)&unop_list[15] },
    { (OP*)&cop_list[13], (OP*)&cop_list[13], pp_sassign, 0, 34, 65535, 0x46, 0x2, (OP*)&svop_list[7], (OP*)&unop_list[16] },
    { (OP*)&cop_list[14], (OP*)&cop_list[14], pp_sassign, 0, 34, 65535, 0x46, 0x2, (OP*)&svop_list[8], (OP*)&unop_list[17] },
    { (OP*)&cop_list[30], (OP*)&cop_list[30], pp_leaveloop, 0, 180, 65535, 0x6, 0x42, (OP*)&loop_list[1], (OP*)&unop_list[18] },
    { (OP*)&logop_list[1], (OP*)&listop_list[9], pp_lt, 0, 68, 65535, 0x6, 0x2, (OP*)&unop_list[19], (OP*)&unop_list[20] },
    { (OP*)&logop_list[2], 0, pp_eq, 0, 76, 65535, 0x6, 0x2, (OP*)&unop_list[27], (OP*)&unop_list[28] },
    { (OP*)&cop_list[18], (OP*)&cop_list[18], pp_sassign, 0, 34, 65535, 0x46, 0x2, (OP*)&binop_list[14], (OP*)&binop_list[15] },
    { (OP*)&gvop_list[28], (OP*)&binop_list[15], pp_aelem, 0, 125, 65535, 0x6, 0x2, (OP*)&unop_list[30], (OP*)&unop_list[31] },
    { (OP*)&binop_list[13], 0, pp_aelem, 0, 125, 65535, 0xb6, 0x2, (OP*)&unop_list[32], (OP*)&unop_list[33] },
    { (OP*)&listop_list[15], 0, pp_aassign, 5, 35, 65535, 0x46, 0x0, (OP*)&unop_list[42], (OP*)&unop_list[43] },
    { (OP*)&listop_list[18], 0, pp_aassign, 7, 35, 65535, 0x46, 0x0, (OP*)&unop_list[46], (OP*)&unop_list[47] },
    { (OP*)&cop_list[29], (OP*)&cop_list[29], pp_sassign, 0, 34, 65535, 0x46, 0x2, (OP*)&unop_list[49], (OP*)&unop_list[50] },
    { &op_list[26], &op_list[26], pp_sassign, 0, 34, 65535, 0x46, 0x2, (OP*)&svop_list[11], (OP*)&unop_list[51] },
};

static LOGOP logop_list[4] = {
    { (OP*)&binop_list[3], 0, pp_and, 0, 157, 65535, 0x6, 0x1, (OP*)&binop_list[4], (OP*)&cop_list[8] },
    { (OP*)&binop_list[10], 0, pp_and, 0, 157, 65535, 0x6, 0x1, (OP*)&binop_list[11], (OP*)&cop_list[15] },
    { (OP*)&listop_list[10], 0, pp_or, 0, 158, 65535, 0x6, 0x1, (OP*)&unop_list[24], &op_list[12] },
    { (OP*)&logop_list[2], 0, pp_or, 0, 158, 65535, 0x6, 0x1, (OP*)&pmop_list[0], (OP*)&gvop_list[24] },
};

static CONDOP condop_list[1] = {
    { (OP*)&cop_list[27], 0, pp_cond_expr, 0, 160, 65535, 0x6, 0x1, (OP*)&pmop_list[1], &op_list[15], &op_list[20] },
};

static LISTOP listop_list[22] = {
    { 0, 0, pp_leave, 0, 175, 65535, 0xe, 0x0, &op_list[0], (OP*)&unop_list[55], 34 },
    { (OP*)&cop_list[1], (OP*)&cop_list[1], pp_open, 1, 188, 65535, 0x6, 0x2, &op_list[1], (OP*)&svop_list[0], 2 },
    { (OP*)&cop_list[2], (OP*)&cop_list[2], pp_open, 1, 188, 65535, 0x6, 0x2, &op_list[2], (OP*)&svop_list[1], 2 },
    { (OP*)&cop_list[3], (OP*)&cop_list[3], pp_open, 1, 188, 65535, 0x6, 0x2, &op_list[3], (OP*)&svop_list[2], 2 },
    { (OP*)&cop_list[4], (OP*)&cop_list[4], pp_open, 1, 188, 65535, 0x6, 0x2, &op_list[4], (OP*)&svop_list[3], 2 },
    { (OP*)&cop_list[10], (OP*)&cop_list[10], pp_lineseq, 0, 170, 65535, 0x6, 0x0, (OP*)&cop_list[7], (OP*)&binop_list[3], 2 },
    { (OP*)&unop_list[7], 0, pp_lineseq, 0, 170, 65535, 0xe, 0x0, (OP*)&cop_list[8], &op_list[9], 6 },
    { (OP*)&cop_list[9], (OP*)&cop_list[9], pp_select, 2, 200, 65535, 0x6, 0x1, &op_list[7], (OP*)&gvop_list[11], 1 },
    { (OP*)&gvop_list[14], (OP*)&unop_list[12], pp_print, 0, 206, 65535, 0x6, 0x0, &op_list[8], (OP*)&binop_list[5], 1 },
    { (OP*)&unop_list[18], 0, pp_lineseq, 0, 170, 65535, 0xe, 0x0, (OP*)&cop_list[15], &op_list[26], 13 },
    { (OP*)&cop_list[20], (OP*)&cop_list[20], pp_leave, 0, 175, 65535, 0x86, 0x40, &op_list[10], (OP*)&unop_list[23], 2 },
    { (OP*)&pmop_list[0], 0, pp_aslice, 0, 126, 65535, 0x6, 0x0, &op_list[11], (OP*)&unop_list[26], 3 },
    { (OP*)&unop_list[23], 0, pp_lineseq, 0, 170, 65535, 0x6, 0x0, (OP*)&unop_list[29], &op_list[13], 2 },
    { &op_list[13], 0, pp_leave, 0, 175, 65535, 0xe, 0x40, &op_list[12], (OP*)&unop_list[36], 7 },
    { (OP*)&pmop_list[1], 0, pp_aslice, 0, 126, 65535, 0x6, 0x0, &op_list[14], (OP*)&unop_list[40], 3 },
    { (OP*)&cop_list[27], (OP*)&listop_list[18], pp_leave, 0, 175, 65535, 0xe, 0x40, &op_list[15], (OP*)&binop_list[16], 7 },
    { (OP*)&cop_list[22], (OP*)&cop_list[22], pp_select, 4, 200, 65535, 0x6, 0x1, &op_list[16], (OP*)&gvop_list[34], 1 },
    { (OP*)&cop_list[23], (OP*)&cop_list[23], pp_print, 0, 206, 65535, 0x6, 0x0, &op_list[17], (OP*)&unop_list[41], 1 },
    { (OP*)&cop_list[27], 0, pp_leave, 0, 175, 65535, 0xe, 0x40, &op_list[20], (OP*)&binop_list[17], 7 },
    { (OP*)&cop_list[25], (OP*)&cop_list[25], pp_select, 6, 200, 65535, 0x6, 0x1, &op_list[21], (OP*)&gvop_list[37], 1 },
    { (OP*)&cop_list[26], (OP*)&cop_list[26], pp_print, 0, 206, 65535, 0x6, 0x0, &op_list[22], (OP*)&unop_list[45], 1 },
    { (OP*)&cop_list[28], (OP*)&cop_list[28], pp_select, 3, 200, 65535, 0x6, 0x1, &op_list[25], (OP*)&gvop_list[40], 1 },
};

static PMOP pmop_list[2] = {
    { (OP*)&logop_list[3], (OP*)&binop_list[12], pp_match, 0, 30, 65535, 0x46, 0x0, (OP*)&listop_list[11], (OP*)&listop_list[11], 1, 0, 0, 0, 0, &sv_list[33], 0x4, 0x0, 5 },
    { (OP*)&condop_list[0], (OP*)&listop_list[15], pp_match, 0, 30, 65535, 0x46, 0x0, (OP*)&listop_list[14], (OP*)&listop_list[14], 1, 0, 0, 0, 0, Nullsv, 0x0, 0x0, 0 },
};

static SVOP svop_list[12] = {
    { (OP*)&listop_list[1], 0, pp_const, 0, 5, 65535, 0x2, 0x0, (SV*)&sv_list[11] },
    { (OP*)&listop_list[2], 0, pp_const, 0, 5, 65535, 0x2, 0x0, (SV*)&sv_list[14] },
    { (OP*)&listop_list[3], 0, pp_const, 0, 5, 65535, 0x2, 0x0, (SV*)&sv_list[17] },
    { (OP*)&listop_list[4], 0, pp_const, 0, 5, 65535, 0x2, 0x0, (SV*)&sv_list[20] },
    { (OP*)&gvop_list[8], (OP*)&unop_list[6], pp_const, 0, 5, 65535, 0x2, 0x0, (SV*)&sv_list[24] },
    { (OP*)&gvop_list[15], (OP*)&unop_list[14], pp_const, 0, 5, 65535, 0x2, 0x0, (SV*)&sv_list[26] },
    { (OP*)&gvop_list[16], (OP*)&unop_list[15], pp_const, 0, 5, 65535, 0x2, 0x0, (SV*)&sv_list[28] },
    { (OP*)&gvop_list[17], (OP*)&unop_list[16], pp_const, 0, 5, 65535, 0x2, 0x0, (SV*)&sv_list[30] },
    { (OP*)&gvop_list[18], (OP*)&unop_list[17], pp_const, 0, 5, 65535, 0x2, 0x0, (SV*)&sv_list[32] },
    { &op_list[19], 0, pp_const, 0, 5, 65535, 0x2, 0x0, (SV*)&sv_list[36] },
    { &op_list[24], 0, pp_const, 0, 5, 65535, 0x2, 0x0, (SV*)&sv_list[37] },
    { (OP*)&gvop_list[43], (OP*)&unop_list[51], pp_const, 0, 5, 65535, 0x2, 0x0, (SV*)&sv_list[38] },
};

static GVOP gvop_list[48] = {
    { (OP*)&svop_list[0], (OP*)&svop_list[0], pp_gv, 0, 7, 65535, 0x2, 0x0, Nullgv },
    { (OP*)&svop_list[1], (OP*)&svop_list[1], pp_gv, 0, 7, 65535, 0x2, 0x0, Nullgv },
    { (OP*)&svop_list[2], (OP*)&svop_list[2], pp_gv, 0, 7, 65535, 0x2, 0x0, Nullgv },
    { (OP*)&svop_list[3], (OP*)&svop_list[3], pp_gv, 0, 7, 65535, 0x2, 0x0, Nullgv },
    { (OP*)&unop_list[1], 0, pp_gv, 0, 7, 65535, 0x2, 0x0, Nullgv },
    { (OP*)&unop_list[3], 0, pp_gv, 0, 7, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&unop_list[4], 0, pp_gv, 0, 7, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&binop_list[1], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&binop_list[2], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&gvop_list[10], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&binop_list[4], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&listop_list[7], 0, pp_gv, 0, 7, 65535, 0x2, 0x0, Nullgv },
    { (OP*)&unop_list[10], 0, pp_gv, 0, 7, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&binop_list[5], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&unop_list[12], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&binop_list[6], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&binop_list[7], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&binop_list[8], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&binop_list[9], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&gvop_list[20], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&binop_list[11], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&unop_list[21], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&gvop_list[23], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&unop_list[26], 0, pp_gv, 0, 7, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&gvop_list[25], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&binop_list[12], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&unop_list[30], 0, pp_gv, 0, 7, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&binop_list[14], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&unop_list[32], 0, pp_gv, 0, 7, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&binop_list[15], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&unop_list[34], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&unop_list[36], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&gvop_list[33], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&unop_list[40], 0, pp_gv, 0, 7, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&listop_list[16], 0, pp_gv, 0, 7, 65535, 0x2, 0x0, Nullgv },
    { (OP*)&unop_list[41], 0, pp_gv, 0, 7, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&unop_list[44], 0, pp_gv, 0, 7, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&listop_list[19], 0, pp_gv, 0, 7, 65535, 0x2, 0x0, Nullgv },
    { (OP*)&unop_list[45], 0, pp_gv, 0, 7, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&unop_list[48], 0, pp_gv, 0, 7, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&listop_list[21], 0, pp_gv, 0, 7, 65535, 0x2, 0x0, Nullgv },
    { (OP*)&gvop_list[42], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&binop_list[18], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&binop_list[19], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&unop_list[52], 0, pp_gv, 0, 7, 65535, 0x2, 0x0, Nullgv },
    { (OP*)&unop_list[53], 0, pp_gv, 0, 7, 65535, 0x2, 0x0, Nullgv },
    { (OP*)&unop_list[54], 0, pp_gv, 0, 7, 65535, 0x2, 0x0, Nullgv },
    { (OP*)&unop_list[55], 0, pp_gv, 0, 7, 65535, 0x2, 0x0, Nullgv },
};

static LOOP loop_list[2] = {
    { (OP*)&gvop_list[9], (OP*)&unop_list[7], pp_enterloop, 0, 179, 65535, 0x2, 0x0, 0, 0, 0, (OP*)&cop_list[8], (OP*)&gvop_list[14], (OP*)&binop_list[3] },
    { (OP*)&gvop_list[19], (OP*)&unop_list[18], pp_enterloop, 0, 179, 65535, 0x2, 0x0, 0, 0, 0, (OP*)&cop_list[15], (OP*)&gvop_list[19], (OP*)&binop_list[10] },
};

static COP cop_list[34] = {
    { (OP*)&gvop_list[0], (OP*)&listop_list[1], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1111, 0, 7 },
    { (OP*)&gvop_list[1], (OP*)&listop_list[2], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1112, 0, 8 },
    { (OP*)&gvop_list[2], (OP*)&listop_list[3], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1113, 0, 9 },
    { (OP*)&gvop_list[3], (OP*)&listop_list[4], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1114, 0, 10 },
    { &op_list[5], (OP*)&binop_list[0], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1115, 0, 13 },
    { (OP*)&gvop_list[6], (OP*)&binop_list[1], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1116, 0, 15 },
    { (OP*)&svop_list[4], (OP*)&binop_list[2], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1119, 0, 20 },
    { (OP*)&loop_list[0], (OP*)&binop_list[3], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1120, 0, 24 },
    { (OP*)&gvop_list[11], (OP*)&listop_list[7], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1117, 0, 22 },
    { &op_list[8], (OP*)&listop_list[8], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1118, 0, 23 },
    { (OP*)&svop_list[5], (OP*)&binop_list[6], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1121, 0, 25 },
    { (OP*)&svop_list[6], (OP*)&binop_list[7], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1122, 0, 26 },
    { (OP*)&svop_list[7], (OP*)&binop_list[8], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1123, 0, 27 },
    { (OP*)&svop_list[8], (OP*)&binop_list[9], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1124, 0, 28 },
    { (OP*)&loop_list[1], (OP*)&binop_list[10], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1140, 0, 29 },
    { (OP*)&gvop_list[21], (OP*)&unop_list[21], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1125, 0, 31 },
    { &op_list[10], (OP*)&listop_list[10], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1129, 0, 33 },
    { (OP*)&gvop_list[26], (OP*)&binop_list[13], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1126, 0, 34 },
    { (OP*)&gvop_list[30], (OP*)&unop_list[34], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1127, 0, 35 },
    { (OP*)&gvop_list[31], (OP*)&unop_list[36], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1128, 0, 35 },
    { &op_list[14], (OP*)&unop_list[38], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1136, 0, 38 },
    { (OP*)&gvop_list[34], (OP*)&listop_list[16], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1130, 0, 40 },
    { &op_list[17], (OP*)&listop_list[17], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1131, 0, 41 },
    { &op_list[18], (OP*)&binop_list[16], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1132, 0, 42 },
    { (OP*)&gvop_list[37], (OP*)&listop_list[19], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1133, 0, 44 },
    { &op_list[22], (OP*)&listop_list[20], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1134, 0, 45 },
    { &op_list[23], (OP*)&binop_list[17], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1135, 0, 46 },
    { (OP*)&gvop_list[40], (OP*)&listop_list[21], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1137, 0, 48 },
    { (OP*)&gvop_list[41], (OP*)&binop_list[18], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1138, 0, 52 },
    { (OP*)&svop_list[11], (OP*)&binop_list[19], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1139, 0, 53 },
    { (OP*)&gvop_list[44], (OP*)&unop_list[52], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1141, 0, 57 },
    { (OP*)&gvop_list[45], (OP*)&unop_list[53], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1142, 0, 58 },
    { (OP*)&gvop_list[46], (OP*)&unop_list[54], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1143, 0, 59 },
    { (OP*)&gvop_list[47], (OP*)&unop_list[55], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1144, 0, 60 },
};

static SV sv_list[39] = {
    { &xpvav_list[0], 2, 0xa },
    { 0, 2, 0x200 },
    { 0, 2, 0x200 },
    { 0, 2, 0x200 },
    { 0, 2, 0x0 },
    { 0, 2, 0x0 },
    { 0, 2, 0x0 },
    { 0, 2, 0x0 },
    { &xpv_list[0], 2, 0x4040004 },
    { 0, 2, 0x0 },
    { &xpvio_list[0], 2, 0x100f },
    { &xpviv_list[0], 2, 0x4840005 },
    { 0, 2, 0x0 },
    { &xpvio_list[1], 2, 0x100f },
    { &xpviv_list[1], 2, 0x4840005 },
    { 0, 2, 0x0 },
    { &xpvio_list[2], 2, 0x100f },
    { &xpviv_list[2], 2, 0x4840005 },
    { 0, 2, 0x0 },
    { &xpvio_list[3], 2, 0x100f },
    { &xpviv_list[3], 2, 0x4840005 },
    { 0, 2, 0x0 },
    { &xpvav_list[1], 2, 0xa },
    { 0, 2, 0x0 },
    { &xpviv_list[4], 2, 0x1810001 },
    { 0, 2, 0x0 },
    { &xpviv_list[5], 2, 0x1810001 },
    { 0, 2, 0x0 },
    { &xpviv_list[6], 2, 0x1810001 },
    { 0, 2, 0x0 },
    { &xpviv_list[7], 2, 0x1810001 },
    { 0, 2, 0x0 },
    { &xpviv_list[8], 2, 0x1810001 },
    { &xpvbm_list[0], 3, 0x87074008 },
    { 0, 2, 0x0 },
    { &xpvav_list[2], 2, 0xa },
    { &xpviv_list[9], 2, 0x4840005 },
    { &xpviv_list[10], 2, 0x4840005 },
    { &xpviv_list[11], 2, 0x1810001 },
};

static XPV xpv_list[1] = {
    { 0, 7, 8 },
};

static XPVIV xpviv_list[12] = {
    { 0, 26, 27, 0 },
    { 0, 26, 27, 0 },
    { 0, 24, 25, 0 },
    { 0, 30, 31, 0 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 0, 1, 0 },
    { 0, 0, 1, 0 },
    { 0, 0, 0, 0 },
};

static XPVBM xpvbm_list[1] = {
    { 0, 262, 520, 0, 0, 0, 0, 0, 0, 0x46 },
};

static XPVAV xpvav_list[3] = {
    { 0, -1, -1, 0, 0.0, 0, Nullhv, 0, 0, 0x1 },
    { 0, -1, -1, 0, 0.0, 0, Nullhv, 0, 0, 0x1 },
    { 0, -1, -1, 0, 0.0, 0, Nullhv, 0, 0, 0x1 },
};

static XPVIO xpvio_list[4] = {
    { 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 60, 0, 0, Nullgv, 0, Nullgv, 0, Nullgv, 0, '\000', 0x0 },
    { 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 60, 0, 0, Nullgv, 0, Nullgv, 0, Nullgv, 0, '\000', 0x0 },
    { 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 60, 0, 0, Nullgv, 0, Nullgv, 0, Nullgv, 0, '\000', 0x0 },
    { 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 60, 0, 0, Nullgv, 0, Nullgv, 0, Nullgv, 0, '\000', 0x0 },
};

static int perl_init()
{
    {
        SV **svp;
        AV *av = (AV*)&sv_list[0];
        av_extend(av, 7);
        svp = AvARRAY(av);
        *svp++ = (SV*)&sv_undef;
        *svp++ = (SV*)&sv_list[1];
        *svp++ = (SV*)&sv_list[2];
        *svp++ = (SV*)&sv_list[3];
        *svp++ = (SV*)&sv_list[4];
        *svp++ = (SV*)&sv_list[5];
        *svp++ = (SV*)&sv_list[6];
        *svp++ = (SV*)&sv_list[7];
        AvFILL(av) = 7;
    }
    gv_list[0] = gv_fetchpv("main::_<chop.pl", TRUE, SVt_PV);
    SvFLAGS(gv_list[0]) = 0x600d;
    GvFLAGS(gv_list[0]) = 0x0;
    GvLINE(gv_list[0]) = 0;
    SvREFCNT(gv_list[0]) += 35;
    GvSV(gv_list[0]) = &sv_list[8];
    xpv_list[0].xpv_pv = savepvn("chop.pl", 7);
    hv0 = gv_stashpv("main", TRUE);
    cop_list[0].cop_filegv = gv_list[0];
    cop_list[0].cop_stash = hv0;
    gv_list[1] = gv_fetchpv("main::MAIL", TRUE, SVt_PV);
    SvFLAGS(gv_list[1]) = 0x600d;
    GvFLAGS(gv_list[1]) = 0x2;
    GvLINE(gv_list[1]) = 7;
    SvREFCNT(gv_list[1]) += 4;
    GvSV(gv_list[1]) = &sv_list[9];
    GvFILEGV(gv_list[1]) = gv_list[0];
    GvIOp(gv_list[1]) = (IO*)&sv_list[10];
    SvSTASH((IO*)&sv_list[10]) = UNUSED;
    gvop_list[0].op_gv = gv_list[1];
    xpviv_list[0].xpv_pv = savepvn("/home/akittel/nsmail/Inbox", 26);
    cop_list[1].cop_filegv = gv_list[0];
    cop_list[1].cop_stash = hv0;
    gv_list[2] = gv_fetchpv("main::JUNK", TRUE, SVt_PV);
    SvFLAGS(gv_list[2]) = 0x600d;
    GvFLAGS(gv_list[2]) = 0x2;
    GvLINE(gv_list[2]) = 8;
    SvREFCNT(gv_list[2]) += 4;
    GvSV(gv_list[2]) = &sv_list[12];
    GvFILEGV(gv_list[2]) = gv_list[0];
    GvIOp(gv_list[2]) = (IO*)&sv_list[13];
    SvSTASH((IO*)&sv_list[13]) = UNUSED;
    gvop_list[1].op_gv = gv_list[2];
    xpviv_list[1].xpv_pv = savepvn(">/home/akittel/nsmail/OPER", 26);
    cop_list[2].cop_filegv = gv_list[0];
    cop_list[2].cop_stash = hv0;
    gv_list[3] = gv_fetchpv("main::OK", TRUE, SVt_PV);
    SvFLAGS(gv_list[3]) = 0x600d;
    GvFLAGS(gv_list[3]) = 0x2;
    GvLINE(gv_list[3]) = 9;
    SvREFCNT(gv_list[3]) += 4;
    GvSV(gv_list[3]) = &sv_list[15];
    GvFILEGV(gv_list[3]) = gv_list[0];
    GvIOp(gv_list[3]) = (IO*)&sv_list[16];
    SvSTASH((IO*)&sv_list[16]) = UNUSED;
    gvop_list[2].op_gv = gv_list[3];
    xpviv_list[2].xpv_pv = savepvn(">/home/akittel/nsmail/OK", 24);
    cop_list[3].cop_filegv = gv_list[0];
    cop_list[3].cop_stash = hv0;
    gv_list[4] = gv_fetchpv("main::ORIGINAL", TRUE, SVt_PV);
    SvFLAGS(gv_list[4]) = 0x600d;
    GvFLAGS(gv_list[4]) = 0x2;
    GvLINE(gv_list[4]) = 10;
    SvREFCNT(gv_list[4]) += 4;
    GvSV(gv_list[4]) = &sv_list[18];
    GvFILEGV(gv_list[4]) = gv_list[0];
    GvIOp(gv_list[4]) = (IO*)&sv_list[19];
    SvSTASH((IO*)&sv_list[19]) = UNUSED;
    gvop_list[3].op_gv = gv_list[4];
    xpviv_list[3].xpv_pv = savepvn(">/home/akittel/nsmail/ORIGINAL", 30);
    cop_list[4].cop_filegv = gv_list[0];
    cop_list[4].cop_stash = hv0;
    gvop_list[4].op_gv = gv_list[1];
    gv_list[5] = gv_fetchpv("main::MAILARRAY", TRUE, SVt_PV);
    SvFLAGS(gv_list[5]) = 0x600d;
    GvFLAGS(gv_list[5]) = 0x2;
    GvLINE(gv_list[5]) = 13;
    SvREFCNT(gv_list[5]) += 7;
    GvSV(gv_list[5]) = &sv_list[21];
    GvAV(gv_list[5]) = (AV*)&sv_list[22];
    GvFILEGV(gv_list[5]) = gv_list[0];
    gvop_list[5].op_gv = gv_list[5];
    cop_list[5].cop_filegv = gv_list[0];
    cop_list[5].cop_stash = hv0;
    gvop_list[6].op_gv = gv_list[5];
    gv_list[6] = gv_fetchpv("main::LINECOUNT", TRUE, SVt_PV);
    SvFLAGS(gv_list[6]) = 0x600d;
    GvFLAGS(gv_list[6]) = 0x2;
    GvLINE(gv_list[6]) = 15;
    SvREFCNT(gv_list[6]) += 5;
    GvSV(gv_list[6]) = &sv_list[23];
    GvFILEGV(gv_list[6]) = gv_list[0];
    gvop_list[7].op_gv = gv_list[6];
    cop_list[6].cop_filegv = gv_list[0];
    cop_list[6].cop_stash = hv0;
    gv_list[7] = gv_fetchpv("main::i", TRUE, SVt_PV);
    SvFLAGS(gv_list[7]) = 0x600d;
    GvFLAGS(gv_list[7]) = 0x2;
    GvLINE(gv_list[7]) = 20;
    SvREFCNT(gv_list[7]) += 11;
    GvSV(gv_list[7]) = &sv_list[25];
    GvFILEGV(gv_list[7]) = gv_list[0];
    gvop_list[8].op_gv = gv_list[7];
    cop_list[7].cop_filegv = gv_list[0];
    cop_list[7].cop_stash = hv0;
    gvop_list[9].op_gv = gv_list[7];
    gvop_list[10].op_gv = gv_list[6];
    cop_list[8].cop_filegv = gv_list[0];
    cop_list[8].cop_stash = hv0;
    gvop_list[11].op_gv = gv_list[4];
    cop_list[9].cop_filegv = gv_list[0];
    cop_list[9].cop_stash = hv0;
    gvop_list[12].op_gv = gv_list[5];
    gvop_list[13].op_gv = gv_list[7];
    gvop_list[14].op_gv = gv_list[7];
    cop_list[10].cop_filegv = gv_list[0];
    cop_list[10].cop_stash = hv0;
    gv_list[8] = gv_fetchpv("main::a", TRUE, SVt_PV);
    SvFLAGS(gv_list[8]) = 0x600d;
    GvFLAGS(gv_list[8]) = 0x2;
    GvLINE(gv_list[8]) = 25;
    SvREFCNT(gv_list[8]) += 5;
    GvSV(gv_list[8]) = &sv_list[27];
    GvFILEGV(gv_list[8]) = gv_list[0];
    gvop_list[15].op_gv = gv_list[8];
    cop_list[11].cop_filegv = gv_list[0];
    cop_list[11].cop_stash = hv0;
    gv_list[9] = gv_fetchpv("main::b", TRUE, SVt_PV);
    SvFLAGS(gv_list[9]) = 0x600d;
    GvFLAGS(gv_list[9]) = 0x2;
    GvLINE(gv_list[9]) = 26;
    SvREFCNT(gv_list[9]) += 3;
    GvSV(gv_list[9]) = &sv_list[29];
    GvFILEGV(gv_list[9]) = gv_list[0];
    gvop_list[16].op_gv = gv_list[9];
    cop_list[12].cop_filegv = gv_list[0];
    cop_list[12].cop_stash = hv0;
    gv_list[10] = gv_fetchpv("main::c", TRUE, SVt_PV);
    SvFLAGS(gv_list[10]) = 0x600d;
    GvFLAGS(gv_list[10]) = 0x2;
    GvLINE(gv_list[10]) = 27;
    SvREFCNT(gv_list[10]) += 5;
    GvSV(gv_list[10]) = &sv_list[31];
    GvFILEGV(gv_list[10]) = gv_list[0];
    gvop_list[17].op_gv = gv_list[10];
    cop_list[13].cop_filegv = gv_list[0];
    cop_list[13].cop_stash = hv0;
    gvop_list[18].op_gv = gv_list[7];
    cop_list[14].cop_filegv = gv_list[0];
    cop_list[14].cop_stash = hv0;
    gvop_list[19].op_gv = gv_list[8];
    gvop_list[20].op_gv = gv_list[6];
    cop_list[15].cop_filegv = gv_list[0];
    cop_list[15].cop_stash = hv0;
    gvop_list[21].op_gv = gv_list[9];
    cop_list[16].cop_filegv = gv_list[0];
    cop_list[16].cop_stash = hv0;
    sv_magic((SV*)&sv_list[33], (SV*)0, 'B', 0, 0);
    xpvbm_list[0].xpv_pv = savepvn("From \000\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\000\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\004\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\001\005\002\005\005\003\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005\005", 262);
    xpvbm_list[0].xpv_cur = 5;
    pmop_list[0].op_pmregexp = pregcomp(re0, re0 + 5, &pmop_list[0]);
    gvop_list[22].op_gv = gv_list[7];
    gvop_list[23].op_gv = gv_list[5];
    gvop_list[24].op_gv = gv_list[7];
    gvop_list[25].op_gv = gv_list[6];
    cop_list[17].cop_filegv = gv_list[0];
    cop_list[17].cop_stash = hv0;
    gvop_list[26].op_gv = gv_list[5];
    gvop_list[27].op_gv = gv_list[7];
    gv_list[11] = gv_fetchpv("main::BUF", TRUE, SVt_PV);
    SvFLAGS(gv_list[11]) = 0x600d;
    GvFLAGS(gv_list[11]) = 0x2;
    GvLINE(gv_list[11]) = 34;
    SvREFCNT(gv_list[11]) += 6;
    GvSV(gv_list[11]) = &sv_list[34];
    GvAV(gv_list[11]) = (AV*)&sv_list[35];
    GvFILEGV(gv_list[11]) = gv_list[0];
    gvop_list[28].op_gv = gv_list[11];
    gvop_list[29].op_gv = gv_list[10];
    cop_list[18].cop_filegv = gv_list[0];
    cop_list[18].cop_stash = hv0;
    gvop_list[30].op_gv = gv_list[7];
    cop_list[19].cop_filegv = gv_list[0];
    cop_list[19].cop_stash = hv0;
    gvop_list[31].op_gv = gv_list[10];
    cop_list[20].cop_filegv = gv_list[0];
    cop_list[20].cop_stash = hv0;
    pmop_list[1].op_pmregexp = pregcomp(re1, re1 + 65, &pmop_list[1]);
    gvop_list[32].op_gv = gv_list[8];
    gvop_list[33].op_gv = gv_list[5];
    cop_list[21].cop_filegv = gv_list[0];
    cop_list[21].cop_stash = hv0;
    gvop_list[34].op_gv = gv_list[2];
    cop_list[22].cop_filegv = gv_list[0];
    cop_list[22].cop_stash = hv0;
    gvop_list[35].op_gv = gv_list[11];
    cop_list[23].cop_filegv = gv_list[0];
    cop_list[23].cop_stash = hv0;
    xpviv_list[9].xpv_pv = savepvn("", 0);
    gvop_list[36].op_gv = gv_list[11];
    cop_list[24].cop_filegv = gv_list[0];
    cop_list[24].cop_stash = hv0;
    gvop_list[37].op_gv = gv_list[3];
    cop_list[25].cop_filegv = gv_list[0];
    cop_list[25].cop_stash = hv0;
    gvop_list[38].op_gv = gv_list[11];
    cop_list[26].cop_filegv = gv_list[0];
    cop_list[26].cop_stash = hv0;
    xpviv_list[10].xpv_pv = savepvn("", 0);
    gvop_list[39].op_gv = gv_list[11];
    cop_list[27].cop_filegv = gv_list[0];
    cop_list[27].cop_stash = hv0;
    gv_list[12] = gv_fetchpv("main::STDOUT", TRUE, SVt_PV);
    SvFLAGS(gv_list[12]) = 0x600d;
    GvFLAGS(gv_list[12]) = 0x2;
    GvLINE(gv_list[12]) = 0;
    SvREFCNT(gv_list[12]) += 4;
    gvop_list[40].op_gv = gv_list[12];
    cop_list[28].cop_filegv = gv_list[0];
    cop_list[28].cop_stash = hv0;
    gvop_list[41].op_gv = gv_list[7];
    gvop_list[42].op_gv = gv_list[8];
    cop_list[29].cop_filegv = gv_list[0];
    cop_list[29].cop_stash = hv0;
    gvop_list[43].op_gv = gv_list[10];
    cop_list[30].cop_filegv = gv_list[0];
    cop_list[30].cop_stash = hv0;
    gvop_list[44].op_gv = gv_list[3];
    cop_list[31].cop_filegv = gv_list[0];
    cop_list[31].cop_stash = hv0;
    gvop_list[45].op_gv = gv_list[2];
    cop_list[32].cop_filegv = gv_list[0];
    cop_list[32].cop_stash = hv0;
    gvop_list[46].op_gv = gv_list[1];
    cop_list[33].cop_filegv = gv_list[0];
    cop_list[33].cop_stash = hv0;
    gvop_list[47].op_gv = gv_list[4];
    main_root = (OP*)&listop_list[0];
    main_start = &op_list[0];
    curpad = AvARRAY((AV*)&sv_list[0]);
    return 0;
}

int
#ifndef CAN_PROTOTYPE
main(argc, argv, env)
int argc;
char **argv;
char **env;
#else  /* def(CAN_PROTOTYPE) */
main(int argc, char **argv, char **env)
#endif  /* def(CAN_PROTOTYPE) */
{
    int exitstatus;
    int i;
    char **fakeargv;

    PERL_SYS_INIT(&argc,&argv);
 
    perl_init_i18nl14n(1);

    if (!do_undump) {
	my_perl = perl_alloc();
	if (!my_perl)
	    exit(1);
	perl_construct( my_perl );
    }

    if (!cshlen) 
      cshlen = strlen(cshname);

#ifdef ALLOW_PERL_OPTIONS
#define EXTRA_OPTIONS 2
#else
#define EXTRA_OPTIONS 3
#endif /* ALLOW_PERL_OPTIONS */
    New(666, fakeargv, argc + EXTRA_OPTIONS + 1, char *);
    fakeargv[0] = argv[0];
    fakeargv[1] = "-e";
    fakeargv[2] = "";
#ifndef ALLOW_PERL_OPTIONS
    fakeargv[3] = "--";
#endif /* ALLOW_PERL_OPTIONS */
    for (i = 1; i < argc; i++)
	fakeargv[i + EXTRA_OPTIONS] = argv[i];
    fakeargv[argc + EXTRA_OPTIONS] = 0;
    
    exitstatus = perl_parse(my_perl, xs_init, argc + EXTRA_OPTIONS,
			    fakeargv, NULL);
    if (exitstatus)
	exit( exitstatus );

    sv_setpv(GvSV(gv_fetchpv("0", TRUE, SVt_PV)), argv[0]);
    main_cv = compcv;
    compcv = 0;

    exitstatus = perl_init();
    if (exitstatus)
	exit( exitstatus );

    exitstatus = perl_run( my_perl );

    perl_destruct( my_perl );
    perl_free( my_perl );

    exit( exitstatus );
}

static void
xs_init()
{
}
