//COMPILED WITH THE GOOGLE CLOSURE COMPILER
// http://closure-compiler.appspot.com/home

/**
 * Main-Methode, die bei body:onload aufgerufen wird.
 * Initialisiert XML und Startet Seite 0.
 */
function main() {
	var connector = new XMLHttpRequest();
	connector.open("GET", "daten.xml" , false);
	connector.send();
	xml_daten = connector.responseXML;
	max_1 = xml_daten.getElementsByTagName("interesse").length;
	max_2 = xml_daten.getElementsByTagName("aufgabe").length;
	document.getElementById("side_progress_text_2").innerHTML = max_1 + "";
	document.getElementById("side_progress_text_4").innerHTML = max_2 + "";
	var item = document.getElementById("page_0");
	removeClass(item,"unused");
	removeClass(item,"unused_bottom");
	setTimeout(function() {removeClass(document.getElementById("pg_0_heading"),"unused_top");},900);
	setTimeout(function() {removeClass(document.getElementById("pg_0_text"),"unused_top");},1000);
	setTimeout(function() {removeClass(document.getElementById("pg_0_button"),"unused_top");},1200);
}

/**
 * Wechselt die "Seite" bzw. Note indem zunächst die Alte Seite Ausgeblendet wird.
 * Danach wird die neue Seite angezeigt.
 */

function wechsel_seite(zuSeite) {
	var item = document.getElementById("page_" + seite);
	addClass(item,"unused_top");
	setTimeout(function() {addClass(item,"unused");},500);
	counter = 0;
	seite = zuSeite;
	var item2 = document.getElementById("page_" + seite);
	removeClass(item2,"unused");
	removeClass(item2,"unused_bottom");
	setTimeout(function() {removeClass(document.getElementById("pg_" + seite + "_heading"),"unused_top");},600);
	setTimeout(function() {removeClass(document.getElementById("pg_" + seite + "_text"),"unused_top");},700);
}

function hasClass(element,name) {
    return element.className.match(new RegExp('(\\s|^)' + name + '(\\s|$)'));
}

function addClass(element,name) {
    if (!this.hasClass(element,name)) {
    	element.className += " " + name;
    }
}

function removeClass(element,name) {
    if (hasClass(element,name)) {
        var reg = new RegExp('(\\s|^)' + name + '(\\s|$)');
        element.className = element.className.replace(reg,' ');
    }
}

/**
 * Zeigt eine (Detail-)Note der entsprechenden ID an.
 * @param event
 * @param id
 */
function showNote(event,id, from, to,highlight) {
	/*First create a Event to close every other Note*/
	var ev = document.createEvent("MouseEvents");
	ev.initEvent("click",true,false);
	document.getElementById(id).parentNode.dispatchEvent(ev);
	
	/*Show the Note and add Event Listener to close it later*/
	var item = document.getElementById(id);
	removeClass(item,"unused_all");
	setTimeout(function() {removeClass(item,from);},10);
	var item2 = event.currentTarget;
	var handler = function(event) {
		var e = event.target;
		do {
			if(e.id == id) {
				return true;
			} else {
				e = e.parentNode;
			}
		} while(e != undefined);
		addClass(item, to);
		removeClass(item2,"highlight");
		setTimeout(function() {addClass(item,"unused_all");},500);
		document.removeEventListener("click",handler);
	};
	document.addEventListener("click", handler);
	event.stopPropagation();
}

//PAGE_0:

/**
 * Event Handler für den Button auf der Start-Seite.
 * Startet den Test, die Sidebar wird eingeblendet.
 */
