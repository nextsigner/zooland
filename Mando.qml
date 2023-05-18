import QtQuick 2.0

Item {
    id: r
    anchors.fill: parent
    Grid{
        spacing: app.fs*0.5
        columns: 3
        anchors.centerIn: r
        Repeater{
            model: 9
            Rectangle{
               width: app.fs*4
               height: width
               border.width: 0
               border.color: 'red'
               opacity: index===1 || index===3 || index===4 || index===5 || index===7?1.0:0.0
               color: 'transparent'
               MouseArea{
                anchors.fill: parent
                onClicked: {
                    if(index===1){
                        app.runToUp()
                        return
                    }
                    if(index===3){
                        app.runToLeft()
                        return
                    }
                    if(index===4){
                        app.runEnter()
                        return
                    }
                    if(index===5){
                        app.runToRight()
                        return
                    }
                    if(index===7){
                        app.runToDown()
                        return
                    }
                }
               }
               Rectangle{
                  width: parent.width*0.8
                  height: width
                  color: 'gray'
                  radius: width*0.5
                  opacity: 0.5
                  anchors.centerIn: parent
                  visible: index===4
               }
               Canvas {
                   width: parent.width*0.8
                   height: width
                   anchors.centerIn: parent
                   opacity: 0.5
                   visible: index!==4
                   onPaint: {
                       var ctx = getContext("2d")
                       ctx.fillStyle = "red"
                       ctx.beginPath();
                       ctx.moveTo(width*0.5, 0);
                       ctx.lineTo(width, height);
                       ctx.lineTo(0, height);
                       ctx.closePath();

                       context.fillStyle = "gray";
                       context.fill();
                       //ctx.fillRect(0, 0, width, height)

                   }
               }

//               Text {
//                   id: txt1
//                   text: index
//                   font.pixelSize: app.fs
//                   color: 'yellow'
//                   anchors.centerIn: parent
//               }

               Component.onCompleted: {
                    if(index===3){
                        rotation=-90
                    }
                    if(index===5){
                        rotation=90
                    }
                    if(index===7){
                        rotation=180
                    }
                }
            }
        }
    }
}
