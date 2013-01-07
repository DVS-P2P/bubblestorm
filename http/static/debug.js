
function debug() {
	var req1 = $.ajax({url:'/poll/counter'});
	setTimeout(function () {
		req1.abort();
	}, 500);
	setTimeout(function () {
		$.ajax({url:'/static/test.html'});
	}, 1000);
}

function debug2() {
	var req1 = $.ajax({url:'/poll/counter'});
	setTimeout(function () {
		req1.abort();
	}, 1000);
}

function debug3() {
	var req1 = $.ajax({url:'/poll/counter'});
	setTimeout(function () {
		$.ajax({url:'/poll/counter'});
	}, 500);
	//setTimeout(function () {
		//req1.abort();
	//}, 1000);
	setTimeout(function () {
		$.ajax({url:'/static/test.html'});
	}, 1500);
}
