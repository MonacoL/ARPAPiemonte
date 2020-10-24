function CheckImageExistance(path) {
    var http = new XMLHttpRequest();
    http.open('HEAD', path, false);
    http.setRequestHeader('Cache-Control', 'no-cache, no-store, must-revalidate');
    http.setRequestHeader('Pragma', 'no-cache');
    http.setRequestHeader('Expires', '0');
    http.send();
    if (http.status != 404) {
        return 1;
    } else {
        return 0;
    }        
}

function GetSlideShow(raggr,tmaxORtmin, inizialiregione, nomeregione) {
    var SlideShowCode = "";
    SlideShowCode += "<div style=\"font-size:16px; text-align:center\"><b>REGIONE " + nomeregione + "</b></div><br/>";
    let imgPresence = [0, 0, 0];
    var imgPaths = ["", "", ""];
    imgPaths[0] = "Grafici/" + inizialiregione + "_" + tmaxORtmin + "_150_"+raggr+".png";
    imgPaths[1] = "Grafici/" + inizialiregione + "_" + tmaxORtmin + "_300_"+raggr+".png";
    imgPaths[2] = "Grafici/" + inizialiregione + "_" + tmaxORtmin + "_700_"+raggr+".png";

    //var baseURL = window.location.href.split('?')[0];
    //baseURL = baseURL.substr(0,(baseURL.length-10));
    //imgPresence[0] = CheckImageExistance(imgPaths[0]);
    //alert(imgPaths[0]+": "+imgPresence[0]); 

    imgPresence[0] = CheckImageExistance(imgPaths[0]);
    
    imgPresence[1] = CheckImageExistance(imgPaths[1]);

    imgPresence[2] = CheckImageExistance(imgPaths[2]);

    var totalImages = 0;
    totalImages = imgPresence[0] + imgPresence[1] + imgPresence[2];
    if (totalImages == 0) {
        SlideShowCode += "Non sono presenti dati."
    } else if (totalImages == 1) {
        var i = 0;
        for (i = 0; i < 3; i++) { //Caso in cui � presente una sola immagine: non sapendo a priori qual'� quella presente, ciclo su tutte, tanto...
            if (imgPresence[i] == 1) { //... eseguo il controllo sulla presenza delle immagini
                random_n=Math.floor(Math.random() * 1000000) + 100000;
                SlideShowCode += "<img src=\"" + imgPaths[i] +"?d="+random_n+"\">";
            }
        }
    } else if (totalImages > 1) {
        var str = "";
        if (imgPresence[0] == 1) {
            str += "_1";
        } else {
            str += "_0";
        }
        if (imgPresence[1] == 1) {
            str += "_1";
        } else {
            str += "_0";
        }
        if (imgPresence[2] == 1) {
            str += "_1";
        } else {
            str += "_0";
        }
        
        SlideShowCode += "<iframe src='slideshow.html?" + tmaxORtmin + "/" + inizialiregione +"/"+raggr+ "/" + str + "' width=950 height=460 style=\"border:0; margin:0; padding:0\"></iframe>";
    }
    // specify popup options 
    var SlideShowOptions =
    {
        'maxWidth': '1500',
        'className': 'custom'
    }
    return [SlideShowCode, SlideShowOptions];
}

function AddRegionLabel(textLatLng, labelregione, GotSlideShow) { //Funzione per aggiungere una label sulla mappa
    var myTextLabel = L.marker(textLatLng, {
        icon: L.divIcon({
            className: 'text-labels',   // Nome della classe CSS per formattare il testo, la gestisco in index.php
            html: labelregione
        }),
        zIndexOffset: 1000     // Cos� impongo che la label vada sopra ogni possibile layer gi� presente
    });
    myTextLabel.addTo(mymap);
    var popup = myTextLabel.bindPopup(GotSlideShow[0], GotSlideShow[1]);
    popup.on("popupclose", CentraMappa);
}

function AddRegionLabelBeginning(textLatLng, labelregione) { //Funzione per aggiungere una label sulla mappa
    var myTextLabel = L.marker(textLatLng, {
        icon: L.divIcon({
            className: 'text-labels',   // Nome della classe CSS per formattare il testo, la gestisco in index.php
            html: labelregione
        }),
        zIndexOffset: 1000     // Cos� impongo che la label vada sopra ogni possibile layer gi� presente
    });
    myTextLabel.addTo(mymap);
    myTextLabel.bindPopup("Carica i dati relativi alla temperatura richiesta!");
}

function onEachFeature(feature, layer) {
    // var GotSlideShow = GetSlideShow(GLOBALraggr,GLOBALtmaxORtmin, feature.properties.iniziali, feature.properties.name.toUpperCase());
    // if (feature.properties.lat && feature.properties.long) {
    //     AddRegionLabel([feature.properties.lat, feature.properties.long], feature.properties.labelName, GotSlideShow);
    // }
    // var popup = layer.bindPopup(GotSlideShow[0], GotSlideShow[1]);
    // popup.on("popupclose", CentraMappa);
    layer.setStyle({
        weight: 1,
        color: "rgba("+feature.properties.colori+")",
        opacity: 0,
        dashArray: '',
        fillOpacity: 0.6,
        fillColor: "rgba("+feature.properties.colori+")"
    });
}


