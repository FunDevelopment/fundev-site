##Fun Backstory

###A templating language with super powers

For a typical web site, the composition of data and code is achieved by using a 
templating language, of which there are many in wide use.  The one thing they have 
in common, other than the ability to embed code in data, is limited ambition.  They 
aim to provide templating, and nothing else.

Fun is a direct descendant of a language called Bento, which began in 2002 
as a project to expand the scope of templating very modestly, by supporting 
object-oriented templating as a way to solve the problem of reuse.  In a web site of 
any complexity, reuse of code, including templating code, is critical.  Each page is a 
combination of features, some that are standard throughout the site, some that are 
specific to particular parts of the site, some that are similar but not identical to 
features elsewhere, and some that appear on one page only.  The difference in cost, 
effort, and most importantly number of defects between reusing the same code for a 
feature everywhere and maintaining a separate copy for each case is substantial.   

With conventional templating approaches, achieving optimal reuse is very complicated 
and generally requires scaffolding of some sort written in a more robust language.  A 
templating language with inheritance and polymorphism, on the other hand, could absorb 
much of this organizational effort into the templates themselves.  Web pages could be
the concrete subclasses in a hierarchy of page classes and abstract interfaces, letting
the superclasses handle the common parts and worrying only about the parts unique to 
themselves.  Moreover, the recurring parts of pages -- menus, headers, widgets, etc. --
could themselves be abstracted, with the implementations living in independent, fully
reusable libraries.

The first iteration of Bento was exactly this.  And it worked.  Once it's possible to 
factor out various parts of pages into base classes and component libraries, the pages 
become much smaller and easier to understand.  At the same time, the scaffolding code 
in the surrounding application diminished and became simpler.

At that point the experiment veered into uncharted territory.  Bento by now had sufficient 
features to do general-purpose programming.  This made it possible to move logic from the 
surrounding Java code into Bento.  And it turned out that doing so had concrete benefits.

For applications that follow the Model-View-Controller (MVC) pattern, templates are closely 
associated with views.  Views handle presentation, leaving business logic
to other parts of the application.  This separation is vital for achieving a maintainable
application.  
