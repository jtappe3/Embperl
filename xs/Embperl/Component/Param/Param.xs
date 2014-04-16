
/*
 * *********** WARNING **************
 * This file generated by Embperl::WrapXS/2.0.0
 * Any changes made here will be lost
 * ***********************************
 * 1. /usr/lib/perl5/site_perl/5.16.0/ExtUtils/XSBuilder/WrapXS.pm:52
 * 2. /usr/lib/perl5/site_perl/5.16.0/ExtUtils/XSBuilder/WrapXS.pm:2068
 * 3. xsbuilder/xs_generate.pl:6
 */


#include "ep.h"

#include "epmacro.h"

#include "epdat2.h"

#include "eptypes.h"

#include "eppublic.h"

#include "EXTERN.h"

#include "perl.h"

#include "XSUB.h"

#include "ep_xs_sv_convert.h"

#include "ep_xs_typedefs.h"



void Embperl__Component__Param_destroy (pTHX_ Embperl__Component__Param  obj) {
            if (obj -> pInput)
                SvREFCNT_dec(obj -> pInput);
            if (obj -> pOutput)
                SvREFCNT_dec(obj -> pOutput);
            if (obj -> pErrArray)
                SvREFCNT_dec(obj -> pErrArray);
            if (obj -> pParam)
                SvREFCNT_dec(obj -> pParam);
            if (obj -> pFormHash)
                SvREFCNT_dec(obj -> pFormHash);
            if (obj -> pFormArray)
                SvREFCNT_dec(obj -> pFormArray);
            if (obj -> pXsltParam)
                SvREFCNT_dec(obj -> pXsltParam);

};



