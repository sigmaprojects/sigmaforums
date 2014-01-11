/* this structure is courtesy of Ben Nadel */

$(function(){
	$(function(){var objController = new SigmaForumsRating('/index.cfm');});
});
function SigmaForumsRating( strControllerURL ){
	this.ControllerURL = strControllerURL;
	this.Init();
};

SigmaForumsRating.prototype.objPostProperties = function( objPostProperties ){
	this.PostProperties = objPostProperties;
};


SigmaForumsRating.prototype.Init = function(){
	var objSelf = this;
	var postForm = $( "#forumPost" );

	
	$('img[class^=ratelink]').click(
		function( objEvent ){
			var $this = $(this);
			objSelf.SubmitRating( $this );
			objEvent.preventDefault();
			return( false );
		}
	);
	$('a[class=subscriptionlink]').click(
		function( objEvent ){
			var $this = $(this);
			objSelf.SubmitSubscription( $this );
			objEvent.preventDefault();
			return( false );
		}
	);
	$('a.sharelinks-help').click(
		function( objEvent ){
			var $this = $(this);
			window.open( $this.attr('href'),this,'toolbar=0,scrollbars=1,location=1,statusbar=0,menubar=0,resizable=1,width=890,height=450,left=640,top=275' );
			objEvent.preventDefault();
			return( false );
		}
	);
	$('th.last > a').click(
		function( objEvent ){
			var $this = $(this);
			$this.attr('href',$this.attr('rel'));
			return(true);
		}
	);
	$('th.count > a').click(
		function( objEvent ){
			var $this = $(this);
			$this.attr('href',$this.attr('rel'));
			return(true);
		}
	);

	$('#adv_preview_btn').click(
		function( objEvent ){
			var $this = $(this);
			objSelf.SubmitAdvPreview($this,postForm);
			objEvent.preventDefault();
			return( false );
		}
	);

	$('#preview_btn').click(
		function( objEvent ){
			var $this = $(this);
			objSelf.SubmitPreview($this,postForm);
			objEvent.preventDefault();
			return( false );
		}
	);
	$('#previewedit_btn').click(
		function( objEvent ){
			objSelf.ToggleEditPreview(false);
			objEvent.preventDefault();
			return( false );
		}
	);
	
	$('#advance_btn').click(
		function( objEvent ){
			postForm.find("input[name='advanced']").val(true);
			postForm.submit();
			return( false );
		}
	);

	$('#post_confirm').click(
		function( objEvent ){
			var $this = $(this);
			postForm.find("input[name='confirmed']").val(true);
			$this.attr('disabled','disabled');
			try { $this.attr('type','button'); } catch(e) { };
			objEvent.preventDefault();
			postForm.submit();
			return( false );
		}
	);

	$('select[name="ReplyAlbumID"]').change(
		function( objEvent ){
			var $this = $(this);
			objSelf.SubmitViewAlbumThumbnail( $this );
		}
	);

	$("td.topics>img").hover(
		function(objEvent){
			var $this = $(this);
			objSelf.ShowTopicPreview($this,objEvent);
			return(false);
		},
		function(){$("p#topic-preview").remove();}
	);

	$("td.topics>img").mousemove(
		function(objEvent){$("p#topic-preview").css("top",(objEvent.pageY-10)+"px").css("left",(objEvent.pageX+10)+"px");}
	);

	setInterval(function(){ 
		$('td.status img[src*="green"]').fadeOut(200);
		$('td.status img[src*="green"]').fadeIn(800);
	},15000);


};

SigmaForumsRating.prototype.ShowTopicPreview = function( jImg, objEvent ) {
	$("body").append("<p id='topic-preview'><img src='/index.cfm/do/api.forums.getTopicPreviewThumb/id/"+ jImg.attr("id") +"/preview.jpg' alt='Loading...' /></p>");
	$("p#topic-preview").css("top",(objEvent.pageY-10)+"px").css("left",(objEvent.pageX+10)+"px").fadeIn("fast");
};


SigmaForumsRating.prototype.SubmitViewAlbumThumbnail = function( jSelect ){
	var objSelf = this;
	$("#newtopicarea").css('background','url(/index.cfm/do/api.gallery.viewGalleryThumbnail/resize/80,80/id/'+jSelect.val()+'/format/view'+jSelect.val()+'.png) top right no-repeat');
};


// This submits the rating.
SigmaForumsRating.prototype.SubmitRating = function( jLink ){
	var objSelf = this;
	var objPostProperties = {
		"event": "SigmaForums:plugins.rating.rate",
		"replyid": jLink.attr("id"),
		"rateType":jLink.attr("title"),
		"rateindex": jLink.attr("alt")
		};
	$.get(
		this.ControllerURL,
		objPostProperties,
		function( objResponse ){
			objSelf.SubmitRatingHandler( objResponse , jLink );
		},
		"json"
		);
};

