#ifdef __cplusplus
extern "C" {
#endif

#include "EXTERN.h"
#include "perl.h"

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

Static OP op_list[71];
Static UNOP unop_list[157];
Static BINOP binop_list[71];
Static LOGOP logop_list[13];
Static CONDOP condop_list[6];
Static LISTOP listop_list[56];
Static PMOP pmop_list[11];
Static SVOP svop_list[37];
Static GVOP gvop_list[102];
Static LOOP loop_list[7];
Static COP cop_list[45];
Static SV sv_list[86];
Static XPV xpv_list[20];
Static XPVIV xpviv_list[18];
Static XPVBM xpvbm_list[6];
Static XPVAV xpvav_list[9];
Static XPVIO xpvio_list[1];
static GV *gv_list[21];

static HV *hv0;
static char *re0 = "\\s+";
static char *re1 = "\\#";
static char *re2 = "no answer";
static char *re3 = "\\#";
static char *re4 = "\\#";
static char *re5 = "failed|not responding|No keep-alive|Errors|Periodic head cleaning";
static char *re6 = "\\#";
static char *re7 = "\\s+";
static char *re8 = "\\s+";
static char *re9 = "\\#";
static char *re10 = "\\s+";

static OP op_list[71] = {
    { (OP*)&cop_list[0], (OP*)&cop_list[0], pp_enter, 0, 174, 65535, 0x0, 0x0 },
    { (OP*)&gvop_list[0], (OP*)&gvop_list[0], pp_null, 3, 0, 65535, 0x2, 0x0 },
    { &op_list[3], (OP*)&listop_list[3], pp_pushmark, 0, 3, 65535, 0x2, 0x0 },
    { (OP*)&svop_list[1], (OP*)&svop_list[1], pp_pushmark, 0, 3, 65535, 0x2, 0x0 },
    { (OP*)&gvop_list[1], (OP*)&unop_list[2], pp_pushmark, 0, 3, 65535, 0x2, 0x0 },
    { (OP*)&gvop_list[2], (OP*)&unop_list[4], pp_pushmark, 0, 3, 65535, 0x2, 0x0 },
    { (OP*)&svop_list[2], (OP*)&svop_list[2], pp_null, 3, 0, 65535, 0x2, 0x0 },
    { (OP*)&gvop_list[23], 0, pp_stub, 0, 1, 65535, 0x2, 0x0 },
    { (OP*)&cop_list[9], (OP*)&cop_list[9], pp_enter, 0, 174, 65535, 0x2, 0x0 },
    { (OP*)&svop_list[6], (OP*)&binop_list[10], pp_null, 3, 0, 65535, 0x2, 0x0 },
    { (OP*)&cop_list[12], (OP*)&cop_list[12], pp_enter, 0, 174, 65535, 0x2, 0x0 },
    { (OP*)&svop_list[7], (OP*)&unop_list[28], pp_pushmark, 0, 3, 65535, 0x2, 0x0 },
    { (OP*)&svop_list[7], (OP*)&binop_list[12], pp_null, 3, 0, 65535, 0x2, 0x0 },
    { &op_list[14], (OP*)&listop_list[12], pp_null, 171, 0, 65535, 0x2, 0x0 },
    { (OP*)&gvop_list[22], (OP*)&unop_list[32], pp_pushmark, 0, 3, 65535, 0x2, 0x0 },
    { (OP*)&gvop_list[8], 0, pp_unstack, 0, 173, 65535, 0x2, 0x0 },
    { (OP*)&gvop_list[39], 0, pp_stub, 0, 1, 65535, 0x2, 0x0 },
    { (OP*)&cop_list[17], (OP*)&cop_list[17], pp_enter, 0, 174, 65535, 0x2, 0x0 },
    { (OP*)&svop_list[11], (OP*)&unop_list[43], pp_pushmark, 0, 3, 65535, 0x2, 0x0 },
    { (OP*)&svop_list[11], (OP*)&binop_list[21], pp_null, 3, 0, 65535, 0x2, 0x0 },
    { (OP*)&gvop_list[31], (OP*)&unop_list[47], pp_pushmark, 0, 3, 65535, 0x2, 0x0 },
    { &op_list[22], (OP*)&listop_list[18], pp_null, 171, 0, 65535, 0x2, 0x0 },
    { (OP*)&gvop_list[35], (OP*)&unop_list[52], pp_pushmark, 0, 3, 65535, 0x2, 0x0 },
    { (OP*)&gvop_list[35], (OP*)&binop_list[26], pp_null, 3, 0, 65535, 0x2, 0x0 },
    { (OP*)&gvop_list[37], (OP*)&unop_list[55], pp_pushmark, 0, 3, 65535, 0x2, 0x0 },
    { (OP*)&gvop_list[25], 0, pp_unstack, 0, 173, 65535, 0x2, 0x0 },
    { (OP*)&gvop_list[43], (OP*)&unop_list[64], pp_pushmark, 0, 3, 65535, 0x2, 0x0 },
    { (OP*)&gvop_list[56], 0, pp_stub, 0, 1, 65535, 0x2, 0x0 },
    { (OP*)&cop_list[23], (OP*)&cop_list[23], pp_enter, 0, 174, 65535, 0x2, 0x0 },
    { (OP*)&svop_list[16], (OP*)&unop_list[67], pp_pushmark, 0, 3, 65535, 0x2, 0x0 },
    { (OP*)&svop_list[16], (OP*)&binop_list[33], pp_null, 3, 0, 65535, 0x2, 0x0 },
    { (OP*)&gvop_list[45], (OP*)&unop_list[68], pp_pushmark, 0, 3, 65535, 0x2, 0x0 },
    { (OP*)&gvop_list[46], (OP*)&unop_list[69], pp_pushmark, 0, 3, 65535, 0x2, 0x0 },
    { (OP*)&gvop_list[48], (OP*)&unop_list[72], pp_pushmark, 0, 3, 65535, 0x2, 0x0 },
    { &op_list[35], (OP*)&listop_list[30], pp_null, 171, 0, 65535, 0x2, 0x0 },
    { (OP*)&gvop_list[53], (OP*)&unop_list[79], pp_pushmark, 0, 3, 65535, 0x2, 0x0 },
    { (OP*)&gvop_list[53], (OP*)&binop_list[39], pp_null, 3, 0, 65535, 0x2, 0x0 },
    { (OP*)&gvop_list[50], 0, pp_unstack, 0, 173, 65535, 0x2, 0x0 },
    { (OP*)&gvop_list[41], 0, pp_unstack, 0, 173, 65535, 0x2, 0x0 },
    { (OP*)&gvop_list[60], (OP*)&unop_list[91], pp_pushmark, 0, 3, 65535, 0x2, 0x0 },
    { (OP*)&gvop_list[82], 0, pp_stub, 0, 1, 65535, 0x2, 0x0 },
    { (OP*)&cop_list[30], (OP*)&cop_list[30], pp_enter, 0, 174, 65535, 0x2, 0x0 },
    { (OP*)&svop_list[22], (OP*)&unop_list[94], pp_pushmark, 0, 3, 65535, 0x2, 0x0 },
    { (OP*)&svop_list[22], (OP*)&binop_list[45], pp_null, 3, 0, 65535, 0x2, 0x0 },
    { (OP*)&gvop_list[62], (OP*)&unop_list[95], pp_pushmark, 0, 3, 65535, 0x2, 0x0 },
    { (OP*)&gvop_list[63], (OP*)&unop_list[96], pp_pushmark, 0, 3, 65535, 0x2, 0x0 },
    { (OP*)&gvop_list[65], (OP*)&unop_list[99], pp_pushmark, 0, 3, 65535, 0x2, 0x0 },
    { (OP*)&unop_list[108], 0, pp_null, 5, 0, 65535, 0x2, 0x0 },
    { (OP*)&unop_list[112], 0, pp_null, 5, 0, 65535, 0x2, 0x0 },
    { (OP*)&unop_list[115], 0, pp_null, 5, 0, 65535, 0x2, 0x0 },
    { &op_list[51], (OP*)&listop_list[43], pp_null, 171, 0, 65535, 0x2, 0x0 },
    { (OP*)&svop_list[28], (OP*)&unop_list[117], pp_pushmark, 0, 3, 65535, 0x2, 0x0 },
    { (OP*)&svop_list[28], (OP*)&binop_list[53], pp_null, 3, 0, 65535, 0x2, 0x0 },
    { (OP*)&gvop_list[76], (OP*)&unop_list[118], pp_pushmark, 0, 3, 65535, 0x2, 0x0 },
    { (OP*)&gvop_list[77], (OP*)&unop_list[119], pp_pushmark, 0, 3, 65535, 0x2, 0x0 },
    { (OP*)&gvop_list[79], (OP*)&unop_list[121], pp_pushmark, 0, 3, 65535, 0x2, 0x0 },
    { (OP*)&gvop_list[69], 0, pp_unstack, 0, 173, 65535, 0x2, 0x0 },
    { (OP*)&gvop_list[58], 0, pp_unstack, 0, 173, 65535, 0x2, 0x0 },
    { (OP*)&gvop_list[100], 0, pp_stub, 0, 1, 65535, 0x2, 0x0 },
    { (OP*)&cop_list[41], (OP*)&cop_list[41], pp_enter, 0, 174, 65535, 0x2, 0x0 },
    { (OP*)&svop_list[32], (OP*)&binop_list[62], pp_null, 3, 0, 65535, 0x2, 0x0 },
    { (OP*)&unop_list[140], 0, pp_null, 5, 0, 65535, 0x2, 0x0 },
    { (OP*)&unop_list[142], 0, pp_null, 5, 0, 65535, 0x2, 0x0 },
    { (OP*)&gvop_list[94], (OP*)&unop_list[144], pp_null, 171, 0, 65535, 0x2, 0x0 },
    { (OP*)&unop_list[145], 0, pp_null, 5, 0, 65535, 0x2, 0x0 },
    { (OP*)&unop_list[147], 0, pp_null, 5, 0, 65535, 0x2, 0x0 },
    { &op_list[67], (OP*)&listop_list[54], pp_null, 171, 0, 65535, 0x2, 0x0 },
    { (OP*)&gvop_list[96], (OP*)&unop_list[149], pp_pushmark, 0, 3, 65535, 0x2, 0x0 },
    { (OP*)&gvop_list[96], (OP*)&binop_list[67], pp_null, 3, 0, 65535, 0x2, 0x0 },
    { (OP*)&gvop_list[98], (OP*)&unop_list[152], pp_pushmark, 0, 3, 65535, 0x2, 0x0 },
    { (OP*)&gvop_list[84], 0, pp_unstack, 0, 173, 65535, 0x2, 0x0 },
};

static UNOP unop_list[157] = {
    { (OP*)&cop_list[1], (OP*)&cop_list[1], pp_null, 0, 0, 65535, 0x6, 0x41, (OP*)&logop_list[0] },
    { &op_list[5], (OP*)&unop_list[3], pp_null, 139, 0, 65535, 0x7, 0x0, &op_list[4] },
    { &op_list[5], 0, pp_readline, 2, 26, 65535, 0x7, 0x1, (OP*)&gvop_list[1] },
    { (OP*)&binop_list[0], 0, pp_null, 139, 0, 65535, 0x7, 0x0, &op_list[5] },
    { (OP*)&binop_list[0], 0, pp_rv2av, 1, 123, 65535, 0xb7, 0x1, (OP*)&gvop_list[2] },
    { (OP*)&gvop_list[4], (OP*)&unop_list[6], pp_rv2av, 1, 123, 65535, 0x6, 0x1, (OP*)&gvop_list[3] },
    { (OP*)&binop_list[1], 0, pp_null, 15, 0, 65535, 0xb6, 0x1, (OP*)&gvop_list[4] },
    { (OP*)&gvop_list[5], (OP*)&unop_list[8], pp_backtick, 1, 24, 65535, 0x6, 0x0, &op_list[6] },
    { (OP*)&binop_list[2], 0, pp_null, 15, 0, 65535, 0xb6, 0x1, (OP*)&gvop_list[5] },
    { (OP*)&svop_list[3], (OP*)&svop_list[3], pp_null, 15, 0, 65535, 0x6, 0x1, (OP*)&gvop_list[6] },
    { (OP*)&binop_list[3], 0, pp_null, 15, 0, 65535, 0xb6, 0x1, (OP*)&gvop_list[7] },
    { (OP*)&binop_list[4], 0, pp_null, 0, 0, 65535, 0x6, 0x41, (OP*)&logop_list[1] },
    { (OP*)&gvop_list[9], (OP*)&unop_list[13], pp_null, 15, 0, 65535, 0x6, 0x1, (OP*)&gvop_list[8] },
    { (OP*)&binop_list[5], 0, pp_null, 15, 0, 65535, 0x6, 0x1, (OP*)&gvop_list[9] },
    { (OP*)&binop_list[6], 0, pp_null, 15, 0, 65535, 0xb6, 0x1, (OP*)&gvop_list[10] },
    { (OP*)&gvop_list[23], (OP*)&unop_list[33], pp_null, 0, 0, 65535, 0x6, 0x41, (OP*)&condop_list[0] },
    { (OP*)&gvop_list[12], (OP*)&unop_list[17], pp_rv2av, 0, 123, 65535, 0x16, 0x1, (OP*)&gvop_list[11] },
    { (OP*)&binop_list[7], 0, pp_null, 15, 0, 65535, 0x6, 0x1, (OP*)&gvop_list[12] },
    { (OP*)&cop_list[10], (OP*)&cop_list[10], pp_schop, 2, 37, 65535, 0x6, 0x1, (OP*)&unop_list[19] },
    { (OP*)&unop_list[18], 0, pp_null, 139, 0, 65535, 0x37, 0x0, (OP*)&binop_list[8] },
    { (OP*)&gvop_list[14], (OP*)&unop_list[21], pp_rv2av, 0, 123, 65535, 0x16, 0x1, (OP*)&gvop_list[13] },
    { (OP*)&binop_list[8], 0, pp_null, 15, 0, 65535, 0x6, 0x1, (OP*)&gvop_list[14] },
    { (OP*)&gvop_list[17], (OP*)&unop_list[25], pp_backtick, 3, 24, 65535, 0x6, 0x0, &op_list[9] },
    { (OP*)&gvop_list[16], (OP*)&unop_list[24], pp_rv2av, 0, 123, 65535, 0x16, 0x1, (OP*)&gvop_list[15] },
    { (OP*)&binop_list[11], 0, pp_null, 15, 0, 65535, 0x6, 0x1, (OP*)&gvop_list[16] },
    { (OP*)&binop_list[9], 0, pp_null, 15, 0, 65535, 0xb6, 0x1, (OP*)&gvop_list[17] },
    { (OP*)&listop_list[8], 0, pp_null, 0, 0, 65535, 0x6, 0x41, (OP*)&condop_list[1] },
    { (OP*)&pmop_list[2], 0, pp_null, 15, 0, 65535, 0x6, 0x1, (OP*)&gvop_list[18] },
    { (OP*)&listop_list[10], 0, pp_null, 65, 0, 65535, 0x6, 0x1, &op_list[12] },
    { (OP*)&gvop_list[20], (OP*)&unop_list[30], pp_rv2av, 0, 123, 65535, 0x16, 0x1, (OP*)&gvop_list[19] },
    { (OP*)&binop_list[14], 0, pp_null, 15, 0, 65535, 0x6, 0x1, (OP*)&gvop_list[20] },
    { (OP*)&binop_list[15], 0, pp_null, 15, 0, 65535, 0xb6, 0x1, (OP*)&gvop_list[21] },
    { (OP*)&listop_list[12], 0, pp_null, 15, 0, 65535, 0x6, 0x1, (OP*)&gvop_list[22] },
    { &op_list[15], &op_list[15], pp_preinc, 1, 44, 65535, 0x6, 0x1, (OP*)&unop_list[34] },
    { (OP*)&unop_list[33], 0, pp_null, 15, 0, 65535, 0x36, 0x1, (OP*)&gvop_list[23] },
    { (OP*)&binop_list[16], 0, pp_null, 15, 0, 65535, 0xb6, 0x1, (OP*)&gvop_list[24] },
    { (OP*)&binop_list[17], 0, pp_null, 0, 0, 65535, 0x6, 0x41, (OP*)&logop_list[2] },
    { (OP*)&gvop_list[26], (OP*)&unop_list[38], pp_null, 15, 0, 65535, 0x6, 0x1, (OP*)&gvop_list[25] },
    { (OP*)&binop_list[18], 0, pp_null, 15, 0, 65535, 0x6, 0x1, (OP*)&gvop_list[26] },
    { (OP*)&gvop_list[39], (OP*)&unop_list[57], pp_null, 0, 0, 65535, 0x6, 0x41, (OP*)&condop_list[2] },
    { (OP*)&gvop_list[28], (OP*)&unop_list[41], pp_rv2av, 0, 123, 65535, 0x16, 0x1, (OP*)&gvop_list[27] },
    { (OP*)&binop_list[19], 0, pp_null, 15, 0, 65535, 0x6, 0x1, (OP*)&gvop_list[28] },
    { &op_list[20], (OP*)&unop_list[46], pp_null, 139, 0, 65535, 0x7, 0x0, &op_list[18] },
    { &op_list[20], 0, pp_backtick, 5, 24, 65535, 0x7, 0x0, &op_list[19] },
    { (OP*)&gvop_list[30], (OP*)&unop_list[45], pp_rv2av, 0, 123, 65535, 0x16, 0x1, (OP*)&gvop_list[29] },
    { (OP*)&binop_list[23], 0, pp_null, 15, 0, 65535, 0x6, 0x1, (OP*)&gvop_list[30] },
    { (OP*)&binop_list[20], 0, pp_null, 139, 0, 65535, 0x7, 0x0, &op_list[20] },
    { (OP*)&binop_list[20], 0, pp_rv2av, 2, 123, 65535, 0xb7, 0x1, (OP*)&gvop_list[31] },
    { (OP*)&gvop_list[33], (OP*)&unop_list[49], pp_rv2av, 2, 123, 65535, 0x6, 0x1, (OP*)&gvop_list[32] },
    { (OP*)&binop_list[24], 0, pp_null, 15, 0, 65535, 0xb6, 0x1, (OP*)&gvop_list[33] },
    { (OP*)&listop_list[16], 0, pp_null, 0, 0, 65535, 0x6, 0x41, (OP*)&logop_list[3] },
    { (OP*)&svop_list[13], (OP*)&svop_list[13], pp_null, 15, 0, 65535, 0x6, 0x1, (OP*)&gvop_list[34] },
    { (OP*)&listop_list[18], 0, pp_null, 65, 0, 65535, 0x6, 0x1, &op_list[23] },
    { (OP*)&gvop_list[36], (OP*)&unop_list[54], pp_rv2av, 0, 123, 65535, 0x16, 0x1, (OP*)&gvop_list[35] },
    { (OP*)&binop_list[28], 0, pp_null, 15, 0, 65535, 0x6, 0x1, (OP*)&gvop_list[36] },
    { (OP*)&gvop_list[38], (OP*)&unop_list[56], pp_null, 15, 0, 65535, 0x6, 0x1, (OP*)&gvop_list[37] },
    { (OP*)&listop_list[19], 0, pp_rv2av, 4, 123, 65535, 0x7, 0x1, (OP*)&gvop_list[38] },
    { &op_list[25], &op_list[25], pp_preinc, 1, 44, 65535, 0x6, 0x1, (OP*)&unop_list[58] },
    { (OP*)&unop_list[57], 0, pp_null, 15, 0, 65535, 0x36, 0x1, (OP*)&gvop_list[39] },
    { (OP*)&binop_list[29], 0, pp_null, 15, 0, 65535, 0xb6, 0x1, (OP*)&gvop_list[40] },
    { (OP*)&binop_list[30], 0, pp_null, 0, 0, 65535, 0x6, 0x41, (OP*)&logop_list[4] },
    { (OP*)&gvop_list[42], (OP*)&unop_list[62], pp_null, 15, 0, 65535, 0x6, 0x1, (OP*)&gvop_list[41] },
    { (OP*)&binop_list[31], 0, pp_null, 15, 0, 65535, 0x6, 0x1, (OP*)&gvop_list[42] },
    { (OP*)&gvop_list[56], (OP*)&unop_list[84], pp_null, 0, 0, 65535, 0x6, 0x41, (OP*)&condop_list[3] },
    { (OP*)&gvop_list[44], (OP*)&unop_list[65], pp_null, 15, 0, 65535, 0x6, 0x1, (OP*)&gvop_list[43] },
    { (OP*)&listop_list[22], 0, pp_rv2av, 2, 123, 65535, 0x16, 0x1, (OP*)&gvop_list[44] },
    { &op_list[33], (OP*)&unop_list[71], pp_null, 139, 0, 65535, 0x7, 0x0, &op_list[29] },
    { &op_list[33], 0, pp_backtick, 8, 24, 65535, 0x7, 0x0, &op_list[30] },
    { &op_list[32], (OP*)&listop_list[26], pp_null, 15, 0, 65535, 0x6, 0x1, (OP*)&gvop_list[45] },
    { (OP*)&gvop_list[47], (OP*)&unop_list[70], pp_null, 15, 0, 65535, 0x6, 0x1, (OP*)&gvop_list[46] },
    { (OP*)&listop_list[26], 0, pp_rv2av, 4, 123, 65535, 0x16, 0x1, (OP*)&gvop_list[47] },
    { (OP*)&binop_list[32], 0, pp_null, 139, 0, 65535, 0x7, 0x0, &op_list[33] },
    { (OP*)&binop_list[32], 0, pp_rv2av, 3, 123, 65535, 0xb7, 0x1, (OP*)&gvop_list[48] },
    { (OP*)&binop_list[35], 0, pp_null, 15, 0, 65535, 0xb6, 0x1, (OP*)&gvop_list[49] },
    { (OP*)&binop_list[36], 0, pp_null, 0, 0, 65535, 0x6, 0x41, (OP*)&logop_list[5] },
    { (OP*)&svop_list[19], (OP*)&svop_list[19], pp_null, 15, 0, 65535, 0x6, 0x1, (OP*)&gvop_list[50] },
    { (OP*)&gvop_list[55], (OP*)&unop_list[82], pp_null, 0, 0, 65535, 0x6, 0x41, (OP*)&logop_list[6] },
    { (OP*)&gvop_list[52], (OP*)&unop_list[78], pp_rv2av, 0, 123, 65535, 0x16, 0x1, (OP*)&gvop_list[51] },
    { (OP*)&binop_list[38], 0, pp_null, 15, 0, 65535, 0x6, 0x1, (OP*)&gvop_list[52] },
    { (OP*)&listop_list[30], 0, pp_null, 65, 0, 65535, 0x6, 0x1, &op_list[36] },
    { (OP*)&gvop_list[54], (OP*)&unop_list[81], pp_rv2av, 0, 123, 65535, 0x16, 0x1, (OP*)&gvop_list[53] },
    { (OP*)&binop_list[40], 0, pp_null, 15, 0, 65535, 0x6, 0x1, (OP*)&gvop_list[54] },
    { &op_list[37], &op_list[37], pp_preinc, 3, 44, 65535, 0x6, 0x1, (OP*)&unop_list[83] },
    { (OP*)&unop_list[82], 0, pp_null, 15, 0, 65535, 0x36, 0x1, (OP*)&gvop_list[55] },
    { &op_list[38], &op_list[38], pp_preinc, 1, 44, 65535, 0x6, 0x1, (OP*)&unop_list[85] },
    { (OP*)&unop_list[84], 0, pp_null, 15, 0, 65535, 0x36, 0x1, (OP*)&gvop_list[56] },
    { (OP*)&binop_list[41], 0, pp_null, 15, 0, 65535, 0xb6, 0x1, (OP*)&gvop_list[57] },
    { (OP*)&binop_list[42], 0, pp_null, 0, 0, 65535, 0x6, 0x41, (OP*)&logop_list[7] },
    { (OP*)&gvop_list[59], (OP*)&unop_list[89], pp_null, 15, 0, 65535, 0x6, 0x1, (OP*)&gvop_list[58] },
    { (OP*)&binop_list[43], 0, pp_null, 15, 0, 65535, 0x6, 0x1, (OP*)&gvop_list[59] },
    { (OP*)&gvop_list[82], (OP*)&unop_list[125], pp_null, 0, 0, 65535, 0x6, 0x41, (OP*)&condop_list[4] },
    { (OP*)&gvop_list[61], (OP*)&unop_list[92], pp_null, 15, 0, 65535, 0x6, 0x1, (OP*)&gvop_list[60] },
    { (OP*)&listop_list[33], 0, pp_rv2av, 2, 123, 65535, 0x16, 0x1, (OP*)&gvop_list[61] },
    { &op_list[46], (OP*)&unop_list[98], pp_null, 139, 0, 65535, 0x7, 0x0, &op_list[42] },
    { &op_list[46], 0, pp_backtick, 8, 24, 65535, 0x7, 0x0, &op_list[43] },
    { &op_list[45], (OP*)&listop_list[37], pp_null, 15, 0, 65535, 0x6, 0x1, (OP*)&gvop_list[62] },
    { (OP*)&gvop_list[64], (OP*)&unop_list[97], pp_null, 15, 0, 65535, 0x6, 0x1, (OP*)&gvop_list[63] },
    { (OP*)&listop_list[37], 0, pp_rv2av, 4, 123, 65535, 0x16, 0x1, (OP*)&gvop_list[64] },
    { (OP*)&binop_list[44], 0, pp_null, 139, 0, 65535, 0x7, 0x0, &op_list[46] },
    { (OP*)&binop_list[44], 0, pp_rv2av, 3, 123, 65535, 0xb7, 0x1, (OP*)&gvop_list[65] },
    { (OP*)&gvop_list[67], (OP*)&unop_list[101], pp_rv2av, 3, 123, 65535, 0x6, 0x1, (OP*)&gvop_list[66] },
    { (OP*)&binop_list[47], 0, pp_null, 15, 0, 65535, 0xb6, 0x1, (OP*)&gvop_list[67] },
    { (OP*)&binop_list[48], 0, pp_null, 15, 0, 65535, 0xb6, 0x1, (OP*)&gvop_list[68] },
    { (OP*)&binop_list[49], 0, pp_null, 0, 0, 65535, 0x6, 0x41, (OP*)&logop_list[8] },
    { (OP*)&gvop_list[70], (OP*)&unop_list[105], pp_null, 15, 0, 65535, 0x6, 0x1, (OP*)&gvop_list[69] },
    { (OP*)&binop_list[50], 0, pp_null, 15, 0, 65535, 0x6, 0x1, (OP*)&gvop_list[70] },
    { (OP*)&gvop_list[72], (OP*)&unop_list[107], pp_rv2av, 0, 123, 65535, 0x16, 0x1, (OP*)&gvop_list[71] },
    { (OP*)&binop_list[51], 0, pp_null, 15, 0, 65535, 0x6, 0x1, (OP*)&gvop_list[72] },
    { (OP*)&svop_list[26], (OP*)&svop_list[26], pp_null, 125, 0, 65535, 0x6, 0x2, (OP*)&unop_list[109] },
    { &op_list[47], &op_list[47], pp_null, 123, 0, 65535, 0x16, 0x1, (OP*)&gvop_list[73] },
    { (OP*)&cop_list[37], (OP*)&cop_list[37], pp_schop, 4, 37, 65535, 0x6, 0x1, (OP*)&unop_list[111] },
    { (OP*)&unop_list[110], 0, pp_null, 139, 0, 65535, 0x37, 0x0, (OP*)&unop_list[112] },
    { (OP*)&unop_list[111], 0, pp_null, 125, 0, 65535, 0x36, 0x2, (OP*)&unop_list[113] },
    { &op_list[48], &op_list[48], pp_null, 123, 0, 65535, 0x16, 0x1, (OP*)&gvop_list[74] },
    { (OP*)&gvop_list[81], (OP*)&unop_list[123], pp_null, 0, 0, 65535, 0x6, 0x41, (OP*)&logop_list[9] },
    { (OP*)&svop_list[27], (OP*)&svop_list[27], pp_null, 125, 0, 65535, 0x6, 0x2, (OP*)&unop_list[116] },
    { &op_list[49], &op_list[49], pp_null, 123, 0, 65535, 0x16, 0x1, (OP*)&gvop_list[75] },
    { (OP*)&listop_list[43], 0, pp_null, 65, 0, 65535, 0x6, 0x1, &op_list[52] },
    { &op_list[54], (OP*)&listop_list[45], pp_null, 15, 0, 65535, 0x6, 0x1, (OP*)&gvop_list[76] },
    { (OP*)&gvop_list[78], (OP*)&unop_list[120], pp_null, 15, 0, 65535, 0x6, 0x1, (OP*)&gvop_list[77] },
    { (OP*)&listop_list[45], 0, pp_rv2av, 5, 123, 65535, 0x16, 0x1, (OP*)&gvop_list[78] },
    { (OP*)&gvop_list[80], (OP*)&unop_list[122], pp_null, 15, 0, 65535, 0x6, 0x1, (OP*)&gvop_list[79] },
    { (OP*)&listop_list[46], 0, pp_rv2av, 9, 123, 65535, 0x7, 0x1, (OP*)&gvop_list[80] },
    { &op_list[56], &op_list[56], pp_preinc, 3, 44, 65535, 0x6, 0x1, (OP*)&unop_list[124] },
    { (OP*)&unop_list[123], 0, pp_null, 15, 0, 65535, 0x36, 0x1, (OP*)&gvop_list[81] },
    { &op_list[57], &op_list[57], pp_preinc, 1, 44, 65535, 0x6, 0x1, (OP*)&unop_list[126] },
    { (OP*)&unop_list[125], 0, pp_null, 15, 0, 65535, 0x36, 0x1, (OP*)&gvop_list[82] },
    { (OP*)&binop_list[57], 0, pp_null, 15, 0, 65535, 0xb6, 0x1, (OP*)&gvop_list[83] },
    { (OP*)&binop_list[58], 0, pp_null, 0, 0, 65535, 0x6, 0x41, (OP*)&logop_list[10] },
    { (OP*)&gvop_list[85], (OP*)&unop_list[130], pp_null, 15, 0, 65535, 0x6, 0x1, (OP*)&gvop_list[84] },
    { (OP*)&binop_list[59], 0, pp_null, 15, 0, 65535, 0x6, 0x1, (OP*)&gvop_list[85] },
    { (OP*)&gvop_list[100], (OP*)&unop_list[154], pp_null, 0, 0, 65535, 0x6, 0x41, (OP*)&condop_list[5] },
    { (OP*)&gvop_list[87], (OP*)&unop_list[133], pp_rv2av, 0, 123, 65535, 0x16, 0x1, (OP*)&gvop_list[86] },
    { (OP*)&binop_list[60], 0, pp_null, 15, 0, 65535, 0x6, 0x1, (OP*)&gvop_list[87] },
    { (OP*)&gvop_list[90], (OP*)&unop_list[137], pp_backtick, 4, 24, 65535, 0x6, 0x0, &op_list[60] },
    { (OP*)&gvop_list[89], (OP*)&unop_list[136], pp_rv2av, 0, 123, 65535, 0x16, 0x1, (OP*)&gvop_list[88] },
    { (OP*)&binop_list[64], 0, pp_null, 15, 0, 65535, 0x6, 0x1, (OP*)&gvop_list[89] },
    { (OP*)&binop_list[61], 0, pp_null, 15, 0, 65535, 0xb6, 0x1, (OP*)&gvop_list[90] },
    { (OP*)&svop_list[34], (OP*)&svop_list[34], pp_null, 15, 0, 65535, 0x6, 0x1, (OP*)&gvop_list[91] },
    { (OP*)&listop_list[50], 0, pp_null, 0, 0, 65535, 0x6, 0x41, (OP*)&logop_list[11] },
    { (OP*)&gvop_list[93], (OP*)&unop_list[142], pp_null, 125, 0, 65535, 0x6, 0x2, (OP*)&unop_list[141] },
    { &op_list[61], &op_list[61], pp_null, 123, 0, 65535, 0x16, 0x1, (OP*)&gvop_list[92] },
    { (OP*)&binop_list[65], 0, pp_null, 125, 0, 65535, 0x6, 0x2, (OP*)&unop_list[143] },
    { &op_list[62], &op_list[62], pp_null, 123, 0, 65535, 0x16, 0x1, (OP*)&gvop_list[93] },
    { (OP*)&listop_list[52], 0, pp_null, 0, 0, 65535, 0x6, 0x41, (OP*)&logop_list[12] },
    { (OP*)&gvop_list[95], (OP*)&unop_list[147], pp_null, 125, 0, 65535, 0x6, 0x2, (OP*)&unop_list[146] },
    { &op_list[64], &op_list[64], pp_null, 123, 0, 65535, 0x16, 0x1, (OP*)&gvop_list[94] },
    { (OP*)&binop_list[66], 0, pp_null, 125, 0, 65535, 0x6, 0x2, (OP*)&unop_list[148] },
    { &op_list[65], &op_list[65], pp_null, 123, 0, 65535, 0x16, 0x1, (OP*)&gvop_list[95] },
    { (OP*)&listop_list[54], 0, pp_null, 65, 0, 65535, 0x6, 0x1, &op_list[68] },
    { (OP*)&gvop_list[97], (OP*)&unop_list[151], pp_rv2av, 0, 123, 65535, 0x16, 0x1, (OP*)&gvop_list[96] },
    { (OP*)&binop_list[70], 0, pp_null, 15, 0, 65535, 0x6, 0x1, (OP*)&gvop_list[97] },
    { (OP*)&gvop_list[99], (OP*)&unop_list[153], pp_null, 15, 0, 65535, 0x6, 0x1, (OP*)&gvop_list[98] },
    { (OP*)&listop_list[55], 0, pp_rv2av, 4, 123, 65535, 0x7, 0x1, (OP*)&gvop_list[99] },
    { &op_list[70], &op_list[70], pp_preinc, 1, 44, 65535, 0x6, 0x1, (OP*)&unop_list[155] },
    { (OP*)&unop_list[154], 0, pp_null, 15, 0, 65535, 0x36, 0x1, (OP*)&gvop_list[100] },
    { (OP*)&listop_list[0], 0, pp_close, 0, 189, 65535, 0x6, 0x1, (OP*)&gvop_list[101] },
};

static BINOP binop_list[71] = {
    { (OP*)&cop_list[2], (OP*)&cop_list[2], pp_aassign, 3, 35, 65535, 0x46, 0x0, (OP*)&unop_list[1], (OP*)&unop_list[3] },
    { (OP*)&cop_list[3], (OP*)&cop_list[3], pp_sassign, 0, 34, 65535, 0x46, 0x2, (OP*)&unop_list[5], (OP*)&unop_list[6] },
    { (OP*)&cop_list[4], (OP*)&cop_list[4], pp_sassign, 0, 34, 65535, 0x46, 0x2, (OP*)&unop_list[7], (OP*)&unop_list[8] },
    { (OP*)&cop_list[6], (OP*)&listop_list[5], pp_sassign, 0, 34, 65535, 0x46, 0x2, (OP*)&svop_list[4], (OP*)&unop_list[10] },
    { (OP*)&cop_list[14], 0, pp_leaveloop, 0, 180, 65535, 0x6, 0x42, (OP*)&loop_list[0], (OP*)&unop_list[11] },
    { (OP*)&logop_list[1], (OP*)&listop_list[6], pp_lt, 0, 68, 65535, 0x6, 0x2, (OP*)&unop_list[12], (OP*)&unop_list[13] },
    { (OP*)&cop_list[8], (OP*)&cop_list[8], pp_sassign, 0, 34, 65535, 0x46, 0x2, (OP*)&svop_list[5], (OP*)&unop_list[14] },
    { (OP*)&pmop_list[1], 0, pp_aelem, 0, 125, 65535, 0x6, 0x2, (OP*)&unop_list[16], (OP*)&unop_list[17] },
    { (OP*)&unop_list[18], 0, pp_aelem, 0, 125, 65535, 0x36, 0x2, (OP*)&unop_list[20], (OP*)&unop_list[21] },
    { (OP*)&cop_list[11], (OP*)&cop_list[11], pp_sassign, 0, 34, 65535, 0x46, 0x2, (OP*)&unop_list[22], (OP*)&unop_list[25] },
    { (OP*)&unop_list[22], 0, pp_concat, 2, 64, 65535, 0x6, 0x2, (OP*)&svop_list[6], (OP*)&binop_list[11] },
    { (OP*)&binop_list[10], 0, pp_aelem, 0, 125, 65535, 0x6, 0x2, (OP*)&unop_list[23], (OP*)&unop_list[24] },
    { (OP*)&listop_list[10], 0, pp_concat, 5, 64, 65535, 0x46, 0x2, (OP*)&binop_list[13], (OP*)&svop_list[8] },
    { (OP*)&svop_list[8], (OP*)&svop_list[8], pp_concat, 4, 64, 65535, 0x6, 0x2, (OP*)&svop_list[7], (OP*)&binop_list[14] },
    { (OP*)&binop_list[13], 0, pp_aelem, 0, 125, 65535, 0x6, 0x2, (OP*)&unop_list[29], (OP*)&unop_list[30] },
    { (OP*)&listop_list[9], 0, pp_sassign, 0, 34, 65535, 0x46, 0x2, (OP*)&svop_list[9], (OP*)&unop_list[31] },
    { (OP*)&cop_list[15], (OP*)&listop_list[13], pp_sassign, 0, 34, 65535, 0x46, 0x2, (OP*)&svop_list[10], (OP*)&unop_list[35] },
    { (OP*)&cop_list[20], 0, pp_leaveloop, 0, 180, 65535, 0x6, 0x42, (OP*)&loop_list[1], (OP*)&unop_list[36] },
    { (OP*)&logop_list[2], (OP*)&listop_list[14], pp_lt, 0, 68, 65535, 0x6, 0x2, (OP*)&unop_list[37], (OP*)&unop_list[38] },
    { (OP*)&pmop_list[3], 0, pp_aelem, 0, 125, 65535, 0x6, 0x2, (OP*)&unop_list[40], (OP*)&unop_list[41] },
    { (OP*)&cop_list[18], (OP*)&cop_list[18], pp_aassign, 6, 35, 65535, 0x46, 0x0, (OP*)&unop_list[42], (OP*)&unop_list[46] },
    { (OP*)&unop_list[43], 0, pp_concat, 4, 64, 65535, 0x46, 0x2, (OP*)&binop_list[22], (OP*)&svop_list[12] },
    { (OP*)&svop_list[12], (OP*)&svop_list[12], pp_concat, 3, 64, 65535, 0x6, 0x2, (OP*)&svop_list[11], (OP*)&binop_list[23] },
    { (OP*)&binop_list[22], 0, pp_aelem, 0, 125, 65535, 0x6, 0x2, (OP*)&unop_list[44], (OP*)&unop_list[45] },
    { (OP*)&cop_list[19], (OP*)&cop_list[19], pp_sassign, 0, 34, 65535, 0x46, 0x2, (OP*)&unop_list[48], (OP*)&unop_list[49] },
    { (OP*)&logop_list[3], (OP*)&listop_list[17], pp_gt, 0, 70, 65535, 0x6, 0x2, (OP*)&unop_list[51], (OP*)&svop_list[13] },
    { (OP*)&listop_list[18], 0, pp_concat, 6, 64, 65535, 0x46, 0x2, (OP*)&binop_list[27], (OP*)&listop_list[19] },
    { &op_list[24], (OP*)&listop_list[19], pp_concat, 3, 64, 65535, 0x6, 0x2, (OP*)&binop_list[28], (OP*)&svop_list[14] },
    { (OP*)&svop_list[14], (OP*)&svop_list[14], pp_aelem, 0, 125, 65535, 0x6, 0x2, (OP*)&unop_list[53], (OP*)&unop_list[54] },
    { (OP*)&cop_list[21], (OP*)&listop_list[20], pp_sassign, 0, 34, 65535, 0x46, 0x2, (OP*)&svop_list[15], (OP*)&unop_list[59] },
    { (OP*)&cop_list[27], 0, pp_leaveloop, 0, 180, 65535, 0x6, 0x42, (OP*)&loop_list[2], (OP*)&unop_list[60] },
    { (OP*)&logop_list[4], (OP*)&listop_list[21], pp_lt, 0, 68, 65535, 0x6, 0x2, (OP*)&unop_list[61], (OP*)&unop_list[62] },
    { (OP*)&cop_list[24], (OP*)&cop_list[24], pp_aassign, 9, 35, 65535, 0x46, 0x0, (OP*)&unop_list[66], (OP*)&unop_list[71] },
    { (OP*)&unop_list[67], 0, pp_concat, 7, 64, 65535, 0x46, 0x2, (OP*)&binop_list[34], (OP*)&svop_list[17] },
    { (OP*)&svop_list[17], (OP*)&svop_list[17], pp_concat, 6, 64, 65535, 0x6, 0x2, (OP*)&svop_list[16], (OP*)&listop_list[25] },
    { (OP*)&cop_list[25], (OP*)&listop_list[27], pp_sassign, 0, 34, 65535, 0x46, 0x2, (OP*)&svop_list[18], (OP*)&unop_list[73] },
    { (OP*)&listop_list[24], 0, pp_leaveloop, 0, 180, 65535, 0x6, 0x42, (OP*)&loop_list[3], (OP*)&unop_list[74] },
    { (OP*)&logop_list[5], (OP*)&listop_list[28], pp_le, 0, 72, 65535, 0x6, 0x2, (OP*)&unop_list[75], (OP*)&svop_list[19] },
    { (OP*)&pmop_list[5], 0, pp_aelem, 0, 125, 65535, 0x6, 0x2, (OP*)&unop_list[77], (OP*)&unop_list[78] },
    { (OP*)&listop_list[30], 0, pp_concat, 4, 64, 65535, 0x6, 0x2, (OP*)&binop_list[40], (OP*)&svop_list[20] },
    { (OP*)&svop_list[20], (OP*)&svop_list[20], pp_aelem, 0, 125, 65535, 0x6, 0x2, (OP*)&unop_list[80], (OP*)&unop_list[81] },
    { (OP*)&cop_list[28], (OP*)&listop_list[31], pp_sassign, 0, 34, 65535, 0x46, 0x2, (OP*)&svop_list[21], (OP*)&unop_list[86] },
    { (OP*)&cop_list[38], 0, pp_leaveloop, 0, 180, 65535, 0x6, 0x42, (OP*)&loop_list[4], (OP*)&unop_list[87] },
    { (OP*)&logop_list[7], (OP*)&listop_list[32], pp_lt, 0, 68, 65535, 0x6, 0x2, (OP*)&unop_list[88], (OP*)&unop_list[89] },
    { (OP*)&cop_list[31], (OP*)&cop_list[31], pp_aassign, 9, 35, 65535, 0x46, 0x0, (OP*)&unop_list[93], (OP*)&unop_list[98] },
    { (OP*)&unop_list[94], 0, pp_concat, 7, 64, 65535, 0x46, 0x2, (OP*)&binop_list[46], (OP*)&svop_list[23] },
    { (OP*)&svop_list[23], (OP*)&svop_list[23], pp_concat, 6, 64, 65535, 0x6, 0x2, (OP*)&svop_list[22], (OP*)&listop_list[36] },
    { (OP*)&cop_list[32], (OP*)&cop_list[32], pp_sassign, 0, 34, 65535, 0x46, 0x2, (OP*)&unop_list[100], (OP*)&unop_list[101] },
    { (OP*)&cop_list[33], (OP*)&listop_list[38], pp_sassign, 0, 34, 65535, 0x46, 0x2, (OP*)&svop_list[24], (OP*)&unop_list[102] },
    { (OP*)&listop_list[35], 0, pp_leaveloop, 0, 180, 65535, 0x6, 0x42, (OP*)&loop_list[5], (OP*)&unop_list[103] },
    { (OP*)&logop_list[8], (OP*)&listop_list[39], pp_le, 0, 72, 65535, 0x6, 0x2, (OP*)&unop_list[104], (OP*)&unop_list[105] },
    { (OP*)&svop_list[25], (OP*)&svop_list[25], pp_aelem, 0, 125, 65535, 0x6, 0x2, (OP*)&unop_list[106], (OP*)&unop_list[107] },
    { (OP*)&logop_list[9], (OP*)&listop_list[42], pp_gt, 0, 70, 65535, 0x6, 0x2, (OP*)&unop_list[115], (OP*)&svop_list[27] },
    { (OP*)&listop_list[43], 0, pp_concat, 12, 64, 65535, 0x46, 0x2, (OP*)&binop_list[54], (OP*)&svop_list[30] },
    { (OP*)&svop_list[30], (OP*)&svop_list[30], pp_concat, 11, 64, 65535, 0x46, 0x2, (OP*)&binop_list[55], (OP*)&listop_list[46] },
    { &op_list[55], (OP*)&listop_list[46], pp_concat, 8, 64, 65535, 0x46, 0x2, (OP*)&binop_list[56], (OP*)&svop_list[29] },
    { (OP*)&svop_list[29], (OP*)&svop_list[29], pp_concat, 7, 64, 65535, 0x6, 0x2, (OP*)&svop_list[28], (OP*)&listop_list[44] },
    { (OP*)&cop_list[39], (OP*)&listop_list[47], pp_sassign, 0, 34, 65535, 0x46, 0x2, (OP*)&svop_list[31], (OP*)&unop_list[127] },
    { (OP*)&cop_list[44], 0, pp_leaveloop, 0, 180, 65535, 0x6, 0x42, (OP*)&loop_list[6], (OP*)&unop_list[128] },
    { (OP*)&logop_list[10], (OP*)&listop_list[48], pp_lt, 0, 68, 65535, 0x6, 0x2, (OP*)&unop_list[129], (OP*)&unop_list[130] },
    { (OP*)&pmop_list[9], 0, pp_aelem, 0, 125, 65535, 0x6, 0x2, (OP*)&unop_list[132], (OP*)&unop_list[133] },
    { (OP*)&cop_list[42], (OP*)&cop_list[42], pp_sassign, 0, 34, 65535, 0x46, 0x2, (OP*)&unop_list[134], (OP*)&unop_list[137] },
    { (OP*)&unop_list[134], 0, pp_concat, 3, 64, 65535, 0x46, 0x2, (OP*)&binop_list[63], (OP*)&svop_list[33] },
    { (OP*)&svop_list[33], (OP*)&svop_list[33], pp_concat, 2, 64, 65535, 0x6, 0x2, (OP*)&svop_list[32], (OP*)&binop_list[64] },
    { (OP*)&binop_list[63], 0, pp_aelem, 0, 125, 65535, 0x6, 0x2, (OP*)&unop_list[135], (OP*)&unop_list[136] },
    { (OP*)&logop_list[11], (OP*)&listop_list[52], pp_eq, 0, 76, 65535, 0x6, 0x2, (OP*)&unop_list[140], (OP*)&unop_list[142] },
    { (OP*)&logop_list[12], (OP*)&listop_list[53], pp_eq, 0, 76, 65535, 0x6, 0x2, (OP*)&unop_list[145], (OP*)&unop_list[147] },
    { (OP*)&listop_list[54], 0, pp_concat, 7, 64, 65535, 0x46, 0x2, (OP*)&binop_list[68], (OP*)&svop_list[36] },
    { (OP*)&svop_list[36], (OP*)&svop_list[36], pp_concat, 6, 64, 65535, 0x46, 0x2, (OP*)&binop_list[69], (OP*)&listop_list[55] },
    { &op_list[69], (OP*)&listop_list[55], pp_concat, 2, 64, 65535, 0x6, 0x2, (OP*)&binop_list[70], (OP*)&svop_list[35] },
    { (OP*)&svop_list[35], (OP*)&svop_list[35], pp_aelem, 0, 125, 65535, 0x6, 0x2, (OP*)&unop_list[150], (OP*)&unop_list[151] },
};

static LOGOP logop_list[13] = {
    { (OP*)&cop_list[1], 0, pp_or, 0, 158, 65535, 0x6, 0x1, (OP*)&listop_list[1], &op_list[2] },
    { (OP*)&binop_list[4], 0, pp_and, 0, 157, 65535, 0x6, 0x1, (OP*)&binop_list[5], (OP*)&cop_list[7] },
    { (OP*)&binop_list[17], 0, pp_and, 0, 157, 65535, 0x6, 0x1, (OP*)&binop_list[18], (OP*)&cop_list[16] },
    { (OP*)&listop_list[16], 0, pp_and, 0, 157, 65535, 0x6, 0x1, (OP*)&binop_list[25], &op_list[21] },
    { (OP*)&binop_list[30], 0, pp_and, 0, 157, 65535, 0x6, 0x1, (OP*)&binop_list[31], (OP*)&cop_list[22] },
    { (OP*)&binop_list[36], 0, pp_and, 0, 157, 65535, 0x6, 0x1, (OP*)&binop_list[37], (OP*)&cop_list[26] },
    { (OP*)&gvop_list[55], 0, pp_and, 0, 157, 65535, 0x6, 0x1, (OP*)&pmop_list[5], &op_list[34] },
    { (OP*)&binop_list[42], 0, pp_and, 0, 157, 65535, 0x6, 0x1, (OP*)&binop_list[43], (OP*)&cop_list[29] },
    { (OP*)&binop_list[49], 0, pp_and, 0, 157, 65535, 0x6, 0x1, (OP*)&binop_list[50], (OP*)&cop_list[34] },
    { (OP*)&gvop_list[81], 0, pp_and, 0, 157, 65535, 0x6, 0x1, (OP*)&binop_list[52], &op_list[50] },
    { (OP*)&binop_list[58], 0, pp_and, 0, 157, 65535, 0x6, 0x1, (OP*)&binop_list[59], (OP*)&cop_list[40] },
    { (OP*)&listop_list[50], 0, pp_and, 0, 157, 65535, 0x6, 0x1, (OP*)&binop_list[65], &op_list[63] },
    { (OP*)&listop_list[50], 0, pp_and, 0, 157, 65535, 0x6, 0x1, (OP*)&binop_list[66], &op_list[66] },
};

static CONDOP condop_list[6] = {
    { (OP*)&gvop_list[23], 0, pp_cond_expr, 0, 160, 65535, 0x6, 0x1, (OP*)&pmop_list[1], &op_list[7], &op_list[8] },
    { (OP*)&listop_list[8], 0, pp_cond_expr, 0, 160, 65535, 0x6, 0x1, (OP*)&pmop_list[2], &op_list[10], &op_list[13] },
    { (OP*)&gvop_list[39], 0, pp_cond_expr, 0, 160, 65535, 0x6, 0x1, (OP*)&pmop_list[3], &op_list[16], &op_list[17] },
    { (OP*)&gvop_list[56], 0, pp_cond_expr, 0, 160, 65535, 0x6, 0x1, (OP*)&pmop_list[4], &op_list[27], &op_list[28] },
    { (OP*)&gvop_list[82], 0, pp_cond_expr, 0, 160, 65535, 0x6, 0x1, (OP*)&pmop_list[6], &op_list[40], &op_list[41] },
    { (OP*)&gvop_list[100], 0, pp_cond_expr, 0, 160, 65535, 0x6, 0x1, (OP*)&pmop_list[9], &op_list[58], &op_list[59] },
};

static LISTOP listop_list[56] = {
    { 0, 0, pp_leave, 0, 175, 65535, 0xe, 0x0, &op_list[0], (OP*)&unop_list[156], 28 },
    { (OP*)&logop_list[0], (OP*)&listop_list[2], pp_open, 1, 188, 65535, 0x6, 0x2, &op_list[1], (OP*)&svop_list[0], 2 },
    { (OP*)&cop_list[1], 0, pp_die, 2, 168, 65535, 0x6, 0x1, &op_list[2], (OP*)&listop_list[3], 1 },
    { (OP*)&listop_list[2], 0, pp_print, 0, 206, 65535, 0x6, 0x0, &op_list[3], (OP*)&svop_list[1], 1 },
    { (OP*)&cop_list[5], (OP*)&cop_list[5], pp_split, 2, 137, 65535, 0x6, 0x0, (OP*)&pmop_list[0], (OP*)&svop_list[3], 3 },
    { (OP*)&cop_list[14], (OP*)&cop_list[14], pp_lineseq, 0, 170, 65535, 0x6, 0x0, (OP*)&cop_list[6], (OP*)&binop_list[4], 2 },
    { (OP*)&unop_list[11], 0, pp_lineseq, 0, 170, 65535, 0xe, 0x0, (OP*)&cop_list[7], &op_list[15], 6 },
    { (OP*)&unop_list[15], (OP*)&listop_list[8], pp_scope, 0, 176, 65535, 0x6, 0x40, &op_list[7], &op_list[7], 1 },
    { (OP*)&gvop_list[23], 0, pp_leave, 0, 175, 65535, 0xe, 0x40, &op_list[8], (OP*)&unop_list[26], 7 },
    { (OP*)&listop_list[8], (OP*)&listop_list[11], pp_leave, 0, 175, 65535, 0xe, 0x40, &op_list[10], (OP*)&binop_list[15], 5 },
    { (OP*)&cop_list[13], (OP*)&cop_list[13], pp_print, 0, 206, 65535, 0x6, 0x0, &op_list[11], (OP*)&unop_list[28], 1 },
    { (OP*)&unop_list[26], 0, pp_scope, 0, 176, 65535, 0x6, 0x40, &op_list[13], (OP*)&listop_list[12], 2 },
    { (OP*)&listop_list[8], 0, pp_print, 0, 206, 65535, 0x6, 0x0, &op_list[14], (OP*)&unop_list[32], 1 },
    { (OP*)&cop_list[20], (OP*)&cop_list[20], pp_lineseq, 0, 170, 65535, 0x6, 0x0, (OP*)&cop_list[15], (OP*)&binop_list[17], 2 },
    { (OP*)&unop_list[36], 0, pp_lineseq, 0, 170, 65535, 0xe, 0x0, (OP*)&cop_list[16], &op_list[25], 4 },
    { (OP*)&unop_list[39], (OP*)&listop_list[16], pp_scope, 0, 176, 65535, 0x6, 0x40, &op_list[16], &op_list[16], 1 },
    { (OP*)&gvop_list[39], 0, pp_leave, 0, 175, 65535, 0xe, 0x40, &op_list[17], (OP*)&unop_list[50], 7 },
    { (OP*)&unop_list[50], 0, pp_scope, 0, 176, 65535, 0x6, 0x40, &op_list[21], (OP*)&listop_list[18], 2 },
    { (OP*)&listop_list[16], 0, pp_print, 0, 206, 65535, 0x6, 0x0, &op_list[22], (OP*)&unop_list[52], 1 },
    { (OP*)&binop_list[26], 0, pp_join, 5, 138, 65535, 0x6, 0x2, &op_list[24], (OP*)&unop_list[56], 2 },
    { (OP*)&cop_list[27], (OP*)&cop_list[27], pp_lineseq, 0, 170, 65535, 0x6, 0x0, (OP*)&cop_list[21], (OP*)&binop_list[30], 2 },
    { (OP*)&unop_list[60], 0, pp_lineseq, 0, 170, 65535, 0xe, 0x0, (OP*)&cop_list[22], &op_list[38], 4 },
    { (OP*)&pmop_list[4], 0, pp_aslice, 0, 126, 65535, 0x6, 0x0, &op_list[26], (OP*)&unop_list[65], 3 },
    { (OP*)&unop_list[63], (OP*)&listop_list[24], pp_scope, 0, 176, 65535, 0x6, 0x40, &op_list[27], &op_list[27], 1 },
    { (OP*)&gvop_list[56], 0, pp_leave, 0, 175, 65535, 0xe, 0x40, &op_list[28], (OP*)&listop_list[27], 6 },
    { (OP*)&binop_list[34], 0, pp_join, 5, 138, 65535, 0x6, 0x2, &op_list[31], (OP*)&listop_list[26], 2 },
    { (OP*)&listop_list[25], 0, pp_aslice, 0, 126, 65535, 0x7, 0x0, &op_list[32], (OP*)&unop_list[70], 3 },
    { (OP*)&listop_list[24], 0, pp_lineseq, 0, 170, 65535, 0x6, 0x0, (OP*)&cop_list[25], (OP*)&binop_list[36], 2 },
    { (OP*)&unop_list[74], 0, pp_lineseq, 0, 170, 65535, 0x6, 0x0, (OP*)&cop_list[26], &op_list[37], 4 },
    { (OP*)&unop_list[76], 0, pp_scope, 0, 176, 65535, 0x6, 0x40, &op_list[34], (OP*)&listop_list[30], 2 },
    { (OP*)&gvop_list[55], 0, pp_print, 0, 206, 65535, 0x6, 0x0, &op_list[35], (OP*)&unop_list[79], 1 },
    { (OP*)&cop_list[38], (OP*)&cop_list[38], pp_lineseq, 0, 170, 65535, 0x6, 0x0, (OP*)&cop_list[28], (OP*)&binop_list[42], 2 },
    { (OP*)&unop_list[87], 0, pp_lineseq, 0, 170, 65535, 0xe, 0x0, (OP*)&cop_list[29], &op_list[57], 4 },
    { (OP*)&pmop_list[6], 0, pp_aslice, 0, 126, 65535, 0x6, 0x0, &op_list[39], (OP*)&unop_list[92], 3 },
    { (OP*)&unop_list[90], (OP*)&listop_list[35], pp_scope, 0, 176, 65535, 0x6, 0x40, &op_list[40], &op_list[40], 1 },
    { (OP*)&gvop_list[82], 0, pp_leave, 0, 175, 65535, 0xe, 0x40, &op_list[41], (OP*)&listop_list[38], 8 },
    { (OP*)&binop_list[46], 0, pp_join, 5, 138, 65535, 0x6, 0x2, &op_list[44], (OP*)&listop_list[37], 2 },
    { (OP*)&listop_list[36], 0, pp_aslice, 0, 126, 65535, 0x7, 0x0, &op_list[45], (OP*)&unop_list[97], 3 },
    { (OP*)&listop_list[35], 0, pp_lineseq, 0, 170, 65535, 0x6, 0x0, (OP*)&cop_list[33], (OP*)&binop_list[49], 2 },
    { (OP*)&unop_list[103], 0, pp_lineseq, 0, 170, 65535, 0xe, 0x0, (OP*)&cop_list[34], &op_list[56], 10 },
    { (OP*)&cop_list[35], (OP*)&cop_list[35], pp_split, 5, 137, 65535, 0x6, 0x0, (OP*)&pmop_list[7], (OP*)&svop_list[25], 3 },
    { (OP*)&cop_list[36], (OP*)&cop_list[36], pp_split, 5, 137, 65535, 0x6, 0x0, (OP*)&pmop_list[8], (OP*)&svop_list[26], 3 },
    { (OP*)&unop_list[114], 0, pp_scope, 0, 176, 65535, 0x6, 0x40, &op_list[50], (OP*)&listop_list[43], 2 },
    { (OP*)&gvop_list[81], 0, pp_print, 0, 206, 65535, 0x6, 0x0, &op_list[51], (OP*)&unop_list[117], 1 },
    { (OP*)&binop_list[56], 0, pp_join, 6, 138, 65535, 0x6, 0x2, &op_list[53], (OP*)&listop_list[45], 2 },
    { (OP*)&listop_list[44], 0, pp_aslice, 0, 126, 65535, 0x7, 0x0, &op_list[54], (OP*)&unop_list[120], 3 },
    { (OP*)&binop_list[54], 0, pp_join, 10, 138, 65535, 0x6, 0x2, &op_list[55], (OP*)&unop_list[122], 2 },
    { (OP*)&cop_list[44], (OP*)&cop_list[44], pp_lineseq, 0, 170, 65535, 0x6, 0x0, (OP*)&cop_list[39], (OP*)&binop_list[58], 2 },
    { (OP*)&unop_list[128], 0, pp_lineseq, 0, 170, 65535, 0xe, 0x0, (OP*)&cop_list[40], &op_list[70], 4 },
    { (OP*)&unop_list[131], (OP*)&listop_list[50], pp_scope, 0, 176, 65535, 0x6, 0x40, &op_list[58], &op_list[58], 1 },
    { (OP*)&gvop_list[100], 0, pp_leave, 0, 175, 65535, 0xe, 0x40, &op_list[59], (OP*)&unop_list[139], 7 },
    { (OP*)&cop_list[43], (OP*)&cop_list[43], pp_split, 3, 137, 65535, 0x6, 0x0, (OP*)&pmop_list[10], (OP*)&svop_list[34], 3 },
    { (OP*)&unop_list[139], 0, pp_scope, 0, 176, 65535, 0x6, 0x40, &op_list[63], (OP*)&unop_list[144], 2 },
    { (OP*)&unop_list[144], 0, pp_scope, 0, 176, 65535, 0x6, 0x40, &op_list[66], (OP*)&listop_list[54], 2 },
    { (OP*)&listop_list[50], 0, pp_print, 0, 206, 65535, 0x6, 0x0, &op_list[67], (OP*)&unop_list[149], 1 },
    { (OP*)&binop_list[68], 0, pp_join, 5, 138, 65535, 0x6, 0x2, &op_list[69], (OP*)&unop_list[153], 2 },
};

static PMOP pmop_list[11] = {
    { (OP*)&gvop_list[6], (OP*)&unop_list[9], pp_pushre, 0, 13, 65535, 0x82, 0x0, 0, 0, 0, 0, 0, 0, 0, Nullsv, 0x812, 0x0, 0 },
    { (OP*)&condop_list[0], (OP*)&listop_list[7], pp_match, 0, 30, 65535, 0x46, 0x0, (OP*)&binop_list[7], (OP*)&binop_list[7], 1, 0, 0, 0, 0, &sv_list[31], 0x4, 0x0, 1 },
    { (OP*)&condop_list[1], (OP*)&listop_list[9], pp_match, 0, 30, 65535, 0x46, 0x0, (OP*)&unop_list[27], (OP*)&unop_list[27], 1, 0, 0, 0, 0, &sv_list[34], 0x4, 0x0, 9 },
    { (OP*)&condop_list[2], (OP*)&listop_list[15], pp_match, 0, 30, 65535, 0x46, 0x0, (OP*)&binop_list[19], (OP*)&binop_list[19], 1, 0, 0, 0, 0, &sv_list[39], 0x4, 0x0, 1 },
    { (OP*)&condop_list[3], (OP*)&listop_list[23], pp_match, 0, 30, 65535, 0x46, 0x0, (OP*)&listop_list[22], (OP*)&listop_list[22], 1, 0, 0, 0, 0, &sv_list[48], 0x4, 0x0, 1 },
    { (OP*)&logop_list[6], (OP*)&listop_list[29], pp_match, 0, 30, 65535, 0x46, 0x0, (OP*)&binop_list[38], (OP*)&binop_list[38], 1, 0, 0, 0, 0, Nullsv, 0x0, 0x0, 0 },
    { (OP*)&condop_list[4], (OP*)&listop_list[34], pp_match, 0, 30, 65535, 0x46, 0x0, (OP*)&listop_list[33], (OP*)&listop_list[33], 1, 0, 0, 0, 0, &sv_list[58], 0x4, 0x0, 1 },
    { (OP*)&gvop_list[71], (OP*)&binop_list[51], pp_pushre, 0, 13, 65535, 0x82, 0x0, 0, 0, 0, 0, 0, 0, 0, Nullsv, 0x812, 0x0, 0 },
    { (OP*)&gvop_list[73], (OP*)&unop_list[108], pp_pushre, 0, 13, 65535, 0x82, 0x0, 0, 0, 0, 0, 0, 0, 0, Nullsv, 0x812, 0x0, 0 },
    { (OP*)&condop_list[5], (OP*)&listop_list[49], pp_match, 0, 30, 65535, 0x46, 0x0, (OP*)&binop_list[60], (OP*)&binop_list[60], 1, 0, 0, 0, 0, &sv_list[77], 0x4, 0x0, 1 },
    { (OP*)&gvop_list[91], (OP*)&unop_list[138], pp_pushre, 0, 13, 65535, 0x82, 0x0, 0, 0, 0, 0, 0, 0, 0, Nullsv, 0x812, 0x0, 0 },
};

static SVOP svop_list[37] = {
    { (OP*)&listop_list[1], 0, pp_const, 0, 5, 65535, 0x2, 0x0, (SV*)&sv_list[17] },
    { (OP*)&listop_list[3], 0, pp_const, 0, 5, 65535, 0x2, 0x0, (SV*)&sv_list[18] },
    { (OP*)&unop_list[7], 0, pp_const, 0, 5, 65535, 0x2, 0x0, (SV*)&sv_list[22] },
    { (OP*)&listop_list[4], 0, pp_const, 0, 5, 65535, 0x2, 0x0, (SV*)&sv_list[26] },
    { (OP*)&gvop_list[7], (OP*)&unop_list[10], pp_const, 0, 5, 65535, 0x2, 0x0, (SV*)&sv_list[27] },
    { (OP*)&gvop_list[10], (OP*)&unop_list[14], pp_const, 0, 5, 65535, 0x2, 0x0, (SV*)&sv_list[29] },
    { (OP*)&gvop_list[15], (OP*)&binop_list[11], pp_const, 0, 5, 65535, 0x2, 0x0, (SV*)&sv_list[32] },
    { (OP*)&gvop_list[19], (OP*)&binop_list[14], pp_const, 0, 5, 65535, 0x2, 0x0, (SV*)&sv_list[35] },
    { (OP*)&binop_list[12], 0, pp_const, 0, 5, 65535, 0x2, 0x0, (SV*)&sv_list[36] },
    { (OP*)&gvop_list[21], (OP*)&unop_list[31], pp_const, 0, 5, 65535, 0x2, 0x0, (SV*)&sv_list[37] },
    { (OP*)&gvop_list[24], (OP*)&unop_list[35], pp_const, 0, 5, 65535, 0x2, 0x0, (SV*)&sv_list[38] },
    { (OP*)&gvop_list[29], (OP*)&binop_list[23], pp_const, 0, 5, 65535, 0x2, 0x0, (SV*)&sv_list[40] },
    { (OP*)&binop_list[21], 0, pp_const, 0, 5, 65535, 0x2, 0x0, (SV*)&sv_list[41] },
    { (OP*)&binop_list[25], 0, pp_const, 0, 5, 65535, 0x2, 0x0, (SV*)&sv_list[45] },
    { (OP*)&binop_list[27], 0, pp_const, 0, 5, 65535, 0x2, 0x0, (SV*)&sv_list[46] },
    { (OP*)&gvop_list[40], (OP*)&unop_list[59], pp_const, 0, 5, 65535, 0x2, 0x0, (SV*)&sv_list[47] },
    { &op_list[31], (OP*)&listop_list[25], pp_const, 0, 5, 65535, 0x2, 0x0, (SV*)&sv_list[49] },
    { (OP*)&binop_list[33], 0, pp_const, 0, 5, 65535, 0x2, 0x0, (SV*)&sv_list[50] },
    { (OP*)&gvop_list[49], (OP*)&unop_list[73], pp_const, 0, 5, 65535, 0x2, 0x0, (SV*)&sv_list[53] },
    { (OP*)&binop_list[37], 0, pp_const, 0, 5, 65535, 0x2, 0x0, (SV*)&sv_list[55] },
    { (OP*)&binop_list[39], 0, pp_const, 0, 5, 65535, 0x2, 0x0, (SV*)&sv_list[56] },
    { (OP*)&gvop_list[57], (OP*)&unop_list[86], pp_const, 0, 5, 65535, 0x2, 0x0, (SV*)&sv_list[57] },
    { &op_list[44], (OP*)&listop_list[36], pp_const, 0, 5, 65535, 0x2, 0x0, (SV*)&sv_list[59] },
    { (OP*)&binop_list[45], 0, pp_const, 0, 5, 65535, 0x2, 0x0, (SV*)&sv_list[60] },
    { (OP*)&gvop_list[68], (OP*)&unop_list[102], pp_const, 0, 5, 65535, 0x2, 0x0, (SV*)&sv_list[64] },
    { (OP*)&listop_list[40], 0, pp_const, 0, 5, 65535, 0x2, 0x0, (SV*)&sv_list[68] },
    { (OP*)&listop_list[41], 0, pp_const, 0, 5, 65535, 0x2, 0x0, (SV*)&sv_list[71] },
    { (OP*)&binop_list[52], 0, pp_const, 0, 5, 65535, 0x2, 0x0, (SV*)&sv_list[72] },
    { &op_list[53], (OP*)&listop_list[44], pp_const, 0, 5, 65535, 0x2, 0x0, (SV*)&sv_list[73] },
    { (OP*)&binop_list[55], 0, pp_const, 0, 5, 65535, 0x2, 0x0, (SV*)&sv_list[74] },
    { (OP*)&binop_list[53], 0, pp_const, 0, 5, 65535, 0x2, 0x0, (SV*)&sv_list[75] },
    { (OP*)&gvop_list[83], (OP*)&unop_list[127], pp_const, 0, 5, 65535, 0x2, 0x0, (SV*)&sv_list[76] },
    { (OP*)&gvop_list[88], (OP*)&binop_list[64], pp_const, 0, 5, 65535, 0x2, 0x0, (SV*)&sv_list[78] },
    { (OP*)&binop_list[62], 0, pp_const, 0, 5, 65535, 0x2, 0x0, (SV*)&sv_list[79] },
    { (OP*)&listop_list[51], 0, pp_const, 0, 5, 65535, 0x2, 0x0, (SV*)&sv_list[83] },
    { (OP*)&binop_list[69], 0, pp_const, 0, 5, 65535, 0x2, 0x0, (SV*)&sv_list[84] },
    { (OP*)&binop_list[67], 0, pp_const, 0, 5, 65535, 0x2, 0x0, (SV*)&sv_list[85] },
};

static GVOP gvop_list[102] = {
    { (OP*)&svop_list[0], (OP*)&svop_list[0], pp_gv, 0, 7, 65535, 0x2, 0x0, Nullgv },
    { (OP*)&unop_list[2], 0, pp_gv, 0, 7, 65535, 0x2, 0x0, Nullgv },
    { (OP*)&unop_list[4], 0, pp_gv, 0, 7, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&unop_list[5], 0, pp_gv, 0, 7, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&binop_list[1], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&binop_list[2], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&svop_list[3], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&binop_list[3], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&gvop_list[9], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&binop_list[5], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&binop_list[6], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&unop_list[16], 0, pp_gv, 0, 7, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&binop_list[7], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&unop_list[20], 0, pp_gv, 0, 7, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&binop_list[8], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&unop_list[23], 0, pp_gv, 0, 7, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&binop_list[11], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&binop_list[9], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&pmop_list[2], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&unop_list[29], 0, pp_gv, 0, 7, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&binop_list[14], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&binop_list[15], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&listop_list[12], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&unop_list[33], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&binop_list[16], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&gvop_list[26], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&binop_list[18], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&unop_list[40], 0, pp_gv, 0, 7, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&binop_list[19], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&unop_list[44], 0, pp_gv, 0, 7, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&binop_list[23], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&unop_list[47], 0, pp_gv, 0, 7, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&unop_list[48], 0, pp_gv, 0, 7, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&binop_list[24], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&svop_list[13], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&unop_list[53], 0, pp_gv, 0, 7, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&binop_list[28], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&gvop_list[38], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&unop_list[56], 0, pp_gv, 0, 7, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&unop_list[57], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&binop_list[29], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&gvop_list[42], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&binop_list[31], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&gvop_list[44], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&unop_list[65], 0, pp_gv, 0, 7, 65535, 0x2, 0x10, Nullgv },
    { &op_list[32], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&gvop_list[47], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&unop_list[70], 0, pp_gv, 0, 7, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&unop_list[72], 0, pp_gv, 0, 7, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&binop_list[35], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&svop_list[19], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&unop_list[77], 0, pp_gv, 0, 7, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&binop_list[38], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&unop_list[80], 0, pp_gv, 0, 7, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&binop_list[40], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&unop_list[82], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&unop_list[84], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&binop_list[41], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&gvop_list[59], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&binop_list[43], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&gvop_list[61], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&unop_list[92], 0, pp_gv, 0, 7, 65535, 0x2, 0x10, Nullgv },
    { &op_list[45], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&gvop_list[64], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&unop_list[97], 0, pp_gv, 0, 7, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&unop_list[99], 0, pp_gv, 0, 7, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&unop_list[100], 0, pp_gv, 0, 7, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&binop_list[47], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&binop_list[48], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&gvop_list[70], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&binop_list[50], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&unop_list[106], 0, pp_gv, 0, 7, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&binop_list[51], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&svop_list[26], 0, pp_aelemfast, 0, 124, 65535, 0x2, 0x3, Nullgv },
    { (OP*)&unop_list[110], 0, pp_aelemfast, 0, 124, 65535, 0x22, 0x1, Nullgv },
    { (OP*)&svop_list[27], 0, pp_aelemfast, 0, 124, 65535, 0x2, 0x1, Nullgv },
    { &op_list[54], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&gvop_list[78], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&unop_list[120], 0, pp_gv, 0, 7, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&gvop_list[80], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&unop_list[122], 0, pp_gv, 0, 7, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&unop_list[123], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&unop_list[125], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&binop_list[57], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&gvop_list[85], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&binop_list[59], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&unop_list[132], 0, pp_gv, 0, 7, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&binop_list[60], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&unop_list[135], 0, pp_gv, 0, 7, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&binop_list[64], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&binop_list[61], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&svop_list[34], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&gvop_list[93], 0, pp_aelemfast, 0, 124, 65535, 0x2, 0x3, Nullgv },
    { (OP*)&binop_list[65], 0, pp_aelemfast, 0, 124, 65535, 0x2, 0x1, Nullgv },
    { (OP*)&gvop_list[95], 0, pp_aelemfast, 0, 124, 65535, 0x2, 0x4, Nullgv },
    { (OP*)&binop_list[66], 0, pp_aelemfast, 0, 124, 65535, 0x2, 0x2, Nullgv },
    { (OP*)&unop_list[150], 0, pp_gv, 0, 7, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&binop_list[70], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&gvop_list[99], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&unop_list[153], 0, pp_gv, 0, 7, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&unop_list[154], 0, pp_gvsv, 0, 6, 65535, 0x2, 0x10, Nullgv },
    { (OP*)&unop_list[156], 0, pp_gv, 0, 7, 65535, 0x2, 0x0, Nullgv },
};

static LOOP loop_list[7] = {
    { (OP*)&gvop_list[8], (OP*)&unop_list[11], pp_enterloop, 0, 179, 65535, 0x2, 0x0, 0, 0, 0, (OP*)&cop_list[7], (OP*)&gvop_list[23], (OP*)&binop_list[4] },
    { (OP*)&gvop_list[25], (OP*)&unop_list[36], pp_enterloop, 0, 179, 65535, 0x2, 0x0, 0, 0, 0, (OP*)&cop_list[16], (OP*)&gvop_list[39], (OP*)&binop_list[17] },
    { (OP*)&gvop_list[41], (OP*)&unop_list[60], pp_enterloop, 0, 179, 65535, 0x2, 0x0, 0, 0, 0, (OP*)&cop_list[22], (OP*)&gvop_list[56], (OP*)&binop_list[30] },
    { (OP*)&gvop_list[50], (OP*)&unop_list[74], pp_enterloop, 0, 179, 65535, 0x2, 0x0, 0, 0, 0, (OP*)&cop_list[26], (OP*)&gvop_list[55], (OP*)&binop_list[36] },
    { (OP*)&gvop_list[58], (OP*)&unop_list[87], pp_enterloop, 0, 179, 65535, 0x2, 0x0, 0, 0, 0, (OP*)&cop_list[29], (OP*)&gvop_list[82], (OP*)&binop_list[42] },
    { (OP*)&gvop_list[69], (OP*)&unop_list[103], pp_enterloop, 0, 179, 65535, 0x2, 0x0, 0, 0, 0, (OP*)&cop_list[34], (OP*)&gvop_list[81], (OP*)&binop_list[49] },
    { (OP*)&gvop_list[84], (OP*)&unop_list[128], pp_enterloop, 0, 179, 65535, 0x2, 0x0, 0, 0, 0, (OP*)&cop_list[40], (OP*)&gvop_list[100], (OP*)&binop_list[58] },
};

static COP cop_list[45] = {
    { (OP*)&gvop_list[0], (OP*)&unop_list[0], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1111, 0, 3 },
    { &op_list[4], (OP*)&binop_list[0], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1112, 0, 4 },
    { (OP*)&gvop_list[3], (OP*)&binop_list[1], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1113, 0, 5 },
    { (OP*)&svop_list[2], (OP*)&binop_list[2], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1114, 0, 6 },
    { (OP*)&pmop_list[0], (OP*)&listop_list[4], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1115, 0, 7 },
    { (OP*)&svop_list[4], (OP*)&binop_list[3], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1124, 0, 10 },
    { (OP*)&loop_list[0], (OP*)&binop_list[4], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1125, 0, 29 },
    { (OP*)&svop_list[5], (OP*)&binop_list[6], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1116, 0, 12 },
    { (OP*)&gvop_list[11], (OP*)&unop_list[15], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1123, 0, 13 },
    { (OP*)&gvop_list[13], (OP*)&unop_list[18], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1117, 0, 19 },
    { (OP*)&svop_list[6], (OP*)&binop_list[9], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1118, 0, 20 },
    { (OP*)&gvop_list[18], (OP*)&unop_list[26], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1122, 0, 21 },
    { &op_list[11], (OP*)&listop_list[10], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1119, 0, 23 },
    { (OP*)&svop_list[9], (OP*)&binop_list[15], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1120, 0, 24 },
    { (OP*)&svop_list[10], (OP*)&binop_list[16], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1131, 0, 33 },
    { (OP*)&loop_list[1], (OP*)&binop_list[17], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1132, 0, 48 },
    { (OP*)&gvop_list[27], (OP*)&unop_list[39], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1130, 0, 35 },
    { &op_list[18], (OP*)&binop_list[20], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1126, 0, 41 },
    { (OP*)&gvop_list[32], (OP*)&binop_list[24], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1127, 0, 42 },
    { (OP*)&gvop_list[34], (OP*)&unop_list[50], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1129, 0, 43 },
    { (OP*)&svop_list[15], (OP*)&binop_list[29], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1139, 0, 51 },
    { (OP*)&loop_list[2], (OP*)&binop_list[30], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1140, 0, 66 },
    { &op_list[26], (OP*)&unop_list[63], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1138, 0, 53 },
    { &op_list[29], (OP*)&binop_list[32], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1133, 0, 57 },
    { (OP*)&svop_list[18], (OP*)&binop_list[35], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1136, 0, 58 },
    { (OP*)&loop_list[3], (OP*)&binop_list[36], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1137, 0, 64 },
    { (OP*)&gvop_list[51], (OP*)&unop_list[76], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1135, 0, 60 },
    { (OP*)&svop_list[21], (OP*)&binop_list[41], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1151, 0, 69 },
    { (OP*)&loop_list[4], (OP*)&binop_list[42], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1152, 0, 88 },
    { &op_list[39], (OP*)&unop_list[90], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1150, 0, 71 },
    { &op_list[42], (OP*)&binop_list[44], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1141, 0, 75 },
    { (OP*)&gvop_list[66], (OP*)&binop_list[47], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1142, 0, 76 },
    { (OP*)&svop_list[24], (OP*)&binop_list[48], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1148, 0, 77 },
    { (OP*)&loop_list[5], (OP*)&binop_list[49], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1149, 0, 86 },
    { (OP*)&pmop_list[7], (OP*)&listop_list[40], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1143, 0, 79 },
    { (OP*)&pmop_list[8], (OP*)&listop_list[41], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1144, 0, 80 },
    { (OP*)&gvop_list[74], (OP*)&unop_list[110], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1145, 0, 81 },
    { (OP*)&gvop_list[75], (OP*)&unop_list[114], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1147, 0, 82 },
    { (OP*)&svop_list[31], (OP*)&binop_list[57], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1159, 0, 91 },
    { (OP*)&loop_list[6], (OP*)&binop_list[58], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1160, 0, 107 },
    { (OP*)&gvop_list[86], (OP*)&unop_list[131], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1158, 0, 93 },
    { (OP*)&svop_list[32], (OP*)&binop_list[61], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1153, 0, 97 },
    { (OP*)&pmop_list[10], (OP*)&listop_list[51], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1154, 0, 98 },
    { (OP*)&gvop_list[92], (OP*)&unop_list[139], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1157, 0, 99 },
    { (OP*)&gvop_list[101], (OP*)&unop_list[156], pp_nextstate, 0, 171, 65535, 0x2, 0x0, 0, Nullhv, Nullgv, 1161, 0, 109 },
};

static SV sv_list[86] = {
    { &xpvav_list[0], 2, 0xa },
    { 0, 2, 0x200 },
    { 0, 2, 0x200 },
    { 0, 2, 0x200 },
    { 0, 2, 0x200 },
    { 0, 2, 0x0 },
    { 0, 2, 0x0 },
    { 0, 2, 0x0 },
    { 0, 2, 0x0 },
    { 0, 2, 0x0 },
    { 0, 2, 0x0 },
    { 0, 2, 0x0 },
    { 0, 2, 0x0 },
    { 0, 2, 0x0 },
    { &xpv_list[0], 2, 0x4040004 },
    { 0, 2, 0x0 },
    { &xpvio_list[0], 2, 0x100f },
    { &xpviv_list[0], 2, 0x4840005 },
    { &xpviv_list[1], 2, 0x4840005 },
    { 0, 2, 0x0 },
    { &xpvav_list[1], 2, 0xa },
    { 0, 2, 0x0 },
    { &xpv_list[1], 2, 0x4840004 },
    { 0, 2, 0x0 },
    { 0, 2, 0x0 },
    { &xpvav_list[2], 2, 0xa },
    { &xpviv_list[2], 2, 0x1810001 },
    { &xpviv_list[3], 2, 0x1810001 },
    { 0, 2, 0x0 },
    { &xpviv_list[4], 2, 0x1810001 },
    { 0, 2, 0x0 },
    { &xpvbm_list[0], 3, 0x7070008 },
    { &xpv_list[2], 2, 0x4840004 },
    { 0, 2, 0x0 },
    { &xpvbm_list[1], 3, 0x87074008 },
    { &xpv_list[3], 2, 0x4840004 },
    { &xpv_list[4], 2, 0x4840004 },
    { &xpviv_list[5], 2, 0x1810001 },
    { &xpviv_list[6], 2, 0x1810001 },
    { &xpvbm_list[2], 3, 0x7070008 },
    { &xpv_list[5], 2, 0x4840004 },
    { &xpv_list[6], 2, 0x4840004 },
    { 0, 2, 0x0 },
    { &xpvav_list[3], 2, 0xa },
    { 0, 2, 0x0 },
    { &xpviv_list[7], 2, 0x1810001 },
    { &xpv_list[7], 2, 0x4840004 },
    { &xpviv_list[8], 2, 0x1810001 },
    { &xpvbm_list[3], 3, 0x7070008 },
    { &xpv_list[8], 2, 0x4840004 },
    { &xpv_list[9], 2, 0x4840004 },
    { 0, 2, 0x0 },
    { &xpvav_list[4], 2, 0xa },
    { &xpviv_list[9], 2, 0x1810001 },
    { 0, 2, 0x0 },
    { &xpviv_list[10], 2, 0x1810001 },
    { &xpv_list[10], 2, 0x4840004 },
    { &xpviv_list[11], 2, 0x1810001 },
    { &xpvbm_list[4], 3, 0x7070008 },
    { &xpv_list[11], 2, 0x4840004 },
    { &xpv_list[12], 2, 0x4840004 },
    { 0, 2, 0x0 },
    { &xpvav_list[5], 2, 0xa },
    { 0, 2, 0x0 },
    { &xpviv_list[12], 2, 0x1810001 },
    { 0, 2, 0x0 },
    { 0, 2, 0x0 },
    { &xpvav_list[6], 2, 0xa },
    { &xpviv_list[13], 2, 0x1810001 },
    { 0, 2, 0x0 },
    { &xpvav_list[7], 2, 0xa },
    { &xpviv_list[14], 2, 0x1810001 },
    { &xpviv_list[15], 2, 0x1810001 },
    { &xpv_list[13], 2, 0x4840004 },
    { &xpv_list[14], 2, 0x4840004 },
    { &xpv_list[15], 2, 0x4840004 },
    { &xpviv_list[16], 2, 0x1810001 },
    { &xpvbm_list[5], 3, 0x7070008 },
    { &xpv_list[16], 2, 0x4840004 },
    { &xpv_list[17], 2, 0x4840004 },
    { 0, 2, 0x0 },
    { 0, 2, 0x0 },
    { &xpvav_list[8], 2, 0xa },
    { &xpviv_list[17], 2, 0x1810001 },
    { &xpv_list[18], 2, 0x4840004 },
    { &xpv_list[19], 2, 0x4840004 },
};

static XPV xpv_list[20] = {
    { 0, 9, 10 },
    { 0, 4, 5 },
    { 0, 15, 16 },
    { 0, 15, 16 },
    { 0, 1, 2 },
    { 0, 12, 13 },
    { 0, 23, 24 },
    { 0, 1, 2 },
    { 0, 12, 13 },
    { 0, 26, 27 },
    { 0, 1, 2 },
    { 0, 12, 13 },
    { 0, 6, 7 },
    { 0, 8, 9 },
    { 0, 1, 2 },
    { 0, 1, 2 },
    { 0, 12, 13 },
    { 0, 7, 8 },
    { 0, 2, 3 },
    { 0, 1, 2 },
};

static XPVIV xpviv_list[18] = {
    { 0, 26, 27, 0 },
    { 0, 6, 7, 0 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 1 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 50 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 3 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 4 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 93 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
};

static XPVBM xpvbm_list[6] = {
    { 0, 258, 516, 0, 0, 0, 0, 0, 0, 0x0 },
    { 0, 266, 524, 0, 0, 0, 0, 0, 6, 0x77 },
    { 0, 258, 516, 0, 0, 0, 0, 0, 0, 0x0 },
    { 0, 258, 516, 0, 0, 0, 0, 0, 0, 0x0 },
    { 0, 258, 516, 0, 0, 0, 0, 0, 0, 0x0 },
    { 0, 258, 516, 0, 0, 0, 0, 0, 0, 0x0 },
};

static XPVAV xpvav_list[9] = {
    { 0, -1, -1, 0, 0.0, 0, Nullhv, 0, 0, 0x1 },
    { 0, -1, -1, 0, 0.0, 0, Nullhv, 0, 0, 0x1 },
    { 0, -1, -1, 0, 0.0, 0, Nullhv, 0, 0, 0x1 },
    { 0, -1, -1, 0, 0.0, 0, Nullhv, 0, 0, 0x1 },
    { 0, -1, -1, 0, 0.0, 0, Nullhv, 0, 0, 0x1 },
    { 0, -1, -1, 0, 0.0, 0, Nullhv, 0, 0, 0x1 },
    { 0, -1, -1, 0, 0.0, 0, Nullhv, 0, 0, 0x1 },
    { 0, -1, -1, 0, 0.0, 0, Nullhv, 0, 0, 0x1 },
    { 0, -1, -1, 0, 0.0, 0, Nullhv, 0, 0, 0x1 },
};

static XPVIO xpvio_list[1] = {
    { 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 60, 0, 0, Nullgv, 0, Nullgv, 0, Nullgv, 0, '\000', 0x0 },
};

static int perl_init()
{
    {
        SV **svp;
        AV *av = (AV*)&sv_list[0];
        av_extend(av, 13);
        svp = AvARRAY(av);
        *svp++ = (SV*)&sv_undef;
        *svp++ = (SV*)&sv_list[1];
        *svp++ = (SV*)&sv_list[2];
        *svp++ = (SV*)&sv_list[3];
        *svp++ = (SV*)&sv_list[4];
        *svp++ = (SV*)&sv_list[5];
        *svp++ = (SV*)&sv_list[6];
        *svp++ = (SV*)&sv_list[7];
        *svp++ = (SV*)&sv_list[8];
        *svp++ = (SV*)&sv_list[9];
        *svp++ = (SV*)&sv_list[10];
        *svp++ = (SV*)&sv_list[11];
        *svp++ = (SV*)&sv_list[12];
        *svp++ = (SV*)&sv_list[13];
        AvFILL(av) = 13;
    }
    gv_list[0] = gv_fetchpv("main::_<netchk.pl", TRUE, SVt_PV);
    SvFLAGS(gv_list[0]) = 0x600d;
    GvFLAGS(gv_list[0]) = 0x0;
    GvLINE(gv_list[0]) = 0;
    SvREFCNT(gv_list[0]) += 46;
    GvSV(gv_list[0]) = &sv_list[14];
    xpv_list[0].xpv_pv = savepvn("netchk.pl", 9);
    hv0 = gv_stashpv("main", TRUE);
    cop_list[0].cop_filegv = gv_list[0];
    cop_list[0].cop_stash = hv0;
    gv_list[1] = gv_fetchpv("main::HOSTSFILE", TRUE, SVt_PV);
    SvFLAGS(gv_list[1]) = 0x600d;
    GvFLAGS(gv_list[1]) = 0x2;
    GvLINE(gv_list[1]) = 3;
    SvREFCNT(gv_list[1]) += 4;
    GvSV(gv_list[1]) = &sv_list[15];
    GvFILEGV(gv_list[1]) = gv_list[0];
    GvIOp(gv_list[1]) = (IO*)&sv_list[16];
    SvSTASH((IO*)&sv_list[16]) = UNUSED;
    gvop_list[0].op_gv = gv_list[1];
    xpviv_list[0].xpv_pv = savepvn("/home/oper/bin/.hosts.list", 26);
    xpviv_list[1].xpv_pv = savepvn("DAMNIT", 6);
    cop_list[1].cop_filegv = gv_list[0];
    cop_list[1].cop_stash = hv0;
    gvop_list[1].op_gv = gv_list[1];
    gv_list[2] = gv_fetchpv("main::HOST", TRUE, SVt_PV);
    SvFLAGS(gv_list[2]) = 0x600d;
    GvFLAGS(gv_list[2]) = 0x2;
    GvLINE(gv_list[2]) = 4;
    SvREFCNT(gv_list[2]) += 18;
    GvSV(gv_list[2]) = &sv_list[19];
    GvAV(gv_list[2]) = (AV*)&sv_list[20];
    GvFILEGV(gv_list[2]) = gv_list[0];
    gvop_list[2].op_gv = gv_list[2];
    cop_list[2].cop_filegv = gv_list[0];
    cop_list[2].cop_stash = hv0;
    gvop_list[3].op_gv = gv_list[2];
    gv_list[3] = gv_fetchpv("main::HOSTCOUNT", TRUE, SVt_PV);
    SvFLAGS(gv_list[3]) = 0x600d;
    GvFLAGS(gv_list[3]) = 0x2;
    GvLINE(gv_list[3]) = 5;
    SvREFCNT(gv_list[3]) += 7;
    GvSV(gv_list[3]) = &sv_list[21];
    GvFILEGV(gv_list[3]) = gv_list[0];
    gvop_list[4].op_gv = gv_list[3];
    cop_list[3].cop_filegv = gv_list[0];
    cop_list[3].cop_stash = hv0;
    xpv_list[1].xpv_pv = savepvn("date", 4);
    gv_list[4] = gv_fetchpv("main::DATE", TRUE, SVt_PV);
    SvFLAGS(gv_list[4]) = 0x600d;
    GvFLAGS(gv_list[4]) = 0x2;
    GvLINE(gv_list[4]) = 6;
    SvREFCNT(gv_list[4]) += 3;
    GvSV(gv_list[4]) = &sv_list[23];
    GvFILEGV(gv_list[4]) = gv_list[0];
    gvop_list[5].op_gv = gv_list[4];
    cop_list[4].cop_filegv = gv_list[0];
    cop_list[4].cop_stash = hv0;
    gv_list[5] = gv_fetchpv("main::DATE2", TRUE, SVt_PV);
    SvFLAGS(gv_list[5]) = 0x600d;
    GvFLAGS(gv_list[5]) = 0x2;
    GvLINE(gv_list[5]) = 7;
    SvREFCNT(gv_list[5]) += 3;
    GvSV(gv_list[5]) = &sv_list[24];
    GvAV(gv_list[5]) = (AV*)&sv_list[25];
    GvFILEGV(gv_list[5]) = gv_list[0];
    pmop_list[0].op_pmregexp = pregcomp(re0, re0 + 3, &pmop_list[0]);
    pmop_list[0].op_pmreplroot = (OP*)gv_list[5];
    gvop_list[6].op_gv = gv_list[4];
    cop_list[5].cop_filegv = gv_list[0];
    cop_list[5].cop_stash = hv0;
    gv_list[6] = gv_fetchpv("main::i", TRUE, SVt_PV);
    SvFLAGS(gv_list[6]) = 0x600d;
    GvFLAGS(gv_list[6]) = 0x2;
    GvLINE(gv_list[6]) = 10;
    SvREFCNT(gv_list[6]) += 31;
    GvSV(gv_list[6]) = &sv_list[28];
    GvFILEGV(gv_list[6]) = gv_list[0];
    gvop_list[7].op_gv = gv_list[6];
    cop_list[6].cop_filegv = gv_list[0];
    cop_list[6].cop_stash = hv0;
    gvop_list[8].op_gv = gv_list[6];
    gvop_list[9].op_gv = gv_list[3];
    cop_list[7].cop_filegv = gv_list[0];
    cop_list[7].cop_stash = hv0;
    gv_list[7] = gv_fetchpv("main::STAT", TRUE, SVt_PV);
    SvFLAGS(gv_list[7]) = 0x600d;
    GvFLAGS(gv_list[7]) = 0x2;
    GvLINE(gv_list[7]) = 12;
    SvREFCNT(gv_list[7]) += 3;
    GvSV(gv_list[7]) = &sv_list[30];
    GvFILEGV(gv_list[7]) = gv_list[0];
    gvop_list[10].op_gv = gv_list[7];
    cop_list[8].cop_filegv = gv_list[0];
    cop_list[8].cop_stash = hv0;
    xpvbm_list[0].xpv_pv = savepvn("#\000\000\000\000\000\000\000\377\001\2570\000\000\000\000\000\000\000\000\000\000\000\000\377\001\257P\000\000\000\000PING\000\000\000\000\377\001\257 \000\000\000\000\000\000\000\000\000\000\000\000\377\001\257`\000\000\000\000PING\000\000\000\000\377\001\257p\000\000\000\000PING\000\000\000\000\377\001\257\000\000\000\000\000\000\000\000\000\000\000\000\000\377\001\257\220\000\000\000\000\n\000ST\000\000\000\000\377\001\257\260\000\000\000\000\\#\000T\000\000\000\000\377\001p@\000\000\000\000\n\000ST\000M\000\000\377\001\257\300\000\000\000\000#\000\000\000\000\000\000\000\377\001\257\320\000\000\000\000\000\000\000\000\000\000\000\000\377\001\257\360\000\000\000\000DEFUNCT\000\377\001\257\300\000\000\000\000\000\000\000\000\000\000\000\000\377\001\000\000\000\000\000\000DEFUNCT\000\377\003\260@\000\000\000\000\000\031\260H\000\000\000\000\000\004\210,\000\000\000\213\000\000", 258);
    xpvbm_list[0].xpv_cur = 1;
    pmop_list[1].op_pmregexp = pregcomp(re1, re1 + 2, &pmop_list[1]);
    gvop_list[11].op_gv = gv_list[2];
    gvop_list[12].op_gv = gv_list[6];
    cop_list[9].cop_filegv = gv_list[0];
    cop_list[9].cop_stash = hv0;
    gvop_list[13].op_gv = gv_list[2];
    gvop_list[14].op_gv = gv_list[6];
    cop_list[10].cop_filegv = gv_list[0];
    cop_list[10].cop_stash = hv0;
    xpv_list[2].xpv_pv = savepvn("/usr/sbin/ping ", 15);
    gvop_list[15].op_gv = gv_list[2];
    gvop_list[16].op_gv = gv_list[6];
    gv_list[8] = gv_fetchpv("main::PING", TRUE, SVt_PV);
    SvFLAGS(gv_list[8]) = 0x600d;
    GvFLAGS(gv_list[8]) = 0x2;
    GvLINE(gv_list[8]) = 20;
    SvREFCNT(gv_list[8]) += 4;
    GvSV(gv_list[8]) = &sv_list[33];
    GvFILEGV(gv_list[8]) = gv_list[0];
    gvop_list[17].op_gv = gv_list[8];
    cop_list[11].cop_filegv = gv_list[0];
    cop_list[11].cop_stash = hv0;
    sv_magic((SV*)&sv_list[34], (SV*)0, 'B', 0, 0);
    xpvbm_list[1].xpv_pv = savepvn("no answer\000\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\006\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\005\t\t\t\001\t\t\t\t\t\t\t\t\004\a\t\t\000\003\t\t\t\002\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t", 266);
    xpvbm_list[1].xpv_cur = 9;
    pmop_list[2].op_pmregexp = pregcomp(re2, re2 + 9, &pmop_list[2]);
    gvop_list[18].op_gv = gv_list[8];
    cop_list[12].cop_filegv = gv_list[0];
    cop_list[12].cop_stash = hv0;
    xpv_list[3].xpv_pv = savepvn("NO ANSWER FROM ", 15);
    gvop_list[19].op_gv = gv_list[2];
    gvop_list[20].op_gv = gv_list[6];
    xpv_list[4].xpv_pv = savepvn("\n", 1);
    cop_list[13].cop_filegv = gv_list[0];
    cop_list[13].cop_stash = hv0;
    gvop_list[21].op_gv = gv_list[7];
    gvop_list[22].op_gv = gv_list[8];
    gvop_list[23].op_gv = gv_list[6];
    cop_list[14].cop_filegv = gv_list[0];
    cop_list[14].cop_stash = hv0;
    gvop_list[24].op_gv = gv_list[6];
    cop_list[15].cop_filegv = gv_list[0];
    cop_list[15].cop_stash = hv0;
    gvop_list[25].op_gv = gv_list[6];
    gvop_list[26].op_gv = gv_list[3];
    cop_list[16].cop_filegv = gv_list[0];
    cop_list[16].cop_stash = hv0;
    xpvbm_list[2].xpv_pv = savepvn("#\000\000\000\000\000\000\000\377\001\257\320\000\000\000\000\000\000\000\000\000\000\000\000\377\001\257\360\000\000\000\000DEFUNCT\000\377\001\257\300\000\000\000\000\000\000\000\000\000\000\000\000\377\001\000\000\000\000\000\000DEFUNCT\000\377\003\260@\000\000\000\000\000\031\260H\000\000\000\000\000\004\210,\000\000\000\213\000\000\000\000\004\000\000\000\000\031\226(\000\031\247\b\000\000\000\003\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\377\003\260\200\000\000\000\000\000\031\263\b\000\000\000\000\000\004\316\234\000\000\000\002\000\244&\025F\003\000\000\000\031\260\b\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\377\003\260\300\000\000\000\000\000\031\263\b\000\000\000\000\000\004\214\224\000\000\000\000\000\235&\016\006\001\000\000\000\031\226H\000\031\226(\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000", 258);
    xpvbm_list[2].xpv_cur = 1;
    pmop_list[3].op_pmregexp = pregcomp(re3, re3 + 2, &pmop_list[3]);
    gvop_list[27].op_gv = gv_list[2];
    gvop_list[28].op_gv = gv_list[6];
    cop_list[17].cop_filegv = gv_list[0];
    cop_list[17].cop_stash = hv0;
    xpv_list[5].xpv_pv = savepvn("rsh -l oper ", 12);
    gvop_list[29].op_gv = gv_list[2];
    gvop_list[30].op_gv = gv_list[6];
    xpv_list[6].xpv_pv = savepvn(" ps -eaf | grep defunct", 23);
    gv_list[9] = gv_fetchpv("main::DEFUNCT", TRUE, SVt_PV);
    SvFLAGS(gv_list[9]) = 0x600d;
    GvFLAGS(gv_list[9]) = 0x2;
    GvLINE(gv_list[9]) = 41;
    SvREFCNT(gv_list[9]) += 4;
    GvSV(gv_list[9]) = &sv_list[42];
    GvAV(gv_list[9]) = (AV*)&sv_list[43];
    GvFILEGV(gv_list[9]) = gv_list[0];
    gvop_list[31].op_gv = gv_list[9];
    cop_list[18].cop_filegv = gv_list[0];
    cop_list[18].cop_stash = hv0;
    gvop_list[32].op_gv = gv_list[9];
    gv_list[10] = gv_fetchpv("main::DEFNUM", TRUE, SVt_PV);
    SvFLAGS(gv_list[10]) = 0x600d;
    GvFLAGS(gv_list[10]) = 0x2;
    GvLINE(gv_list[10]) = 42;
    SvREFCNT(gv_list[10]) += 3;
    GvSV(gv_list[10]) = &sv_list[44];
    GvFILEGV(gv_list[10]) = gv_list[0];
    gvop_list[33].op_gv = gv_list[10];
    cop_list[19].cop_filegv = gv_list[0];
    cop_list[19].cop_stash = hv0;
    gvop_list[34].op_gv = gv_list[10];
    gvop_list[35].op_gv = gv_list[2];
    gvop_list[36].op_gv = gv_list[6];
    xpv_list[7].xpv_pv = savepvn("\n", 1);
    gv_list[11] = gv_fetchpv("main::\"", TRUE, SVt_PV);
    SvFLAGS(gv_list[11]) = 0x600d;
    GvFLAGS(gv_list[11]) = 0x2;
    GvLINE(gv_list[11]) = 0;
    SvREFCNT(gv_list[11]) += 11;
    gvop_list[37].op_gv = gv_list[11];
    gvop_list[38].op_gv = gv_list[9];
    gvop_list[39].op_gv = gv_list[6];
    cop_list[20].cop_filegv = gv_list[0];
    cop_list[20].cop_stash = hv0;
    gvop_list[40].op_gv = gv_list[6];
    cop_list[21].cop_filegv = gv_list[0];
    cop_list[21].cop_stash = hv0;
    gvop_list[41].op_gv = gv_list[6];
    gvop_list[42].op_gv = gv_list[3];
    cop_list[22].cop_filegv = gv_list[0];
    cop_list[22].cop_stash = hv0;
    xpvbm_list[3].xpv_pv = savepvn("#\000\000\000\000\000\000\000\377\001p\200\000\000\000\000\000\000\000\000\000\000\000\000\377\001p\240\000\000\000\000HOSTMSG\000\377\001pp\000\000\000\000\000\000\000\000\000\000\000\000\377\001p\260\000\000\000\000HOSTMSG\000\377\001p\300\000\000\000\000HOSTMSG\000\377\001p\320\000\000\000\000c\000\000\000\000\000\000\000\377\001p\340\000\000\000\000c\000\000\000\000\000\000\000\377\001p\360\000\000\000\000c\000\000\000\000\000\000\000\377\001q\000\000\000\000\000\000\000\000\000\000\000\000\000\377\001q\020\000\000\000\000\n\000STMSG\000\377\001q0\000\000\000\000\\#\000T\000\000\000\000\377\001qP\000\000\000\000 df -k\000\000\377\001q@\000\000\000\000#\000\000\000\000\000\000\000\377\001qP\000\000\000\000\000\000\000\000\000\000\000\000\377\001r\020\000\000\000\000\\s+\000T\000\000\000\377\001q@\000\000\000\000\000\000", 258);
    xpvbm_list[3].xpv_cur = 1;
    pmop_list[4].op_pmregexp = pregcomp(re4, re4 + 2, &pmop_list[4]);
    gvop_list[43].op_gv = gv_list[6];
    gvop_list[44].op_gv = gv_list[2];
    cop_list[23].cop_filegv = gv_list[0];
    cop_list[23].cop_stash = hv0;
    xpv_list[8].xpv_pv = savepvn("rsh -l oper ", 12);
    gvop_list[45].op_gv = gv_list[11];
    gvop_list[46].op_gv = gv_list[6];
    gvop_list[47].op_gv = gv_list[2];
    xpv_list[9].xpv_pv = savepvn(" tail -3 /var/adm/messages", 26);
    gv_list[12] = gv_fetchpv("main::HOSTMSG", TRUE, SVt_PV);
    SvFLAGS(gv_list[12]) = 0x600d;
    GvFLAGS(gv_list[12]) = 0x2;
    GvLINE(gv_list[12]) = 57;
    SvREFCNT(gv_list[12]) += 4;
    GvSV(gv_list[12]) = &sv_list[51];
    GvAV(gv_list[12]) = (AV*)&sv_list[52];
    GvFILEGV(gv_list[12]) = gv_list[0];
    gvop_list[48].op_gv = gv_list[12];
    cop_list[24].cop_filegv = gv_list[0];
    cop_list[24].cop_stash = hv0;
    gv_list[13] = gv_fetchpv("main::c", TRUE, SVt_PV);
    SvFLAGS(gv_list[13]) = 0x600d;
    GvFLAGS(gv_list[13]) = 0x2;
    GvLINE(gv_list[13]) = 58;
    SvREFCNT(gv_list[13]) += 6;
    GvSV(gv_list[13]) = &sv_list[54];
    GvFILEGV(gv_list[13]) = gv_list[0];
    gvop_list[49].op_gv = gv_list[13];
    cop_list[25].cop_filegv = gv_list[0];
    cop_list[25].cop_stash = hv0;
    gvop_list[50].op_gv = gv_list[13];
    cop_list[26].cop_filegv = gv_list[0];
    cop_list[26].cop_stash = hv0;
    pmop_list[5].op_pmregexp = pregcomp(re5, re5 + 65, &pmop_list[5]);
    gvop_list[51].op_gv = gv_list[12];
    gvop_list[52].op_gv = gv_list[13];
    gvop_list[53].op_gv = gv_list[12];
    gvop_list[54].op_gv = gv_list[13];
    xpv_list[10].xpv_pv = savepvn("\n", 1);
    gvop_list[55].op_gv = gv_list[13];
    gvop_list[56].op_gv = gv_list[6];
    cop_list[27].cop_filegv = gv_list[0];
    cop_list[27].cop_stash = hv0;
    gvop_list[57].op_gv = gv_list[6];
    cop_list[28].cop_filegv = gv_list[0];
    cop_list[28].cop_stash = hv0;
    gvop_list[58].op_gv = gv_list[6];
    gvop_list[59].op_gv = gv_list[3];
    cop_list[29].cop_filegv = gv_list[0];
    cop_list[29].cop_stash = hv0;
    xpvbm_list[4].xpv_pv = savepvn("#\000\000\000\000\000\000\000\377\001qP\000\000\000\000\000\000\000\000\000\000\000\000\377\001r\020\000\000\000\000\\s+\000T\000\000\000\377\001q@\000\000\000\000\000\000\000\000\000\000\000\000\377\001q\200\000\000\000\000COUNT\000\000\000\377\001q\220\000\000\000\000COUNT\000\000\000\377\001q\240\000\000\000\000COUNT\000\000\000\377\001q\260\000\000\000\000a\000\000\000\000\000\000\000\377\001q\300\000\000\000\000a\000\000\000\000\000\000\000\377\001q\320\000\000\000\000a\000\000\000\000\000\000\000\377\001q\340\000\000\000\000TMP\000\000\000\000\000\377\001q\360\000\000\000\000TMP\000\000\000\000\000\377\001r\000\000\000\000\000TMP\000\000\000\000\000\377\001rp\000\000\000\000\\s+\000\000\000\000\000\377\001r \000\000\000\000\000\000\000\000\000\000\000\000\377\001r0\000\000\000\000\000\000\000\000\000\000\000\000\377\001r@\000\000\000\000TM", 258);
    xpvbm_list[4].xpv_cur = 1;
    pmop_list[6].op_pmregexp = pregcomp(re6, re6 + 2, &pmop_list[6]);
    gvop_list[60].op_gv = gv_list[6];
    gvop_list[61].op_gv = gv_list[2];
    cop_list[30].cop_filegv = gv_list[0];
    cop_list[30].cop_stash = hv0;
    xpv_list[11].xpv_pv = savepvn("rsh -l oper ", 12);
    gvop_list[62].op_gv = gv_list[11];
    gvop_list[63].op_gv = gv_list[6];
    gvop_list[64].op_gv = gv_list[2];
    xpv_list[12].xpv_pv = savepvn(" df -k", 6);
    gv_list[14] = gv_fetchpv("main::DISKSPACE", TRUE, SVt_PV);
    SvFLAGS(gv_list[14]) = 0x600d;
    GvFLAGS(gv_list[14]) = 0x2;
    GvLINE(gv_list[14]) = 75;
    SvREFCNT(gv_list[14]) += 4;
    GvSV(gv_list[14]) = &sv_list[61];
    GvAV(gv_list[14]) = (AV*)&sv_list[62];
    GvFILEGV(gv_list[14]) = gv_list[0];
    gvop_list[65].op_gv = gv_list[14];
    cop_list[31].cop_filegv = gv_list[0];
    cop_list[31].cop_stash = hv0;
    gvop_list[66].op_gv = gv_list[14];
    gv_list[15] = gv_fetchpv("main::COUNT", TRUE, SVt_PV);
    SvFLAGS(gv_list[15]) = 0x600d;
    GvFLAGS(gv_list[15]) = 0x2;
    GvLINE(gv_list[15]) = 76;
    SvREFCNT(gv_list[15]) += 3;
    GvSV(gv_list[15]) = &sv_list[63];
    GvFILEGV(gv_list[15]) = gv_list[0];
    gvop_list[67].op_gv = gv_list[15];
    cop_list[32].cop_filegv = gv_list[0];
    cop_list[32].cop_stash = hv0;
    gv_list[16] = gv_fetchpv("main::a", TRUE, SVt_PV);
    SvFLAGS(gv_list[16]) = 0x600d;
    GvFLAGS(gv_list[16]) = 0x2;
    GvLINE(gv_list[16]) = 77;
    SvREFCNT(gv_list[16]) += 5;
    GvSV(gv_list[16]) = &sv_list[65];
    GvFILEGV(gv_list[16]) = gv_list[0];
    gvop_list[68].op_gv = gv_list[16];
    cop_list[33].cop_filegv = gv_list[0];
    cop_list[33].cop_stash = hv0;
    gvop_list[69].op_gv = gv_list[16];
    gvop_list[70].op_gv = gv_list[15];
    cop_list[34].cop_filegv = gv_list[0];
    cop_list[34].cop_stash = hv0;
    gv_list[17] = gv_fetchpv("main::TMP", TRUE, SVt_PV);
    SvFLAGS(gv_list[17]) = 0x600d;
    GvFLAGS(gv_list[17]) = 0x2;
    GvLINE(gv_list[17]) = 79;
    SvREFCNT(gv_list[17]) += 2;
    GvSV(gv_list[17]) = &sv_list[66];
    GvAV(gv_list[17]) = (AV*)&sv_list[67];
    GvFILEGV(gv_list[17]) = gv_list[0];
    pmop_list[7].op_pmregexp = pregcomp(re7, re7 + 3, &pmop_list[7]);
    pmop_list[7].op_pmreplroot = (OP*)gv_list[17];
    gvop_list[71].op_gv = gv_list[14];
    gvop_list[72].op_gv = gv_list[16];
    cop_list[35].cop_filegv = gv_list[0];
    cop_list[35].cop_stash = hv0;
    gv_list[18] = gv_fetchpv("main::TMP2", TRUE, SVt_PV);
    SvFLAGS(gv_list[18]) = 0x600d;
    GvFLAGS(gv_list[18]) = 0x2;
    GvLINE(gv_list[18]) = 80;
    SvREFCNT(gv_list[18]) += 4;
    GvSV(gv_list[18]) = &sv_list[69];
    GvAV(gv_list[18]) = (AV*)&sv_list[70];
    GvFILEGV(gv_list[18]) = gv_list[0];
    pmop_list[8].op_pmregexp = pregcomp(re8, re8 + 3, &pmop_list[8]);
    pmop_list[8].op_pmreplroot = (OP*)gv_list[18];
    gvop_list[73].op_gv = gv_list[17];
    cop_list[36].cop_filegv = gv_list[0];
    cop_list[36].cop_stash = hv0;
    gvop_list[74].op_gv = gv_list[18];
    cop_list[37].cop_filegv = gv_list[0];
    cop_list[37].cop_stash = hv0;
    gvop_list[75].op_gv = gv_list[18];
    xpv_list[13].xpv_pv = savepvn("WARNING ", 8);
    gvop_list[76].op_gv = gv_list[11];
    gvop_list[77].op_gv = gv_list[6];
    gvop_list[78].op_gv = gv_list[2];
    xpv_list[14].xpv_pv = savepvn(" ", 1);
    gvop_list[79].op_gv = gv_list[11];
    gvop_list[80].op_gv = gv_list[18];
    xpv_list[15].xpv_pv = savepvn("\n", 1);
    gvop_list[81].op_gv = gv_list[16];
    gvop_list[82].op_gv = gv_list[6];
    cop_list[38].cop_filegv = gv_list[0];
    cop_list[38].cop_stash = hv0;
    gvop_list[83].op_gv = gv_list[6];
    cop_list[39].cop_filegv = gv_list[0];
    cop_list[39].cop_stash = hv0;
    gvop_list[84].op_gv = gv_list[6];
    gvop_list[85].op_gv = gv_list[3];
    cop_list[40].cop_filegv = gv_list[0];
    cop_list[40].cop_stash = hv0;
    xpvbm_list[5].xpv_pv = savepvn("#\000\000\000\000\000\000\000\377\001r\340\000\000\000\000\000\000\000\000\000\000\000\000\377\001s\020\000\000\000\000\\s+\000\000\000\000\000\377\001r\320\000\000\000\000\000\000\000\000\000\000\000\000\377\001s0\000\000\000\000\t \000T\000\000\000\000\377\001s \000\000\000\000\000\000\000\000\000\000\000\000\377\001s0\000\000\000\000\000\000\000\000\000\000\000\000\377\001s@\000\000\000\000\n\000\000\000\000\000\000\000\377\001sP\000\000\000\000REFCNT\000\000\377\001s`\000\000\000\000REFCNT\000\000\377\001sp\000\000\000\000REFCNT\000\000\377\001s\200\000\000\000\000REFCNT\000\000\377\001s\220\000\000\000\000REFCNT\000\000\377\001s\240\000\000\000\000REFCNT\000\000\377\001s\260\000\000\000\000REFCNT\000\000\377\001s\300\000\000\000\000REFCNT\000\000\377\001s\320\000\000\000\000RE", 258);
    xpvbm_list[5].xpv_cur = 1;
    pmop_list[9].op_pmregexp = pregcomp(re9, re9 + 2, &pmop_list[9]);
    gvop_list[86].op_gv = gv_list[2];
    gvop_list[87].op_gv = gv_list[6];
    cop_list[41].cop_filegv = gv_list[0];
    cop_list[41].cop_stash = hv0;
    xpv_list[16].xpv_pv = savepvn("rsh -l oper ", 12);
    gvop_list[88].op_gv = gv_list[2];
    gvop_list[89].op_gv = gv_list[6];
    xpv_list[17].xpv_pv = savepvn(" who -b", 7);
    gv_list[19] = gv_fetchpv("main::LASTBOOT", TRUE, SVt_PV);
    SvFLAGS(gv_list[19]) = 0x600d;
    GvFLAGS(gv_list[19]) = 0x2;
    GvLINE(gv_list[19]) = 97;
    SvREFCNT(gv_list[19]) += 3;
    GvSV(gv_list[19]) = &sv_list[80];
    GvFILEGV(gv_list[19]) = gv_list[0];
    gvop_list[90].op_gv = gv_list[19];
    cop_list[42].cop_filegv = gv_list[0];
    cop_list[42].cop_stash = hv0;
    gv_list[20] = gv_fetchpv("main::LASTBOOT2", TRUE, SVt_PV);
    SvFLAGS(gv_list[20]) = 0x600d;
    GvFLAGS(gv_list[20]) = 0x2;
    GvLINE(gv_list[20]) = 98;
    SvREFCNT(gv_list[20]) += 4;
    GvSV(gv_list[20]) = &sv_list[81];
    GvAV(gv_list[20]) = (AV*)&sv_list[82];
    GvFILEGV(gv_list[20]) = gv_list[0];
    pmop_list[10].op_pmregexp = pregcomp(re10, re10 + 3, &pmop_list[10]);
    pmop_list[10].op_pmreplroot = (OP*)gv_list[20];
    gvop_list[91].op_gv = gv_list[19];
    cop_list[43].cop_filegv = gv_list[0];
    cop_list[43].cop_stash = hv0;
    gvop_list[92].op_gv = gv_list[20];
    gvop_list[93].op_gv = gv_list[5];
    gvop_list[94].op_gv = gv_list[20];
    gvop_list[95].op_gv = gv_list[5];
    gvop_list[96].op_gv = gv_list[2];
    gvop_list[97].op_gv = gv_list[6];
    xpv_list[18].xpv_pv = savepvn("\t ", 2);
    gvop_list[98].op_gv = gv_list[11];
    gvop_list[99].op_gv = gv_list[20];
    xpv_list[19].xpv_pv = savepvn("\n", 1);
    gvop_list[100].op_gv = gv_list[6];
    cop_list[44].cop_filegv = gv_list[0];
    cop_list[44].cop_stash = hv0;
    gvop_list[101].op_gv = gv_list[1];
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
