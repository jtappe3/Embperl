
/*
 * *********** WARNING **************
 * This file generated by Embperl::WrapXS/0.01
 * Any changes made here will be lost
 * ***********************************
 * 1. /opt/perlt5.6.1/lib/site_perl/5.6.1/ExtUtils/XSBuilder/WrapXS.pm:38
 * 2. /opt/perlt5.6.1/lib/site_perl/5.6.1/ExtUtils/XSBuilder/WrapXS.pm:1883
 * 3. xsbuilder/xs_generate.pl:6
 */


#include "ep.h"

#include "epmacro.h"

#include "EXTERN.h"

#include "perl.h"

#include "XSUB.h"

#include "eptypes.h"

#include "eppublic.h"

#include "epdat2.h"

#include "ep_xs_sv_convert.h"

#include "ep_xs_typedefs.h"



void Embperl__App_destroy (pTHX_ Embperl__App  obj) {
	    /*
            if (obj -> pUserHash)
                SvREFCNT_dec(obj -> pUserHash);
            if (obj -> pUserObj)
                SvREFCNT_dec(obj -> pUserObj);
            if (obj -> pStateHash)
                SvREFCNT_dec(obj -> pStateHash);
            if (obj -> pStateObj)
                SvREFCNT_dec(obj -> pStateObj);
            if (obj -> pAppHash)
                SvREFCNT_dec(obj -> pAppHash);
            if (obj -> pAppObj)
                SvREFCNT_dec(obj -> pAppObj);
	    */
};



void Embperl__App_new_init (pTHX_ Embperl__App  obj, SV * item, int overwrite) {

    SV * * tmpsv ;

    if (SvTYPE(item) == SVt_PVMG) 
        memcpy (obj, (void *)SvIVX(item), sizeof (*obj)) ;
    else if (SvTYPE(item) == SVt_PVHV) {
        if ((tmpsv = hv_fetch((HV *)item, "thread", sizeof("thread") - 1, 0)) || overwrite) {
            obj -> pThread = (tThreadData *)epxs_sv2_Embperl__Thread((tmpsv && *tmpsv?*tmpsv:&PL_sv_undef)) ;
        }
        if ((tmpsv = hv_fetch((HV *)item, "curr_req", sizeof("curr_req") - 1, 0)) || overwrite) {
            obj -> pCurrReq = (struct tReq *)epxs_sv2_Embperl__Req((tmpsv && *tmpsv?*tmpsv:&PL_sv_undef)) ;
        }
        if ((tmpsv = hv_fetch((HV *)item, "udat", sizeof("udat") - 1, 0)) || overwrite) {
            HV * tmpobj = ((HV *)epxs_sv2_HVREF((tmpsv && *tmpsv?*tmpsv:&PL_sv_undef)));
            if (tmpobj)
                obj -> pUserHash = (HV *)SvREFCNT_inc(tmpobj);
            else
                obj -> pUserHash = NULL ;
        }
        if ((tmpsv = hv_fetch((HV *)item, "user_session", sizeof("user_session") - 1, 0)) || overwrite) {
            SV * tmpobj = ((SV *)epxs_sv2_SVPTR((tmpsv && *tmpsv?*tmpsv:&PL_sv_undef)));
            if (tmpobj)
                obj -> pUserObj = (SV *)SvREFCNT_inc(tmpobj);
            else
                obj -> pUserObj = NULL ;
        }
        if ((tmpsv = hv_fetch((HV *)item, "sdat", sizeof("sdat") - 1, 0)) || overwrite) {
            HV * tmpobj = ((HV *)epxs_sv2_HVREF((tmpsv && *tmpsv?*tmpsv:&PL_sv_undef)));
            if (tmpobj)
                obj -> pStateHash = (HV *)SvREFCNT_inc(tmpobj);
            else
                obj -> pStateHash = NULL ;
        }
        if ((tmpsv = hv_fetch((HV *)item, "state_session", sizeof("state_session") - 1, 0)) || overwrite) {
            SV * tmpobj = ((SV *)epxs_sv2_SVPTR((tmpsv && *tmpsv?*tmpsv:&PL_sv_undef)));
            if (tmpobj)
                obj -> pStateObj = (SV *)SvREFCNT_inc(tmpobj);
            else
                obj -> pStateObj = NULL ;
        }
        if ((tmpsv = hv_fetch((HV *)item, "mdat", sizeof("mdat") - 1, 0)) || overwrite) {
            HV * tmpobj = ((HV *)epxs_sv2_HVREF((tmpsv && *tmpsv?*tmpsv:&PL_sv_undef)));
            if (tmpobj)
                obj -> pAppHash = (HV *)SvREFCNT_inc(tmpobj);
            else
                obj -> pAppHash = NULL ;
        }
        if ((tmpsv = hv_fetch((HV *)item, "app_session", sizeof("app_session") - 1, 0)) || overwrite) {
            SV * tmpobj = ((SV *)epxs_sv2_SVPTR((tmpsv && *tmpsv?*tmpsv:&PL_sv_undef)));
            if (tmpobj)
                obj -> pAppObj = (SV *)SvREFCNT_inc(tmpobj);
            else
                obj -> pAppObj = NULL ;
        }
        if ((tmpsv = hv_fetch((HV *)item, "errors_count", sizeof("errors_count") - 1, 0)) || overwrite) {
            obj -> nErrorsCount = (int)epxs_sv2_IV((tmpsv && *tmpsv?*tmpsv:&PL_sv_undef)) ;
        }
        if ((tmpsv = hv_fetch((HV *)item, "errors_last_time", sizeof("errors_last_time") - 1, 0)) || overwrite) {
            obj -> nErrorsLastTime = (int)epxs_sv2_IV((tmpsv && *tmpsv?*tmpsv:&PL_sv_undef)) ;
        }
        if ((tmpsv = hv_fetch((HV *)item, "errors_last_send_time", sizeof("errors_last_send_time") - 1, 0)) || overwrite) {
            obj -> nErrorsLastSendTime = (int)epxs_sv2_IV((tmpsv && *tmpsv?*tmpsv:&PL_sv_undef)) ;
        }
   ; }

    else
        croak ("initializer for Embperl::App::new is not a hash or object reference") ;

} ;


