$(document).ready(function(){
	$("table.tablesorter").tablesorter();
	
	$(".unwatchLink").click(function(){
		var that = this
		$.ajax({
		  type: "POST",
			dataType: "text",
		  url: "/unwatch/" + $(this).data('username') + '/' + $(this).data('repo'),
			success: function(msg){
				$("#notice").html(msg);
				$(that).parent().parent().remove();
			},
			error:function(xhr, ajaxOptions, thrownError){
			  $("#notice").html(xhr.responseText);
			}
		});
		return false;
	})
	
	$('#datePicker').datepicker();
	$("#datePicker").bind("change", function(){
		$('tr').show()
		var date_str = $(this).val()
		var date = Date.parse(date_str)
		if( jQuery.trim( date_str ) != "" ){
			$(".pushDate").each(function(){
				if(Date.parse( $(this).text() ) > date){
					$(this).parent().hide();
				}
			})
		}
		else{
			$('tr').show()
		}
		
	});

})