noflo = require 'noflo'
if typeof process is 'object' and process.title is 'node'
  chai = require 'chai' unless chai
  AllPackets = require '../components/AllPackets.coffee'
else
  AllPackets = require 'noflo-adapters/components/AllPackets.js'

describe 'AllPackets component', ->
  c = null
  ins = null
  out = null

  beforeEach ->
    c = AllPackets.getComponent()
    ins = noflo.internalSocket.createSocket()
    out = noflo.internalSocket.createSocket()
    c.inPorts.in.attach ins
    c.outPorts.out.attach out

  describe 'when instantiated', ->
    it 'should have an input port', ->
      chai.expect(c.inPorts.in).to.be.an 'object'
    it 'should have an output port', ->
      chai.expect(c.outPorts.out).to.be.an 'object'

  describe 'given two streams of numbers', ->
    input1 = [6, 3, 4, 1, 3]
    input2 = [2, 4, 4, 0, 2]

    it 'the first one wins because it has more larger numbers', (done) ->
      packets = [6, 3, 4, 1, 3]

      out.on 'data', (data) ->
        chai.expect(packets.shift()).to.equal data
      out.on 'disconnect', (data) ->
        chai.expect(packets.length).to.equal 0
        done()

      ins.connect()
      ins.send i for i in input1
      ins.disconnect()

      ins.connect()
      ins.send i for i in input2
      ins.disconnect()

  describe 'given two streams of strings', ->
    input1 = ['abc', 'def', 'ghi']
    input2 = ['aaa', 'zzz', 'ggg']

    it 'the first one wins because it has more
      lexicographically bigger strings', (done) ->
      packets = ['abc', 'def', 'ghi']

      out.on 'data', (data) ->
        chai.expect(packets.shift()).to.equal data
      out.on 'disconnect', (data) ->
        chai.expect(packets.length).to.equal 0
        done()

      ins.connect()
      ins.send i for i in input1
      ins.disconnect()

      ins.connect()
      ins.send i for i in input2
      ins.disconnect()

  describe 'groups are ignored and dropped', ->
    it 'the first one wins because it has more
      winning counts, but without groups', (done) ->
      packets = ['abc', 'aaa']

      out.on 'begingroup', (group) ->
        chai.expect(null).to.be.ok
      out.on 'data', (data) ->
        chai.expect(packets.shift()).to.deep.equal data
      out.on 'disconnect', (data) ->
        chai.expect(packets.length).to.equal 0
        done()

      ins.connect()
      ins.beginGroup 'group'
      ins.send 'abc'
      ins.endGroup 'group'
      ins.send 'aaa'
      ins.disconnect()

      # missing packets are treated as always losing
      ins.connect()
      ins.send 'aaa'
      ins.disconnect()
