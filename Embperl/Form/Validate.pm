
###################################################################################
#
#   Embperl - Copyright (c) 1997-2002 Gerald Richter / ecos gmbh   www.ecos.de
#
#   You may distribute under the terms of either the GNU General Public
#   License or the Artistic License, as specified in the Perl README file.
#
#   THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR
#   IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
#   WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
#
#   $Id: Validate.pm,v 1.1.2.10 2002/03/08 06:44:14 richter Exp $
#
###################################################################################


package Embperl::Form::Validate;

use strict;
use vars qw($VERSION);

$VERSION = q$Id: Validate.pm,v 1.1.2.10 2002/03/08 06:44:14 richter Exp $;

=head1 NAME

Embperl::Form::Validate - Form validation with server- and client-side support.

=head1 DESCRIPTION

This modules is developed to do form validation for you. It works
on the server side by checking the posted form data and it
generates client side script functions, to validate the
form values, as far as possible, before they are send to
the server, to avoid another server roundtrip.

Also it has the best support for Embperl, it should also work
outside of Embperl e.g. with CGI.pm or mod_perl.

It can be extended by new validation rules for
additional syntaxes (e.g. US zip codes, German
Postleitzahlen, number plates, iso-3166 2-digit language or country
codes, etc.)

Each module has the ability to rely it's answer on parameters like
e.g. the browser, which caused the request for or submitted the form.

The module fully supports internationalisation. Any message can be
provided in multiple languages and it makes use of Embperl's 
multilanguage support.

=head1 SYNOPSIS

 use Embperl::Form::Validate;

 my $epf = new Embperl::Form::Validate($rules, $form_id);

 $epf->add_rule('fnord', $fnord_rules);

 # validate the form values and returns error information, if any
 my $result = $epf -> validate ;

 # Does the form content validate?
 print 'Validate: ' . ($result?'no':'yes');
 
 # validate the form values and reaturn all error messages, if any
 my @errors = $epf->validate_messages($fdat, $pref);

 # Get the code for a client-side form validation according to the
 # rules given to new:
 $epf -> get_script_code ;

=head1 METHODS

The following methods are available:

=head2 $epf = Embperl::Form::Validate -> new ($rules [, $form_id ], [$default_language]);

Constructor for a new form validator. Returns a reference to a
Embperl::Form::Validate object.

=over

=item $rules 

should be a reference to an array of rules, see L<"RULES"> elsewhere in this
document for details. 

=item $form_id 

should be the name (im HTML) or id (in XHTML) parameter of
the form tag, which has to be verified.It\'s e.g. used for
generating the right path in the JavaScript DOM. It defaults to 'forms[0]'
which should be the first form in your page.

=item $default_language

language to use when no messages are available in the desired language.
Defaults to 'en'.

=back

=cut

sub new 
    {
    my $invokedby = shift;
    my $class = ref($invokedby) || $invokedby;
    my ($frules, $form_id, $default_language) = @_ ;

    my $self = {
	         form_id          => $form_id || 'forms[0]', # The name 
		 frules           => $frules || [],          # \@frules
		 default_language => $default_language || 'en',
	       };
    bless($self, $class);
    $self->init;
    return $self;
    }

###
### init() yet undocumented. The only purpose of init() is too allow
### to add functionality without rewriting the whole new() method.
###

sub init # $self
{
    my $self = shift;
    return 1;
}

=head2 $epf->add_rules($field, $field_rules);

Adds rules $field_rules for a (new) field $field to the validator,
e.g.

 $epf->add_rule([ -key => 'fnord', -type => 'Float', -max => 1.3, -name => 'Fnord' ]);

The new rule will be appended to the end of the list of rules.

See L<"RULES"> elsewhere in this document.

=cut

sub add_rule # $self, $field, \%rules
    {
    my $self = shift;
    my $rules = shift;

    push @{$self->{frules}}, $rules;
    return 1;
    }




=head2 $epf -> validate ([$fdat, [$pref]]);

Does the server-side form validation.

=over

=item $fdat

should be a hash reference to all postend form values.
It defaults to %fdat of the current Embperl page.

=item $pref

can contain addtional information for the validation process.
At the moment the keys C<language> and C<default_language>
are recognized. C<language> defaults to the language set by
Embperl. C<default_language> defaults to the one given with C<new>.

=back

