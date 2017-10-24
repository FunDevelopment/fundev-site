/**  fundev_tests.fun
 *
 *   Tests for Bento web site.
 *
 **/

site fundev {

    test_runner[] test_runners = [ content_parser_tests ]
    

    public page(*) tests(params{}) {
        boolean needs_login = false
        boolean needs_admin = false    
        boolean show_menu = false

        label = "Tests"
    
        [| <h2>Test Results</h2> |]

        /--- run all the tests in the test runner list ---/
        for test_runner tr in test_runners {                
        
            [| <strong>{= tr.name; =}<strong><ol> |]
            
            tr.run;
        
            for test_result rslt in tr.results {
                [| <li>{= rslt.name; =}<br> |]
                if (rslt.result) [|
                    Passed
                |] else [|
                    <span style="color:red">Failed</span>
                |]
                [| <br><ul> |]
                for msg in rslt.messages [|
                    <li>{= msg; =}</li>
                |]
                [| </ul></li> |]                
           }
            [| </ol> |]
        }
    }   
}
