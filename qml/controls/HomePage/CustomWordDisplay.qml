import QtQuick 2.15
import QtQuick.Controls 2.15
import "../../scripts/color_mixer.js" as Co


Rectangle {
    id: container

    property string mot: "mot"
    property string definition: "definition"
    property string context: "qdfqsdf qdsf qsdf sqdf qds fq dfdqf qfsdf qsd fqsd qsdf sqdf sdq fsqd"
    property int niveau: -1

    property bool isPair: true
    property int parentWidth: 100

    property color btnColorNotPair: "#282C34"
    property color btnColorIsPair: "#2C313C"
    property color textColor: "#ffffff"
    property color mediumtextColor: "#5f6a82"
    property color accentColor: "#00a1f1"

    property string destroy: ""
    property int change: 0

    onDestroyChanged: if(change === 0){change = 1}else{destroy(0)}




    anchors.left: parent.left
    anchors.leftMargin: 0

    width: parentWidth
    radius: 5

    color: isPair ? btnColorNotPair: btnColorIsPair

    height: if(labelMot.height >= labelDef.height && labelMot.height >= labelContext.height && labelMot.height >= labelLv.height){
                labelMot.height + 13
            }else if(labelDef.height >= labelMot.height && labelDef.height >= labelContext.height && labelDef.height >= labelLv.height){
                labelDef.height + 13
            }else if(labelContext.height >= labelMot.height && labelContext.height >= labelDef.height && labelContext.height >= labelLv.height){
                labelContext.height + 13
            }else{
                labelLv.height + 13
            }

    QtObject{
        id: internal

        property color dynamicTextColor: if(niveau === -1){mediumtextColor}
                                         else if(niveau === 0){textColor}
                                         else if(niveau === 1){Co.mix_hexes(String(textColor),String(textColor), String(accentColor))}
                                         else if(niveau === 2 || niveau === 3){Co.mix_hexes(String(textColor), String(accentColor))}
                                         else if(niveau === 4){Co.mix_hexes(String(textColor), String(accentColor), String(accentColor))}
                                         else if(niveau === 5){Co.mix_hexes(String(textColor), String(accentColor), String(accentColor), String(accentColor))}
                                         else if(niveau === 6){accentColor}

    }

    Row{
        id: row
        anchors.fill: parent



        Label{
            id: labelMot
            leftPadding: 5
            width: (parent.width) / 5
            color: textColor

            text: mot
            anchors.verticalCenter: parent.verticalCenter
            wrapMode: Label.Wrap
        }

        Label{
            id: labelDef
            leftPadding: 5
            width: (parent.width) / 5
            color: textColor

            text: definition
            anchors.verticalCenter: parent.verticalCenter

            wrapMode: Label.Wrap
        }
        Label{
            id: labelContext
            leftPadding: 5
            width: (2 * (parent.width)) / 5
            color: textColor

            text: context
            anchors.verticalCenter: parent.verticalCenter
            wrapMode: Label.Wrap
        }
        Label{
            id: labelLv
            rightPadding: 15
            color: internal.dynamicTextColor
            width: (parent.width) / 5

            text: if(niveau === -1){"Pas de donnée"} else if(niveau === 0){"inconnu"}
                  else if(niveau === 1){"débutant"} else if(niveau === 2 || niveau === 3){"intermédiaire"}
                  else if(niveau === 4){"avancé"} else if(niveau === 5){"maitrisé"} else if(niveau === 6){"prafait"}
            anchors.verticalCenter: parent.verticalCenter

            horizontalAlignment: Text.AlignRight
            wrapMode: Label.Wrap


        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorZoom:1.66;height:50;width:500}
}
##^##*/
