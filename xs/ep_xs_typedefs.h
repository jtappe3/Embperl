
/*
 * *********** WARNING **************
 * This file generated by Embperl::WrapXS/2.0.0
 * Any changes made here will be lost
 * ***********************************
 * 1. /usr/lib/perl5/site_perl/5.16.0/ExtUtils/XSBuilder/WrapXS.pm:52
 * 2. /usr/lib/perl5/site_perl/5.16.0/ExtUtils/XSBuilder/WrapXS.pm:2068
 * 3. xsbuilder/xs_generate.pl:6
 */


#ifndef EP_XS_TYPEDEFS_H
#define EP_XS_TYPEDEFS_H

typedef tThreadData * Embperl__Thread;
typedef tApp * Embperl__App;
typedef tAppConfig * Embperl__App__Config;
typedef tReq * Embperl__Req;
typedef tReqConfig * Embperl__Req__Config;
typedef tReqParam * Embperl__Req__Param;
typedef tComponent * Embperl__Component;
typedef tComponentConfig * Embperl__Component__Config;
typedef tComponentParam * Embperl__Component__Param;
typedef tComponentOutput * Embperl__Component__Output;
typedef tCacheItem * Embperl__CacheItem;
typedef tTokenTable * Embperl__Syntax;
typedef request_rec * Apache;
typedef server_rec * Apache__Server;
typedef void * PTR;
#if PERL_VERSION > 5
typedef char * PV;
#endif
typedef char * PVnull;

#ifndef pTHX_
#define pTHX_
#endif
#ifndef aTHX_
#define aTHX_
#endif
#ifndef pTHX
#define pTHX
#endif
#ifndef aTHX
#define aTHX
#endif

#ifndef XSprePUSH
#define XSprePUSH (sp = PL_stack_base + ax - 1)
#endif


#endif /* EP_XS_TYPEDEFS_H */