function beginn(event) {
	var item1 = document.getElementById("page_0");
	addClass(item1,"unused_left");
	setTimeout(function() {addClass(item1,"unused");},800);
	counter = 0;
	seite = 1;
	var item2 = document.getElementById("page_1");
	removeClass(item2,"unused");
	removeClass(item2,"unused_bottom");
	
	setTimeout(function() {removeClass(document.getElementById("pg_1_heading"),"unused_top");},600);
	setTimeout(function() {removeClass(document.getElementById("pg_1_text"),"unused_top");},700);
	setTimeout(function() {spawn_interesse("pg_1_spawn_1");},800);
	setTimeout(function() {spawn_interesse("pg_1_spawn_2");},900);
	setTimeout(function() {spawn_interesse("pg_1_spawn_3");},1000);
	setTimeout(function() {removeClass(document.getElementById("pg_1_drop_1"),"unused_bottom");},1100);
	setTimeout(function() {removeClass(document.getElementById("pg_1_drop_2"),"unused_bottom");},1200);
	setTimeout(function() {removeClass(document.getElementById("pg_1_drop_3"),"unused_bottom");},1300);
	setTimeout(function() {removeClass(document.getElementById("pg_1_drop_4"),"unused_bottom");},1400);
	setTimeout(function() {removeClass(document.getElementById("pg_1_drop_5"),"unused_bottom");},1500);
	item2 = document.getElementById("side_bar");
	setTimeout(function() {
		removeClass(item2,"unused");
		removeClass(item2,"unused_left");
	},1600);
	setTimeout(function() {removeClass(document.getElementById("side_text_1"),"unused_left");},2200);
	setTimeout(function() {removeClass(document.getElementById("side_progress_1"),"unused_left");},2300);
	setTimeout(function() {removeClass(document.getElementById("side_text_2"),"unused_left");},2400);
	setTimeout(function() {removeClass(document.getElementById("side_progress_2"),"unused_left");},2500);
	setTimeout(function() {removeClass(document.getElementById("side_bottom"),"unused_bottom");},2600);
}

//PAGE_1:

/**
 * Lässt ein gezogenes Element (hier: Interessen-Note) im Detail-Bereich des entsprechenden Droppers verschwinden.
 * Manipuliert ebenfalls alle nötigen Counter.
 * Beinhaltet spawn_interesse() & spawn_button_pg_1()
 */
function drop_interesse(event) {
	event.preventDefault();
	var data = event.dataTransfer.getData("text");
	if(event.currentTarget.id.substr(0,10) == "pg_1_drop_" && data.substr(0,10) == "pg_1_note_") move_interesse(document.getElementById(data),event.currentTarget.id);
}

function drop_kategorie(event) {
	event.preventDefault();
	var data = event.dataTransfer.getData("text");
	if(event.currentTarget.id.substr(0,10) == "pg_1_note_" && data.substr(0,10) == "pg_1_drop_") move_interesse(event.currentTarget,data);
}

function allowDrop(event) {
	event.preventDefault();
}

function dragStart(event) {
	event.dataTransfer.setData("text", event.currentTarget.id);
	addClass(event.currentTarget,"dragged");
	if(current_interesse != null) {
		document.removeEventListener("click",current_interesse_handler);
		removeClass(current_interesse,"highlight");
		current_interesse = null;
	}
}

function dragEnd(event) {
	removeClass(event.currentTarget,"dragged");
}

//Point & CLICK:

function click_interesse(event) {
	if(current_interesse != null) {
		document.removeEventListener("click",current_interesse_handler);
		removeClass(current_interesse,"highlight");
	}
	current_interesse = event.currentTarget;
	addClass(current_interesse,"highlight");
	current_interesse_handler = function(event) {
		var e = event.target;
		do {
			if(e.id == current_interesse.id || e.id == "pg_1_drop_1" || e.id == "pg_1_drop_2" || e.id == "pg_1_drop_3" || e.id == "pg_1_drop_4" || e.id == "pg_1_drop_5") {
				return true;
			} else {
				e = e.parentNode;
			}
		} while(e != undefined);
		removeClass(current_interesse,"highlight");
		current_interesse = null;
		document.removeEventListener("click",current_interesse_handler);
	};
	document.addEventListener("click", current_interesse_handler);
}

function click_kategorie(event) {
	if(current_interesse == null){
		addClass(event.currentTarget,"highlight");
		showNote(event,event.currentTarget.id + "_detail","unused_bottom_note","unused_bottom_note",true);
	} else {
		move_interesse(current_interesse,event.currentTarget.id);
		document.removeEventListener("click",current_interesse_handler);
		removeClass(current_interesse,"highlight");
		current_interesse = null;
	}
}