SigmaForumsRating.prototype.SubmitRatingHandler = function( objResponse , jLink ){
	if(objResponse.data >= 0) { var inputClass = "positive"; } else { var inputClass = "negative";}
	var jTarget = '#rating_'+jLink.attr("id");
	var jElement = $(jTarget);
		jElement.children().remove();
		jElement.append([
			"<span class='"+inputClass+"'>",
			objResponse.data,
			"</span>"
		].join(""));
};

SigmaForumsRating.prototype.SubmitSubscription = function( jLink ){
	var objSelf = this;
	$.get(jLink.attr('href'),'',function(objResponse){objSelf.SubmitSubscriptionHandler(objResponse,jLink);},"json");
};

SigmaForumsRating.prototype.SubmitSubscriptionHandler = function( objResponse , jLink ){
	jLink.children().remove();
	jLink.html(objResponse.DATA);
};


SigmaForumsRating.prototype.SubmitPreview = function(jButton,jForm){
	var objSelf = this;
	var objPostProperties = {
		"do": "api.forums.previewReply",
		"TopicID": jForm.find("input[name='topicid']").val(),
		"Message": jForm.find("textarea[name='message']").val()
		};
	$.post(
		this.ControllerURL,
		objPostProperties,
		function( objResponse ){
			objSelf.SubmitPreviewHandler(objResponse,jButton,jForm);
		},
		"json"
		);
};

SigmaForumsRating.prototype.SubmitPreviewHandler = function(objResponse,jButton,jForm){
	var objSelf = this;
	objSelf.ToggleEditPreview(true);
	$("#previewArea").html(objResponse.DATA);
};

SigmaForumsRating.prototype.ToggleEditPreview = function(swt){
	var previewArea = $("#previewArea");
	var txtarea = $("textarea#message");
	var editbtn = $('#previewedit_btn');
	var previewbtn = $('#preview_btn');
	if(swt) {
		previewArea.css("display","block");
		previewArea.html('');
		txtarea.css("display","none");
		editbtn.css("visibility","visible");
		previewbtn.css("visibility","hidden");
	} else {
		editbtn.css("visibility","hidden");
		previewArea.css("display","none");
		previewArea.html('');
		txtarea.css("display","block");
		previewbtn.css("visibility","visible");
	};
};

FCKeditor_OnComplete = function(editorInstance) {
	document.getElementById(editorInstance.Name + '___Frame').style.height = '450px';
	SigmaForumsRating.prototype.setEditorInstance(editorInstance);
};

SigmaForumsRating.prototype.setEditorInstance = function(editorInstance){
	var objSelf = this;
	this.EditorInstance=editorInstance;
	if(objSelf.ReplyQuoteID) { objSelf.SubmitGetReplyQuote(); };
};
SigmaForumsRating.prototype.getEditorInstance = function() { return this.EditorInstance; };


SigmaForumsRating.prototype.setReplyQuoteID = function(id) {this.ReplyQuoteID=id;};
SigmaForumsRating.prototype.getReplyQuoteID = function() {return this.ReplyQuoteID;};


SigmaForumsRating.prototype.SubmitGetReplyQuote = function() {
	var objSelf = this;
	$.get('/index.cfm/do/api.forums.getQuoteHTML/ObjectID/'+objSelf.ReplyQuoteID,'',function(objResponse){objSelf.setReplyQuoteHandler(objResponse);},"json");
};

SigmaForumsRating.prototype.setReplyQuoteHandler = function(objResponse){
	var objSelf = this;
	objSelf.EditorInstance.InsertHtml('&nbsp;');
	objSelf.EditorInstance.InsertHtml(objResponse.DATA);
};

SigmaForumsRating.prototype.SubmitAdvPreview = function(jButton,jForm){
	var objSelf = this;
	var objPostProperties = {
		"do": "api.forums.advPreviewReply",
		"TopicID": jForm.find("input[name='topicid']").val(),
		"Message": objSelf.getEditorInstance().GetData()
		};
	$.post(
		this.ControllerURL,
		objPostProperties,
		function( objResponse ){
			objSelf.SubmitAdvPreviewHandler(objResponse,jButton,jForm);
		},
		"json"
		);
};

SigmaForumsRating.prototype.SubmitAdvPreviewHandler = function(objResponse,jButton,jForm){
	var objSelf = this;
	$("#adv-preview-area").html(objResponse.DATA);
	$("#adv-preview-area > div").css("border","1px dashed #f47c15");
};