void Embperl__Component__Param_new_init (pTHX_ Embperl__Component__Param  obj, SV * item, int overwrite) {

    SV * * tmpsv ;

    if (SvTYPE(item) == SVt_PVMG) 
        memcpy (obj, (void *)SvIVX(item), sizeof (*obj)) ;
    else if (SvTYPE(item) == SVt_PVHV) {
        if ((tmpsv = hv_fetch((HV *)item, "inputfile", sizeof("inputfile") - 1, 0)) || overwrite) {
            char * tmpobj = ((char *)epxs_sv2_PV((tmpsv && *tmpsv?*tmpsv:&PL_sv_undef)));
            if (tmpobj)
                obj -> sInputfile = (char *)ep_pstrdup(obj->pPool,tmpobj);
            else
                obj -> sInputfile = NULL ;
        }
        if ((tmpsv = hv_fetch((HV *)item, "outputfile", sizeof("outputfile") - 1, 0)) || overwrite) {
            char * tmpobj = ((char *)epxs_sv2_PV((tmpsv && *tmpsv?*tmpsv:&PL_sv_undef)));
            if (tmpobj)
                obj -> sOutputfile = (char *)ep_pstrdup(obj->pPool,tmpobj);
            else
                obj -> sOutputfile = NULL ;
        }
        if ((tmpsv = hv_fetch((HV *)item, "subreq", sizeof("subreq") - 1, 0)) || overwrite) {
            char * tmpobj = ((char *)epxs_sv2_PV((tmpsv && *tmpsv?*tmpsv:&PL_sv_undef)));
            if (tmpobj)
                obj -> sSubreq = (char *)ep_pstrdup(obj->pPool,tmpobj);
            else
                obj -> sSubreq = NULL ;
        }
        if ((tmpsv = hv_fetch((HV *)item, "input", sizeof("input") - 1, 0)) || overwrite) {
            SV * tmpobj = ((SV *)epxs_sv2_SVPTR((tmpsv && *tmpsv?*tmpsv:&PL_sv_undef)));
            if (tmpobj)
                obj -> pInput = (SV *)SvREFCNT_inc(tmpobj);
            else
                obj -> pInput = NULL ;
        }
        if ((tmpsv = hv_fetch((HV *)item, "output", sizeof("output") - 1, 0)) || overwrite) {
            SV * tmpobj = ((SV *)epxs_sv2_SVPTR((tmpsv && *tmpsv?*tmpsv:&PL_sv_undef)));
            if (tmpobj)
                obj -> pOutput = (SV *)SvREFCNT_inc(tmpobj);
            else
                obj -> pOutput = NULL ;
        }
        if ((tmpsv = hv_fetch((HV *)item, "sub", sizeof("sub") - 1, 0)) || overwrite) {
            char * tmpobj = ((char *)epxs_sv2_PV((tmpsv && *tmpsv?*tmpsv:&PL_sv_undef)));
            if (tmpobj)
                obj -> sSub = (char *)ep_pstrdup(obj->pPool,tmpobj);
            else
                obj -> sSub = NULL ;
        }
        if ((tmpsv = hv_fetch((HV *)item, "import", sizeof("import") - 1, 0)) || overwrite) {
            obj -> nImport = (int)epxs_sv2_IV((tmpsv && *tmpsv?*tmpsv:&PL_sv_undef)) ;
        }
        if ((tmpsv = hv_fetch((HV *)item, "object", sizeof("object") - 1, 0)) || overwrite) {
            char * tmpobj = ((char *)epxs_sv2_PV((tmpsv && *tmpsv?*tmpsv:&PL_sv_undef)));
            if (tmpobj)
                obj -> sObject = (char *)ep_pstrdup(obj->pPool,tmpobj);
            else
                obj -> sObject = NULL ;
        }
        if ((tmpsv = hv_fetch((HV *)item, "isa", sizeof("isa") - 1, 0)) || overwrite) {
            char * tmpobj = ((char *)epxs_sv2_PV((tmpsv && *tmpsv?*tmpsv:&PL_sv_undef)));
            if (tmpobj)
                obj -> sISA = (char *)ep_pstrdup(obj->pPool,tmpobj);
            else
                obj -> sISA = NULL ;
        }
        if ((tmpsv = hv_fetch((HV *)item, "errors", sizeof("errors") - 1, 0)) || overwrite) {
            AV * tmpobj = ((AV *)epxs_sv2_AVREF((tmpsv && *tmpsv?*tmpsv:&PL_sv_undef)));
            if (tmpobj)
                obj -> pErrArray = (AV *)SvREFCNT_inc(tmpobj);
            else
                obj -> pErrArray = NULL ;
        }
        if ((tmpsv = hv_fetch((HV *)item, "firstline", sizeof("firstline") - 1, 0)) || overwrite) {
            obj -> nFirstLine = (int)epxs_sv2_IV((tmpsv && *tmpsv?*tmpsv:&PL_sv_undef)) ;
        }
        if ((tmpsv = hv_fetch((HV *)item, "mtime", sizeof("mtime") - 1, 0)) || overwrite) {
            obj -> nMtime = (int)epxs_sv2_IV((tmpsv && *tmpsv?*tmpsv:&PL_sv_undef)) ;
        }
        if ((tmpsv = hv_fetch((HV *)item, "param", sizeof("param") - 1, 0)) || overwrite) {
            AV * tmpobj = ((AV *)epxs_sv2_AVREF((tmpsv && *tmpsv?*tmpsv:&PL_sv_undef)));
            if (tmpobj)
                obj -> pParam = (AV *)SvREFCNT_inc(tmpobj);
            else
                obj -> pParam = NULL ;
        }
        if ((tmpsv = hv_fetch((HV *)item, "fdat", sizeof("fdat") - 1, 0)) || overwrite) {
            HV * tmpobj = ((HV *)epxs_sv2_HVREF((tmpsv && *tmpsv?*tmpsv:&PL_sv_undef)));
            if (tmpobj)
                obj -> pFormHash = (HV *)SvREFCNT_inc(tmpobj);
            else
                obj -> pFormHash = NULL ;
        }
        if ((tmpsv = hv_fetch((HV *)item, "ffld", sizeof("ffld") - 1, 0)) || overwrite) {
            AV * tmpobj = ((AV *)epxs_sv2_AVREF((tmpsv && *tmpsv?*tmpsv:&PL_sv_undef)));
            if (tmpobj)
                obj -> pFormArray = (AV *)SvREFCNT_inc(tmpobj);
            else
                obj -> pFormArray = NULL ;
        }
        if ((tmpsv = hv_fetch((HV *)item, "xsltparam", sizeof("xsltparam") - 1, 0)) || overwrite) {
            HV * tmpobj = ((HV *)epxs_sv2_HVREF((tmpsv && *tmpsv?*tmpsv:&PL_sv_undef)));
            if (tmpobj)
                obj -> pXsltParam = (HV *)SvREFCNT_inc(tmpobj);
            else
                obj -> pXsltParam = NULL ;
        }
   ; }

    else
        croak ("initializer for Embperl::Component::Param::new is not a hash or object reference") ;

} ;


