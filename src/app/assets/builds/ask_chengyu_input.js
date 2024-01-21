(() => {
  // app/javascript/custom/ask_chengyu_input.js
  window.globalInputAnswerText = function(str) {
    var elem = document.getElementById("input_answer");
    if (elem.value.length < 4) {
      elem.value = elem.value + str;
    }
  };
  window.globalDeleteAnswerText = function() {
    var elem = document.getElementById("input_answer");
    elem.value = elem.value.slice(0, -1);
  };
})();
//# sourceMappingURL=assets/ask_chengyu_input.js.map
