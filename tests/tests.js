test("test SOPanel",function(){
    var dashboard = new KelviDashboard("Stacks")

    var panel = new KelviTopic("topic","",10, function(){})
    notEqual(panel,null)


    //check for hooks available
    equal(typeof(panel.dataloadComplete),"function");
    equal(typeof(panel.dataloadInit),"function");
    equal(typeof(panel.dataLoader),"function");

    //initialize the panel
    panel.init();

    var messages = [];
    panel.dataloadInit = function() { messages.push("dataloadInit"); }
    
    questions = {
          "total": 15,
          "page": 1,
          "pagesize": 30,
          "questions": [
            {
              "tags": [
                "python",
                "python-2.7",
                "file-upload",
                "ftplib"
              ],
              "answer_count": 1,
              "favorite_count": 1,
              "bounty_closes_date": 1388502694,
              "bounty_amount": 50,
              "question_timeline_url": "/questions/20660576/timeline",
              "question_comments_url": "/questions/20660576/comments",
              "question_answers_url": "/questions/20660576/answers",
              "question_id": 20660576,
              "owner": {
                "user_id": 2487602,
                "user_type": "registered",
                "display_name": "Hyflex",
                "reputation": 69,
                "email_hash": "9b03d264eabf2b842a71be216e0dbf29"
              },
              "creation_date": 1387376265,
              "last_edit_date": 1387398987,
              "last_activity_date": 1388150790,
              "up_vote_count": 1,
              "down_vote_count": 0,
              "view_count": 91,
              "score": 1,
              "community_owned": false,
              "title": "Uploads via ftplib in python taking signicantly longer than doing it manually"
            },
            
          ]
        };


    panel.dataLoader = function() { 
        messages.push("dataLoader"); 
    } 

    panel.dataloadComplete = function() { messages.push("dataloadComplete"); }

    //"callback_${topic}_${watch}" is callback name generated

    panel.update();
    var callbacks = ["callback_topic_active", "callback_topic_new", "callback_topic_featured", "callback_topic_unanswered"];
    for(var i = 0; i < callbacks.length; i++)
    {
        var cb = callbacks[i];
        equal(typeof(window[cb]),"function");
        window[cb].call(window,questions); //trigger the callbacks manually
    }
    equal(messages.length,3 * 4);
})

test("Compare and Copy",function(){

  var default_map ={
    "a": 1,
    "b": 2,
    "c" : 3
  };

  /* compare and copy empty map */
  var target_map = {};
  var result = compareAndCopy(target_map,default_map)
  equal( JSON.stringify(default_map),JSON.stringify(target_map) )

  /* compare and copy partial map */
  var target_map = {
    "a":1
  };
  var result = compareAndCopy(target_map,default_map)
  equal( JSON.stringify(default_map),JSON.stringify(target_map) )

  /* compare and copy overlapped map */
  var target_map = {
    "d":1
  };

  var target_map_before_processing = JSON.parse(JSON.stringify(target_map)); //create a new instance
  var result = compareAndCopy(target_map,default_map)
  notEqual( JSON.stringify(default_map),JSON.stringify(target_map) )

  /* check if all attribtues of default_map + target_map is available */
  var flag = true;
  for(key in default_map)
    flag = flag && (key in target_map)

  for(key in target_map_before_processing)
    flag = flag && (key in target_map)

  equal(flag,true)

  /* check for nested objects */
  default_map["e"] = {"e1":1,"e2":2}
  var target_map = {};
  var result = compareAndCopy(target_map,default_map)

  equal(JSON.stringify(default_map),JSON.stringify(target_map));

  /* check for more deeply nested objects */
  default_map["e"] = {"e1":1,"e2":{"f":{"g":"h"}}}
  var target_map = {};
  var result = compareAndCopy(target_map,default_map)

  equal(JSON.stringify(default_map),JSON.stringify(target_map));

})