function move_interesse(item,kategorie_id) {
    var old_Parent = item.parentNode;
    var parentItem = document.getElementById(kategorie_id + "_detail");
    var drop_counter = document.getElementById(kategorie_id + "_counter");
	var i = parseInt(drop_counter.innerHTML) + 1;
	if(i <= 0 || isNaN(i)) {
		drop_counter.innerHTML = "1";
	} else {
		drop_counter.innerHTML = i;
	}
    parentItem.appendChild(item);
	item.style.zIndex=parentItem.style.zIndex + 1;
    if(old_Parent.id == "pg_1_drop_1_detail" || old_Parent.id == "pg_1_drop_2_detail" || old_Parent.id == "pg_1_drop_3_detail" || old_Parent.id == "pg_1_drop_4_detail" || old_Parent.id == "pg_1_drop_5_detail") {
    	drop_counter = document.getElementById(old_Parent.id.substr(0,11) + "_counter");
    	i = parseInt(drop_counter.innerHTML) - 1;
    	if(i <= 0 || isNaN(i)) {
    		drop_counter.innerHTML = "";
    	} else {
    		drop_counter.innerHTML = i;
    	}
    } else {
    	//Entsprechenden Counter in der Progresssbar ändern:
    	var tmp = document.getElementById("progress_1");
    	counter -= 2;
    	tmp.style.width = ((counter / max_1) * 100) + "%";
    	document.getElementById("side_progress_text_1").innerHTML = counter + "";
    	counter += 2;
    	//Neues Element anlegen:
    	if(document.getElementById("pg_1_spawn_1").innerHTML == "" && document.getElementById("pg_1_spawn_2").innerHTML == "" && document.getElementById("pg_1_spawn_3").innerHTML == "") {
        	//fertig!
        	spawn_button_pg_1();
        } else {
        	spawn_interesse(old_Parent.id);
        }
    }
}

/**
 * Erzeugt eine neue Note in einem der drei Spawner:
 * <div id="pg_1_note_??" class="note inner_note text" draggable="true" ondragstart="drag(event)">CONTENT</div>
 */
function spawn_interesse(id) {
	if(counter < max_1) {
		var item = document.createElement("div");
		item.id = "pg_1_note_" + counter;
		item.className = "note inner_note slow text unused_right";
		item.draggable = "true";
		var data = xml_daten.getElementsByTagName("interesse")[counter];
		var content = document.createElement("div");
		content.className="info_button";
		content.appendChild(document.createTextNode("?"));
		item.appendChild(content);
		var tmp = document.createTextNode(data.getElementsByTagName("beschreibung")[0].innerHTML);
		item.appendChild(tmp);
		item.appendChild(document.createElement("br"));
		var tmp = document.createElement("div");
		tmp.id = item.id + "_cp_A";
		tmp.className = "cp unused";
		tmp.appendChild(document.createTextNode(data.getElementsByTagName("cp_A")[0].innerHTML));
		item.appendChild(tmp);
		tmp = document.createElement("div");
		tmp.id = item.id + "_cp_W";
		tmp.className = "cp unused";
		tmp.appendChild(document.createTextNode(data.getElementsByTagName("cp_W")[0].innerHTML));
		item.appendChild(tmp);
		tmp = document.createElement("div");
		tmp.id = item.id + "_cp_M";
		tmp.className = "cp unused";
		tmp.appendChild(document.createTextNode(data.getElementsByTagName("cp_M")[0].innerHTML));
		item.appendChild(tmp);
		item.appendChild(document.createElement("br"));
		var help = document.createElement("div");
		help.id="pg_1_note_" + counter + "_help";
		help.className = "note help text unused_right unused_all";
		var modul = document.createElement("b");
		modul.appendChild(document.createTextNode(data.getElementsByTagName("modul")[0].innerHTML));
		help.appendChild(modul);
		modul = document.createElement("ul");
		modul.innerHTML = data.getElementsByTagName("info")[0].innerHTML;
		help.appendChild(modul);
		help.style.zIndex = 14;
		item.appendChild(help);
		document.getElementById(id).appendChild(item);
		item.addEventListener("dragstart",dragStart);
		//item.addEventListener("drag",drag);
		item.addEventListener("dragend",dragEnd);
		item.addEventListener("drop",drop_kategorie);
		item.addEventListener("dragover",allowDrop);
		item.addEventListener("click",click_interesse);
		var help_id = "pg_1_note_" + counter + "_help";
		content.addEventListener("click",function(event) {
			showNote(event,help_id,"unused_right","unused_right",false);
		});
		setTimeout(function() {removeClass(item,"unused_right");},100);
		counter += 1;
	} else {
		counter++;
	}
}

/**
 * Erzeugt einen Button auf der ersten Seite nachdem alle Notes abgearbeitet wurden.
 * Beinhaltet einen entsprechenden EventListener mit wechsel_seite(2) und spawn_aufgabe().
 */
