window.globalInputAnswerText = function(str){
  var elem = document.getElementById("input_answer");
  if(elem.value.length < 4) {
    elem.value = elem.value + str;
  }
}
window.globalDeleteAnswerText = function(){
  var elem = document.getElementById("input_answer");
  elem.value = elem.value.slice( 0, -1 );
}