The method verifies the content $fdat according to the rules given 
to the Embperl::Form::Validate
constructor and added by the add_rule() method and returns an 
array refernce to error informations. If there is no error it
returns undef. Each element of the returned array contains a hash with
the following keys:

=over

=item key

key into $fdat which caused the error

=item id

message id

=item typeobj

object reference to the Validate object which was used to validate the field

=item name

human readable name, if any. Maybe a hash with multiple languages.

=item msg

field specific messages, if any. Maybe a hash with multiple languages.

=item param

array with parameters which should subsituted inside the message

=back

=cut


sub loadtype 
    {
    my ($self, $type) = @_ ;

    
    eval "require $type;";
    die 'Died inside '.__PACKAGE__.'::loadtype::eval: '.$@ if $@;
    return $type;
    }


sub newtype 
    {
    my ($self, $type) = @_ ;

    $type ||= 'Default';
    $type = 'Embperl::Form::Validate::'.$type
        unless $type =~ m!(::|/)!;

    my $obj = $self -> {typeobjs}{$type} ;
    return $obj if ($obj) ;
    
    $type = $self -> loadtype ($type) ;

    $obj = $self -> {typeobjs}{$type} = $type -> new ;

    return $obj ;
    }



sub validate_rules
    {
    my ($self, $frules, $fdat, $pref, $result) = @_ ;

    my %param ;
    my $type ;
    my $typeobj ;
    my $i ;
    my $keys = [] ;
    my $key ;
    my $status ;
    my $name ;
    my $msg ;

    while ($i < @$frules) 
        {
        my $action = $frules -> [$i++] ;
        if (ref $action eq 'ARRAY')
            {
            my $fail = $self -> validate_rules ($action, $fdat, $pref, $result) ;
            return $fail if ($fail) ;
            }
        elsif (ref $action eq 'CODE')
            {
            my $arg = $frules -> [$i++] ;
            foreach my $k (@$keys) 
                {
                $status = &$action($k, $fdat -> {$name}, $arg, $fdat, $pref) ;
                last if (!$status) ;
                }
            }
        elsif ($action =~ /^-(.*?)$/)
            {
            if ($1 eq 'key')
                {
                $key        = $frules->[$i++] ;
		$keys 	    = ref $key?$key:[$key] ;
                $type       = 'Default' ;
                $typeobj    = $self -> newtype ($type) ;
                $name       = undef ;
                $msg        = undef ;
                }
            if ($1 eq 'name')
                {
                $name    = $i++ ;
                }
            if ($1 eq 'msg')
                {
                $msg    = $i++ ;
                }
            elsif ($1 eq 'type')
                {
                $type    = $frules->[$i++] ;
                $typeobj = $self -> newtype ($type) ;
		foreach my $k (@$keys) 
		    {
		    $status  = $typeobj -> validate ($k, $fdat -> {$k}, $fdat, $pref) ;
		    last if (!$status) ;
		    }
                }
            else
                {
                $param{$1} = 1 ;
                }
            }
        else
            {
            my $arg = $frules -> [$i++] ;
            foreach my $k (@$keys) 
                {
		my $method = 'validate_' . $action ;                 
                $status = $typeobj -> $method ($k, $fdat -> {$k}, $arg, $fdat, $pref) ;
                last if (!$status) ;
                }
            }
        
        if ($status)
            {
            if (@$status)
                { 
                my $id = $status  -> [0] ;
                push @$result, { typeobj => $typeobj, id => $id, key => $key, ($name?(name => $frules -> [$name]):()), ($msg?(msg => $frules -> [$msg]):()), param => $status} ;
                }
            last if (!$param{cont}) 
            }
        }
    return $param{fail} ;
    }




sub validate
    {
    my ($self, $fdat, $pref, $epreq) = @_ ;

    $epreq ||= $Embperl::req ;
    $fdat  ||= $epreq -> thread -> form_hash ;

    my @result ;
    $self -> validate_rules ($self->{frules}, $fdat, $pref, \@result) ;

    return \@result ;
    }


