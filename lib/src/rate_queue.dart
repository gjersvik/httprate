library httprate.rate_queue;

import 'dart:async';
import 'dart:collection';

class RateQueue{
  int domainLimit = 6;

  RateQueue.independent();

  Map<String,Queue> _queue = {};
  Map<String,int> _running = {};

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

  bool _canRun(_Job job) => _running[job.domain] < domainLimit;

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