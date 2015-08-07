# httprate

Have you ever done some async work and just happened to send of 100 of request in the span of a few ms. The the api you
are talking to is very unhappy on lack of respect. Or maybe it was an internal service that just died. The problem with
async its way to easy too just start a lot of work now.

This is where Httprate comes in to save the day. It will handle the muck of rate limiting your traffic so you an
continue to be as irresponsible with your code as you like. You just set how many calls per domain you want and Httprate
handle the rest. And if that is to much work for you it comes with sane defaults that should just work. 

## Usage

Httprate have three level of integrations from just works to more custom;

The first are package:httprate/http.dart and package:httprate/httpbrowser.dart that is just drop in replacements for 
package:http/http.dart. No code change is needed it just works.

    import 'package:httprate/http.dart' as http;
    
    var url = "http://example.com/whatsit/create";
    http.post(url, body: {"name": "doodle", "color": "blue"})
        .then((response) {
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");
    });
    
    http.read("http://example.com/foobar.txt").then(print);
    
or if you want to go crazy and let rate limit do its work: 

    import 'package:httprate/http.dart' as http;
        
    var urls = new List.fill(200, 'http://example.com');
    // requests 200 files at one time would be a very bad idea without Httprate
    var request = urls.map(http.get);
    
    Future.wait(request).then((responses){
        for(response in responses){
            print("Response status: ${response.statusCode}");
            print("Response body: ${response.body}");
        }
    });

The second way is use the RateClient that is proxy with the http.Clinet so that you can use it inline with other http
middleware.

    import 'package:http/http.dart' show Client;
    import 'package:httprate/httprate.dart';
    
    var http = new RateClient(new Client());

The last way is to talk directly to the RateQueue object it self. For the times when you want full control or you code
or library you use don't use the http package. Its a more general implementation and have no knowledge of http and can
be used to limit any kind of mass future creations. 

    import 'package:http/http.dart' as http;
    import 'package:httprate/httprate.dart';
    
    // rateQueue is a global object that represent the default global request queue.
    // when you do it manually you need to specify what bucket your request is part of. For most practical applications
    // its the hostname but it can be any string.
    rateQueue.do('example.com',() => http.get('http://example.com';)).then((){
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");
    });


## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: http://example.com/issues/replaceme
