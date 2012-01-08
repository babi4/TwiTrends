function set_trends(){
  var js_trends = $("div.module.trends.component ul.js-trends");  
  js_trends.fadeOut("slow", function(){
    $("div.module.trends.component ul.js-trends li").remove();
    $.getJSON("http://trends.babi4.com/top.json?mode=10min", function(data) {
      $.each(data, function(index, trend){      
              js_trends.append("<li class=\"\"><a href=\"/#!/search/" +
                        encodeURIComponent(trend.hashtag)+ "\">" + 
                        trend.hashtag + "</a></li>")
      });
    });      
  });

  js_trends.fadeIn("fast");
}

set_trends();
setInterval(set_trends, 30000);
