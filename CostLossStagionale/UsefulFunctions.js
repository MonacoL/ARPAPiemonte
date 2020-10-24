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


function getRndNumber(){
    return Math.floor(Math.random() * 1000000) + 100000;
}

function getSeasonsToShow(path){
    if (GlobalToShowOnPage!=""){
        var output;
        var request = new XMLHttpRequest();
        request.open('GET', path, false);
        request.send(null);
        output=request.responseText;
        output=output.split(/\n/);
        for (i=0; i<output.length;i++){
            output[i] = output[i].split(" "); 
        }
        GlobalToShowOnPage=output;   
        return output;
    }else{
        return GlobalToShowOnPage;
    }
}

function ClearYearsDLL(){
    var select = document.getElementById("ddlAnno");
    var length = select.options.length;
    for (i = length-1; i >= 0; i--) {
      select.options[i] = null;
    }    
}

function ClearSeasonsDLL(){
    var select = document.getElementById("ddlPeriodo");
    var length = select.options.length;
    for (i = length-1; i >= 0; i--) {
      select.options[i] = null;
    }    
}

function FillYearsDDL(path){
    SeasonsToShow=getSeasonsToShow(path);
    ClearYearsDLL();
    var years = new Array();
    for (i=0; i<SeasonsToShow.length;i++){
        if (!years.includes(SeasonsToShow[i][0]) && SeasonsToShow[i][0]!="") {
            years.push(SeasonsToShow[i][0]);
        } 
    }
    years.sort((a,b)=>b-a);

    for (i=0; i<years.length;i++){
        AddItemToSelect("ddlAnno", years[i]);
    }
}

function FillStagioniDDL(year){
    SeasonsToShow=GlobalToShowOnPage;
    ClearSeasonsDLL();
    var seasons = new Array();
    for (i=0; i<SeasonsToShow.length;i++){
        if (SeasonsToShow[i][0]==year) {
            seasons.push(SeasonsToShow[i][1]);
        } 
    }

    if (seasons.includes("SON")) {
        AddItemToSelect("ddlPeriodo", "SON");
    }
    if (seasons.includes("JJA")) {
        AddItemToSelect("ddlPeriodo", "JJA");
    }    
    if (seasons.includes("MAM")) {
        AddItemToSelect("ddlPeriodo", "MAM");
    }   
    if (seasons.includes("DJF")) {
        AddItemToSelect("ddlPeriodo", "DJF");
    }       
}


function WriteModelButtons(year, season){
    var models = new Array();
    for (i=0; i<GlobalToShowOnPage.length;i++){
        if (!models.includes(GlobalToShowOnPage[i][4]) && GlobalToShowOnPage[i][0]==year && GlobalToShowOnPage[i][1]==season) {
            models.push(GlobalToShowOnPage[i][4]);
        } 
    }    
    buttons="Modelli: ";
    for (j=0; j<models.length;j++){
        buttons+="<button value=\""+models[j]+"\" onclick=\"BuildSlideShows("+year+",'"+season+"','"+models[j]+"')\">"+ModelIDtoModelName(models[j])+"</button>&nbsp;";
    }
    document.getElementById("divModelli").innerHTML = buttons;
}

function BuildSlideShows(year, season, model){
    var avePlots = new Array();
    var maxPlots = new Array();
    for (i=0; i<GlobalToShowOnPage.length;i++){
        if (GlobalToShowOnPage[i][0]==year && GlobalToShowOnPage[i][1]==season && GlobalToShowOnPage[i][4]==model) {
            if(GlobalToShowOnPage[i][2]=="max"){
                maxPlots.push("Grafici/"+year+"/"+season+"/max/max_"+model+"_"+GlobalToShowOnPage[i][3]+"_"+GlobalToShowOnPage[i][5]+".png");
            }else{
                avePlots.push("Grafici/"+year+"/"+season+"/ave/ave_"+model+"_"+GlobalToShowOnPage[i][3]+"_"+GlobalToShowOnPage[i][5]+".png");
            }
        } 
    }
    var slideshows="<div class=\"regular slider\">"
    for (i=0; i<maxPlots.length;i++){
        slideshows+="<div><img src=\""+maxPlots[i]+"?d="+getRndNumber()+"\"></div>";
    }
    slideshows+="</div><br/>"
    slideshows+="<div class=\"regular slider\">"
    for (i=0; i<avePlots.length;i++){
        slideshows+="<div><img src=\""+avePlots[i]+"?d="+getRndNumber()+"\"></div>";
    }
    slideshows+="</div>"    
    document.getElementById("SlideShow").innerHTML = slideshows;
    SetSlickOptions();    
}

function SetSlickOptions(){
    $(".regular").slick({
        dots: true,
        infinite: true,
        centerMode: false,
        slidesToShow: 1,
        slidesToScroll: 1
    });
}

function ModelIDtoModelName(modelsid){
    var ids = new Array("m0103","b0700","c2200","c5m00","e1000","i0700","wrf00","prvsa");
    var names = new Array("MOLOCH","BOLAM","COSMO-2I","COSMO-I5","ECMWF","ICON","WRF","PSA");
    models=modelsid.split("_");
    var firstmodelID = ids.indexOf(models[0]);
    var secondmodelID = ids.indexOf(models[1]);
    return names[firstmodelID]+" VS. "+names[secondmodelID];
}
