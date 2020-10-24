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

function GetSlideShow(numeroZona) {
    var SlideShowCode = "";
    SlideShowCode += "<div style=\"font-size:16px; text-align:center\"><b>AREA " + GetDPCAreaNumber(numeroZona) + "</b></div><br/>";
    let imgPresence = [0, 0];
    var imgPaths = ["", ""];
    imgPaths[0] = "Grafici/VerificaQPFMASSIMA_"+numeroZona+".png";
    imgPaths[1] = "Grafici/VerificaQPFMEDIA_"+numeroZona+".png";

    //var baseURL = window.location.href.split('?')[0];
    //baseURL = baseURL.substr(0,(baseURL.length-10));
    //imgPresence[0] = CheckImageExistance(imgPaths[0]);
    //alert(imgPaths[0]+": "+imgPresence[0]); 

    imgPresence[0] = CheckImageExistance(imgPaths[0]);
    
    imgPresence[1] = CheckImageExistance(imgPaths[1]);

    var totalImages = 0;
    totalImages = imgPresence[0] + imgPresence[1]
    if (totalImages == 0) {
        SlideShowCode += "Non sono presenti dati."
    } else if (totalImages == 1) {
        var i = 0;
        for (i = 0; i < 2; i++) { //Caso in cui � presente una sola immagine: non sapendo a priori qual'� quella presente, ciclo su tutte, tanto...
            if (imgPresence[i] == 1) { //... eseguo il controllo sulla presenza delle immagini
                random_n=Math.floor(Math.random() * 1000000) + 100000;
                SlideShowCode += "<img src=\"" + imgPaths[i] +"?d="+random_n+"\">";
            }
        }
    } else if (totalImages > 1) {
        SlideShowCode += "<iframe src='slideshow.html?"+numeroZona+"' width=550 height=580 style=\"border:0; margin:0; padding:0\"></iframe>";
    }
    // specify popup options 
    var SlideShowOptions =
    {
        'maxWidth': '1500',
        'className': 'custom'
    }
    return [SlideShowCode, SlideShowOptions];
}

function AddRegionLabel(textLatLng, labelArea, GotSlideShow) { //Funzione per aggiungere una label sulla mappa
    var myTextLabel = L.marker(textLatLng, {
        icon: L.divIcon({
            className: 'text-labels',   // Nome della classe CSS per formattare il testo, la gestisco in index.php
            html: labelArea
        }),
        zIndexOffset: 1000     // Cos� impongo che la label vada sopra ogni possibile layer gi� presente
    });
    myTextLabel.addTo(mymap);
    var popup = myTextLabel.bindPopup(GotSlideShow[0], GotSlideShow[1]);
    popup.on("popupclose", CentraMappa);
}

function AddRegionLabelBeginning(textLatLng, labelArea) { //Funzione per aggiungere una label sulla mappa
    var myTextLabel = L.marker(textLatLng, {
        icon: L.divIcon({
            className: 'text-labels',   // Nome della classe CSS per formattare il testo, la gestisco in index.php
            html: labelArea
        }),
        zIndexOffset: 1000     // Cos� impongo che la label vada sopra ogni possibile layer gi� presente
    });
    myTextLabel.addTo(mymap);
    myTextLabel.bindPopup("Schiaccia sul bottone carica dati!");
}

function onEachFeature(feature, layer) {
    var GotSlideShow = GetSlideShow(feature.properties.OBJECTID);
    if (feature.properties.lat && feature.properties.long) {
        AddRegionLabel([feature.properties.lat, feature.properties.long], feature.properties.labelName, GotSlideShow);
    }
    var popup = layer.bindPopup(GotSlideShow[0], GotSlideShow[1]);
    popup.on("popupclose",CentraMappaOnPopupClose);
    var colore=getAreaColor(feature.properties.OBJECTID);
    layer.setStyle({
        weight: 1,
        color: "#000000",
        dashArray: '',
        fillOpacity: 0.7,
        fillColor: colore
    });
}

//"OBJECTID":55,"Nome_zona":"55","Shape_Leng":437934.870097,"Shape_Area":2975.15073254,"Regioni":"Sicilia"
function onEachFeatureBeginning(feature, layer) {
    if (feature.properties.lat && feature.properties.long) {
        AddRegionLabelBeginning([feature.properties.lat, feature.properties.long], feature.properties.labelName);
    }
    layer.bindPopup("Schiaccia sul bottone carica dati!");
    var colore=getAreaColor(feature.properties.OBJECTID);

    //alert(feature.properties.OBJECTID+ " "+ feature.properties.Nome_zona);
    layer.setStyle({
        weight: 1,
        color: "#000000",
        dashArray: '',
        fillOpacity: 0.7,
        fillColor: colore
    });
}

function CentraMappa(zona) {
    GlobalCentra=zona;
    CentraMappaOnPopupClose();
}

function CentraMappaOnPopupClose() {
    if (GlobalCentra=='nord'){
        mymap.setView([GlobLatNord, GlobLongNord], GlobZoom);
    }else if (GlobalCentra=='centro'){
        mymap.setView([GlobLatCentro, GlobLongCentro], GlobZoom);
    }else if (GlobalCentra=='sud'){
        mymap.setView([GlobLatSud, GlobLongSud], GlobZoom);
    }else if (GlobalCentra=='isole'){
        mymap.setView([GlobLatIsole, GlobLongIsole], GlobZoom);
    }else{
        mymap.setView([GlobLatItalia, GlobLongItalia], GlobZoomItalia);
    }
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
    window.location.href = "index.html?ON";
}


function getVerificationData(path){
    var output;
    var request = new XMLHttpRequest();
    request.open('GET', path, false);
    request.send(null);
    output=request.responseText;
    output=output.split(/\n/);
    strOutput1=formatDate(output[0]);
    strOutput2=getPrevisionRun(output[1]);
    strOutput3=getPrevisionRun(output[2]);
    var arrayColori=[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
    for (i=3;i<73;i++){
        arrayColori[i-3]=output[i];
    }
    return [strOutput1,strOutput2,strOutput3,arrayColori]
}

function formatDate(date){
    anno=date.substr(0,4);
    giorno=date.substr(6,2);
    mese=date.substr(4,2);
    return giorno+" "+mese+" "+anno;
}

function getToday(){
    var today = new Date();
    var dd = String(today.getDate()).padStart(2, '0');
    var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
    var yyyy = today.getFullYear();
    
    today = dd + " " + mm + " " + yyyy;
    return today;    
}

function getPrevisionRun(date){
    return formatDate(date)+" run delle "+ date.substr(9,2)
}

function getAreaColor(OBJECTID){
    qpf=GlobalQPFMax[OBJECTID-1];
    if(parseInt(qpf)>value2){
        return colorHigh
    }else if(parseInt(qpf)>value1){
        return colorMedium
    }else if (parseInt(qpf)>0){
        return colorLow
    }else if(parseInt(qpf)==0){
        return "#FFFFFF"
    }else{
        
    }
}

function OpenOrderFile(path){
    var output;
    var request = new XMLHttpRequest();
    request.open('GET', path, false);
    request.send(null);
    output=request.responseText;
    output=output.split(/\n/);
    var matrix = [];
    for(var i=0; i<70; i++) {
        matrix[i] = new Array(2);
    }

    for (i=0;i<70;i++){
        temp=output[i].split(';');
        matrix[i][0]=temp[0];
        matrix[i][1]=temp[1];
    }    
    return matrix;
}

function GetDPCAreaNumber(area){
    return GlobalAreeOrder[area-1][1];
}