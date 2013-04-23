test = require "noflo-test"

test.component("compare/AllPackets").
  discuss("send in two connections of numbers").
    send.connect("in").
      send.data("in", 6).
      send.data("in", 3).
      send.data("in", 4).
      send.data("in", 1).
      send.data("in", 3).
    send.disconnect("in").
    send.connect("in").
      send.data("in", 2).
      send.data("in", 4).
      send.data("in", 4).
      send.data("in", 0).
      send.data("in", 2).
    send.disconnect("in").
  discuss("the first one wins because it has more larger numbers").
    receive.connect("out").
      receive.data("out", 6).
      receive.data("out", 3).
      receive.data("out", 4).
      receive.data("out", 1).
      receive.data("out", 3).
    receive.disconnect("out").

  next().
  discuss("send in two connections of strings").
    send.connect("in").
      send.data("in", "abc").
      send.data("in", "def").
      send.data("in", "ghi").
    send.disconnect("in").
    send.connect("in").
      send.data("in", "aaa").
      send.data("in", "zzz").
      send.data("in", "ggg").
    send.disconnect("in").
  discuss("the first one wins because it has more lexicographically 'bigger' strings").
    receive.connect("out").
      receive.data("out", "abc").
      receive.data("out", "def").
      receive.data("out", "ghi").
    receive.disconnect("out").

  next().
  discuss("groups are ignored and dropped").
    send.connect("in").
      send.beginGroup("in", "group").
      send.data("in", "abc").
      send.endGroup("in", "group").
      send.data("in", "aaa").
    send.disconnect("in").
  discuss("missing packets are treated as always losing").
    send.connect("in").
      send.data("in", "aaa").
    send.disconnect("in").
  discuss("the first one wins because it has more winning counts, but without groups").
    receive.connect("out").
      receive.data("out", "abc").
      receive.data("out", "aaa").
    receive.disconnect("out").

export module
