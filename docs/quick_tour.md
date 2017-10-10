This is a very brief look at Fun's main features, with examples but with
little background or explanation.  For a more in-depth account, see 
<a href="overview?article=leisurely_tour">A More Leisurely Tour of Fun</a>.   


###Fun Statements

Fun is a declarative language.  A Fun program is a specification 
of output.  A Fun program can be either a script or a web site; in the
latter case, Fun runs as a web server and the Fun program specifies web pages.

Fun programs consist of <b>definitions</b> and <b>constructions</b>.
A construction is a statement that potentially yields output.  There are several
kinds of constructions:

* Blocks (code or data)
* Control statements (loops, conditionals and redirections)
* Expressions
* Instantiations
* Literal values (strings, characters, booleans or numbers)

An example of each of the above, with comments:

    /* a data block */
    [| <h1>Hello, World.</h1> |]

    /* a conditional statement */
    if (say_hello) {
        hello_world;
    }

    /* an expression */
    ("<h1>Hello, " + user_name + ".</h1>");
    
    /* an instantiation */
    hello_world;
    
    /* literal values */
    "<h1>Hello, World.</h1>";
    true;
    3.14159;


###Definitions

A definition associates a name and optionally a type with a set of Fun statements, which
can be any combination of child definitions and constructions. The following is a 
definition of <code>hello</code>, of type <code>page</code>, which contains 
one definition and one construction:

    page hello {
        hello_world [|
            <h1>Hello, World.</h1>
        |]
    
        hello_world;
    }

Definitions take various forms.  In a <b>block definition</b> the body of the
definition is a block. Both definitions in the above example are block definitions.
The body of <code>hello</code> is a code block, delimited by <code>{</code> and 
<code>}</code>.  The body of the contained definition, <code>hello_world</code>, 
is a data block, delimited by <code>[|</code> and <code>|]</code>.  If a definition
contains exactly one construction and zero definitions another form is available,
an <b>element definition</b>.  Here is the definition of <code>hello_world</code>
rewritten in element form:

    hello_world = "<h1>Hello, World.</h1>"
    
There is also a shorthand form for an empty definition, i.e. a definition containing
zero definitions and zero constructions:

    hello_nobody [/]
    
And there is a special form for an abstract definition, which has no implementation
rather than an empty implementation, and therefore throws an error if you try to
instantiate it:
 
    abstract_hello [?]

Other forms exist for collection definitions.  They will be presented in a later
section.



###Collections

Fun supports two kinds of collections, <b>arrays</b> and <b>tables</b>. An array is an
ordered collection of elements; a table is an unordered collection of key-element pairs.

Here is an array definition:

    cities[] = [ "Baltimore", "Cincinnati", "Cleveland", "Pittsburgh" ]

Here is a table definition:

    teams{} = { "Baltimore": "Ravens", "Cincinnati": "Bengals", "Cleveland": "Browns", "Pittsburgh": "Steelers" }    

Here is 
