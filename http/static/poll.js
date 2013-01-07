"use strict";

var $ = jQuery;

function sendPollingRequest() {
	$.ajax({
		url: '/poll',
		success: function (data) {
			$('#counter').text(data.counter);
			sendPollingRequest();
		}
	});
}

$('#incbutton').click(function() {
	$.ajax({
		url: '/call',
		data: '{"fun": "incrementCounter", "args":null}',
		type: "POST",
		success: function (data) { console.log('increment success', data); }
	});
});

$('#rstbutton').click(function() {
	$.ajax({
		url: '/call',
		data: '{"fun": "resetCounter", "args":null}',
		type: "POST",
		success: function (data) { console.log('reset success', data); }
	});
});

sendPollingRequest();