sub build_message
    {
    my ($self, $id, $key, $name, $msg, $param, $typeobj, $pref, $epreq) = @_ ;

    my $language = $pref -> {language} ;
    my $default_language = $pref -> {default_language} ;
    my $txt ;

    $name ||= $key ;
    if (ref $name eq 'ARRAY')
        {
        my @names ;
        foreach my $n (@$name)
            {
            push @names, ref $n ? ($n -> {$language} || $n -> {$default_language} || (each %$n)[1] || $key):$n ; 
            }
        $name = join (', ', @names) ;
        }
    else
        {
        $name = ref $name ? ($name -> {$language} || $name -> {$default_language} || (each %$name)[1] || $key):$name ; 
        }

    if ($msg)
        {
        $txt = ref $msg ? ($msg -> {$language} || $msg -> {$default_language} || (each %$msg)[1] || undef):$msg ; 
        }
    else
        {
        $txt = $typeobj -> getmsg ($id, $language, $default_language) ;
        }
    $txt = $epreq -> gettext($id) if (!$txt && $epreq) ;
    $txt ||= "Missing Message $id: %0 %1 %2 %3" ;                 
    my $id = $param -> [0] ;
    $param -> [0] = $name ;
    $txt =~ s/%(\d+)/$param->[$1]/g ;
    $param -> [0] = $id ;

    return $txt ;
    }


=pod

=head2 $epf -> error_message ($err, [ $pref ])

Converts one item returned by validate into a error message

=over

=item $err

Item returned by validate

=item $pref

Preferences (see L<validate>)

=back

=cut


sub error_message
    {
    my ($self, $err, $pref, $epreq) = @_ ;

    $epreq ||= $Embperl::req ;

    return $self -> build_message ($err -> {id}, $err -> {key}, $err -> {name}, $err -> {msg}, $err -> {param}, $err -> {typeobj}, $pref, $epreq) ;
    }


=pod

=head2 $epf -> validate_messages ($fdat, [ $pref ])

Validate the form content and returns the error messages
if any. See L<validate> for details.

=cut


sub validate_messages
    {
    my ($self, $fdat, $pref, $epreq) = @_ ;
    
    $epreq ||= $Embperl::req ;
    $pref -> {language} ||= $epreq -> param -> language if ($epreq) ;
    $pref -> {default_language} ||= $self -> {default_language} ;

    my $result = $self -> validate ($fdat, $pref, $epreq) ;
    return [] if (!@$result) ;

    my @msgs ;
    foreach my $err (@$result)
        {
        my $msg = $self -> build_message ($err -> {id}, $err -> {key}, $err -> {name}, $err -> {msg}, $err -> {param}, $err -> {typeobj}, $pref, $epreq) ;
        push @msgs, $msg ;    
        }

    return \@msgs ;
    }



sub gather_script_code
    {
    my ($self, $frules, $pref, $epreq) = @_ ;

    my %param ;
    my $type ;
    my $typeobj ;
    my $i ;
    my $keys = [] ;
    my $key ;
    my $status ;
    my $name ;
    my $msg ;
    my $msgparam ;
    my $language = $pref -> {language} ;
    my $default_language = $pref -> {default_language} || 'en' ;
    my $scriptcode = $self -> {scriptcode} ||= {} ;
    my $script = '' ;
    my $form  = $self -> {form_id} ;

    while ($i < @$frules) 
        {
        my $arg ;
        my $method ;
        my $action = $frules -> [$i++] ;
        if (ref $action eq 'ARRAY')
            {
            $script .= $self -> gather_script_code ($action, $pref, $epreq) ;
            }
        elsif (ref $action eq 'CODE')
            {
            $i++ ;
            }
        elsif ($action =~ /^-(.*?)$/)
            {
            if ($1 eq 'key')
                {
                $key        = $frules->[$i++] ;
		$keys 	    = ref $key?$key:[$key] ;
                $type       = 'Default' ;
                $typeobj    = $self -> newtype ($type) ;
                $name       = undef ;
                $msg        = undef ;
                }
            if ($1 eq 'name')
                {
                $name    = $i++ ;
                }
            if ($1 eq 'msg')
                {
                $msg    = $i++ ;
                }
            elsif ($1 eq 'type')
                {
                $type    = $frules->[$i++] ;
                $typeobj = $self -> newtype ($type) ;
                $method  = 'getscript_validate' ;
                }
            else
                {
                $param{$1} = 1 ;
                }
            }
        else
            {
	    $method = 'getscript_' . $action ;                 
            $arg = $frules -> [$i++] ;
            }
        
        if ($method)
            {
            my $code ;
            my $ret ;
            my $k = "$type*$action" ;
            if (!exists ($scriptcode -> {$k}))
                {
                if ($typeobj -> can ($method))
                    {
                    ($code, $msgparam) = $typeobj -> $method ($arg, $pref) ;
                    $scriptcode -> {$k} = [$code, $msgparam] ;
                    }
                else
                    {
                    $code = '' ;
                    $scriptcode -> {$k} = '' ;
                    }
                }
            else
                {
                if ($scriptcode -> {$k})
                    {
                    $code     = $scriptcode -> {$k}[0] ;
                    $msgparam = $scriptcode -> {$k}[1] ;
                    }
                }   

            if ($code)
                {
                my $nametxt = $name?$frules -> [$name]:undef ;
                my $msgtxt  = $msg?$frules -> [$msg]:undef ;
                my $setmsg = '' ;
                if ($msgparam)
                    {
                    my $txt = $self -> build_message ($msgparam -> [0], $key, $nametxt, $msgtxt, $msgparam, $typeobj, $pref, $epreq) ;
                    $setmsg = "msgs[i++]='$txt';" 
                    }
                if (!ref $key)
                    {
                    $script .= "obj = document.$form.$key ; if (!($code)) { $setmsg " . ($param{fail}?'fail=1;break;':($param{cont}?'':'break;')) . "}\n" ;
                    }
                else
                    {
                    foreach my $k (@$keys)
                        {
                        $script .= "obj = document.$form.$k ; if (!($code)) {" ;
                        }
                     
                    $script .= " $setmsg " . ($param{fail}?'fail=1;break;':($param{cont}?'':'break;')) . "\n" ;
                    foreach my $k (@$keys)
                        {
                        $script .= "}" ;
                        }
                    }
                }
            }
        }
    if ($script)
        {
        return qq{
do {
$script 
} while (0) ; if (fail) break ;
} ;
        }
    return '' ;
    }


