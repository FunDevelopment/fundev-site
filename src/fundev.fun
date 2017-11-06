/**  fundev.fun
 *
 *   Official Bento web site.
 *
 *
 **/

site fundev {

    /-------- global values -----------------------/

    global User_Table(utbl{}){} = utbl
    global Admin_User_Table(atbl{}){} = atbl

    /-------- initialization ----------------------/

    init {
        load_users("users", "admins");
    }
    
    session_init {
    }

    load_users(ufilename, afilename) {
        file user_file = file(ufilename)
        file admin_file = file(afilename)
        
        dynamic table_loader(str){} = table.parse(str)
        
        log("looking for user file " + user_file.canonical_path + " and admin file " + admin_file.canonical_path);
        
        if (!user_file.exists) {
            log("user file not found; aborting");
            redirect error("User file " + ufilename + " not found.")

        } else if (!admin_file.exists) {
            log("admin file not found; aborting");
            redirect error("Admin file " + afilename + " not found.")

        } else {
            eval(User_Table(table_loader(user_file.contents)));
            eval(Admin_User_Table(table_loader(admin_file.contents)));
        }
        
        if (!User_Table) {
            redirect error("Invalid user file " + ufilename + ".")
        }
        if (!Admin_User_Table) {
            redirect error("Invalid admin file " + afilename + ".")
        }
    }
    
    /-------- error handling ----------------------/

    component error(msg) {
        component_class = "error_msg"
        message = msg
        
        "Error: ";
        msg;
    }


    /-------- login status and information --------/

    this_username(u) = u

    boolean logged_in(boolean flag) = flag

    dynamic boolean authenticate(username, password) {
        if (User_Table[username] == password) {
            eval(this_username(: username :));
            true;
        } else {
            false;
        }
    }

    dynamic boolean authenticate_admin(username) {
        if (Admin_User_Table[username]) {
            true;
        } else {
            false;
        }
    }

    /-------- session status ---------------------/


    /-------- log file ---------------------------/

    static LOG_FILE = "fundev.log"

    /-------- parameter constants ----------------/
    
    static USERNAME_PARAM = "user"
    static PASSWORD_PARAM = "pass"

    /-------- styles and appearance constants -----/

    static SPLASH_LOGO = "images/fun-logo-280x120.png"
    static HEADER_LOGO = "images/fun-logo-140x60.png"
    static int HEADER_LOGO_WIDTH = 140
    static int HEADER_LOGO_HEIGHT = 60
    static int HEADER_MIN_WIDTH = 20
    static int MENU_WIDTH = 13
    static int CONTENT_MIN_WIDTH = 36

    color main_bgcolor = "#0022AA"

    /-------- common user interface ---------------/
    
    dynamic menu_item(base_page p) {
        base_page pg = p
        
        dynamic show(selected_page_name) {
            if (selected_page_name == pg.type) {
                [| <span class="menu_item selected_item"> |]
                pg.label;
                [| </span> |]
            } else { 
                [| <a class="menu_item unselected_item" href="/ |]
                pg.type;
                [| "> |]
                pg.label;
                [| </a> |]
            }
        }    
    }    

    dynamic menu_item[] main_menu = [ menu_item(index), menu_item(overview), menu_item(docs), menu_item(download) ] // , menu_item(examples) ]


    media_queries {
    
        int narrow_max = HEADER_MIN_WIDTH + MENU_WIDTH   
      
      
        /--- narrow ---/
          
        [| @media (max-width: {= narrow_max; =}rem) {
               .page_wrapper {
                   width: 100%;
                   padding: 0;
               }
               .header_bar {
                   width: 100%;
               }
               .menu_box {
                   width: 100%;
               }
               .content_box {
                   width: 96%;
                   padding: 2%;
               }
               .content_body ul {
                   padding-left: 1rem;
               }
           }
        |]
        
    
        /--- wide ---/    
    
        [| @media (min-width: {= narrow_max; =}rem) {
               .page_wrapper {
                   width: 100%;
                   padding: 0;
               }
               .header_bar {
                   width: 100%;
               }
               .menu_box {
                   float: left;
                   width: {= MENU_WIDTH; =}rem;
               }
               .content_box {
                   margin-left: {= MENU_WIDTH; =}rem;
               }
           }
        |]
    }


    /-------- base page ---------------------------/

    page(*) base_page(params{}) {
        boolean ajax_enabled = true
    
        boolean needs_login [?]    
        boolean needs_admin = false
        
        boolean show_menu = true
        
        label [?]
        
        style [| 
            html, body { 
                width: 100%;
                height: 100%;
                margin: 0 0 0 0;
                background-color: {= main_bgcolor; =};
                font-family: "Arial", sans-serif;
            }
            
            code, pre {
                font-family: "Lucida Console", Monaco, monospace
            }

            .page_wrapper {
                background-color: #D5DEE7;
            }
            
            .header_bar {
                background-color: black;
                color: white;
                text-align: center;
                padding: 0.75rem 0;
                margin: 0;
            }

            .header_bar img {
                display: block;
                width: {= HEADER_LOGO_WIDTH; =}px;
                height: {= HEADER_LOGO_HEIGHT; =}px;
                margin-left: auto;
                margin-right: auto;
            }

            .menu_box {
                background-color: #443322;
                color: #EEEEEE;
                margin: 0;
                padding: 0.5rem 0;
            }

            .menu_box li {
                display: block;
                padding: 0.5rem 1rem;
            }
            
            .menu_box ul {
                padding: 0;
                margin: 0;
            }
           
            .menu_box a {
                text-decoration: none;
            }    
            
            .menu_item {
                font-weight: bold;
                font-size: 1.2rem;
                font-family: "Arial", sans-serif;
            }

            .selected_item {
                color: #FFFFAA;
            }

            .unselected_item {
                color: #D5DEE7;
            }
            
            .menu_box a:hover {
                color: #FFFFFF;
            }
            
            .content_box {
                background-color: white;
                max-width: 49rem;
            }

            .content_body {
                color: black;
                padding: 1rem 1.5rem;
                font-family: "Lucida Bright", Georgia, serif;
                font-size: 0.95rem;
                line-height: 1.5;
            }
            
            .content_body li {
                padding-bottom: 1rem;
            }

            .content_body ul {
                list-style-type: square;
            }
            
            .content_body pre {
                background-color: #DEE3EE;
                color: #0000CC; 
                margin: 0 1rem 1rem 0;
                padding: 1rem;
                font-size: 0.9rem;
            }

            .content_body code {
                color: #0000CC; 
                font-size: 0.9rem;
            }

            .centered_container {
                width: 100%;
                height: 100%;
                margin: 0 0 0 0;
                position: relative;
            }
            
            .centered_high_box {
                position: absolute;
                left: 50%;
                top: 38%;
                margin-right: -50%;
                transform: translate(-50%, -50%);
                width: 36rem;
            }
            
            .centered_div  {
                width: 100%;
                text-align: center;
             }
            
           .labeled_edit {
                text-align: center;
                font-weight: bold;
                padding:0.5rem;
            }

            #splash_image_holder img {
                display: block;
                margin-left: auto;
                margin-right: auto;
            }
            
            #login_splash_box {
                color: white;
                font-size: 1rem;
                font-weight: bold;
                font-family: "Arial", sans-serif;
            }
            
            #login_button {
                width: 10rem;
            }
            
            #ok_button {
                width: 10rem;
            }

            #cancel_button {
                width: 10rem;
            }
            
            #tc_container {
                width: 100%;
                height: 100%;
            }
            
            #tc {
                width: 100%;
                height: 100%;
            }
            
            h2 {
                margin: 0;
                font-size: 1.1rem;
                line-height: 1;
                padding-top: 1.5rem;
                color: #1100DD;
            }
            
            {= media_queries; =}
        |]        
        
        component splash_image_holder(img_url) {
            id = "splash_image_holder"
            [| <img src="{= img_url; =}"> |]
        }
        
        dynamic component login_splash_box {
            id = "login_splash_box"
            component_class = "centered_container"
            
            [| <div class="centered_high_box"> |]
            splash_image_holder(SPLASH_LOGO);
            login_component(page_name);
            [| </div> |]
        }
        
        component header_bar {
            component_class = "header_bar"
            
            [| <img src="{= HEADER_LOGO; =}">
               a fun(ctional) programming language                       
            |]
        }
        
        dynamic component menu_box(menu_item[] menu_items) {
            component_class = "menu_box"

            [| <ul> |]
            for menu_item m in menu_items [|
                <li>{= m.show(page_name); =}</li>
            |]
            [| </ul> |]
        }

        base_page this_page = owner
        page_name = owner.type

        log("constructing base_page, page_name is " + page_name);
        if (needs_login && !logged_in) {
            log("needs login");
            login_splash_box;

        } else if (!needs_admin || authenticate_admin(this_username)) {
            log("we're good");
            [| <div class="page_wrapper"> |]
            header_bar;
            if (show_menu) {
                menu_box(main_menu);
            }
            [| <div class="content_box"><div class="content_body"> |] 
            sub;
            [| </div></div></div> |]

        } else {
            log("access to " + page_name + " by " + this_username + " denied");
            "fail";
        }   
    
    }


    /-------- login mechanics ---------------------/

    public dynamic component login_component(params{}),(page_name) {
        goto_page = page_name ? page_name : goto_param
        goto_param {= with (params) {= params["goto"]; =} else [| index |] =}
        component this_component = owner
        field_ids[] = [ USERNAME_PARAM, PASSWORD_PARAM ]
        submit_params{} = { "goto": goto_page } 
        
        
        log(" login component params: " + params);
        log(" login submit params: " + submit_params);
        
        if (params[USERNAME_PARAM]) {
            log("trying to authenticate " + params[USERNAME_PARAM]);
            eval(logged_in(: authenticate(params[USERNAME_PARAM], params[PASSWORD_PARAM]) :)); 
        }
        if (logged_in) {
            log("logged in, redirecting to " + goto_page);
            redirect (goto_page)

        } else {
            [| <div class="centered_div"><table><tr> |]
            if (params[USERNAME_PARAM]) [|
                <td colspan="2" style="background-color: white; color: red; text-align: center;">Login unsuccessful.  Try again.</td>
            |] else [|
                <td colospan="2">&nbsp;</td>
            |]
            [| </tr><tr><td><table><tr><td>Username:</td><td> |]
            textedit(USERNAME_PARAM, this_username, 20);
            [| </td></tr><tr><td>Password:</td><td> |]
            passwordedit(PASSWORD_PARAM, "", 20);
            [| </td></tr></table> |]
            [| </td><td> |]
            submit_button("login", "Login", "/" + this_component.id, field_ids, submit_params);
            [| </td></tr></table></div> |]
        }
        
    }    


    /-------- home page ---------------------------/

    public base_page(*) index(params{}) {
        boolean needs_login = false    

        label = "Home"
        
        what_is_fun;
    }  

    what_is_fun {
        [| <h2>Welcome to Fun</h2>
           
           <p>Fun is a new programming language that intends to be more expressive than languages
           that have come before, while at the same time simpler, just as a poem can be more
           expressive yet simpler than a prose composition that says the same thing.</p>
           
           <h3>Poetic Programming</h3>
           
           <p>Fun is intended for a style of programming that approaches the task more like
           writing poems than prose.  Poetry accomplishes this by using fewer words, each
           carrying more meaning, arranged into a melodious and rhythmic whole.  Fun embodies
           the same values: economy, richness of meaning and beauty of form.</p>
           
           <p><b>Economy:</b> Fun is economical by having only one kind of entity.  Other languages have
           distinct syntax for creating and using various kinds of entities such as classes,
           types, functions, variables, objects and interfaces.  Fun doesn't have all these
           syntactic mechanisms because in Fun classes, types, functions and so forth are roles,
           not entities, and roles can be inferred from context.  This works because humans 
           happen to be very good at inferring from context.</p>
           
           <p><b>Richness of meaning:</b> Fun achieves this through an especially flexible and 
           intuitive approach to object-oriented programming.  Fun's inheritance model is deeply 
           and seemlessly embedded into the language, and is the opposite of rigid.  Inheritance
           relationships aren't limited to top-down, hierarchical style that is the norm;
           multiple, lateral (i.e. aspect-oriented) and inside-out inheritance are supported
           as well.</p>
           
           <p><b>Beauty of form:</b>  Fun is declarative.  A Fun program is not a set of
           instructions with output being a side effect; a Fun program is a representation of
           the output.  
           
           <p>Finally, Fun is fun!  Fun was designed by a programmer for programmers in order
           to be enjoyable.  Have Fun!/p>
        |]
    }
 
    more_what_is_fun {
        [|
           <ul>
           <li><b>Object-oriented</b>: Fun has a rich set of OO features, including some unique to
           Fun.  For example, Fun has a <code>sub</code> keyword that works like the <code>super</code> 
           keyword in Java, C++ and other languages, only in reverse: it allows a superclass 
           to invoke its subclass.  Instead of the subclass invoking the superclass   This turns 
           out to be very useful when defining a class hierarchy for things like web pages or message
           packets, where the stuff on the outside is created by the superclass and the stuff
           on the inside by the subclass.</li> 
           <li><b>Web-oriented</b>: Fun has a built-in web server, and a program doesn't have to do
           anything special to be a web site.</li>
           <li><b>Automated state management</b>: Fun is at heart a functional language and has no 
           assignment operator.  But unlike other functional languages, it's not hard to manage state 
           in Fun; in fact it happens automatically via caching, which is built in to the language 
           and can provide whatever stateful behavior a program might need.</li>
           <li><b>Flexible Typing</b>: Fun supports a hybrid static/dynamic type model.  Static
           typing is supported but not required.</li>
           <li><b>Code-Data Mixing</b>: like a templating language, Fun allows code to be embedded
           in data; Fun also allows data to be embedded in code, with no limit to the nesting.</li>
           </ul> 
           
      |]
    }

    cutting_room_floor [|
    

           Bento's object modeling features are both rich and concise.  The richness comes from
           Bento's support for multiple inheritance as well as multiple modes of inheritance -- interface
           (inheriting functions), implementation (inheriting construction logic), override (inheriting 
           from the type being overridden) and lateral (mixing in construction logic from an interface).
           The conciseness flows from the object lifecycle paradigm that allows object hierarchies to be
           defined without the need for syntactic buttressing (see next bullet point).
           
           <li><strong>One namespace, multiple layers of meaning.</strong> In Bento, types, classes, 
           functions, objects and variables are not different kinds of entities living in distinct 
           namespaces.  Rather, they are different roles that a Bento entity can play, depending on
           the context.  This reduces both the number of entities needed (because entities can play 
           multiple roles) and the syntax neeed to declare them (because it isn't necessary to specify
           the category of entity).
           </li>

           <p>Templating languages are popular in web development
           because the template paradigm of code embedded in data efficiently captures the typical 
           structure of actual web pages: static content with embedded bits of dynamic content.  Bento
           goes further.  Not only does it support embedding code in data, like a templating language,
           it also supports embedding data in code, which can be more efficient when the content
           is mostly dynamic with some embedded static bits.    

           <li><strong>Web-oriented.</strong> Every Bento program is automatically a web site or service. 
           More precisely, a Bento program defines a system of responses which the Bento runtime engine 
           uses to respond to HTTP requests, either from an external server or from the runtime engine's 
           own embedded Jetty HTTP server.  The immediate benefit is freeing the programmer from having
           to handle connections or protocol details.  
           </li>
           <p>Having a built-in web server, as convenient as it is, is a fairly superficial feature.  The 
           real difference lies at the level of interaction between language and human (user or programmer).
           The standard paradgim of language-human interaction for languages of all kinds – functional, 
           procedural, object-oriented – is the command paradigm.  In this paradigm, a program is a command.
           Programs are invoked and run till completion or interruption.  The distinguishing feature of 
           languages which follow the command paradigm is a singleton entry point.  The rules for the name, 
           parameters and other details vary from language to language, but whatever it's called there is
           a particular point in the code where the program begins.
           </p><p>
           To be web-oriented, in contrast, is to be driven by request, not command.  A program in a language 
           that follows the request paradigm has multiple entry points.  There is no guarantee that any 
           particular entry point will be executed first, or ever, and the completion of a request does not in 
           general imply completion of the program.   
           </p><p>
           Neither paradigm is inherently superior to the other, and neither precludes any interactive 
           possibilities.  You can in fact implement any kind of interaction model in either language.    The 
           significance of the interaction paradigm is that it determines which kind of interaction model 
           comes naturally or automatically when using a language, and which must be devised and engineered.
           </p>

    
           <h2>Simple and familiar, yet radically new</h2>
           <p>Much of Bento's syntax will be recognizable to programmers familiar with mainstream
           languages such as C, Java, Python and Javascript.  (An obvious exception is the set of 
           delimiters Bento uses, which are purposefully unusual so that embedded Bento code can be 
           safely distinguished from Javascript or other non-Bento code that can appear in Bento data 
           blocks.)  This allows programmers to leverage their existing knowledge and experience when
           learning to use Bento.  However, while the syntax may be functionally similar, the 
           actual meaning is different due to the underlying paradigm.
           </p><p>
           Consider the following Bento snippet:</p><pre>[``

    int x = 23
    
    log("The value of x is " + x);

           ``]</pre><p>The first line looks very much like an assignment, and indeed has the same ultimate
           effect; the second line will cause "The value of x is 23" to appear on the console.  But in
           actuality the first line is a definition, not an assignment: x is a function that returns 23,
           not a memory location which is assigned the value 23.  This syntactic similarity allows Bento
           to support lazy evaluation and other benefits of declarative programming without the steep 
           learning curve typical of functional languages.  
           </p>
           
           Conceptually, a Bento entity follows a lifecycle. It begins as a bare type.
           If the entity has children, then the type becomes an interface.  If the entity is instantiated,
           it becomes a function; if that instantiated value is cached (the default in Bento), it becomes
           a variable; if the entity's children are instantiated and cached it becomes a full-fledged
           object.
                      
           <h2>Why use Bento?</h2>
           <p>
           </p>
    
    |]
      
    /-------- overview page --------------------------/

    current_article(article_key) = article_key


    /** The list of available articles.  This is the canonical source of article
     *  availability; other sources of article information, such as the article
     *  lookup table, are constructed from this list.
     **/
    global article[] all_articles = [ quick_tour_article, leisurely_tour_article, backstory_article ]

    /** Lookup table for articles.  Keyed on article key. **/
    global article{} article_table = { for article a in all_articles { a.key: a } }
    
    global article overview_article(doc_name, article_name) {
        title = article_name
        key = doc_name
        content = include_content(doc_name)
    }

    global article quick_tour_article = overview_article("quick_tour", "A Brief Tour of Fun");
    global article leisurely_tour_article = overview_article("leisurely_tour", "A More Leisurely Tour of Fun");
    global article backstory_article = overview_article("backstory", "Fun Backstory")

   
    public base_page(*) overview(params{}) {
        boolean needs_login = false    

        label = "A Tour of Fun"

        article_param = params["article"]
        
        static DEFAULT_ARTICLE = "quick_tour"

        if (article_param) {
            eval(current_article(: article_param :));
        } else if (!current_article) {
            eval(current_article(: DEFAULT_ARTICLE :));
        }
        log("current article is " + current_article); 
        
        show_article(article_table[current_article]); 

    }

    dynamic include_content(doc_name) {
        include_file(main_site.filepath + "/docs/" + doc_name + ".md");
    }



    /-------- docs page ---------------------------/

    public base_page(*) docs(params{}) {
        boolean needs_login = false    

        label = "Documentation"
        
        [| <h1>Fun Documentation</h1> |]
        
        
    }
    
    /-------- download page -----------------------/

    public base_page(*) download(params{}) {
        boolean needs_login = false    

        label = "Download"
    }
    
    /-------- examples page -----------------------/

    public base_page(*) examples(params{}) {
        boolean needs_login = false    

        label = "Examples"
    }
    
    public base_page show_logs {
        boolean needs_login = true
        boolean needs_admin = true

        [| <h3>fundev.log</h3><pre> |]
        include_file(LOG_FILE);
        [| </pre> |]
    }


    /---- pseudofiles ----/

    js {
        lib {
            three {
                public js {
                    include_file("lib/three.js");
                }
            }
            stats {
                public js {
                    include_file("../../3p/lib/stats.min.js");
                }
            }
        }
    }


    /-------- error page --------------------------/
    public page error_page(request r) {
        boolean needs_login = false    
        title = [| Error |]
        color bgcolor = "#EEDDAA"

        error_div(r);        
    }    

}
