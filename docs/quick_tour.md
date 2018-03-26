##Quick Tour

In some ways, Fun is a regular programming language.  Much of the syntax looks and feels familiar to anyone conversant in a language in the C family (C, C++, C#, Java, and to a degree Javascript).  But the underlying model is quite different.

The following is a valid statement in Fun as well as most of the languages listed above:

    int x = 5;

In C (and C++, Java, etc.) the above statement defines a variable and sets the initial value.  In Fun, this statement defines a function called x that returns an integer.  

To understand Fun it helps to understand its conceptual underpinnings.  

###Fun Entities and Roles

Whereas most languages distinguish between types, functions, variables, etc., in Fun 
there is just one category of entity, and a range of roles an entity can play, depending
on circumstances:

* _Type_. The one role that every entity plays is type. If a definition is abstract, i.e. has no 
implementation, then type is the only role the defined entity can play.  The type role
occurs when the definition's name is specified as another definition's supertype.

* _Function_. If a definition is not abstract, then it can play the role of 
function.  Instantiating a definition is the equivalent of calling a function,
with the return value being the output specified by the definition's constructions.

* _Class_. If a definition contains child definitions, then it plays the role of class
and defines an inheritable and overridable interface.

* _Constructor_. If a definition contains an implementation, then it plays the role of a
constructor for the class it defines.  If the implementation contains a <code>super</code>,
<code>sub</code> or <code>next</code> keyword then this implementation can extend or be
extended by a superclass or subclass. 

* _Variable_. By default, when a definition is instantiated, the value is cached, and if the 
definition is referenced again in the same scope the cached value is used instead of constructing 
the value again. Such an entity can play the role of a variable.

* _Object_. A definition can specify that a child definition's value be cached along with its parent.
Such a definition can play the role of an object. 

