$(function() {

	attachSortables = function () {
		$("#tracked_times").sortable({
			update: function (event, ui) { saveOrder(ui); },
		});
	};

	saveOrder = function() {
		data = 'user_id=' + user_id + '&' + $("#tracked_times").sortable('serialize');		

		$.ajax({
			type: "POST",
			url: "multi_time_tracker/reorder",
			dataType: "html",
			data: data,
			success: function(response) { 
			  $("#times_list_space").html(response);
			  attachSortables(); 
			},
		});
	};
	
	attachSortables();
});