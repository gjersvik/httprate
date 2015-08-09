library httprate.rate_queue;

import 'dart:async';

class RateQueue{
  int domainLimit = 6;

  RateQueue.independent();

  Future runJob(String domain, Future job()){
    return new Future.value(null);
  }
}