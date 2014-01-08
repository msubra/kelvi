test( "Cache test", function() {
    equal(Cache.size(),0);

    /* test putter */
    Cache.put("a",1);
    equal(Cache.size(),1);

    Cache.put("b",2);
    equal(Cache.size(),2);

    Cache.put("c",3);
    equal(Cache.size(),3);

    /* test getter */
    equal(Cache.get("c"),3);
    equal(Cache.get("a"),1);
    equal(Cache.get("b"),2);
    notEqual(Cache.get("b"),Cache.get("a"));

    /* test remover */
    Cache.remove("b");
    equal(Cache.size(),2);
    equal(Cache.get("b"),undefined);

    /* test remover */
    equal(Cache.size(),2);
    Cache.remove("a")
    equal(Cache.size(),1);
    equal(Cache.get("a"),undefined);

    /* test cache reset */
    equal(Cache.size(),1);
    Cache.put("a1",2);
    equal(Cache.size(),2);
    Cache.reset();
    equal(Cache.size(),0);

    /* test cache 'has' */
    Cache.put("a1",2);
    equal(Cache.has("a1"),true);

});