MODULE = Embperl::Component::Param    PACKAGE = Embperl::Component::Param 

char *
inputfile(obj, val=NULL)
    Embperl::Component::Param obj
    char * val
  PREINIT:
    /*nada*/

  CODE:
    RETVAL = (char *)  obj->sInputfile;

    if (items > 1) {
        obj->sInputfile = (char *)ep_pstrdup(obj->pPool,val);
    }
  OUTPUT:
    RETVAL

MODULE = Embperl::Component::Param    PACKAGE = Embperl::Component::Param 

char *
outputfile(obj, val=NULL)
    Embperl::Component::Param obj
    char * val
  PREINIT:
    /*nada*/

  CODE:
    RETVAL = (char *)  obj->sOutputfile;

    if (items > 1) {
        obj->sOutputfile = (char *)ep_pstrdup(obj->pPool,val);
    }
  OUTPUT:
    RETVAL

MODULE = Embperl::Component::Param    PACKAGE = Embperl::Component::Param 

char *
subreq(obj, val=NULL)
    Embperl::Component::Param obj
    char * val
  PREINIT:
    /*nada*/

  CODE:
    RETVAL = (char *)  obj->sSubreq;

    if (items > 1) {
        obj->sSubreq = (char *)ep_pstrdup(obj->pPool,val);
    }
  OUTPUT:
    RETVAL

MODULE = Embperl::Component::Param    PACKAGE = Embperl::Component::Param 

SV *
input(obj, val=NULL)
    Embperl::Component::Param obj
    SV * val
  PREINIT:
    /*nada*/

  CODE:
    RETVAL = (SV *)  obj->pInput;

    if (items > 1) {
        obj->pInput = (SV *)SvREFCNT_inc(val);
    }
  OUTPUT:
    RETVAL

MODULE = Embperl::Component::Param    PACKAGE = Embperl::Component::Param 

SV *
output(obj, val=NULL)
    Embperl::Component::Param obj
    SV * val
  PREINIT:
    /*nada*/

  CODE:
    RETVAL = (SV *)  obj->pOutput;

    if (items > 1) {
        obj->pOutput = (SV *)SvREFCNT_inc(val);
    }
  OUTPUT:
    RETVAL

MODULE = Embperl::Component::Param    PACKAGE = Embperl::Component::Param 

char *
sub(obj, val=NULL)
    Embperl::Component::Param obj
    char * val
  PREINIT:
    /*nada*/

  CODE:
    RETVAL = (char *)  obj->sSub;

    if (items > 1) {
        obj->sSub = (char *)ep_pstrdup(obj->pPool,val);
    }
  OUTPUT:
    RETVAL

MODULE = Embperl::Component::Param    PACKAGE = Embperl::Component::Param 

int
import(obj, val=0)
    Embperl::Component::Param obj
    int val
  PREINIT:
    /*nada*/

  CODE:
    RETVAL = (int)  obj->nImport;

    if (items > 1) {
        obj->nImport = (int) val;
    }
  OUTPUT:
    RETVAL

MODULE = Embperl::Component::Param    PACKAGE = Embperl::Component::Param 

char *
object(obj, val=NULL)
    Embperl::Component::Param obj
    char * val
  PREINIT:
    /*nada*/

  CODE:
    RETVAL = (char *)  obj->sObject;

    if (items > 1) {
        obj->sObject = (char *)ep_pstrdup(obj->pPool,val);
    }
  OUTPUT:
    RETVAL

MODULE = Embperl::Component::Param    PACKAGE = Embperl::Component::Param 

char *
isa(obj, val=NULL)
    Embperl::Component::Param obj
    char * val
  PREINIT:
    /*nada*/

  CODE:
    RETVAL = (char *)  obj->sISA;

    if (items > 1) {
        obj->sISA = (char *)ep_pstrdup(obj->pPool,val);
    }
  OUTPUT:
    RETVAL

MODULE = Embperl::Component::Param    PACKAGE = Embperl::Component::Param 

AV *
errors(obj, val=NULL)
    Embperl::Component::Param obj
    AV * val
  PREINIT:
    /*nada*/

  CODE:
    RETVAL = (AV *)  obj->pErrArray;

    if (items > 1) {
        obj->pErrArray = (AV *)SvREFCNT_inc(val);
    }
  OUTPUT:
    RETVAL

MODULE = Embperl::Component::Param    PACKAGE = Embperl::Component::Param 

