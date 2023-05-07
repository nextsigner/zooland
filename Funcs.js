function getRD(url, item){//Remote Data
    var request = new XMLHttpRequest()
    request.open('GET', url, true);
    request.onreadystatechange = function() {
        if (request.readyState === XMLHttpRequest.DONE) {
            if (request.status && request.status === 200) {
                /*let d=request.responseText
                if(d.indexOf('redirected')>=0&&d.indexOf('</html>')>=0){
                    let m0=d.split('</html>')
                     item.setData(m0[1], true)
                }else{
                     item.setData(d, true)
                }*/
                item.setData(request.responseText, true)
            } else {
                item.setData("Url: "+url+" Status:"+request.status+" HTTP: "+request.statusText, false)
            }
        }
    }
    request.send()
}