function CentraMappa() {
    mymap.setView([42.104154, 12.646361], 13);
}

function AddItemToSelect(ID, item) {
    // get reference to select element
    var sel = document.getElementById(ID);

    // create new option element
    var opt = document.createElement('option');

    // create text node to add to option element (opt)
    opt.appendChild(document.createTextNode(item));

    // set value property of opt
    opt.value = item;

    // add opt to end of select box (sel)
    sel.appendChild(opt); 
}

function RemoveItemFromSelect(ID, item) {
    var sel = document.getElementById(ID);
    for (var i=0; i<sel.length; i++) {
        if (sel.options[i].value == item)
            sel.remove(i);
    }    
}

function LoadRun() {
    e = document.getElementById("ddlT");
    var tmaxORtmin  = e.options[e.selectedIndex].value;
    e = document.getElementById("ddlRaggr");
    var raggr  = e.options[e.selectedIndex].value;
    window.location.href = "index.html?"+tmaxORtmin+"/"+raggr;
}

function UpdateRunSelection() {
    document.getElementById("ddlT").value = GLOBALtmaxORtmin;
    document.getElementById("ddlRaggr").value = GLOBALraggr;
    raggr=document.getElementById("ddlRaggr").options[document.getElementById("ddlRaggr").selectedIndex].text;
    document.getElementById("RunCaricato").innerHTML="Dati caricati: "+GLOBALtmaxORtmin+" "+raggr;
}

function getExactPeriod(path){
    var output;
    var request = new XMLHttpRequest();
    request.open('GET', path, false);
    request.send(null);
    output=request.responseText;
    output=output.split(/\n/);
    strOutput="dal "+output[0] + " al "+output[1]
    return strOutput;
}

function AddTileLayer(mp){
    L.tileLayer('https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}', {
        attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/">OpenStreetMap</a> contributors, <a href="https://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="https://www.mapbox.com/">Mapbox</a><br/>Thanks to <a href="https://github.com/stefanocudini/leaflet-panel-layers" target="_blank">Stefano Cudini</a> for Leaflet Panel Layers',
        minZoom: 6,
        maxZoom: 6,
        id: 'mapbox/satellite-v9', //mapbox/satellite-v9  mapbox/streets-v11
        tileSize: 512,
        zoomOffset: -1,
        accessToken: 'pk.eyJ1IjoibW9uYWNvbHVjYXZlIiwiYSI6ImNrNnJwZW5ldDA2anQzZG15OWJweGMydzIifQ.2jqQlm490VG8mHE60PXv4A'
    }).addTo(mp);
}

function CreaMappa(nome, livello){
    mappa=L.map(nome).setView([42.104154, 12.646361], 6);
    AddTileLayer(mappa);
    mappa.dragging.disable(); //rimuovi la possibilità di draggare la mappa dove vuoi
    mappa.removeControl(mappa.zoomControl); //rimuovi il controllo zoom +- che ci sarebbe in alto a sinistra
    mappa.doubleClickZoom.disable();  
    livello.addTo(mappa);
    return mappa;
}

function getColor(d) {
    return d > 600 ? '#ab00ab' :
        d > 500  ? '#ff00a2' :
        d > 400  ? '#ff0000' :
        d > 300  ? '#ff8205' :
        d > 200  ? '#ffc40e' :
        d > 150  ? '#ffff00' :
        d > 100  ? '#1dc400' :
        d > 75  ? '#73f5a5' :
        d > 50   ? '#1b3fff' :
        d > 25   ? '#4181ff' :
        d > 10   ? '#a5f0ff' :
        d > 5  ? '#969696' :
        d > 1  ? '#d2d2d2' :
                    '#FFFFFF';
}


function ApplicaLegenda(map){
    var legend = L.control({position: 'bottomleft'});

    legend.onAdd = function (map) {
        var div = L.DomUtil.create('div', 'info legend'),
        grades=[1,5,10,25,50,75,100,150,200,300,400,500,600];
        div.innerHTML = "<b>LEGENDA</b> (mm)<br/>"
        // loop through our density intervals and generate a label with a colored square for each interval
        for (var i = 0; i < grades.length; i++) {
            div.innerHTML +=
                '<i style="background:' + getColor(grades[i] + 1) + '"></i> ' +
                grades[i] + (grades[i + 1] ? '&ndash;' + grades[i + 1] + '<br>' : '+');
        }

        return div;  
    };

    legend.addTo(map);
}

function getStringaPeriodo(path){
    var output;
    var request = new XMLHttpRequest();
    request.open('GET', path, false);
    request.send(null);
    output=request.responseText;
    return output   

}