function spawn_button_pg_1() {
	addClass(document.getElementById("pg_1_text"),"unused_top");
	addClass(document.getElementById("pg_1_spawn_1"),"unused_all");
	addClass(document.getElementById("pg_1_spawn_2"),"unused_all");
	addClass(document.getElementById("pg_1_spawn_3"),"unused_all");
	var item = document.createElement("div");
	item.id="pg_1_button";
	item.className="button button_center heading unused_top";
	item.innerHTML = "<p>Weiter</p>";
	document.getElementById("pg_1_upper_content").appendChild(item);
	item.addEventListener("click",function(event) {
		if(event.currentTarget == undefined) {}
		else {
			//event.stopPropagation();
			//document.findElementById("pg_" + seite + "_button").removeEventListener("click",this);
			wechsel_seite(2);
			setTimeout(spawn_aufgabe,700);
		}
	});
	removeClass(document.getElementById("pg_1_continue_text"),"unused_all");
	setTimeout(function() {addClass(document.getElementById("pg_1_text"),"unused_all");},500);
	setTimeout(function() {removeClass(document.getElementById("pg_1_continue_text"),"unused_top");},600);
	setTimeout(function() {removeClass(item,"unused_top");},700);
}

//PAGE_2:

/**
 * Button-Onclick-Handler zur Korrektur der vorherigen Aufgabe.
 */
function roll_back() {
	counter -= 2;
	document.getElementById("progress_2").style.width = ((counter / max_2) * 100) + "%";
	document.getElementById("side_progress_text_3").innerHTML = counter + "";
	if(counter >= max_2 - 1) {
		removeClass(document.getElementById("pg_2_text"),"unused_all");
		removeClass(document.getElementById("pg_2_task"),"unused_all");
		removeClass(document.getElementById("pg_2_spawn_0"),"unused_all");
		removeClass(document.getElementById("pg_2_spawn_1"),"unused_all");
		removeClass(document.getElementById("pg_2_spawn_2"),"unused_all");
		removeClass(document.getElementById("pg_2_spawn_3"),"unused_all");
		removeClass(document.getElementById("pg_2_text"),"unused_top");
		addClass(document.getElementById("pg_2_button"),"unused_bottom");
		addClass(document.getElementById("pg_2_continue_text"),"unused_top");
		setTimeout(function() {
			document.getElementById("pg_2_upper_content").removeChild(document.getElementById("pg_2_button"));
			addClass(document.getElementById("pg_2_continue_text"),"unused_all");
			spawn_aufgabe();
		},500);
	} else {
		hide_aufgabe();
	}
	//roll_back:
	rolled_back = true;
	setTimeout(function() {addClass(document.getElementById("pg_2_back"),"unused_right");},0);
	
	//ALTE ANTWORT LÖSCHEN:
	var parent = document.getElementById("pg_2_answers");
	var name = "pg_2_task_" + counter;
	for(i=parent.childNodes.length - 1;i >= 0;i--) {
		if (parent.childNodes[i].id.lastIndexOf(name, 0) === 0) {
			parent.removeChild(parent.childNodes[i]);
            return true;
        }
	}
	return false;
}

function hide_aufgabe() {
	setTimeout(function() {addClass(document.getElementById("pg_2_task"),"unused_top");},0);
	setTimeout(function() {addClass(document.getElementById("pg_2_graphic"),"unused_right");},100);
	setTimeout(function() {addClass(document.getElementById("pg_2_spawn_0"),"unused_right");},200);
	setTimeout(function() {addClass(document.getElementById("pg_2_spawn_1"),"unused_right");},300);
	setTimeout(function() {addClass(document.getElementById("pg_2_spawn_2"),"unused_right");},400);
	setTimeout(function() {addClass(document.getElementById("pg_2_spawn_3"),"unused_right");},500);
	
	setTimeout(clear_aufgabe,1000);
}

/**
 * Entleert die Seite 2 für neue Aufgaben.
 */
function clear_aufgabe() {
	document.getElementById("pg_2_task").innerHTML = "";
	document.getElementById("pg_2_graphic").innerHTML = "";
	for(i=0;i<4;i++) {
		document.getElementById("pg_2_spawn_" + i).innerHTML = "";
	}
	
	spawn_aufgabe();
}


