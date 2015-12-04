# Pro-rata-Expectancy

## Problem description

One of the markets we seek to trade more actively in is the CME Fed Funds Future (symbol usually is ZQ). Its matching algorithm is a strict pro-rata [CME Pro-rata matching algorithm description](http://www.cmegroup.com/confluence/display/EPICSANDBOX/Matching+Algorithms#MatchingAlgorithms-Pro-Rata) which makes it convenient to model in certain ways.

The first step is to simplify the problem by ignoring the nuances of CME's pro-rata algorithm and assume we can execute in decimal quantities. We seek to work passive orders ("joining") at the BBO (best bid/offer, one or both sides) in order to be exposed to *hopefully* positive expectancy trades. One simplifying assumption that we won't make is that we can make instantaneous decisions. Instead, we must face a *decision latency* within which we are unable to place or cancel an outstanding order. To model the latency effect, we use a simple script to shift backwards in time the trades that we would have been exposed to at a given time. E.g. With a decision latency of *L* and a trade occuring at time *T_t*, we would have been able to make a decision (to have an order on the best bid, best offer, both, or neither) at time *T_t-L*.

## Task

Create a script to model our expectancy (at a given prediction horizon) for a simple algorithm that passively joins as a function of the best bid quantity to best ask quantity ratio, e.g. best bid = 400 @ 99.80, best ask = 50 @ 99.81 then current *baqRatio* = (400)/(400+50). Expectancy should be measured from trade price to any reasonable measure of (future) fair value.

## Artifacts

* loadData.m is some code for loading the quote and trade data, merging them by time, and creating the shifted trade price and quantity variables (for estimating our executions with a given latency)
* [ZQ contract sample data](https://drive.google.com/a/kapitaltrading.com/folderview?id=0BxSOc9YJbsPnRnV4Z1dtRm82NUE&usp=sharing) with (BBO) quotes and trades in separate files
