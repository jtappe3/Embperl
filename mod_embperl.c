/*###################################################################################
#
#   Embperl - Copyright (c) 1997-2002 Gerald Richter / ecos gmbh   www.ecos.de
#
#   You may distribute under the terms of either the GNU General Public
#   License or the Artistic License, as specified in the Perl README file.
#   For use with Apache httpd and mod_perl, see also Apache copyright.
#
#   THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR
#   IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
#   WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
#
#   $Id: mod_embperl.c,v 1.1.2.3 2002/06/25 05:59:17 richter Exp $
#
###################################################################################*/


#include "ep.h"


#ifdef APACHE

#include <http_core.h>
#include "epdefault.c"

#if !defined(MOD_EMBPERL) && !defined(EMBPERL_SO)
#define MOD_EMBPERL
#define EMBPERL_SO
#endif


/* use getenv from runtime library and not from Perl */
#undef getenv
#undef getpid

/* define get thread id if not already done by Apache */
#ifndef gettid
#ifdef WIN32
#define gettid GetCurrentThreadId
#else
static int gettid()
    {
    return 0 ;
    }
#endif
#endif

/* debugging by default off, enable with httpd -D EMBPERL_APDEBUG */
static int bApDebug = 0 ;


/* --- declare config datastructure --- */

#define EPCFG_STR EPCFG
#define EPCFG_INT EPCFG
#define EPCFG_BOOL EPCFG
#define EPCFG_CHAR EPCFG

#define EPCFG_CV EPCFG_SAVE
#define EPCFG_SV EPCFG_SAVE
#define EPCFG_HV EPCFG_SAVE
#define EPCFG_REGEX EPCFG_SAVE
#define EPCFG_AV(STRUCT,TYPE,NAME,CFGNAME,SEPARATOR) EPCFG_SAVE(STRUCT,TYPE,NAME,CFGNAME)

#define EPCFG_APP    
#define EPCFG_REQ   
#define EPCFG_COMPONENT   


#define EPCFG(STRUCT,TYPE,NAME,CFGNAME)   int  set_##STRUCT##NAME:1 ;
#define EPCFG_SAVE(STRUCT,TYPE,NAME,CFGNAME)  \
     int  set_##STRUCT##NAME:1 ; \
     char *  save_##STRUCT##NAME ; 

struct tApacheDirConfig
    {
    tPerlInterpreter * pPerlTHX ;                  /* pointer to Perl interpreter */
    tAppConfig       AppConfig ;
    tReqConfig       ReqConfig ;
    tComponentConfig ComponentConfig ;
    int              bUseEnv ;
    /* flags if config directive is given in context */
#include "epcfg.h"
    }  ;



#ifdef MOD_EMBPERL


/* --- declare other function prototypes --- */

#ifdef APACHE2
static int embperl_ApacheInit (apr_pool_t *p, apr_pool_t *plog, apr_pool_t *ptemp, server_rec *s) ;
static apr_status_t embperl_ApacheInitCleanup (void * p) ;
#else
static void embperl_ApacheInitCleanup (void * p) ;
static void embperl_ApacheInit (server_rec *s, apr_pool_t *p) ;
#endif


static const char * embperl_Apache_Config_useenv (cmd_parms *cmd, /*tApacheDirConfig*/ void * pDirCfg, int arg) ;
static void *embperl_create_dir_config(apr_pool_t *p, char *d) ;
static void *embperl_create_server_config(apr_pool_t *p, server_rec *s) ;
static void *embperl_merge_dir_config (apr_pool_t *p, void *basev, void *addv) ;



/* --- declare config function prototypes --- */

#undef EPCFG_SAVE
#define EPCFG_SAVE EPCFG
#undef EPCFG 
#define EPCFG(STRUCT,TYPE,NAME,CFGNAME) \
    const char * embperl_Apache_Config_##STRUCT##NAME (cmd_parms *cmd, /*tApacheDirConfig*/ void * pDirCfg, const char *  arg) ;

#include "epcfg.h"

#ifndef AP_INIT_TAKE1
#define AP_INIT_TAKE1(name,func,foo,valid,comment) { name,func,foo,valid, TAKE1, comment }
#endif
#ifndef AP_INIT_FLAG
#define AP_INIT_FLAG(name,func,foo,valid,comment) { name,func,foo,valid, FLAG, comment }
#endif