int
firstline(obj, val=0)
    Embperl::Component::Param obj
    int val
  PREINIT:
    /*nada*/

  CODE:
    RETVAL = (int)  obj->nFirstLine;

    if (items > 1) {
        obj->nFirstLine = (int) val;
    }
  OUTPUT:
    RETVAL

MODULE = Embperl::Component::Param    PACKAGE = Embperl::Component::Param 

int
mtime(obj, val=0)
    Embperl::Component::Param obj
    int val
  PREINIT:
    /*nada*/

  CODE:
    RETVAL = (int)  obj->nMtime;

    if (items > 1) {
        obj->nMtime = (int) val;
    }
  OUTPUT:
    RETVAL

MODULE = Embperl::Component::Param    PACKAGE = Embperl::Component::Param 

AV *
param(obj, val=NULL)
    Embperl::Component::Param obj
    AV * val
  PREINIT:
    /*nada*/

  CODE:
    RETVAL = (AV *)  obj->pParam;

    if (items > 1) {
        obj->pParam = (AV *)SvREFCNT_inc(val);
    }
  OUTPUT:
    RETVAL

MODULE = Embperl::Component::Param    PACKAGE = Embperl::Component::Param 

HV *
fdat(obj, val=NULL)
    Embperl::Component::Param obj
    HV * val
  PREINIT:
    /*nada*/

  CODE:
    RETVAL = (HV *)  obj->pFormHash;

    if (items > 1) {
        obj->pFormHash = (HV *)SvREFCNT_inc(val);
    }
  OUTPUT:
    RETVAL

MODULE = Embperl::Component::Param    PACKAGE = Embperl::Component::Param 

AV *
ffld(obj, val=NULL)
    Embperl::Component::Param obj
    AV * val
  PREINIT:
    /*nada*/

  CODE:
    RETVAL = (AV *)  obj->pFormArray;

    if (items > 1) {
        obj->pFormArray = (AV *)SvREFCNT_inc(val);
    }
  OUTPUT:
    RETVAL

MODULE = Embperl::Component::Param    PACKAGE = Embperl::Component::Param 

HV *
xsltparam(obj, val=NULL)
    Embperl::Component::Param obj
    HV * val
  PREINIT:
    /*nada*/

  CODE:
    RETVAL = (HV *)  obj->pXsltParam;

    if (items > 1) {
        obj->pXsltParam = (HV *)SvREFCNT_inc(val);
    }
  OUTPUT:
    RETVAL

MODULE = Embperl::Component::Param    PACKAGE = Embperl::Component::Param 



SV *
new (class,initializer=NULL)
    char * class
    SV * initializer 
PREINIT:
    SV * svobj ;
    Embperl__Component__Param  cobj ;
    SV * tmpsv ;
CODE:
    epxs_Embperl__Component__Param_create_obj(cobj,svobj,RETVAL,malloc(sizeof(*cobj))) ;

    if (initializer) {
        if (!SvROK(initializer) || !(tmpsv = SvRV(initializer))) 
            croak ("initializer for Embperl::Component::Param::new is not a reference") ;

        if (SvTYPE(tmpsv) == SVt_PVHV || SvTYPE(tmpsv) == SVt_PVMG)  
            Embperl__Component__Param_new_init (aTHX_ cobj, tmpsv, 0) ;
        else if (SvTYPE(tmpsv) == SVt_PVAV) {
            int i ;
            SvGROW(svobj, sizeof (*cobj) * av_len((AV *)tmpsv)) ;     
            for (i = 0; i <= av_len((AV *)tmpsv); i++) {
                SV * * itemrv = av_fetch((AV *)tmpsv, i, 0) ;
                SV * item ;
                if (!itemrv || !*itemrv || !SvROK(*itemrv) || !(item = SvRV(*itemrv))) 
                    croak ("array element of initializer for Embperl::Component::Param::new is not a reference") ;
                Embperl__Component__Param_new_init (aTHX_ &cobj[i], item, 1) ;
            }
        }
        else {
             croak ("initializer for Embperl::Component::Param::new is not a hash/array/object reference") ;
        }
    }
OUTPUT:
    RETVAL 

MODULE = Embperl::Component::Param    PACKAGE = Embperl::Component::Param 



void
DESTROY (obj)
    Embperl::Component::Param  obj 
CODE:
    Embperl__Component__Param_destroy (aTHX_ obj) ;

PROTOTYPES: disabled

BOOT:
    items = items; /* -Wall */