/**
 * Generiert eine neue Aufgabe in der Page_2 Note.
 * Jede angeklickte Antwort erzeugt eine neue Aufgabe.
 */
function spawn_aufgabe() {
	if(counter >= max_2) {
		//Abbruchbedingung bei counter >= maxCount
		spawn_button_pg_2();
		counter++;
	} else {
		var content = xml_daten.getElementsByTagName("aufgabe")[counter];
		//pg_2_task:
		document.getElementById("pg_2_task").innerHTML = content.getElementsByTagName("beschreibung")[0].innerHTML;
		
		//pg_2_graphic:
		document.getElementById("pg_2_graphic").innerHTML = content.getElementsByTagName("grafik")[0].innerHTML;
		
		//pg_2_answers:
		for(i = 0; i < 4; i++) {
			var antwort = content.getElementsByTagName("antwort")[i];
			text = document.createTextNode(antwort.getElementsByTagName("beschreibung")[0].innerHTML);
			var item = document.createElement("div");
			item.id="pg_2_task_" + counter + "_" + i;
			item.className="note inner_note text task";
			item.appendChild(text);
			item.appendChild(document.createElement("br"));
			var cp = document.createElement("div");
			cp.id = item.id + "_cp_A";
			cp.className = "cp unused";
			cp.appendChild(document.createTextNode(antwort.getElementsByTagName("cp_A")[0].innerHTML));
			item.appendChild(cp);
			cp = document.createElement("div");
			cp.id = item.id + "_cp_W";
			cp.className = "cp unused";
			cp.appendChild(document.createTextNode(antwort.getElementsByTagName("cp_W")[0].innerHTML));
			item.appendChild(cp);
			cp = document.createElement("div");
			cp.id = item.id + "_cp_M";
			cp.className = "cp unused";
			cp.appendChild(document.createTextNode(antwort.getElementsByTagName("cp_M")[0].innerHTML));
			item.appendChild(cp);
			document.getElementById("pg_2_spawn_" + i).appendChild(item);
			var handler = function(event) {
				if(event.currentTarget == undefined) {}
				else {
					var target = event.currentTarget
					addClass(target,"highlight");
					setTimeout(function() {
						document.getElementById("pg_2_answers").appendChild(document.getElementById(target.id));
						document.getElementById(target.id).removeEventListener("click",handler);
						
						document.getElementById("progress_2").style.width = ((counter / max_2) * 100) + "%";
						document.getElementById("side_progress_text_3").innerHTML = counter + "";
						
						if(rolled_back) {
							setTimeout(function() {removeClass(document.getElementById("pg_2_back"),"unused_right");},1100);
							rolled_back = false;
						}
						
						hide_aufgabe();
					},200);
				}
			};
			item.addEventListener("click",handler);
		}
		setTimeout(function() {removeClass(document.getElementById("pg_2_task"),"unused_top");},100);
		setTimeout(function() {removeClass(document.getElementById("pg_2_graphic"),"unused_right");},200);
		setTimeout(function() {removeClass(document.getElementById("pg_2_spawn_0"),"unused_right");},300);
		setTimeout(function() {removeClass(document.getElementById("pg_2_spawn_1"),"unused_right");},400);
		setTimeout(function() {removeClass(document.getElementById("pg_2_spawn_2"),"unused_right");},500);
		setTimeout(function() {removeClass(document.getElementById("pg_2_spawn_3"),"unused_right");},600);
		counter += 1;
	}
	
}

/**
 * Nach Abarbeitung aller Aufgaben wird ein Button auf der zweiten Seite angezeigt.
 * Entsprechender EventListener mit wechsel_seite(3) und spawn_auswertung().
 */
function spawn_button_pg_2() {
	addClass(document.getElementById("pg_2_text"),"unused_top");
	addClass(document.getElementById("pg_2_task"),"unused_top");
	addClass(document.getElementById("pg_2_spawn_0"),"unused_all");
	addClass(document.getElementById("pg_2_spawn_1"),"unused_all");
	addClass(document.getElementById("pg_2_spawn_2"),"unused_all");
	addClass(document.getElementById("pg_2_spawn_3"),"unused_all");
	var item = document.createElement("div");
	item.id="pg_2_button";
	item.className="button button_center heading unused_top";
	item.innerHTML = "<p>Weiter</p>";
	document.getElementById("pg_2_upper_content").appendChild(item);
	item.addEventListener("click",function(event) {
		if(event.currentTarget == undefined) {}
		else {
			//event.stopPropagation();
			//document.findElementById("pg_" + seite + "_button").removeEventListener("click",this);
			wechsel_seite(3);
			spawn_auswertung();
		}
	});
	removeClass(document.getElementById("pg_2_continue_text"),"unused_all");
	setTimeout(function() {
		addClass(document.getElementById("pg_2_text"),"unused_all");
		addClass(document.getElementById("pg_2_task"),"unused_all");
	},500);
	setTimeout(function() {removeClass(document.getElementById("pg_2_continue_text"),"unused_top");},600);
	setTimeout(function() {removeClass(item,"unused_top");},700);
}

