test("Jaadi tests",function(){


	notEqual(Container.createInstance("localstorage"),null)
	notEqual(Container.createInstance("dom"),null)

	/* verify if the base class JaadiPlugin is available to use and extend */
	notEqual(typeof(JaadiPlugin),"undefined")
	equal("name" in JaadiPlugin,true)

	/* check if inbuilt plugins works */
	j = Container.createInstance("dom")
	notEqual(j,null)

	/* verify all the basic functions are available */
	fns = ["get","put","size","remove"]
	for(var i = 0; i < fns.length; i++)
	{
		equal(typeof(j[fns[i]]),"function")	
	}

	/* add 1 element */
	j.put("a",1);
	equal(j.get("a"),1)	;
	equal(j.size(),1);
	
	/* add 1  more element */
	j.put("b",2);
	equal(j.get("b"),2)	;
	equal(j.size(),2);

	/* add 1  more element */
	j.remove("b");
	equal(j.get("b"),null)	;
	equal(j.size(),1);


	/* create a custom Storage plugin */
	TestLocalStoragePlugin = (function(_super) {
	  __extends(TestLocalStoragePlugin, _super);

	  function TestLocalStoragePlugin() {}

	  TestLocalStoragePlugin.prototype.get = function(key) {
	    return 0;
	  };

	  TestLocalStoragePlugin.prototype.put = function(key, value) {
	    return 0;
	  };

	  TestLocalStoragePlugin.prototype.remove = function(key) {
	    return 0;
	  };

	  TestLocalStoragePlugin.prototype.size = function() {
	    return 0;
	  };

	  return TestLocalStoragePlugin;

	})(JaadiPlugin);

	/* add the plugin to the container */
	Container.plugins.add("teststore",TestLocalStoragePlugin);
	equal(Container.plugins.get("teststore"),TestLocalStoragePlugin)

	j1 = Container.createInstance("teststore");
	notEqual(j1,null);
	equal(j1 instanceof TestLocalStoragePlugin,true)

	/* all operations will return 0 */
	equal(j1.get("a"),0);
	equal(j1.put("b",100),0);
	equal(j1.get("a"),0);
	equal(j1.size(),0);
	equal(j1.remove(),0);
	equal(j1.size(),0);


	/* test localStorage capabilities */
	console.log(Container.createInstance("localstorage"))
	equal(Container.createInstance("localstorage") instanceof W3CLocalStoragePlugin,true)
})