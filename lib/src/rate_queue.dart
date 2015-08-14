library httprate.rate_queue;

import 'dart:async';
import 'dart:collection';

/// the default [RateQueue] for this instance.
///
/// This should be used in most cases. As having many queues for one application
/// defeats the purpose of having one. You can also get it with [new RateQueue].
RateQueue rateQueue = new RateQueue.independent();

///The most basic class for rate limiting.
///
/// As the name suggest it queues job so that only [domainLimit] is active at
/// one time.
///
/// ## Host limit
/// The host limit is not strictly a limit per host as it works more like a
/// bucket. Where every unique string as its own limit. The name was chosen more
/// on its most often use case. The limiting of traffic to different hostname.
/// But can be anything you want as RateQueue works on [Future] not on networks
/// traffic.
class RateQueue{
  /// the max limit of concurrent request per host
  ///
  /// You can change this value when there is work active. But it will not have
  /// immediate effect. The behavior is safe but it is undefined as in the order
  /// of task for a period after the change will not be strictly first in first
  /// out.
  int hostLimit = 6;

  /// returns the default [RateQueue];
  factory RateQueue() => rateQueue;
  /// creates a new independent RateQueue.
  ///
  /// This new queue share no limits or queues with any other so its great if
  /// you want isolation of effects like in Testing. Or having rate limits on
  /// fundamental different tings. Like one for network and one for io.
  RateQueue.independent();

  Map<String,Queue> _queue = {};
  Map<String,int> _running = {};

  /// run a job at the earliest opportunely.
  ///
  /// Will run the callback task when there is a slot open for it to run.
  /// The future of the task must complete at some point as it will hold a
  /// slot for as long as it uncompleted. And the future should not complete
  /// before the underlying resource is ready for another task. For example when
  /// the http data from the server is fully read of the network.
  ///
  /// The future returned will complete with the same state and value as the one
  /// task will return.
  ///
  /// Just remember the task callback must start the work when it is called not
  /// before.
  Future runJob(String domain, Future task()) async{
    if(domain == null){
      throw new ArgumentError.notNull('domain');
    }
    _queue.putIfAbsent(domain, ()=> new Queue());
    _running.putIfAbsent(domain, ()=>0);
    var job = new _Job(domain,task);
    if(_canRun(job)){
      _run(job);
    }else{
      _queue[domain].add(job);
    }
    return job.com.future;
  }

  bool _canRun(_Job job) => _running[job.domain] < hostLimit;

  _whenComplete(_Job job){
    _running[job.domain] -= 1;
    if(_queue[job.domain].isNotEmpty){
      _run(_queue[job.domain].removeFirst());
    }
  }

  _run(_Job job){
    _running[job.domain] += 1;
    var task = new Future(job.callback).whenComplete(() => _whenComplete(job));
    job.com.complete(task);
  }
}

class _Job{
  final Completer com =  new Completer.sync();
  final Function callback;
  final domain;
  _Job(this.domain, this.callback);
}