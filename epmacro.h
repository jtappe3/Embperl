/*###################################################################################
#
#   Embperl - Copyright (c) 1997-1999 Gerald Richter / ECOS
#
#   You may distribute under the terms of either the GNU General Public
#   License or the Artistic License, as specified in the Perl README file.
#   For use with Apache httpd and mod_perl, see also Apache copyright.
#
#   THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR
#   IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
#   WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
#
###################################################################################*/

#define ADDINTMG(name)    \
    if (rc == 0)    \
        rc = AddMagic (pApp, EMBPERL_##name##_NAME, &EMBPERL2_mvtTab##name) ;

#define ADDOPTMG(name)    \
    if (rc == 0)    \
        rc = AddMagic (pApp, "Embperl::"#name, &EMBPERL2_mvtTab##name) ;


#define INTMG(name,var,used,sub) \
    \
int EMBPERL2_mgGet##name (pTHX_ SV * pSV, MAGIC * mg) \
\
    { \
    tReq       * r = CurrReq ; \
    tComponent * c = &r -> Component ; \
    tApp       * a = r -> pApp ; \
    sv_setiv (pSV, var) ; \
    if (c -> bReqRunning) \
	used++ ; \
    if ((c -> Config.bDebug & dbgTab) && c -> bReqRunning) \
        lprintf (a, "[%d]TAB:  get %s = %d, Used = %d\n", r -> pThread -> nPid, #name, var, used) ; \
    return 0 ; \
    } \
\
    int EMBPERL2_mgSet##name (pTHX_ SV * pSV, MAGIC * mg) \
\
    { \
    tReq       * r = CurrReq ; \
    tComponent * c = &r -> Component ; \
    tApp       * a = r -> pApp ; \
    var = SvIV (pSV) ; \
    if ((c -> Config.bDebug & dbgTab) && c -> bReqRunning) \
        lprintf (a, "[%d]TAB:  set %s = %d, Used = %d\n", r -> pThread -> nPid, #name, var, used) ; \
    sub ; \
    return 0 ; \
    } \
    \
    MGVTBL EMBPERL2_mvtTab##name = { EMBPERL2_mgGet##name, EMBPERL2_mgSet##name, NULL, NULL, NULL } ;

#define INTMGshort(name,var) \
    \
int EMBPERL2_mgGet##name (pTHX_ SV * pSV, MAGIC * mg) \
\
    { \
    sv_setiv (pSV, var) ; \
    return 0 ; \
    } \
\
    int EMBPERL2_mgSet##name (pTHX_ SV * pSV, MAGIC * mg) \
\
    { \
    var = SvIV (pSV) ; \
    return 0 ; \
    } \
    \
    MGVTBL EMBPERL2_mvtTab##name = { EMBPERL2_mgGet##name, EMBPERL2_mgSet##name, NULL, NULL, NULL } ;



#define INTMGcall(name,var,sub) \
    \
void EMBPERL2_mgGet##name (pTHX_ SV * pSV, MAGIC * mg) \
\
    { \
    sv_setiv (pSV, var) ; \
    sub ; \
    } \
\
    void EMBPERL2_mgSet##name (pTHX_ SV * pSV, MAGIC * mg) \
\
    { \
    var = SvIV (pSV) ; \
    sub ; \
    } \
    \
    MGVTBL EMBPERL2_mvtTab##name = { EMBPERL2_mgGet##name, EMBPERL2_mgSet##name, NULL, NULL, NULL } ;


#define OPTMGRD(name,var) \
    \
int EMBPERL2_mgGet##name (pTHX_ SV * pSV, MAGIC * mg) \
\
    { \
\
    sv_setiv (pSV, (var & name)?1:0) ; \
    return 0 ; \
    } \
\
int EMBPERL2_mgSet##name (pTHX_ SV * pSV, MAGIC * mg) \
\
    { \
    return 0 ; \
    } \
    \
    MGVTBL EMBPERL2_mvtTab##name = { EMBPERL2_mgGet##name, EMBPERL2_mgSet##name, NULL, NULL, NULL } ;


#define OPTMG(name,var) \
    \
int EMBPERL2_mgGet##name (pTHX_ SV * pSV, MAGIC * mg) \
\
    { \
\
    sv_setiv (pSV, (var & name)?1:0) ; \
    return 0 ; \
    } \
\
int EMBPERL2_mgSet##name (pTHX_ SV * pSV, MAGIC * mg) \
\
    { \
\
    if (SvIV (pSV)) \
        var |= name ; \
    else \
        var &= ~name ; \
    return 0 ; \
    } \
    \
    MGVTBL EMBPERL2_mvtTab##name = { EMBPERL2_mgGet##name, EMBPERL2_mgSet##name, NULL, NULL, NULL } ;




#ifdef EPDEBUGALL
#define EPENTRY(func) if (r -> bDebug & dbgFunc) { lprintf (r, "[%d]DBG:  %dms %s\n", r -> nPid, clock () * 1000 / CLOCKS_PER_SEC, #func) ; FlushLog (r) ; }
#define EPENTRY1N(func,arg1) if (r -> bDebug & dbgFunc) { lprintf (r, "[%d]DBG:  %dms %s %d\n", r -> nPid, clock () * 1000 / CLOCKS_PER_SEC, #func, arg1) ; FlushLog (r) ; }
#define EPENTRY1S(func,arg1) if (r -> bDebug & dbgFunc) { lprintf (r, "[%d]DBG:  %dms %s %s\n", r -> nPid, clock () * 1000 / CLOCKS_PER_SEC, #func, arg1) ; FlushLog (r) ; }
#else
#define EPENTRY(func)
#define EPENTRY1N(func,arg1)
#define EPENTRY1S(func,arg1)
#endif



#define AssignSVPtr(ppDst,pSrc) { if (*ppDst) SvREFCNT_dec (*ppDst) ; *ppDst = pSrc ; }

