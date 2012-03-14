
import QtQuick 1.1
import "script"
import "script/ajaxmee.js"    as Ajaxmee
import "script/array2json.js" as ArrayToJson
import "script/strftime.js"   as Strftime

Rectangle {
    id: container
    width: 854; height: 480
    color: "#222222"

    Image {
	width: 344
	x: 510
	y: 0
	z: 0
	source: "images/bg.jpg"
    }

    Row {
	width: 600;
	spacing: 20

	Column {

	    Image {
		id: background
		source: "images/background.png"
	    }
	    Image {
		id: topography
		anchors.top: parent.top
		anchors.left: parent.left
		source: "images/topography.png"
	    }
	    Image {
		id: locations
		anchors.top: parent.top
		anchors.left: parent.left
		source: "images/locations.png"
	    }
	    Image {
		id: obs
		anchors.top: parent.top
		anchors.left: parent.left
		source: ""
	    }
	    Image {
		id: radar
		anchors.top: parent.top
		anchors.left: parent.left
		source: ""
		opacity: 0.7
	    }
	}

	Column {
	    spacing: 8

	    Text { 
		id: status
		text: "Starting up..." 
		color: "#ddddaa"
		font.pixelSize: 15
	    }
	    Grid {
		columns: 2
		spacing: 2
		Text { 
		    text: "Radar Time:" 
		    font.pixelSize: 18
		    color: radar.status == '#eeeeee'
		    horizontalAlignment: Text.AlignRight
		}
		Text { 
		    id: maptime
		    text: "" 
		    font.pixelSize: 18
		    color: radar.status == Image.Ready ? '#eeeeee' : '#ff3333'
		}
		Text { 
		    text: "OBS Time:" 
		    font.pixelSize: 18
		    color: radar.status == '#eeeeee'
		    horizontalAlignment: Text.AlignRight
		}
		Text { 
		    id: obstime
		    text: "" 
		    font.pixelSize: 18
		    color: obs.status == Image.Ready ? '#eeeeee' : '#ff3333'
		}
	    }
	    Row {
		Text { 
 		    width: 30;
		    id: todaymin
		    color: "#eeeeee"
		    font.pixelSize: 18
		}
		Text { 
		    width: 30;
		    id: todaymax
		    text: "" 
		    color: "#eeeeee"
		    font.pixelSize: 22
		}
		Text { 
		    text: " " 
		    color: "#eeeeee"
		    font.pixelSize: 18
		}
		Text { 
		    id: todayforecast
		    text: "" 
		    color: "#eeeeee"
		    font.pixelSize: 16
		    width: 250
		    wrapMode: Text.WordWrap
		}
	    }
	    Row {
		Text { 
 		    width: 30;
		    id: uvmax
		    color: "#eeeeee"
		    font.pixelSize: 22
		}
		Text { 
		    id: uvtimes
		    color: "#eeeeee"
		    font.pixelSize: 22
		}
	    }
	    Row {
		Text { 
 		    width: 30;
		    id: tommin
		    text: "" 
		    color: "#eeeeee"
		    font.pixelSize: 18
		}
		Text { 
 		    width: 30;
		    id: tommax
		    text: "" 
		    color: "#eeeeee"
		    font.pixelSize: 22
		}
		Text { 
		    text: " " 
		    color: "#eeeeee"
		    font.pixelSize: 18
		}
		Text { 
		    id: tomforecast
		    text: "" 
		    color: "#eeeeee"
		    font.pixelSize: 16
		    width: 300
		    wrapMode: Text.WordWrap
		}
	    }
	}
    }

    Timer {
        interval: 3000; running: true; repeat: true
        onTriggered: timer()
    }

    Timer {
        interval: 6 * 60 * 1000; 
	running: true; repeat: true
        onTriggered: radarTimer()
    }

    function timer() 
    {
	var data;

	status.text = "Updated at:" + Date().toString();
    }


    function startupFunction() 
    {
	status.text = "started";

	radarTimer();
	obsTimer();
	timer();
	forecasts();
    }

    Component.onCompleted: startupFunction();

    function forecasts()
    {
	console.log("forecasts()");


        var doc = new XMLHttpRequest();
	doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
                var status = doc.status;
		console.log('status', status)
	    }
	    if (doc.readyState == XMLHttpRequest.DONE) {
                var data = doc.responseText;
                var contentType = doc.getResponseHeader("Content-Type");
//		console.log("forecast datas...:", data);

		var m = data.match(/Gold Coast[\s\S]*Sunshine Coast/m);
//		console.log("matchR2:" + m);

		m = "" + m;
		var ftoday   = m.match("<p>([^<]*)</p>")[1];
		var fmax     = m.match(/<em class="max">([0-9]*)/)[1];
		var fuvtimes = m.match(/<p class="alert">UV Alert from([^,]*)/)[1];
		var fuvmax   = m.match(/<p class="alert">[\s\S]*reach[^0-9]*([0-9]+) \[/)[1];

		console.log("today:" + ftoday + " fmax:" + fmax );
		console.log("fuvmax:" + fuvmax );

		todayforecast.text = ftoday;
		todaymax.text  = fmax;
		uvtimes.text   = fuvtimes;
		uvmax.text     = fuvmax;
//		var tom = m.match(/class="dated[\s\S]*<em class="max">([0-9]*)/m);
		var tom = m.match(/class="dated[\s\S]*summary">([^<]*)[\s\S]*<em class="min">([0-9]*)[\s\S]*<em class="max">([0-9]*)/m);
//		var tom = m.match(/class="dated[\s\S]*summary">(.*)dd[\s\S]*<em class="max">([0-9]*)/m);
		var ff   = tom[1];
		var fmin = tom[2];
		var fmax = tom[3];
		console.log("tom:" + ff + " min:" + fmin  + " max:" + fmax);

		tomforecast.text = ff;
		tommax.text = fmax;
		tommin.text = fmin;

		console.log("match2:" + data.match("Gold Coast"));

            }
        }
        doc.open("GET", "http://www.bom.gov.au/qld/forecasts/secoast.shtml");
        doc.send();

///	var a = myTxt.split(',');
    }

    function obsTimer() 
    {
	var id = "663";
	var earlbase = "http://www.bom.gov.au/radar/IDR" + id + ".observations.";
	var d = new Date();
	if( d.getMinutes() < 8 ) 
	{
	    d.setHours( d.getHours() - 1 );
	    d.setMinutes( 7, 0, 0 );
	}
	else 
	{
	    d.setMinutes( 7, 0, 0 );
	}
	var dutc = new Date(d.getUTCFullYear(), d.getUTCMonth(), d.getUTCDate(),  d.getUTCHours(), d.getUTCMinutes(), d.getUTCSeconds());
	var tstr = Strftime.strftime( "%Y%m%d%H%M", dutc ); 
	var earl = earlbase + tstr + ".png";
	console.log( "obs.earl:" + earl );
	obs.source = earl;
	obstime.text = Strftime.strftime( "%d, %H:%M", d ); 
    }

    function radarTimer() 
    {
	var id = "66B";
	var earlbase = "http://www.bom.gov.au/radar/IDR" + id + ".T.";
	// new image each 6 minutes;
	var releaseWindow = 6 * 60 * 1000;  

	var d = new Date();
	d.setMinutes( 6 * (Math.floor( (d.getMinutes()-10) / 6 )), 
		      0, 0 );

	var dutc = new Date(d.getUTCFullYear(), d.getUTCMonth(), d.getUTCDate(),  d.getUTCHours(), d.getUTCMinutes(), d.getUTCSeconds());
	var tstr = Strftime.strftime( "%Y%m%d%H%M", dutc ); 
	var earl = earlbase + tstr + ".png";

	console.log( "earl:" + earl );
	radar.source = earl;
	maptime.text = Strftime.strftime( "%d, %H:%M", d ); 
    }

}
