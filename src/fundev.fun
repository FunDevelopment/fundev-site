/**  fundev.fun
 *
 *   Official web site for the Fun programming language.
 *
 *
 **/

site fundev {

    adopt three

    /-------- global values -----------------------/

    global User_Table(utbl{}){} = utbl
    global Admin_User_Table(atbl{}){} = atbl

    /-------- initialization ----------------------/

    init {
        load_users("users", "admins");
        three.set_logging_level(three.LOG_DEBUG);
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

    static SPLASH_LOGO = "images/fun-logo-blue-bg-280x120.png"
    static HEADER_LOGO = "images/fun-logo-blue-bg-140x60.png"
    static int HEADER_LOGO_WIDTH = 140
    static int HEADER_LOGO_HEIGHT = 60
    static int HEADER_MIN_WIDTH = 20
    static int MENU_WIDTH = 13
    static int CONTENT_MIN_WIDTH = 36

    color main_bgcolor = "white"

    /-------- common user interface ---------------/

    menu_style [|    
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
        
        .submenu_box {
            padding-left: 1.2rem;    
        }

        .menu_item {
            font-weight: bold;
            font-size: 1.2rem;
            font-family: "Arial", sans-serif;
        }

        .submenu_item {
            font-weight: bold;
            font-size: 1rem;
            font-family: "Arial", sans-serif;
        }
        
        .submenu_header {
            font-weight: bold;
            font-size: 1.2rem;
            font-family: "Arial", sans-serif;
            color: #D5D5D7;
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
    |]

    dynamic component menu_box(selected_page, menu_item[] menu_items),
                              (selected_page, menu_item[] menu_items, boolean is_submenu) {

        component_class = (is_submenu ? "submenu_box" : "menu_box")

        [| <ul> |]
        for menu_item m in menu_items {
            [| <li> |]
            m.show(selected_page);
            [| </li> |]
        }
        [| </ul> |]
    }

    dynamic menu_item(base_page p) {
        base_page pg = p
        item_class = "menu_item"
        
        dynamic show(selected_page_name) {
            if (selected_page_name == pg.type) {
                [| <span class="{= item_class; =} selected_item"> |]
                pg.label;
                [| </span> |]
            } else { 
                [| <a class="{= item_class; =} unselected_item" href="/ |]
                pg.type;
                [| "> |]
                pg.label;
                [| </a> |]
            }
        }    
    }    

    dynamic menu_item(*) submenu(label, menu_item[] sub_items) {
        item_class = "submenu"
        
        menu_item[] submenu_items = sub_items

        dynamic show(selected_page_name) {
            [| <span class="submenu_header"> |]
            label;
            [| </span> |]
            menu_box(selected_page_name, submenu_items, true);
        }
    }


    dynamic menu_item[] main_menu = [ menu_item(index),
                                      submenu("A Tour of Fun", [
                                          menu_item(quick_tour_page),
                                          menu_item(leisurely_tour_page),
                                          menu_item(backstory_page)
                                      ]),
                                      menu_item(docs),
                                      menu_item(download) ]


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
               .side_box {
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
               .side_box {
                   position: fixed;
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
        
        label [?]
        
        scene bg_scene [?]
        
        style {
            main_style;
            menu_style;
        }
        
        main_style [| 
            html, body { 
                height: 100%;
                margin: 0 0 0 0;
                background-color: {= main_bgcolor; =};
                font-family: "Arial", sans-serif;
            }
            
            code, pre {
                font-family: "Lucida Console", Monaco, monospace
            }

            .page_wrapper {
                padding: 1rem;
                background-color: #EAEAEF;
                width: 100%;
                min-height: 100%;
                overflow: hidden;
            }
            
            .viewer_container {
                width: 100%;
                height: 100%;
            }
            
            .header_bar {
                background-color: #1701BC;
                color: white;
                text-align: left;
                padding: 0.75rem 1rem;
                margin: 0;
                width: 11rem;
            }

            .header_bar img {
                display: block;
                width: {= HEADER_LOGO_WIDTH; =}px;
                height: {= HEADER_LOGO_HEIGHT; =}px;
            }

            .side_box {
                margin: 0;
                padding: 0;
                z-index: 1000;
            }
            
            .content_box {
                background-color: white;
                max-width: 49rem;
            }

            .content_header {
                position: fixed;
                height: {= HEADER_LOGO_HEIGHT; =}px;
                background-color: #D5DEE7;
            }
                
            .content_main_points li {
                display: block;
                padding: 0.5rem 1rem;
            }
        
            .content_main_points ul {
                padding: 0;
                margin: 0;
                list-style-type: square;
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

            .content_panel {
                width: 40rem;
                padding: 1.5rem;
                color: #88FFAA;
                z-index: 100;
                background: rgba(31, 31, 31, 0.75);
            }

            .main_point {
                color: saddlebrown;
                background-color: white;
                font-size: 1.25rem;
                padding: 0.25rem;
                display: block;
                list-style-type: square;
            }
            
            .main_point_body {
                overflow: hidden;
                transition: transform 0.67s ease-out, height 0.67s ease-out;
            }

            .active, .main_point:hover {
                background-color: gold; 
            }
            
            .point_closed {
                height: 0;
            }

            .point_open {
                height: 100%;
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
                font-size: 1.5rem;
                line-height: 1;
                color: blue;
                font-family: "Courier", monospace;
                font-weight: bold;
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
        
        /--------------------/
        /---- the canvas ----/
    
        three_component(*) tc(scene s),(params{}) {
            style  [| position: absolute; top: 0; left: 0;
                      width: 100%; height: 100%; 
                      margin: 0; padding: 0;
                      z-index: 0;
                   |]

            canvas_id = "tc"
            
        }        

        component header_bar {
            component_class = "header_bar"
            
            [| <img src="{= HEADER_LOGO; =}"> |]
        }
        

        base_page this_page = owner
        page_name = owner.type

        log("constructing base_page, page_name is " + page_name);
        if (needs_login && !logged_in) {
            log("needs login");
            login_splash_box;

        } else if (!needs_admin || authenticate_admin(this_username)) {
            log("we're good");
            [| <div class="page_wrapper"><div class="side_box"> |]
            header_bar;
            menu_box(page_name, main_menu);
            [| 
               </div><div class="content_box"><div class="content_body">
            |] 
            sub;
            [| </div></div> |]
            with (bg_scene) {
                tc(bg_scene);
            }
            [| </div> |] 

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

        static javascript toggle_point [|
            this.classList.toggle('point_active');
            var div = this.nextElementSibling;
            if (div.classList.contains('point_open')) {
                div.classList.remove('point_open');
                collapseElement(div);
                div.classList.add('point_closed');
            } else {
                div.classList.remove('panel_closed');
                expandElement(div);
                div.classList.add('point_open');
            }
        |]

        static javascript accordion_functions [|
            function collapseElement(element) {
                element.style.height = 0 + 'px';
/*****
                var height = element.scrollHeight;
                var transition = element.style.transition;
                element.style.transition = '';
                requestAnimationFrame(function() {
                    element.style.height = height + 'px';
                    requestAnimationFrame(function() {
                        element.style.transition = transition;
                        element.style.height = 0 + 'px';
                    });
                });
*****/
            }

            function expandElement(element) {
                var height = element.scrollHeight;
                element.style.height = height + 'px';
                element.addEventListener('transitionend', function handle_end(e) {
                    element.removeEventListener('transitionend', handle_end);
                    element.style.height = null;
                });

            }
        |]
        

        dynamic main_point(pt_label, pt_body) {
            [| <li class="main_point" onclick="{= toggle_point; =}"> |]
            pt_label;
            [| </li><div class="main_point_body point_closed"> |]
            pt_body;
            [| </div> |]
        }


        [| <div class="main_panel content_main_points">
           <h2>The Fun Programming Language is</h2>
           <ul>
        |]
        
        main_point("Simple and Expressive", expressive_and_simple);
        main_point("Declarative and Flexibly Functional", declarative);
        main_point("Object-Oriented", object_oriented);
        main_point("Web-Oriented", web_oriented);
        main_point("Automated State Management", automated_state_management);
        main_point("Fun is Fun!", fun_is_fun);

        [| </ul></div><script> |]
        
        accordion_functions;
        
        [| </script> |]
    }  

    public base_page(*) index3D(params{}) {
        boolean needs_login = false    

        label = "Home"
        
        /---------------------/
        /----  the scene  ----/

        scene bg_scene {
            phong_material blue_material {
                undecorated color = 0x3333CC
                int side = BACK_SIDE
                float opacity = 0.55
                boolean transparent = true
            }
            
            mesh(sphere_geometry(100, 64, 64), blue_material) blue_sphere {
                position pos = position(0, 0, 0)
                on_drag {
                    log("blue_sphere.on_drag called");
                }
            }

            phong_material sky_dome_material {
                int side = BACK_SIDE
                float opacity = 0.5
                boolean transparent = true
                undecorated map = load_texture("images/sky_fyros_dusk_fair.png")
            }
            
            mesh(sphere_geometry(800, 64, 32), sky_dome_material) sky_dome {
                position pos = position(0, -690, 0)
                rotation rot = rotation(0, 0, 0.5 * 3.14159)
            }

            point_light(0xAAAAAA) soft_light {
                position pos = position(0, 12, 40)
            }

            three_object[] objs = [
                sky_dome,
                soft_light
            ]
            
            javascript next_frame {
                sky_dome.rotate(0, 0.00005, 0);
            }
        }
      


        [| 
           <div class="content_panel" style="position: relative; top: 1rem; left: 2rem;">
           <h2>The Fun Programming Language</h2>
        |]
        what_is_fun;
        [| </div> |] 
    }  

    expressive_and_simple [|
        <p>Fun is an open source programming language designed to be simple and 
        expressive.  Language designers sometimes see this as a tradeoff; you can have 
        more features and be more expressive, or you can have fewer features and be 
        simpler.  Fun shows that with the right design you can 
        be more expressive and simpler at the same time.</p>
       
        <p>Fun's secret for achieving expressiveness and simplicity at the same time is 
        a design philosophy called <b>Poetic Programming</b>.  Poetic Programming
        asserts that the same qualities that allow poetry to be simultaneously more 
        expressive and simpler than prose can work for programming as well: economy
        (use fewer words and shorter phrases), richness (use words and phrases that 
        have multiple layers of meaning) and beauty (arrange the words and phrases 
        into a melodious, rhythmic and visually pleasing whole).  These are the 
        principles that have guided the design of Fun.</p>
    |]
    
    declarative [|
        <p>A Fun program is a description of output, not a list of commands.  Fun is not
        strictly functional, because this description is not limited to functions -- it
        can also include procedural-style control structures (conditionals and loops)
        and template-style embedded data (HTML, CSS and Javascript).  Another departure
        from strict functional programming is Fun's automated state management.</p>
    |]
    
    object_oriented [|
        <p>Fun has a rich set of OO features, including some unique to Fun.  For example,
        Fun has a <code>sub</code> keyword that works like the <code>super</code> keyword 
        in Java, C++ and other languages, only in reverse: it allows a superclass to 
        invoke its subclass.  Instead of the subclass invoking the superclass   This turns 
        out to be very useful when defining a class hierarchy for things like web pages or
        message packets, where the stuff on the outside is created by the superclass and the
        stuff on the inside by the subclass.</p>
    |]
    
    web_oriented [|
        <p>Fun has a built-in web server, and a program doesn't have to do anything special
        to be a web site.  Moreover, Fun allows free mixing of code and data, making it an
        excellent templating language.</p>
    |]
    
    automated_state_management [|
        <p>As a declarative, flex-functional language, Fun has no variables and no assignment
        operator.  But Fun does support state by building caching into the language.  By default,
        if a function is referenced multiple times in a local scope, only the first reference
        results in a function call; the return value is cached, and subsequent references make
        use of the cached value.</p>
    |]
        
    fun_is_fun [|
        <p>Fun was designed by a programmer in order to be enjoyable to program in.  And it
        is.  Have Fun!</p>
    |]
    

    what_is_fun {
        [| 
           <p>Fun is an open source programming language designed to be expressive and 
           simple.  Language designers sometimes see this as a tradeoff; you can have 
           more features and be more expressive, or you can have fewer features and be 
           simpler.  Fun shows that with the right design you can 
           be more expressive and simpler at the same time.</p>
           
           <p>Fun's secret for achieving expressiveness and simplicity at the same time is 
           a design philosophy called <b>Poetic Programming</b>.  Poetic Programming
           asserts that the same qualities that allow poetry to be simultaneously more 
           expressive and simpler than prose can work for programming as well: economy
           (use fewer words and shorter phrases), richness (use words and phrases that 
           have multiple layers of meaning) and beauty (arrange the words and phrases 
           into a melodious, rhythmic and visually pleasing whole).  These are the 
           principles that have guided the design of Fun.</p>
           
           <ul>
           <li><b>Economy:</b> Fun is economical by having only one kind of entity.  Other 
           languages have distinct syntax for creating and using various kinds of entities such
           as classes, types, functions, variables, objects and interfaces.  Fun has all these 
           things, but doesn't have all the syntactic mechanisms, because in Fun these things 
           are roles, not entities, and roles can be inferred from context.</li>
           
           <li><b>Richness:</b> Because entities have multiple roles, Fun statements naturally
           have multiple levels of meaning.  Further richness flows from object-oriented
           features such as polymorphism and <b>polyinheritance</b> -- the ability to inherit 
           in multiple ways, including some that are not available in standard OO languages.</li>
           
           <li><b>Beauty:</b> The aesthetics of code is at the heart of Fun's design.  Among other
           things, Fun is a declarative language.  Most widely used languages are imperative, and 
           their programs are lists of instructions.  A Fun program is a description of output.  
           Descriptive language lends itself to beauty; lists of instructions, not so much.  
           Writing a beautiful program is not guaranteed by Fun, but it is enabled and 
           encouraged.</li>
           </ul>
           
           <p>Finally, <b>Fun is fun</b>.  Fun was designed by a programmer in order to be enjoyable
           to program in.  Have Fun!</p>
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

    global article quick_tour_article = overview_article("quick_tour", "Quick Tour");
    global article leisurely_tour_article = overview_article("leisurely_tour", "Leisurely Tour");
    global article backstory_article = overview_article("backstory", "Backstage Tour")

    public article_page(quick_tour_article) quick_tour_page = article_page(quick_tour_article) 
    public article_page(leisurely_tour_article) leisurely_tour_page = article_page(leisurely_tour_article) 
    public article_page(backstory_article) backstory_page = article_page(backstory_article) 

public tt {
 article_page[] pp = [ quick_tour_page, leisurely_tour_page ]
 for article_page ap in pp {
    show(ap);
 }
 show(article_page ap) {
  article_page app = ap
  app.type;
  app.label;
 }

 br; br;
 quick_tour_page.type;
 quick_tour_page.label;
}


    dynamic public base_page article_page(article a) {
        boolean needs_login = false    

        label = a.title
    
        show_article(a);
    }

   
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
        include_file(file_base + "/docs/" + doc_name + ".md");
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
        libs {
            three {
                public js {
                    include_file("../3p/js/libs/three.js");
                }
            }
            stats {
                public js {
                    include_file("../3p/js/libs/stats.min.js");
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
