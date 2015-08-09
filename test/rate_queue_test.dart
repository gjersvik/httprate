library httprate.rate_queue.test;

import 'dart:async';
import 'package:test/test.dart';
import 'package:httprate/src/rate_queue.dart';

const ms10 = const Duration(microseconds: 10);

main() => group('RateQueue', (){
  //integration tests.
  test('that it actualy limmits the rate and queue the jobs',() async {
    // first setup the job
    int numberOfConcurrentJobs = 0;

    Future job() async {
      numberOfConcurrentJobs += 1;
      // test that the number of concurrent jobs never get over 2. The same value given to queue.domainLimit.
      expect(numberOfConcurrentJobs,lessThanOrEqualTo(2));
      await new Future.delayed(ms10);
      numberOfConcurrentJobs -= 1;
    }


    var queue = new RateQueue.independent();
    queue.domainLimit = 2;
    /// start 5 jobs at the same time. To the same domain.
    var jobs = new List.generate(5, (_) => queue.runJob('testDoamin',job));
    var results = await Future.wait(jobs);

    expect(results, hasLength(5));
  });

  //Unit Tests.
});