MODULE = Embperl::App    PACKAGE = Embperl::App 

Embperl::Thread
thread(obj, val=NULL)
    Embperl::App obj
    Embperl::Thread val
  PREINIT:
    /*nada*/

  CODE:
    RETVAL = (Embperl__Thread)  obj->pThread;

    if (items > 1) {
        obj->pThread = (Embperl__Thread) val;
    }
  OUTPUT:
    RETVAL

MODULE = Embperl::App    PACKAGE = Embperl::App 

Embperl::Req
curr_req(obj, val=NULL)
    Embperl::App obj
    Embperl::Req val
  PREINIT:
    /*nada*/

  CODE:
    RETVAL = (Embperl__Req)  obj->pCurrReq;

    if (items > 1) {
        obj->pCurrReq = (Embperl__Req) val;
    }
  OUTPUT:
    RETVAL

MODULE = Embperl::App    PACKAGE = Embperl::App 

Embperl::App::Config
config(obj, val=NULL)
    Embperl::App obj
    Embperl::App::Config val
  PREINIT:
    /*nada*/

  CODE:
    RETVAL = (Embperl__App__Config) & obj->Config;
    if (items > 1) {
         croak ("Config is read only") ;
    }
  OUTPUT:
    RETVAL

MODULE = Embperl::App    PACKAGE = Embperl::App 

HV *
udat(obj, val=NULL)
    Embperl::App obj
    HV * val
  PREINIT:
    /*nada*/

  CODE:
    RETVAL = (HV *)  obj->pUserHash;

    if (items > 1) {
        obj->pUserHash = (HV *)SvREFCNT_inc(val);
    }
  OUTPUT:
    RETVAL

MODULE = Embperl::App    PACKAGE = Embperl::App 

SV *
user_session(obj, val=NULL)
    Embperl::App obj
    SV * val
  PREINIT:
    /*nada*/

  CODE:
    RETVAL = (SV *)  obj->pUserObj;

    if (items > 1) {
        obj->pUserObj = (SV *)SvREFCNT_inc(val);
    }
  OUTPUT:
    RETVAL

MODULE = Embperl::App    PACKAGE = Embperl::App 

HV *
sdat(obj, val=NULL)
    Embperl::App obj
    HV * val
  PREINIT:
    /*nada*/

  CODE:
    RETVAL = (HV *)  obj->pStateHash;

    if (items > 1) {
        obj->pStateHash = (HV *)SvREFCNT_inc(val);
    }
  OUTPUT:
    RETVAL

