$(document).ready(function(){
	$("table.tablesorter").tablesorter();
	
	$(".unwatchLink").click(function(){
		var that = this
		$.ajax({
		  type: "POST",
			dataType: "text",
		  url: "/unwatch/" + $(this).data('username') + '/' + $(this).data('repo'),
			statusCode: {
				200: function(msg){
					$("#notice").html(msg);
					$(that).parent().parent().hide();
				},
				503: function(msg){
					$("#notice").html("Error occured");
				}	
			}
		});
		return false;
	})
	
})