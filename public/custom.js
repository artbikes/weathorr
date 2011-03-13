"#time".onClick(function(event) {
  event.stop();
  $('msg').load("/time");
});

"#server".onClick(function(event) {
  event.stop();
  $('msg').load("/response");
});
