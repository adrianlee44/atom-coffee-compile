helper = require "../lib/helper"

describe "helper", ->

  describe "extend", ->
    source = null

    beforeEach ->
      source =
        hello: "world"
        foo:   "bar"

    it "should return the source without alternating it", ->
      expect(helper.extend source).toBe source

    it "should extend the source", ->
      source = helper.extend source,
        hello: "world1"

      expect(source).toEqual
        hello: "world1"
        foo:   "bar"

    it "should extend the source with 2 args", ->
      source = helper.extend source,
        hello: "world1"
      ,
        foo: "bar1"

      expect(source).toEqual
        hello: "world1"
        foo:   "bar1"

    it "should extend the source with 2 args with the last object taking priority", ->
      source = helper.extend source,
        hello: "world1"
      ,
        hello: "world2"

      expect(source).toEqual
        hello: "world2"
        foo:   "bar"