=pod

=head2 $epf -> get_script_code ([$pref])

Returns the script code necessary to do the client-side validation.
Put the result between <SCRIPT> and </SCRIPT> tags inside your page.
It will contain a function that is named C<epform_validate_<name_of_your_form>>
where <name_of_your_form> is replaced by the form named you have passed 
to L<new>. You should call this function in the C<onSubmit> of your form.
Example:

    <script>
    [+ do { local $escmode = 0 ; $epf -> get_script_code } +]
    </script>

    <form name="foo" action="POST" onSubmit="return epform_validate_foo()">
        ....
    </form>

=cut


sub get_script_code
    {
    my ($self, $pref, $epreq) = @_ ;

    $epreq ||= $Embperl::req ;
    $pref  ||= {} ;
    $pref -> {language} ||= $epreq -> param -> language if ($epreq) ;
    $pref -> {default_language} ||= $self -> {default_language} ;
    
    my $script ;
    $script = $self -> gather_script_code ($self->{frules}, $pref, $epreq) ;
    my $fname = $self -> {form_id} ;
    
    $fname =~ s/([^a-zA-Z0-9_])/_/g ;

    return qq{

function epform_validate_$fname()
    {
    var msgs = new Array ;
    var fail = 0 ;
    var i = 0 ;
    var obj ;

    do {
    $script ;
    }
    while (0) ;
    if (i)
        alert (msgs.join('\\n')) ;

    return !i ;
    }
} ;
    }



=head1 DATA STRUCTURES

The functions and methods expect the named data structures as follows:

=head2 RULES

The $rules array contains a list of tests to perform. Alls the given tests
are process sequenzially. You can group tests together, so when one test fails
the remaining of the same group are not processed.

  [
    [
    -key        => 'lang',
    -name       => 'Language'
    required    => 1,
    length_max  => 5,
    ],
    [
    -key        => 'from',
    -type       => 'Date',
    emptyok     => 1,
    ],

    -key        => ['foo', 'bar']
    required    => 1,
  ]   


All items starting with a dash are control elements, while all items
without a dash are tests to perform.

=over

=item -key

gives the key in the passed form data hash which should be tested. -key
is normaly the name given in the HTML name attribute within a form field.
C<-key> can also be a arrayref, in which case B<only one of> the given keys
must statisfy the following test to succeed.

=item -name

is a human readable name that should be used in error messages. Can be 
hash with multiple languages, e.g.

    -name => { 'en' => 'date', 'de' => 'Datum' }

