library httprate.rate_queue.test;

import 'dart:async';
import 'package:test/test.dart';
import 'package:httprate/httprate.dart';

const ms10 = const Duration(microseconds: 10);

main() => group('RateQueue', () {
  //integration tests.
  test('that it actualy limits the rate and queue the jobs', () async {
    // first setup the job
    int numberOfConcurrentJobs = 0;

    Future job() async {
      numberOfConcurrentJobs += 1;
      // test that the number of concurrent jobs never get over 2. The same value given to queue.domainLimit.
      expect(numberOfConcurrentJobs, lessThanOrEqualTo(2));
      await new Future.delayed(ms10);
      numberOfConcurrentJobs -= 1;
    }

    var queue = new RateQueue.independent();
    queue.domainLimit = 2;
    /// start 5 jobs at the same time. To the same domain.
    var jobs = new List.generate(5, (_) => queue.runJob('testDoamin', job));
    var results = await Future.wait(jobs);

    expect(results, hasLength(5));
  });

  //Unit Tests.
  group('runJob', () {
    var queue;
    // starts an independent queue to eliminate clobbering.
    setUp(() => queue = new RateQueue.independent());

    // common jobs;
    simpleJob() async => 'some data';
    jobThatThrows() async => throw new Error();
    simpleJobSync() => 'some data';
    jobThatThrowsSync() => throw new Error();

    test('acualy run the job', () async {
      expect(await queue.runJob('testDoamin', simpleJob), 'some data');
    });

    test('handle callback that throws', () async {
      expect(queue.runJob('testDoamin', jobThatThrows), throws);
    });

    test('handle sync callback', () async {
      expect(await queue.runJob('testDoamin', simpleJobSync), 'some data');
    });

    test('handle sync callback that throws', () async {
      expect(queue.runJob('testDoamin', jobThatThrowsSync), throws);
    });

    test('don\'t accept null as domain', () async {
      expect(queue.runJob(null, simpleJob), throwsArgumentError);
    });
  });
});
