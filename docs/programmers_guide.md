This is a very brief look at Fun's main features, with examples but with
little background or explanation.  For a more in-depth account, see
<a href="overview?article=leisurely_tour">A More Leisurely Tour of Fun</a>.   


###Statements

Fun is a declarative language.  A Fun program specifies output.  Typically
a Fun program is run as a web site, in which case the output consists of
web pages.

A Fun program is comprised of <b>definitions</b> and <b>constructions</b>.  A
definition associates a name with a (possibly empty) set of constructions and
child definitions.  A construction is a statement that potentially yields 
output.  There are several kinds of constructions:

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
one construction:

    page hello {
        "Hello, World";
    }
 
Fun is declarative, not imperative, and what a definition defines is output, not commands.  So
instead of a command to output "Hello, World", something like <code>print "Hello, World"</code>,
all you need is "Hello, World".

This definition is the equivalent of the previous one, but has a child definition as well as
a construction:

    page hello {
        say_hello = "Hello, World."
    
        say_hello;
    }

The child definition here looks like an assignment, but is actually just a shorthand form of
definition available when the definition contains exactly one construction and zero child
definitions.  The following two definitions are exactly equivalent:

        say_hello = "Hello, World."
    
        say_hello {
            "Hello, World.";
        }

A third definition form uses a data block instead of a code block or a single
construction.  The following definition is exactly equivalent to the two preceding
definitions (in a standard data block leading and trailing whitespace is trimmed):

        say_hello [|
            Hello, World.
        |]

If you actually try to compile the above three definitions together at once the
compile will fail.  You can define a name only once in any particular scope.  But you can
define the name as often as you like as long as each is in a different scope.  The following
will compile:

    test_definition_options {
    
        element {
            say_hello = "Hello, World."
        }
        
        code_block {
            say_hello {
                "Hello, World.";
            }
        }
        
        data_block {
            say_hello [|
                Hello, World.
            |]
        }
        
        if (element.say_hello == code_block.say_hello
              && code_block.say_hello == data_block.say_hello) [|
              
             Ok

        |] else [|

             <span style='color:red'>Fail</span>
        |]
        
    }

###Types

In Fun, every definition defines a type by that name.  This type can then be used as
the basis for typed definitions.  

A typed definition behaves differently from an untyped definition in several ways,
including:

* A typed definition has access to all child definitions of its type (interface inheritance).
* A typed definition has access to its type's constructions (implementation inheritance).
* An instance of a typed definition can match a parameter of that type when passed as an
argument to an overloaded definition.
* An instance of a typed definition can be detected as an instance of that type in
a <code>isa</code> expression. 

A definition is typed if the definition name is preceded by a type name.  The type name can
be the name of another definition or a primitive type (<code>int</code>, <code>boolean</code>,
<code>string</code>, etc.).  The following definitions are all typed:

    int x = 5
    
    page hello_page {
        "Hello.";
    }
    
    javascript hello_alert [|
        window.alert("Hello.");
    |]

    boolean this_is_true = (hello_alert isa javascript)

The types declared by the above definitions include two primitive types (<code>int</code> and
<code>boolean</code> and two defined types (<code>page</code> and <code>javascript</code>).  The
latter two types are defined in the standard fun library.



###Programs

A Fun program is typically a web site, which is a definition of type <code>site</code> such as
the following:

    site hello_world {
    
        public page index = hello
        
        page hello {
            say_hello = "Hello, World."
     
            say_hello;
        }
    }

Note the use of the <code>public</code> keyword; this indicates that the associated definition
is externally accessible.

Definitions of type <code>site</code> have several special properties:

* They can be served as web sites.
* They can contain site-level directives (<code>adopt</code> and <code>extern</code>) that enable access
to Fun and non-Fun code outside of the site.
* They cannot directly contain constructions (though they can contain definitions that contain constructions).
* They can be split across multiple files.



    script hello_world {
        public main = "Hello, World."
    }





    
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
