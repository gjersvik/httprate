library httprate.rate_queue;

import 'dart:async';

class RateQueue{
  int domainLimit = 6;

  RateQueue.independent();

  Future runJob(String domain, Future job()) async{
    if(domain == null){
      throw new ArgumentError.notNull('domain');
    }
    return await job();
  }
}