MODULE = Embperl::App    PACKAGE = Embperl::App 

SV *
state_session(obj, val=NULL)
    Embperl::App obj
    SV * val
  PREINIT:
    /*nada*/

  CODE:
    RETVAL = (SV *)  obj->pStateObj;

    if (items > 1) {
        obj->pStateObj = (SV *)SvREFCNT_inc(val);
    }
  OUTPUT:
    RETVAL

MODULE = Embperl::App    PACKAGE = Embperl::App 

HV *
mdat(obj, val=NULL)
    Embperl::App obj
    HV * val
  PREINIT:
    /*nada*/

  CODE:
    RETVAL = (HV *)  obj->pAppHash;

    if (items > 1) {
        obj->pAppHash = (HV *)SvREFCNT_inc(val);
    }
  OUTPUT:
    RETVAL

MODULE = Embperl::App    PACKAGE = Embperl::App 

SV *
app_session(obj, val=NULL)
    Embperl::App obj
    SV * val
  PREINIT:
    /*nada*/

  CODE:
    RETVAL = (SV *)  obj->pAppObj;

    if (items > 1) {
        obj->pAppObj = (SV *)SvREFCNT_inc(val);
    }
  OUTPUT:
    RETVAL

MODULE = Embperl::App    PACKAGE = Embperl::App 

int
errors_count(obj, val=0)
    Embperl::App obj
    int val
  PREINIT:
    /*nada*/

  CODE:
    RETVAL = (int)  obj->nErrorsCount;

    if (items > 1) {
        obj->nErrorsCount = (int) val;
    }
  OUTPUT:
    RETVAL

MODULE = Embperl::App    PACKAGE = Embperl::App 

int
errors_last_time(obj, val=0)
    Embperl::App obj
    int val
  PREINIT:
    /*nada*/

  CODE:
    RETVAL = (int)  obj->nErrorsLastTime;

    if (items > 1) {
        obj->nErrorsLastTime = (int) val;
    }
  OUTPUT:
    RETVAL

MODULE = Embperl::App    PACKAGE = Embperl::App 

int
errors_last_send_time(obj, val=0)
    Embperl::App obj
    int val
  PREINIT:
    /*nada*/

  CODE:
    RETVAL = (int)  obj->nErrorsLastSendTime;

    if (items > 1) {
        obj->nErrorsLastSendTime = (int) val;
    }
  OUTPUT:
    RETVAL

MODULE = Embperl::App    PACKAGE = Embperl::App 



SV *
new (class,initializer=NULL)
    char * class
    SV * initializer 
PREINIT:
    SV * svobj ;
    Embperl__App  cobj ;
    SV * tmpsv ;
CODE:
    epxs_Embperl__App_create_obj(cobj,svobj,RETVAL,malloc(sizeof(*cobj))) ;

    if (initializer) {
        if (!SvROK(initializer) || !(tmpsv = SvRV(initializer))) 
            croak ("initializer for Embperl::App::new is not a reference") ;

        if (SvTYPE(tmpsv) == SVt_PVHV || SvTYPE(tmpsv) == SVt_PVMG)  
            Embperl__App_new_init (aTHX_ cobj, tmpsv, 0) ;
        else if (SvTYPE(tmpsv) == SVt_PVAV) {
            int i ;
            SvGROW(svobj, sizeof (*cobj) * av_len((AV *)tmpsv)) ;     
            for (i = 0; i <= av_len((AV *)tmpsv); i++) {
                SV * * itemrv = av_fetch((AV *)tmpsv, i, 0) ;
                SV * item ;
                if (!itemrv || !*itemrv || !SvROK(*itemrv) || !(item = SvRV(*itemrv))) 
                    croak ("array element of initializer for Embperl::App::new is not a reference") ;
                Embperl__App_new_init (aTHX_ &cobj[i], item, 1) ;
            }
        }
        else {
             croak ("initializer for Embperl::App::new is not a hash/array/object reference") ;
        }
    }
OUTPUT:
    RETVAL 

MODULE = Embperl::App    PACKAGE = Embperl::App 



void
DESTROY (obj)
    Embperl::App  obj 
CODE:
    Embperl__App_destroy (aTHX_ obj) ;

PROTOTYPES: disabled

BOOT:
    items = items; /* -Wall */