=item -type

specfify to not use the standard tests, but the ones for a special type.
For example there is a type C<Number> which will replaces all the comparsions
by numeric ones instead of string comparisions. You may add your own types
by wrting a module that contains the necessary test and dropping it under
Embperl::Form::Validate::<Typename>. The -type directive also can verfiy
that the given data has a valid format for the type.

At the moment the only types that are available is C<Default> and C<Number>.
The first is the default and need not to be specified. If you are writing new 
type make sure to send them back, so they can be part of the next distribution.

=item -msg

Used to give messages which should be used when the test fails. This message
overrides the standart messages provided by Embperl::Form::Validate and
by Embperls message management. Can also be a hash with messages for multiple
languages.

=item -fail

stops further validation after the first error is found

=item -cont

continues validation in the same group, also a error was found

=item [arrayref]

you can place a arrayref with tests at any point in the rules list. The array will
be considered as a group and the default is the stop processing of a group as soon
as the first error is found and continue with processing with the next rules.

=back

The following test are currently defined:

=over

=item required

=item emptyok

=item length_min

=item length_max

=item length_eq

=item eq

=item ne

=item lt

=item gt

=item le

=item ge

=item matches_regex

=item matches_wildcard

=item must_only_contain

=item must_not_contain

=item must_contain_one_of

=back


=head2 PREFERENCES

The $pref hash (reference) contains information about a single form
request or submission, e.g. the browser version, which made the
request or submission and the language in which the error messages
should be returned. See also L<validate>


=head2 ERROR CODES

For a descriptions of the error codes, validate is returning see L<validate>


=head2 FDAT

See also L<Embperl>.

 my $fdat = { foo => 'foobar',
	      bar => 'baz', 
	      baz => 49, 
	      fnord => 1.2 };

=head1 Example

This example simply validates the form input when you hit submit.
If your input is correct, the form is redisplay with your input,
otherwise the error message is shown. If you turn off JavaScript
the validation is still done one the server-side. Any validation
for which no JavaScript validation is defined (like regex matches), 
only the server-side validation is performed.


    <html>
    <head>
    [-

    use Embperl::Form::Validate ;

    $epf = Embperl::Form::Validate -> new (
        [
            [
            -key => 'name',
            -name => 'Name',
            required => 1,
            length_min => 4,
            ],
            [
            -key => 'id',
            -name => 'Id',
            -type => 'Number',
            gt   => 0,
            lt   => 10,
            ],
            [
            -key => 'email',
            -msg => 'This is not a valid E-Mail address',
            must_contain_one_of => '@.',
            matches_regex => '..+@..+\\...+',
            length_min => 8,
            ],
            [
            -key => 'msg',
            -name => 'Message',
            emptyok => 1,
            length_min => 10,
            ]
        ]) ;

    if ($fdat{check})
        {
        $errors = $epf -> validate_messages ;
        }

    -]
    <script>
    [+ do { local $escmode = 0 ; $epf -> get_script_code } +]
    </script>
    </head>
    <body>

    <h1>Embperl Example - Input Form Validation</h1>

    [$if @$errors $]
        <h3>Please correct the following errors</h3>
        [$foreach $e (@$errors)$]
            <font color="red">[+ $e +]</font><br>
        [$endforeach$]
    [$else$]
        <h3>Please enter your data</h3>
    [$endif$]

    <form action="formvalidation.htm" method="GET" onSubmit="return epform_validate_forms_0_()">
      <table>
        <tr><td><b>Name</b></td> <td><input type="text" name="name"></td></tr>
        <tr><td><b>Id (1-9)</b></td> <td><input type="text" name="id"></td></tr>
        <tr><td><b>E-Mail</b></td> <td><input type="text" name="email"></td></tr>
        <tr><td><b>Message</b></td> <td><input type="text" name="msg"></td></tr>
        <tr><td colspan=2><input type="submit" name="check" value="send"></td></tr>
      </table>
    </form>


    <p><hr>

    <small>Embperl (c) 1997-2002 G.Richter / ecos gmbh <a href="http://www.ecos.de">www.ecos.de</a></small>

    </body>
    </html>


See also eg/x/formvalidation.htm


=head1 SEE ALSO

See also L<Embperl>.

=head1 AUTHOR

Axel Beckert (abe@ecos.de)
Gerald Richter (richter@dev.ecos.de)