#undef EPCFG
#undef EPCFG_SAVE
#define EPCFG_SAVE EPCFG
#define EPCFG(STRUCT,TYPE,NAME,CFGNAME) \
    AP_INIT_TAKE1( "EMBPERL_"#CFGNAME,   embperl_Apache_Config_##STRUCT##NAME,   NULL, RSRC_CONF | OR_OPTIONS,  "" ),


static const command_rec embperl_cmds[] =
{
#include "epcfg.h"
    
    AP_INIT_FLAG("EMBPERL_USEENV", embperl_Apache_Config_useenv, NULL, RSRC_CONF, "If set to 'on' Embperl will also scan the environment variable for configuration informations"),
    {NULL}
};



/* --- apache callback datastructures --- */

#ifdef APACHE2

static void embperl_register_hooks (apr_pool_t * p)
    {
    ap_hook_open_logs(embperl_ApacheInit, NULL, NULL, APR_HOOK_LAST) ; /* make sure we run after modperl init */
    }


module AP_MODULE_DECLARE_DATA embperl_module =
    {
    STANDARD20_MODULE_STUFF,
    embperl_create_dir_config,  /* dir config creater */
    embperl_merge_dir_config,   /* dir merger --- default is to override */
    embperl_create_server_config, /* server config */
    embperl_merge_dir_config,   /* merge server configs */
    embperl_cmds,               /* command table */
    embperl_register_hooks      /* register hooks */
    };



#else

/* static module MODULE_VAR_EXPORT embperl_module = { */
static module embperl_module = {
    STANDARD_MODULE_STUFF,
    embperl_ApacheInit,         /* initializer */
    embperl_create_dir_config,  /* dir config creater */
    embperl_merge_dir_config,   /* dir merger --- default is to override */
    embperl_create_server_config, /* server config */
    embperl_merge_dir_config,   /* merge server configs */
    embperl_cmds,               /* command table */
    NULL,                       /* handlers */
    NULL,                       /* filename translation */
    NULL,                       /* check_user_id */
    NULL,                       /* check auth */
    NULL,                       /* check access */
    NULL,                       /* type_checker */
    NULL,			/* fixups */
    NULL,                       /* logger */
    NULL,                       /* header parser */
    NULL,                       /* child_init */
    NULL,                       /* child_exit */
    NULL                        /* post read-request */
};


#endif


/*---------------------------------------------------------------------------
* embperl_ApacheAddModule
*/
/*!
*
* \_en									   
* Apache 1: Add module to dynamily loaded modules
* Apache 2: Just print a debug message. (mod_embperl.so must have been already loaded)
* \endif                                                                       
*
* \_de									   
* Apache 1: Module zu dynamisch geladenen Modulen hinzuf�gen
* Apache 2: Nur eine Debugmessage ausgeben. (mod_embperl.so mu� bereits geladen sein)
* \endif                                                                       
*                                                                          
* ------------------------------------------------------------------------ */

void embperl_ApacheAddModule (void)

    {
    apr_pool_t * pool ;

    bApDebug |= ap_exists_config_define("EMBPERL_APDEBUG") ;
   
#ifdef APACHE2
    if (bApDebug)
        ap_log_error (APLOG_MARK, APLOG_WARNING | APLOG_NOERRNO, APLOG_STATUSCODE NULL, "Embperl: Perl part initialization start [%d/%d]\n", getpid(), gettid()) ;
    return ;
    /*
    void * p = dlsym (0, "apr_global_hook_pool") ;

    if (!p)
        {
        ap_log_error (APLOG_MARK, APLOG_ERR, APLOG_STATUSCODE NULL, "Embperl: Cannot get address of apr_global_hook_pool [%d/%d]\n", getpid(), gettid()) ;
        return ;
        }

    pool = *((apr_pool_t * *)(p)) ;
    */
#else 


    if (!ap_find_linked_module("mod_embperl.c"))
        {
        if (bApDebug)
            ap_log_error (APLOG_MARK, APLOG_WARNING | APLOG_NOERRNO, APLOG_STATUSCODE NULL, "Embperl: About to add mod_embperl.c as dynamic module [%d/%d]\n", getpid(), gettid()) ;
        
        ap_add_module (&embperl_module) ;
        }
    else
        if (bApDebug)
            ap_log_error (APLOG_MARK, APLOG_WARNING | APLOG_NOERRNO, APLOG_STATUSCODE NULL, "Embperl: mod_embperl.c already added as dynamic module [%d/%d]\n", getpid(), gettid()) ;
#endif
    }


/*---------------------------------------------------------------------------
* embperl_ApacheInit
*/
/*!
*
* \_en									   
* Apache 1: Call initialization of Embperl, after configuration is read in
* Apache 2: Just add version component. (Initilalization is call from Perl)
* \endif                                                                       
*
* \_de									   
* Apache 1: Initzialisierung von Embperl ausf�hren, nachdem Konfiguration eingelesen ist
* Apache 2: Nur Versionsnummer dem Apache hinzuf�gen. (Initialisierung von von Perl aus aufgerufen)
* \endif                                                                       
*                                                                          
* ------------------------------------------------------------------------ */



#ifdef APACHE2
static int embperl_ApacheInit (apr_pool_t *p, apr_pool_t *plog, apr_pool_t *ptemp, server_rec *s)
#else
static void embperl_ApacheInit (server_rec *s, apr_pool_t *p)
#endif

    {
    int    rc ;
    apr_pool_t * subpool ;
    dTHX ;

#ifdef APACHE2
    apr_pool_sub_make(&subpool, p, NULL);
#else
    subpool = ap_make_sub_pool(p);
#endif

    bApDebug |= ap_exists_config_define("EMBPERL_APDEBUG") ;
    
    if (bApDebug)
        ap_log_error (APLOG_MARK, APLOG_WARNING | APLOG_NOERRNO, APLOG_STATUSCODE NULL, "Embperl: ApacheInit [%d/%d]\n", getpid(), gettid()) ;

#ifdef APACHE2
    ap_add_version_component (p, "Embperl/"VERSION) ;
    return APR_SUCCESS ;
#else
    ap_register_cleanup(subpool, NULL, embperl_ApacheInitCleanup, embperl_ApacheInitCleanup);
    ap_add_version_component ("Embperl/"VERSION) ;

    if ((rc = embperl_Init (aTHX_ NULL, NULL, s)) != ok)
        {
        ap_log_error (APLOG_MARK, APLOG_ERR | APLOG_NOERRNO, APLOG_STATUSCODE NULL, "Initialization of Embperl failed (#%d)\n", rc) ;
        }

#endif
    }


/*---------------------------------------------------------------------------
* embperl_ApacheInitCleanup
*/
/*!
*
* \_en									   
* Apache 1: Make sure Embperl is unloaded before mod_perl is unloaded
* Apache 2: not used
* \endif                                                                       
*
* \_de									   
* Apache 1: Sicherstellen, das Embperl vor mod_perl aus dem Speicher entladen wird
* Apache 2: Nich benutzt
* \endif                                                                       
*                                                                          
* ------------------------------------------------------------------------ */



#ifdef APACHE2
static apr_status_t embperl_ApacheInitCleanup (void * p)
#else
static void embperl_ApacheInitCleanup (void * p)
#endif

    {
    module * m ;
    /* make sure embperl module is removed before mod_perl in case mod_perl is loaded dynamicly*/
    if (m = ap_find_linked_module("mod_perl.c"))
        {
        if (m -> dynamic_load_handle)
            {
            if (bApDebug)
                ap_log_error (APLOG_MARK, APLOG_WARNING | APLOG_NOERRNO, APLOG_STATUSCODE NULL, "Embperl: ApacheInitCleanup: mod_perl.c dynamicly loaded -> remove mod_embperl.c [%d/%d]\n", getpid(), gettid()) ;
            ap_remove_module (&embperl_module) ; 
            }
        else
            {
            if (bApDebug)
                ap_log_error (APLOG_MARK, APLOG_WARNING | APLOG_NOERRNO, APLOG_STATUSCODE NULL, "Embperl: ApacheInitCleanup: mod_perl.c not dynamic loaded [%d/%d]\n", getpid(), gettid()) ;
            }
        }
    else
        {
        if (bApDebug)
            ap_log_error (APLOG_MARK, APLOG_WARNING | APLOG_NOERRNO, APLOG_STATUSCODE NULL, "Embperl: ApacheInitCleanup: mod_perl.c not found [%d/%d]\n", getpid(), gettid()) ;
        }

#ifdef APACHE2
    return OK ;
#endif
    }



/*---------------------------------------------------------------------------
* embperl_GetApacheConfig
*/

int embperl_GetApacheConfig (/*in*/ tThreadData * pThread,
                            /*in*/  request_rec * r,
                            /*in*/  server_rec * s,
                            /*out*/ tApacheDirConfig * * ppConfig)

    {
    *ppConfig = NULL ;

    if (embperl_module.module_index >= 0)
        {
        if(r && r->per_dir_config)
            {
            *ppConfig = (tApacheDirConfig *) ap_get_module_config(r->per_dir_config, &embperl_module);
            if (bApDebug)
                ap_log_error (APLOG_MARK, APLOG_WARNING | APLOG_NOERRNO, APLOG_STATUSCODE NULL, "Embperl: GetApacheConfig for dir\n") ;
            }
        else if(s && s->lookup_defaults) /*s->module_config)*/
            {
            *ppConfig = (tApacheDirConfig *) ap_get_module_config(s->lookup_defaults /*s->module_config*/, &embperl_module);
            if (bApDebug)
                ap_log_error (APLOG_MARK, APLOG_WARNING | APLOG_NOERRNO, APLOG_STATUSCODE NULL, "Embperl: GetApacheConfig for server\n") ;
            }
        else if (bApDebug)
            ap_log_error (APLOG_MARK, APLOG_WARNING | APLOG_NOERRNO, APLOG_STATUSCODE NULL, "Embperl: GetApacheConfig -> no config available for %s\n",r && r->per_dir_config?"dir":"server" ) ;
        }
    else
        if (bApDebug)
            ap_log_error (APLOG_MARK, APLOG_WARNING | APLOG_NOERRNO, APLOG_STATUSCODE NULL, "Embperl: GetApacheConfig -> no config available for %s; mod_embperl not loaded?\n",r && r->per_dir_config?"dir":"server" ) ;

    return ok ;
    }

/*---------------------------------------------------------------------------
* embperl_create_dir_config
*/

static void *embperl_create_dir_config(apr_pool_t * p, char *d)
    {
    tApacheDirConfig *cfg = (tApacheDirConfig *) ap_pcalloc(p, sizeof(tApacheDirConfig));

    embperl_DefaultReqConfig (&cfg -> ReqConfig) ;
    embperl_DefaultAppConfig (&cfg -> AppConfig) ;
    embperl_DefaultComponentConfig (&cfg -> ComponentConfig) ;
    cfg -> bUseEnv = -1 ; 

    if (bApDebug)
        ap_log_error (APLOG_MARK, APLOG_WARNING | APLOG_NOERRNO, APLOG_STATUSCODE NULL, "Embperl: create_dir_config [%d/%d]\n", getpid(), gettid()) ;

    return cfg;
    }


/*---------------------------------------------------------------------------
* embperl_create_server_config
*/

static void *embperl_create_server_config(apr_pool_t * p, server_rec *s)
    {
    tApacheDirConfig *cfg = (tApacheDirConfig *) ap_pcalloc(p, sizeof(tApacheDirConfig));

    bApDebug |= ap_exists_config_define("EMBPERL_APDEBUG") ;

    embperl_DefaultReqConfig (&cfg -> ReqConfig) ;
    embperl_DefaultAppConfig (&cfg -> AppConfig) ;
    embperl_DefaultComponentConfig (&cfg -> ComponentConfig) ;
    cfg -> bUseEnv = -1 ; 

    if (bApDebug)
        ap_log_error (APLOG_MARK, APLOG_WARNING | APLOG_NOERRNO, APLOG_STATUSCODE NULL, "Embperl: create_server_config [%d/%d]\n", getpid(), gettid()) ;


    return cfg;
    }


/* --- functions for merging configurations --- */

#define EPCFG_APP    
#define EPCFG_REQ   
#define EPCFG_COMPONENT   

#undef EPCFG_STR
#undef EPCFG_INT
#undef EPCFG_BOOL
#undef EPCFG_CHAR
#undef EPCFG_CV
#undef EPCFG_SV
#undef EPCFG_HV
#undef EPCFG_AV
#undef EPCFG_REGEX

#define EPCFG_INT EPCFG
#define EPCFG_BOOL EPCFG
#define EPCFG_CHAR EPCFG

#define EPCFG_CV EPCFG_SAVE
#define EPCFG_SV EPCFG_SAVE
#define EPCFG_HV EPCFG_SAVE
#define EPCFG_REGEX EPCFG_SAVE
#define EPCFG_AV(STRUCT,TYPE,NAME,CFGNAME,SEPARATOR) EPCFG_SAVE(STRUCT,TYPE,NAME,CFGNAME)

#undef EPCFG
#define EPCFG(STRUCT,TYPE,NAME,CFGNAME)  \
    if (add -> set_##STRUCT##NAME) \
        { \
        mrg -> set_##STRUCT##NAME = 1 ; \
        mrg -> STRUCT.NAME = add -> STRUCT.NAME ; \
        if (bApDebug) \
            ap_log_error (APLOG_MARK, APLOG_WARNING | APLOG_NOERRNO, APLOG_STATUSCODE NULL, "Embperl: Merge "#CFGNAME" (type="#TYPE") => %d\n", mrg -> STRUCT.NAME) ; \
        } \
    else \
        {  \
        if (bApDebug && mrg -> set_##STRUCT##NAME) \
            ap_log_error (APLOG_MARK, APLOG_WARNING | APLOG_NOERRNO, APLOG_STATUSCODE NULL, "Embperl: Merge "#CFGNAME" (type="#TYPE") stays %d\n", mrg -> STRUCT.NAME) ; \
        } 

#define EPCFG_STR(STRUCT,TYPE,NAME,CFGNAME)  \
    if (add -> set_##STRUCT##NAME) \
        { \
        mrg -> set_##STRUCT##NAME = 1 ; \
        mrg -> STRUCT.NAME = add -> STRUCT.NAME ; \
        if (bApDebug) \
            ap_log_error (APLOG_MARK, APLOG_WARNING | APLOG_NOERRNO, APLOG_STATUSCODE NULL, "Embperl: Merge "#CFGNAME" (type="#TYPE") => %s\n", mrg -> STRUCT.NAME?mrg -> STRUCT.NAME:"<null>") ; \
        } \
    else \
        {  \
        if (bApDebug && mrg -> set_##STRUCT##NAME) \
            ap_log_error (APLOG_MARK, APLOG_WARNING | APLOG_NOERRNO, APLOG_STATUSCODE NULL, "Embperl: Merge "#CFGNAME" (type="#TYPE") stays %s\n", mrg -> STRUCT.NAME?mrg -> STRUCT.NAME:"<null>") ; \
        } 

#undef EPCFG_SAVE
#define EPCFG_SAVE(STRUCT,TYPE,NAME,CFGNAME)  \
    if (add -> set_##STRUCT##NAME) \
        { \
        mrg -> set_##STRUCT##NAME = 1 ; \
        mrg -> STRUCT.NAME = add -> STRUCT.NAME ; \
        mrg -> save_##STRUCT##NAME = add -> save_##STRUCT##NAME ; \
        if (bApDebug) \
            ap_log_error (APLOG_MARK, APLOG_WARNING | APLOG_NOERRNO, APLOG_STATUSCODE NULL, "Embperl: Merge "#CFGNAME" (type="#TYPE") => %s\n", mrg -> save_##STRUCT##NAME?mrg -> save_##STRUCT##NAME:"<null>") ; \
        } \
    else \
        {  \
        if (bApDebug && mrg -> set_##STRUCT##NAME) \
        ap_log_error (APLOG_MARK, APLOG_WARNING | APLOG_NOERRNO, APLOG_STATUSCODE NULL, "Embperl: Merge "#CFGNAME" (type="#TYPE") stays %s\n", mrg -> save_##STRUCT##NAME?mrg -> save_##STRUCT##NAME:"<null>") ; \
        } 


/*---------------------------------------------------------------------------
* embperl_merge_dir_config
*/

static void *embperl_merge_dir_config (apr_pool_t *p, void *basev, void *addv)
    {
    if (!basev)
        return addv ;
    
        {
        tApacheDirConfig *mrg = (tApacheDirConfig *)ap_palloc (p, sizeof(tApacheDirConfig));
        tApacheDirConfig *base = (tApacheDirConfig *)basev;
        tApacheDirConfig *add = (tApacheDirConfig *)addv;

        memcpy (mrg, base, sizeof (*mrg)) ;

        if (bApDebug)
            ap_log_error (APLOG_MARK, APLOG_WARNING | APLOG_NOERRNO, APLOG_STATUSCODE NULL, "Embperl: merge_dir/server_config\n") ;


#include "epcfg.h" 

        if (add -> bUseEnv >= 0)
            mrg -> bUseEnv = add -> bUseEnv ;

        return mrg ;
        }
    }

/*---------------------------------------------------------------------------
* embperl_Apache_Config_useenv
*/


static const char * embperl_Apache_Config_useenv (cmd_parms *cmd, /*tApacheDirConfig*/ void * pDirCfg, int arg)
    { 
    ((tApacheDirConfig *)pDirCfg) -> bUseEnv = arg ; 
    if (bApDebug)
        ap_log_error (APLOG_MARK, APLOG_WARNING | APLOG_NOERRNO, APLOG_STATUSCODE NULL, "Embperl: Set UseEnv = %d\n", arg) ;

    return NULL; 
    } 




/* --- functions for apache config cmds --- */


#undef EPCFG
#undef EPCFG_INT
#define EPCFG_INT(STRUCT,TYPE,NAME,CFGNAME) \
const char * embperl_Apache_Config_##STRUCT##NAME (cmd_parms *cmd, /* tApacheDirConfig */ void * pDirCfg, const char * arg) \
    { \
    ((tApacheDirConfig *)pDirCfg) -> STRUCT.NAME = (TYPE)strtol(arg, NULL, 0) ; \
    ((tApacheDirConfig *)pDirCfg) -> set_##STRUCT##NAME = 1 ; \
    if (bApDebug) \
        ap_log_error (APLOG_MARK, APLOG_WARNING | APLOG_NOERRNO, APLOG_STATUSCODE NULL, "Embperl: Set "#CFGNAME" (type="#TYPE";INT) = %s\n", arg) ; \
    return NULL; \
    } 

#undef EPCFG_BOOL
#define EPCFG_BOOL(STRUCT,TYPE,NAME,CFGNAME) \
const char * embperl_Apache_Config_##STRUCT##NAME (cmd_parms *cmd, /* tApacheDirConfig */ void * pDirCfg, const char * arg) \
    { \
    ((tApacheDirConfig *)pDirCfg) -> STRUCT.NAME = (TYPE)arg ; \
    ((tApacheDirConfig *)pDirCfg) -> set_##STRUCT##NAME = 1 ; \
    if (bApDebug) \
        ap_log_error (APLOG_MARK, APLOG_WARNING | APLOG_NOERRNO, APLOG_STATUSCODE NULL, "Embperl: Set "#CFGNAME" (type="#TYPE";BOOL) = %s\n", arg) ; \
    return NULL; \
    } 


#undef EPCFG_STR
#define EPCFG_STR(STRUCT,TYPE,NAME,CFGNAME) \
const char * embperl_Apache_Config_##STRUCT##NAME (cmd_parms *cmd, /* tApacheDirConfig */ void * pDirCfg, const char* arg) \
    { \
    apr_pool_t * p = cmd -> pool ;    \
    ((tApacheDirConfig *)pDirCfg) -> STRUCT.NAME = ap_pstrdup(p, arg) ; \
    ((tApacheDirConfig *)pDirCfg) -> set_##STRUCT##NAME = 1 ; \
    if (bApDebug) \
        ap_log_error (APLOG_MARK, APLOG_WARNING | APLOG_NOERRNO, APLOG_STATUSCODE NULL, "Embperl: Set "#CFGNAME" (type="#TYPE";STR) = %s\n", arg) ; \
    return NULL; \
    } 

#undef EPCFG_CHAR
#define EPCFG_CHAR(STRUCT,TYPE,NAME,CFGNAME) \
const char * embperl_Apache_Config_##STRUCT##NAME (cmd_parms *cmd, /* tApacheDirConfig */ void * pDirCfg, const char * arg) \
    { \
    ((tApacheDirConfig *)pDirCfg) -> STRUCT.NAME = (TYPE)arg[0] ; \
    ((tApacheDirConfig *)pDirCfg) -> set_##STRUCT##NAME = 1 ; \
    if (bApDebug) \
        ap_log_error (APLOG_MARK, APLOG_WARNING | APLOG_NOERRNO, APLOG_STATUSCODE NULL, "Embperl: Set "#CFGNAME" (type="#TYPE";CHAR) = %s\n", arg) ; \
    return NULL; \
    } 

#undef EPCFG_CV
#undef EPCFG_SV
#undef EPCFG_HV
#undef EPCFG_AV
#undef EPCFG_REGEX
#define EPCFG_CV EPCFG_SAVE
#define EPCFG_SV EPCFG_SAVE
#define EPCFG_HV EPCFG_SAVE
#define EPCFG_REGEX EPCFG_SAVE
#define EPCFG_AV(STRUCT,TYPE,NAME,CFGNAME,SEPARATOR) EPCFG_SAVE(STRUCT,TYPE,NAME,CFGNAME)

#undef EPCFG_SAVE
#define EPCFG_SAVE(STRUCT,TYPE,NAME,CFGNAME) \
const char * embperl_Apache_Config_##STRUCT##NAME (cmd_parms *cmd, /* tApacheDirConfig */ void * pDirCfg, const char* arg) \
    { \
    ((tApacheDirConfig *)pDirCfg) -> save_##STRUCT##NAME = ap_pstrdup(cmd -> pool, arg) ; \
    ((tApacheDirConfig *)pDirCfg) -> set_##STRUCT##NAME = 1 ; \
    if (bApDebug) \
        ap_log_error (APLOG_MARK, APLOG_WARNING | APLOG_NOERRNO, APLOG_STATUSCODE NULL, "Embperl: Set "#CFGNAME" (type="#TYPE") = %s (save for later conversion to Perl data)\n", arg) ; \
    return NULL ; \
    } 

#define EPCFG_APP    
#define EPCFG_REQ   
#define EPCFG_COMPONENT   


#include "epcfg.h"

#endif /* MOD_EMBPERL */
/*--------------------------------------------------------------------------- */
#ifdef EMBPERL_SO

/*---------------------------------------------------------------------------
* embperl_GetApacheAppName
*/

char * embperl_GetApacheAppName (/*in*/ tApacheDirConfig * pDirCfg)


    {
    return pDirCfg?pDirCfg -> AppConfig.sAppName:"Embperl" ;
    }


/* --- functions for converting string to Perl structures --- */

#undef EPCFG_STR
#undef EPCFG_INT
#undef EPCFG_BOOL
#undef EPCFG_CHAR
#define EPCFG_INT EPCFG
#define EPCFG_BOOL EPCFG
#define EPCFG_CHAR EPCFG
#undef EPCFG

#define EPCFG(STRUCT,TYPE,NAME,CFGNAME)  \
        if (bApDebug && pDirCfg -> set_##STRUCT##NAME) \
            ap_log_error (APLOG_MARK, APLOG_WARNING | APLOG_NOERRNO, APLOG_STATUSCODE NULL, "Embperl: Get "#CFGNAME" (type="#TYPE") %d (0x%x)\n", pDirCfg -> STRUCT.NAME, pDirCfg -> STRUCT.NAME) ; 

#define EPCFG_STR(STRUCT,TYPE,NAME,CFGNAME)  \
        if (bApDebug && pDirCfg -> set_##STRUCT##NAME) \
            ap_log_error (APLOG_MARK, APLOG_WARNING | APLOG_NOERRNO, APLOG_STATUSCODE NULL, "Embperl: Get "#CFGNAME" (type="#TYPE") %s\n", pDirCfg -> STRUCT.NAME?pDirCfg -> STRUCT.NAME:"<null>") ; 



#undef EPCFG_SV
#define EPCFG_SV(STRUCT,TYPE,NAME,CFGNAME) \
    if (pDirCfg -> save_##STRUCT##NAME && !pDirCfg -> STRUCT.NAME) \
        { \
        if (bApDebug) \
            ap_log_error (APLOG_MARK, APLOG_WARNING | APLOG_NOERRNO, APLOG_STATUSCODE NULL, "Embperl: Get: about to convert "#CFGNAME" (type="#TYPE";SV) to perl data: %s\n", pDirCfg -> save_##STRUCT##NAME) ; \
\
        pDirCfg -> STRUCT.NAME = newSVpv((char *)pDirCfg -> save_##STRUCT##NAME, 0) ; \
        }

#undef EPCFG_CV
#define EPCFG_CV(STRUCT,TYPE,NAME,CFGNAME) \
    if (pDirCfg -> save_##STRUCT##NAME && !pDirCfg -> STRUCT.NAME) \
        { \
        int rc ;\
        if (bApDebug) \
            ap_log_error (APLOG_MARK, APLOG_WARNING | APLOG_NOERRNO, APLOG_STATUSCODE NULL, "Embperl: Get: about to convert "#CFGNAME" (type="#TYPE";CV) to perl data: %s\n", pDirCfg -> save_##STRUCT##NAME) ; \
\
        if ((rc = EvalConfig (pApp, sv_2mortal(newSVpv(pDirCfg -> save_##STRUCT##NAME, 0)), 0, NULL, "Configuration: EMBPERL_"#CFGNAME, &pDirCfg -> STRUCT.NAME)) != ok) \
            LogError (pReq, rc) ; \
            return rc ; \
        }


#undef EPCFG_AV
#define EPCFG_AV(STRUCT,TYPE,NAME,CFGNAME,SEPARATOR) \
    if (pDirCfg -> save_##STRUCT##NAME && !pDirCfg -> STRUCT.NAME) \
        { \
        if (bApDebug) \
            ap_log_error (APLOG_MARK, APLOG_WARNING | APLOG_NOERRNO, APLOG_STATUSCODE NULL, "Embperl: Get: about to convert "#CFGNAME" (type="#TYPE";AV) to perl data: %s\n", pDirCfg -> save_##STRUCT##NAME) ; \
\
        pDirCfg -> STRUCT.NAME = embperl_String2AV(pApp, pDirCfg -> save_##STRUCT##NAME, SEPARATOR) ;\
        tainted = 0 ; \
        } 

  
#undef EPCFG_HV
#define EPCFG_HV(STRUCT,TYPE,NAME,CFGNAME) \
    if (pDirCfg -> save_##STRUCT##NAME && !pDirCfg -> STRUCT.NAME) \
        { \
        if (bApDebug) \
            ap_log_error (APLOG_MARK, APLOG_WARNING | APLOG_NOERRNO, APLOG_STATUSCODE NULL, "Embperl: Get: about to convert "#CFGNAME" (type="#TYPE";HV) to perl data: %s\n", pDirCfg -> save_##STRUCT##NAME) ; \
\
        pDirCfg -> STRUCT.NAME = embperl_String2HV(pApp, pDirCfg -> save_##STRUCT##NAME, ' ', NULL) ;\
        tainted = 0 ; \
        } 
    

#undef EPCFG_REGEX
#define EPCFG_REGEX(STRUCT,TYPE,NAME,CFGNAME) \
    if (pDirCfg -> save_##STRUCT##NAME && !pDirCfg -> STRUCT.NAME) \
        { \
        int rc ; \
        if (bApDebug) \
            ap_log_error (APLOG_MARK, APLOG_WARNING | APLOG_NOERRNO, APLOG_STATUSCODE NULL, "Embperl: Get: about to convert "#CFGNAME" (type="#TYPE";REGEX) to perl data: %s\n", pDirCfg -> save_##STRUCT##NAME) ; \
\
        if ((rc = EvalRegEx (pApp, pDirCfg -> save_##STRUCT##NAME, "Configuration: EMBPERL_"#CFGNAME, &pDirCfg -> STRUCT.NAME)) != ok) \
            return rc ; \
        tainted = 0 ; \
        } 


/*---------------------------------------------------------------------------
* embperl_GetApacheAppConfig
*/

int embperl_GetApacheAppConfig (/*in*/ tThreadData * pThread,
                                /*in*/ tMemPool    * pPool,
                                /*in*/ tApacheDirConfig * pDirCfg,
                                /*out*/ tAppConfig * pConfig)


    {
    eptTHX_
    tApp * pApp = NULL ;
    if(pDirCfg)
        {
#define EPCFG_APP    
#undef EPCFG_REQ   
#undef EPCFG_COMPONENT   

#include "epcfg.h"         
        
        memcpy (&pConfig -> pPool + 1, &pDirCfg -> AppConfig.pPool + 1, sizeof (*pConfig) - ((tUInt8 *)(&pConfig -> pPool) - (tUInt8 *)pConfig) - sizeof (pConfig -> pPool)) ;
        pConfig -> bDebug = pDirCfg -> ComponentConfig.bDebug ;
        if (pConfig -> pSessionArgs)
            SvREFCNT_inc(pConfig -> pSessionArgs);
        if (pConfig -> pSessionClasses)
            SvREFCNT_inc(pConfig -> pSessionClasses);
        if (pConfig -> pObjectAddpathAV)
            SvREFCNT_inc(pConfig -> pObjectAddpathAV);
        
        if (pDirCfg -> bUseEnv)
             embperl_GetCGIAppConfig (pThread, pPool, pConfig, 1, 0, 0) ;
        }
    else
        embperl_DefaultAppConfig (pConfig) ;

    return ok ;
    }


/*---------------------------------------------------------------------------
* embperl_GetApacheReqConfig
*/

int embperl_GetApacheReqConfig (/*in*/ tApp *        pApp,
                                /*in*/ tMemPool    * pPool,
                                /*in*/ tApacheDirConfig * pDirCfg,
                                /*out*/ tReqConfig * pConfig)


    {
#define a pApp
    epaTHX_
#undef a

    if(pDirCfg)
        {
#undef EPCFG_APP    
#define EPCFG_REQ   
#undef EPCFG_COMPONENT   

#include "epcfg.h"         

        memcpy (&pConfig -> pPool + 1, &pDirCfg -> ReqConfig.pPool + 1, sizeof (*pConfig) - ((tUInt8 *)(&pConfig -> pPool) - (tUInt8 *)pConfig) - sizeof (pConfig -> pPool)) ;
        pConfig -> bDebug = pDirCfg -> ComponentConfig.bDebug ;
        pConfig -> bOptions = pDirCfg -> ComponentConfig.bOptions ;
        if (pConfig -> pAllow)
            SvREFCNT_inc(pConfig -> pAllow);
        if (pConfig -> pPathAV)
            SvREFCNT_inc(pConfig -> pPathAV);
        
        if (pDirCfg -> bUseEnv)
             embperl_GetCGIReqConfig (pApp, pPool, pConfig, 1, 0, 0) ;
        }
    else
        embperl_DefaultReqConfig (pConfig) ;
    pConfig -> bOptions |= optSendHttpHeader ;

    return ok ;
    }

/*---------------------------------------------------------------------------
* embperl_GetApacheComponentConfig
*/

int embperl_GetApacheComponentConfig (/*in*/ tReq * pReq,
                                /*in*/ tMemPool    * pPool,
                                /*in*/ tApacheDirConfig * pDirCfg,
                                /*out*/ tComponentConfig * pConfig)


    {

    if(pDirCfg)
        {
    #define r pReq
        epTHX_
    #undef r
        tApp * pApp = pReq -> pApp ;

#undef EPCFG_APP    
#undef EPCFG_REQ   
#define EPCFG_COMPONENT   

#include "epcfg.h"         

        memcpy (&pConfig -> pPool + 1, &pDirCfg -> ComponentConfig.pPool + 1, sizeof (*pConfig) - ((tUInt8 *)(&pConfig -> pPool) - (tUInt8 *)pConfig) - sizeof (pConfig -> pPool)) ;
        if (pConfig -> pExpiredFunc)
            SvREFCNT_inc(pConfig -> pExpiredFunc);
        if (pConfig -> pCacheKeyFunc)
            SvREFCNT_inc(pConfig -> pCacheKeyFunc);
        if (pConfig -> pRecipe)
            SvREFCNT_inc(pConfig -> pRecipe);

        if (pDirCfg -> bUseEnv)
             embperl_GetCGIComponentConfig (pReq, pPool, pConfig, 1, 0, 0) ;
        }
    else
        embperl_DefaultComponentConfig (pConfig) ;

    return ok ;
    }


/*---------------------------------------------------------------------------
* embperl_AddCookie
*/

struct addcookie
    {
    tApp * pApp ;
    tReqParam * pParam ;
    } ;

static int embperl_AddCookie (/*in*/ void * s, const char * pKey, const char * pValue)

    {
    tApp * a = ((struct addcookie *)s) -> pApp ;
    epaTHX_ 
    HV *   pHV ;
        
    if (!(pHV = ((struct addcookie *)s) -> pParam -> pCookies))    
        pHV = ((struct addcookie *)s) -> pParam -> pCookies = newHV () ;

    embperl_String2HV(a, pValue, ';', pHV) ;

    return 1 ;
    }


/*---------------------------------------------------------------------------
* embperl_GetApacheReqParam
*/

int embperl_GetApacheReqParam  (/*in*/  tApp        * pApp,
                                /*in*/ tMemPool    * pPool,
                                /*in*/  request_rec * r,
                                /*out*/ tReqParam * pParam)


    {
    tApp * a = pApp ;
    epaTHX_
    char * p ;
    struct addcookie s ;
    s.pApp = a ;
    s.pParam = pParam ;


    pParam -> sFilename    = r -> filename ;
    pParam -> sUnparsedUri = r -> unparsed_uri ;
    pParam -> sUri         = r -> uri ;
    pParam -> sPathInfo    = r -> path_info ;
    pParam -> sQueryInfo   = r -> args ;  
    if (p = ep_pstrdup (pPool, ap_table_get (r -> headers_in, "Accept-Language")))
        {
        while (isspace(*p))
            p++ ;
        pParam -> sLanguage = p ;
        while (isalpha(*p))
            p++ ;
        *p = '\0' ;
        }

    ap_table_do (embperl_AddCookie, &s, r -> headers_in, "Cookie", NULL) ;
    
    return ok ;
    }

#endif /* EMBPERL_SO */

#endif /* APACHE */