/**  fundev_content.fun
 *
 *   Content for official Bento web site.
 *
 *
 **/

site fundev {

    /---- base classes for documemt system ----/

    /** base class for documents **/
    article {
        keep: title [?]
        keep: key [?]
        keep: keywords[] = []
        
        keep: article parent [/]
        keep: article[] children = []
        
        keep: content [/]
        
        this;
    }
    
    /** base class for content blocks.  A content block is a paragraph, header,
     *  code block or other chunk of text that should be styled and displayed as
     *  a unit.
     **/
    content_block(str),(strs[]) {
        with (str) {
            str;
        } else {
            for s in strs {
                s;
                "\n";
            }
        }
    }
    
    /** content block factory.  This class takes input and returns a content
     *  of the appropriate type depending on the input.
     **/
    dynamic content_block(*) content_block_factory(str),(strs[]) {
        first_str = (str ? str : strs[0])
        one_str = (str ? str : concat(strs))
        trimmed_str = trim_leading(one_str, '#')
        
        if (starts_with(first_str, "####")) {
            subsec_header(: trimmed_str :);
        } else if (starts_with(first_str, "###")) {
            sec_header(: trimmed_str :);
        } else if (starts_with(first_str, "##")) {
            chap_header(: trimmed_str :);
        } else if (starts_with(first_str, "#")) {
            doc_header(: trimmed_str :);
        } else with (str) {
            paragraph(: str :);
        } else {
            paragraph(: strs :);
        }
    } 
                
    /---- content block types ----/

    content_block(*) paragraph(str),(strs[]) {
        [| <p> |]
        super;
        [| </p> |]
    }

    content_block(str) subsec_header(str) {
        [| <h4> |]
        super;
        [| </h4> |]
    }
    
    content_block(str) sec_header(str) {
        [| <h3> |]
        super;
        [| </h3> |]
    }
    
    content_block(str) chap_header(str) {
        [| <h2> |]
        super;
        [| </h2> |]
    }
    
    content_block(str) doc_header(str) {
        [| <h1> |]
        super;
        [| </h1> |]
    }

    content_block(strs) code_block(strs[]) {
        [| <pre> |]
        html_encode(super);
        [| </pre> |]
    }
    

    content_block(strs) bullet_list(strs[]) {
        [| <ul> |]
        for str in strs {
            [| <li> |]
            str;
            [| </li> |]
        }
        [| </ul> |]
    }
    
    /---- document presentation ----/

    /** display a document **/
    dynamic show_article(article a) {

        if (a.children) {
            show_grand_title(a.title);
            show_toc(a);
        } else {
            show_title(a.title);
        }
        
        show_content(a.content);
        
        for article aa in a.children {
            show_article(aa);
        }
    }
    
    /** display the top-level title of a compound document **/
    dynamic show_grand_title(title) {
        [| <h1> |]
        title;
        [| </h1> |]
    }
    
    /** display the title of a simple document, or the second-level title of
     *  a compound document
     **/
    dynamic show_title(title) {
        [| <h2> |]
        title;
        [| </h2> |]
    }

    /** display the table of contents of a compound document **/
    dynamic show_toc(article a) {
        [| <ul> |]
        for article aa in a.children {
            [| <li> |]
            aa.title;
            [| </li> |]
        }
        [| </ul> |]
    }

    /** display the contents of a document **/
    dynamic show_content(content) {
        lns[] = lines(content)
        content_block blocks[] = parse_blocks(lns)
        
        for content_block block in blocks {
            block;
        }        
    }




    /---- utilities ----/
    
   
    dynamic content_block[] parse_blocks(lns[]) {
        static int NORMAL_MODE = 0
        static int CODE_MODE = 1
        static int BULLET_MODE = 2
        
        static MODE_NAMES[] = [ "NORMAL", "CODE", "BULLET" ];

        int mode(int m) = m
        
        dynamic boolean is_normal(ln) {
            char fc = first_char(ln)
            
            (fc > ' ' && fc != '*');
        }

        dynamic boolean is_code(ln) {
            char fc = first_char(ln)
            char fpc = first_printable_char(ln)
            
            (fc <= ' ' && fpc != '*');
        }
        
        dynamic boolean is_bullet(ln) = (first_printable_char(ln) == '*')
        
        dynamic boolean is_header(ln) = (first_char(ln) == '#')

        dynamic boolean trim_bullet(ln) = trim_leading(trim_leading(ln), "*")

        /** The content_block array to return. The array is added to by the
         *  parsing loop as blocks are completed.
         **/    
        content_block[] content_blocks(content_block[] blocks) = blocks
        
        /** Temporary accumulator for collecting strings while in code mode
         *  or bullet mode.
         **/
        string[] accumulator(string[] strs) = strs

        /** Content parser. Processes each line, and adds blocks to the content_block
         *  array as they are completed.  It switches among three modes: normal, code
         *  and bullet, as follows:
         *
         *      -- the parser starts in normal mode.
         *
         *      -- if the parser is in normal mode and encounters a line that starts
         *         with whitespace, and the first non-whitespace character is not an
         *         asterisk, the parser switches to code mode.
         *
         *      -- if the parser is in normal mode and encounters a line whose first 
         *         non-whitespace character is an asterisk, the parser switches to bullet 
         *         mode.
         *
         *      -- if the parser is in code mode or bullet mode and encounters a line 
         *         whose first character is neither whitespace nor an asterisk, the parser 
         *         switches to normal mode.
         *  
         *  In normal mode, each line that comes in is accumulated until an empty line 
         *  arrives.  At that point the accumulated lines are turned into a content block
         *  and added to the return array.  In bullet and code modes, lines are accumulated
         *  until the parser switches to normal mode or runs out lines, at which point 
         *  the accumulated lines are turned into a single content block and added to the 
         *  return array. 
         * 
         **/
     
        eval(mode(: NORMAL_MODE :));
        log("mode starts at " + MODE_NAMES[mode]);   
        for ln in lns and int i from 0 {
            log("line " + i + " first char: " + (int) first_char(ln) + "   first printable char: " + (int) first_printable_char(ln));

            /-- first, handle mode switching --/
            if (strlen(ln) > 0) {
                if (is_normal(ln)) {
                    if (mode == CODE_MODE) {
                        eval(mode(: NORMAL_MODE :));
                        if (accumulator) {
                            eval(content_blocks(: content_blocks + code_block(: accumulator :) :));
                            eval(accumulator(: null :));
                        }
                    } else if (mode == BULLET_MODE && i > 0 && !lns[i-1]) {
                        eval(mode(: NORMAL_MODE :));
                        if (accumulator) {
                            eval(content_blocks(: content_blocks + bullet_list(: accumulator :) :));
                            eval(accumulator(: null :));
                        }
                    }            
                
                } else if (mode == NORMAL_MODE) {            
                    if (is_code(ln)) {
                        if (accumulator) {
                            eval(content_blocks(: content_blocks + content_block_factory(: accumulator :).this :));
                            eval(accumulator(: null :));
                        }
                        eval(mode(: CODE_MODE :));
                    } else if (is_bullet(ln)) {
                        if (accumulator) {
                            eval(content_blocks(: content_blocks + content_block_factory(: accumulator :).this :));
                            eval(accumulator(: null :));
                        }
                        eval(mode(: BULLET_MODE :));
                    }                
                }
            }
            
            log(" -- mode now " + MODE_NAMES[mode] + "   strlen(ln) = " + strlen(ln));
            log(" -- accumulator size before processing: " + accumulator.count);
            if (accumulator.count > 0) { log("   ---- accumulator contents: " + accumulator); }
            
            /-- next, process the current line according to the mode --/
            if (mode == BULLET_MODE) {
                if (ln) {
                    if (is_normal(ln)) {
                        log("appending to last bullet string in place");
                        array.set(accumulator, accumulator.count - 1, accumulator[accumulator.count - 1] + " " + ln);
                    } else {
                        log("accumulating bullet string");
                        eval(accumulator(: accumulator + trim_bullet(ln) :));
                    }
                }
            } else if (ln && !is_header(ln)) {
                log("accumulating non-header string: " + ln);
                eval(accumulator(: accumulator + ln :));

            } else if (mode == CODE_MODE) {
                log("accumulating empty code string");
                eval(accumulator(: accumulator + " " :));
                
            } else {
                if (accumulator) {
                    log("constructing content block from accumulated strings");
                    eval(content_blocks(: content_blocks + content_block_factory(: accumulator :).this :));
                    eval(accumulator(: null :));
                }
                if (ln) {
                    log("constructing content block from line: " + ln);
                    eval(content_blocks(: content_blocks + content_block_factory(: ln :).this :));
                }
            }
        }

        /-- finally, handle dangling content --/
        if (accumulator) {
            log("adding dangling content for mode " + MODE_NAMES[mode]);        
            if (mode == CODE_MODE) {
                eval(content_blocks(: content_blocks + code_block(: accumulator :).this :));
            } else if (mode == BULLET_MODE) {
                eval(content_blocks(: content_blocks + bullet_list(: accumulator :).this :));
            } else {
                eval(content_blocks(: content_blocks + content_block_factory(: accumulator :).this :));
            }
        }            
     
        content_blocks;
    }

    /---- unit tests ----/

    plain_text_content [|

This is the first paragraph.  It
consists of three lines of text
followed by an empty line.

This is the second paragraph.  It consists of three sentences, all in one line of text.  This is the third sentence.

    |]

    bullet_only_content [|
        * first bullet
        * second bullet
        * third bullet
    |]

    code_only_content [/
        func(x) {
            y;
        }
    |]
    
    headers_content [|
#level 1 header
##level 2 header
###level 3 header
####level 4 header
#####level 4 header is max
######level 4 header is max
plain text
###another level 3 header

plain text and blank lines

##another level 2 header

   #not a header

#final level 1 header 
    |]
    
    text_and_code_content [|
First comes plain text.

    second is code;

Third is more plain text.    
    |]
    
    text_and_bullet_content [|
First line is plain text.

* Second line is a bullet.
Third line is part of the same bullet.

Fourth line is plain text.
    |]     
    
    
    test_base parsing_test_base {
        content [?]
        
        lns[] = lines(content)
        content_block[] blx = parse_blocks(lns)
    }
    
    test_runner content_parser_tests {
    
        parsing_test_base test_plain_text_parsing {
            expected = "ABC"
            content = plain_text_content
            content_block first_para = blx[0]
            content_block second_para = blx[1]
            
            if (blx.count == 2) {
                "A";
                test_log("correct paragraph count");
            } else {
                test_log("incorrect paragraph count " + blx.count + " (expected 2)");
            }
            if (starts_with(first_para, "<p>This is the first") && ends_with(first_para, "</p>")) {
                "B";
                test_log("correct first paragraph");
            } else {
                test_log("incorrect first paragraph: " + first_para);
            }
            if (starts_with(second_para, "<p>This is the second") && ends_with(second_para, "</p>")) {
                "C";
                test_log("correct second paragraph");
            } else {
                test_log("incorrect second paragraph: " + second_para);
            }
        }

        parsing_test_base test_bullet_parsing {
            expected = "ABCDEF"
            content = bullet_only_content
            content_block first_block = blx[0]
            bullet[] = split(first_block, "<li>")
            
            // the split on <li> includes the leading <ul> plus the parsed bullets, so the 
            // number of elements in the bullet array is one more than the actual number 
            // of bullets
            
            int bullet_count = bullet.count - 1
            
            if (blx.count == 1) {
                "A";
                test_log("correct block count");
            } else {
                test_log("incorrect block count " + blx.count + " (expected 1)");
            }

           
            if (bullet_count == 3) {
                "B";
                test_log("correct bullet count");
            } else {
                test_log("incorrect bullet count " + bullet_count + " (expected 3)");
            }
            if (bullet.count > 0) {
                if (index_of(bullet[0], "<ul>") >= 0) {
                    "C";
                    test_log("correct list tag");
                } else {
                    test_log("no list tag, instead: " + bullet[0]);
                }
            }
            if (bullet_count > 0) {
                if (index_of(bullet[1], "first") >= 0 && index_of(bullet[1], "second") < 0) {
                    "D";
                    test_log("correct first bullet");
                } else {
                    test_log("incorrect first bullet: " + bullet[1]);
                }
            } else {
                test_log("missing first bullet");
            }
            if (bullet_count > 1) {
                if (index_of(bullet[2], "second") >= 0 && index_of(bullet[2], "first") < 0) {
                    "E";
                    test_log("correct second bullet");
                } else {
                    test_log("incorrect second bullet: " + bullet[2]);
                }
            } else {
                test_log("missing second bullet");
            }
            if (bullet_count > 2) {
                if (index_of(bullet[3], "third") >= 0) {
                    "F";
                    test_log("correct third bullet");
                } else {
                    test_log("incorrect third bullet: " + bullet[2]);
                }
            } else {
                test_log("missing third bullet");
            }
        }

        parsing_test_base test_code_parsing {
            expected = "ABCD"
            content = code_only_content
            content_block first_block = blx[0]
            
            if (blx.count == 1) {
                "A";
                test_log("correct block count");
            } else {
                test_log("incorrect block count " + blx.count + " (expected 1)");
            }
            if (index_of(first_block, "<pre>") >= 0) {
                "B";
                test_log("correct leading tag");
            } else {
                test_log("incorrect leading tag");
            }
            /--- the content should be present verbatim, except possibly for an initial
             --- newline.
             ---/
            if (index_of(first_block, trim(content)) >= 0) {
                "C";
                test_log("correct content");
            } else {
                test_log("incorrect content");
            }
            if (index_of(first_block, "</pre>") >= 0) {
                "D";
                test_log("correct trailing tag");
            } else {
                test_log("incorrect trailing tag");
            }
        }

        parsing_test_base test_headers_parsing {
            expected = "ABCDEFGH"
            content = headers_content
            
            int expected_block_count = 12
            content_block first_level_1_block = blx[0]
            content_block first_level_2_block = blx[1]
            content_block first_level_3_block = blx[2]
            content_block first_level_4_block = blx[3]
            content_block second_level_4_block = blx[4]
            content_block third_level_4_block = blx[5]
            content_block second_level_3_block = blx[7]
            content_block second_level_2_block = blx[9]
            content_block second_level_1_block = blx[11]
            
            if (blx.count == expected_block_count) {
                "A";
                test_log("correct block count");
            } else {
                test_log("incorrect block count " + blx.count + " (expected " + expected_block_count + ")");
            }
            if (starts_with(first_level_1_block, "<h1>level 1")) {
                "B";
                test_log("correct level 1 header");
            } else {
                test_log("incorrect level 1 header: " + first_level_1_block);
            }
            if (starts_with(first_level_2_block, "<h2>level 2")) {
                "C";
                test_log("correct level 2 header");
            } else {
                test_log("incorrect level 2 header: " + first_level_2_block);
            }
            if (starts_with(first_level_3_block, "<h3>level 3")) {
                "D";
                test_log("correct level 3 header");
            } else {
                test_log("incorrect level 3 header: " + first_level_3_block);
            }
            if (starts_with(first_level_4_block, "<h4>level 4")) {
                "E";
                test_log("correct level 4 header");
            } else {
                test_log("incorrect level 4 header: " + first_level_4_block);
            }
            if (starts_with(second_level_4_block, "<h4>level 4") && starts_with(third_level_4_block, "<h4>level 4")) {
                "F";
                test_log("correct headers with more than four #'s");
            } else {
                test_log("incorrect header with more that four #'s");
            }
            if (starts_with(second_level_2_block, "<h2>another level 2") && starts_with(second_level_3_block, "<h3>another level 3")) {
                "G";
                test_log("correct headers with interspersed plain text");
            } else {
                test_log("incorrect headers with interspersed plain text");
            }
            if (starts_with(second_level_1_block, "<h1>final level 1")) {
                "H";
                test_log("correct final header");
            } else {
                test_log("incorrect final header");
            }
        }

        parsing_test_base test_text_and_code_parsing {
            expected = "ABCD"
            content = text_and_code_content
            content_block first_block = blx[0]
            content_block second_block = blx[1]
            content_block third_block = blx[2]
            
            if (blx.count == 3) {
                "A";
                test_log("correct block count");
            } else {
                test_log("incorrect block count " + blx.count + " (expected 3)");
            }
            if (index_of(first_block, "<p>First") == 0) {
                "B";
                test_log("correct first block");
            } else {
                test_log("incorrect first block");
            }
            if (index_of(second_block, "<pre>    second") == 0) {
                "C";
                test_log("correct second block");
            } else {
                test_log("incorrect second block");
            }
            if (index_of(third_block, "<p>Third") == 0) {
                "D";
                test_log("correct third block");
            } else {
                test_log("incorrect third block");
            }
        }


        parsing_test_base test_text_and_bullet_parsing {
            expected = "ABCDE"
            content = text_and_bullet_content

            content_block first_block = blx[0]
            content_block second_block = blx[1]
            content_block third_block = blx[2]
            
            // the bullet block should begin with "<ul><li>" and have as many bullets as <li>'s
            bullet_block = starts_with(second_block, "<ul><li>") ? substring(second_block, 8) : ""
            bullet[] = split(bullet_block, "<li>")
            
            if (blx.count == 3) {
                "A";
                test_log("correct block count");
            } else {
                test_log("incorrect block count " + blx.count + " (expected 3)");
            }
            if (bullet.count == 1) {
                "B";
                test_log("correct bullet count");
            } else {
                test_log("incorrect bullet count " + bullet.count + " (expected 1)");
            }
            if (blx.count > 0 && starts_with(first_block, "<p>First")) {
                "C";
                test_log("correct first paragraph");
            } else {
                test_log("incorrect first paragraph: " + first_block);
            }
            if (blx.count > 1) {
                if (index_of(second_block, "Second") >= 0 && index_of(second_block, "Third") > 0
                       && index_of(second_block, "bullet.Third") < 0) {
                    "D";
                    test_log("correct bullet");
                } else {
                    test_log("incorrect bullet: " + second_block);
                }
            } else {
                test_log("missing bullet");
            }
            if (blx.count > 2) {
                if (starts_with(blx[2], "<p>Fourth")) {
                    "E";
                    test_log("correct final paragraph");
                } else {
                    test_log("incorrect final paragraph: " + blx[2]);
                }
            } else {
                test_log("missing final paragraph");
            }
        }
    }

tbc {
  content = bullet_only_content
  lns[] = lines(content)
  content_block[] blx = parse_blocks(lns)
  content_block first_block = blx[0]
  bullet[] = split(first_block, "<li>")
  bullet.count;
}


}