//PAGE_3:

/**
 * Führt die Auswertung der Ergebnisse durch und generiert die entsprechenden Texte aus der XML.
 */
function spawn_auswertung() {
	var xml_auswertung = xml_daten.getElementsByTagName("auswertung")[0];
	var max_cp = [0,0,0];
	var cp = [0,0,0];
	//PG_1:
	var rating = 1;
	var i;
	for(j = 1; j < 6; j++) {
		var parent = document.getElementById("pg_1_drop_" + j + "_detail");
		i = 0;
		var e = parent.childNodes[i];
		while(e != undefined) {
			//Calculate the cp for A,W,M:
			var a = parseFloat(document.getElementById(e.id + "_cp_A").innerHTML);
			var w = parseFloat(document.getElementById(e.id + "_cp_W").innerHTML);
			var m = parseFloat(document.getElementById(e.id + "_cp_M").innerHTML);
			max_cp[0] += a;
			max_cp[1] += w;
			max_cp[2] += m;
			cp[0] += a * rating;
			cp[1] += w * rating;
			cp[2] += m * rating;
			e = parent.childNodes[++i];
		}
		rating -= 0.25;
	}
	
	/** SVG - Triangle:
	 * AI -> Y = 30 to 463.01 				-> X = 250
	 * WI -> 250x - 433.01y = -75489.13		-> X = 125 to 500
	 * MI -> -250x -433.01y = -200489.13	-> X = 0 to 375
	 */
	var weight = [cp[0]*cp[0], cp[1]*cp[1], cp[2]*cp[2]];
	var svg_x = 0;
	var svg_y = 0;
	if(weight[0] == 0 && weight[1] == 0 && weight[2] == 0) {
		svg_x = 250;
		svg_y = 318.67;
	} else {
		var summe = weight[0] + weight[1] + weight[2];
		for(var i = 0; i < 3; i++) weight[i] /= summe;
		svg_x = (2*weight[1]+weight[0])/2;
		svg_y = 0.8660254038*weight[0];
		svg_x *= 500;
		svg_y *= 500;
		svg_y = 463.01 - svg_y;
	}
	var item = document.createElementNS("http://www.w3.org/2000/svg","circle");
	item.setAttributeNS(null,"cx",svg_x);
	item.setAttributeNS(null,"cy",svg_y);
	item.setAttributeNS(null,"r",5);
	item.setAttributeNS(null,"fill","black");
	document.getElementById("pg_3_svg").appendChild(item);
	
	//PG_3 (text & cp):
	var cutoff_cp = [parseFloat(xml_auswertung.getElementsByTagName("cp_A_min")[0].innerHTML)*max_cp[0],parseFloat(xml_auswertung.getElementsByTagName("cp_W_min")[0].innerHTML)*max_cp[1],parseFloat(xml_auswertung.getElementsByTagName("cp_M_min")[0].innerHTML)*max_cp[2]];
	var result = "";
	var none = false;
	if(cp[0] > cutoff_cp[0] && cp[1] > cutoff_cp[1] && cp[2] > cutoff_cp[2]) result = xml_auswertung.getElementsByTagName("AWM")[0].innerHTML;
	else if(cp[0] > cutoff_cp[0] && cp[1] > cutoff_cp[1]) result = xml_auswertung.getElementsByTagName("AW")[0].innerHTML;
	else if(cp[0] > cutoff_cp[0] && cp[2] > cutoff_cp[2]) result = xml_auswertung.getElementsByTagName("AM")[0].innerHTML;
	else if(cp[0] > cutoff_cp[0]) result = xml_auswertung.getElementsByTagName("A")[0].innerHTML;
	else if(cp[1] > cutoff_cp[1] && cp[2] > cutoff_cp[2]) result = xml_auswertung.getElementsByTagName("WM")[0].innerHTML;
	else if(cp[1] > cutoff_cp[1]) result = xml_auswertung.getElementsByTagName("W")[0].innerHTML;
	else if(cp[2] > cutoff_cp[2]) result = xml_auswertung.getElementsByTagName("M")[0].innerHTML;
	else {
		none = true;
		result = xml_auswertung.getElementsByTagName("keine")[0].innerHTML;
	}
	
	//PG_2:
	var parent = document.getElementById("pg_2_answers")
	i = 0;
	var e = parent.childNodes[0];
	while(e != undefined) {
		cp[0] += parseFloat(document.getElementById(e.id + "_cp_A").innerHTML);
		cp[1] += parseFloat(document.getElementById(e.id + "_cp_W").innerHTML);
		cp[2] += parseFloat(document.getElementById(e.id + "_cp_M").innerHTML);
		e = parent.childNodes[++i];
	}
	
	//XML:MAX AUFGABEN
	var aufgaben = xml_daten.getElementsByTagName("aufgabe");
	for(var i = 0; i < aufgaben.length; i++) {
		var antwort_cp = aufgaben[i].getElementsByTagName("cp_A");
		for(var j = 0; j < antwort_cp.length; j++) {
			var k = parseFloat(antwort_cp[j].innerHTML);
			if(k > 0) max_cp[0] += k;
		}
		antwort_cp = aufgaben[i].getElementsByTagName("cp_W");
		for(var j = 0; j < antwort_cp.length; j++) {
			var k = parseFloat(antwort_cp[j].innerHTML);
			if(k > 0) max_cp[1] += k;
		}
		antwort_cp = aufgaben[i].getElementsByTagName("cp_M");
		for(var j = 0; j < antwort_cp.length; j++) {
			var k = parseFloat(antwort_cp[j].innerHTML);
			if(k > 0) max_cp[2] += k;
		}
	}
	//PG_3 (text & cp)
	var cutoff_max = [parseFloat(xml_auswertung.getElementsByTagName("cp_A_max")[0].innerHTML)*max_cp[0],parseFloat(xml_auswertung.getElementsByTagName("cp_W_max")[0].innerHTML)*max_cp[1],parseFloat(xml_auswertung.getElementsByTagName("cp_M_max")[0].innerHTML)*max_cp[2]];
	if(cp[0] > cutoff_max[0] || cp[1] > cutoff_max[1] || cp[2] > cutoff_max[2]) {
		result = xml_auswertung.getElementsByTagName("gut")[0].innerHTML + result;
	} else if(!none) {
		result = xml_auswertung.getElementsByTagName("mid")[0].innerHTML + result;
	}
	document.getElementById("pg_3_auswertung").innerHTML = result;
	
	//Eignungsgrad SVG:
	for(var i=0; i < 3; i++) {
		max_cp[i] -= cutoff_cp[i];
		cp[i] -= cutoff_cp[i];
		cp[i] = cp[i] < 0 ? 0 : cp[i];
	}
	var grad = Math.max(cp[0]/max_cp[0],cp[1]/max_cp[1],cp[2]/max_cp[2]);
	grad *= 500;
	grad -= 2.5;
	item = document.createElementNS("http://www.w3.org/2000/svg","rect");
	item.setAttributeNS(null,"x",grad);
	item.setAttributeNS(null,"y",510);
	item.setAttributeNS(null,"rx",2.5);
	item.setAttributeNS(null,"ry",2.5);
	item.setAttributeNS(null,"height",40);
	item.setAttributeNS(null,"width",5);
	item.setAttributeNS(null,"fill","black");
	document.getElementById("pg_3_svg").appendChild(item);
	
	//ANIMATION:
	setTimeout(function() {removeClass(document.getElementById("pg_3_auswertung"),"unused_top");},800);
	setTimeout(function() {removeClass(document.getElementById("pg_3_print"),"unused_top");},900);
	setTimeout(function() {removeClass(document.getElementById("pg_3_svg_outer"),"unused_top");},1000);
	
}

/*function animate_table(i) {
	if(i < counter) {
		removeClass(document.getElementById("pg_3_row_" + i),"unused_top");
		setTimeout(function(){ animate_table(++i);} ,100);
	} else {
		removeClass(document.getElementById("pg_3_print"),"unused_top");
	}
}*/