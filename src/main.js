function switchText() {
  var obj1 = document.getElementById("from_address").value;
  var obj2 = document.getElementById("to_address").value;

  var temp = obj1;
  obj1 = obj2;
  obj2 = temp;

  // Save the swapped values to the input element.
  document.getElementById("from_address").value = obj1;
  document.getElementById("to_address").value = obj2;
  
  document.getElementById("from_address").toggleAttribute("readonly");
  document.getElementById("to_address").toggleAttribute("readonly");
}

function help_liquidity() {
  //tell the user how to provide liquidity in a prompt
  alert(
  "Wondering why the + symbol in between?\n\n\
Providing liquidity is not the same as exchange feature. Please make sure that you understand \
the process of providing liquidity before going for it. This would prevent any unfortunate gas fee loss.\n"
  );
}
