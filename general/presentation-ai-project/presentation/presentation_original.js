//COMPILED WITH THE GOOGLE CLOSURE COMPILER
// http://closure-compiler.appspot.com/home

/**
 * Main-Methode, die bei body:onload aufgerufen wird.
 * Zeigt Präsentationsseite 0
 */
function main_presentation() {
	var item = document.getElementById("presentation_0");
	removeClass(item,"unused");
	removeClass(item,"unused_bottom");
	setTimeout(function() {removeClass(document.getElementById("presentation_0_heading"),"unused_top");},600);
	setTimeout(function() {removeClass(document.getElementById("presentation_0_text"),"unused_top");},700);
//	setTimeout(function() {
//		var forward = document.getElementById("presentation_forward");
//		removeClass(forward,"unused");
//		removeClass(forward,"unused_bottom");
//	},800);
}

function presentation_forward() {
	var item = document.getElementById("presentation_" + seite);
	if(item != null) {
	    addClass(item,"unused_top");
	    setTimeout(function() {addClass(item,"unused");},500);
	}
	counter = 0;
	seite += 1;
	var item2 = document.getElementById("presentation_" + seite);
	if(item2 == null) {
		//addClass(document.getElementById("presentation_forward"),"unused_bottom");
		//addClass(document.getElementById("presentation_backward"),"unused_bottom");
		setTimeout(function() {
			addClass(document.getElementById("presentation_buttons"),"unused_all");
		},500);
	} else {
//		if(seite == 1) {
//			var backward = document.getElementById("presentation_backward");
//			removeClass(backward,"unused");
//			removeClass(backward,"unused_bottom");
//		}
		removeClass(item2,"unused");
		removeClass(item2,"unused_bottom");
		setTimeout(function() {removeClass(document.getElementById("presentation_" + seite + "_heading"),"unused_top");},600);
		setTimeout(function() {removeClass(document.getElementById("presentation_" + seite + "_text"),"unused_top");},700);
	}
}

function presentation_backward() {
	var item = document.getElementById("presentation_" + seite);
	var heading = document.getElementById("presentation_" + seite + "_heading");
	var text = document.getElementById("presentation_" + seite + "_text");
	if(seite == 0) {
	    return;
	}
	if(item != null) {
	addClass(item,"unused_bottom");
        setTimeout(function() {
            addClass(item,"unused");
            addClass(heading,"unused_top");
            addClass(text,"unused_top");
        },500);
	}
	counter = 0;
	seite -= 1;
	var item2 = document.getElementById("presentation_" + seite);
	removeClass(item2,"unused");
	removeClass(item2,"unused_top");
//	if(seite == 0) {
//		var backward = document.getElementById("presentation_backward");
//		addClass(backward,"unused_bottom");
//		setTimeout(function() {addClass(backward,"unused");},500);
//	}
}

function presentation_onKeyDown(event) {
    var key = event.keyCode;
    if(key == 13 || key == 32) {
        presentation_forward();
    } else if(key == 8) {
        presentation_backward();
    }
}