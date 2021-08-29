import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import "../../"
import "../../controls/Revision"
import "../../controls/modify"
import "../"
import QtQuick.Timeline 1.0

Item{
    id: qcm

    property bool clickable: true
    property bool result: true

     Rectangle{
         id: displayWordWrite

         color: medium_color
         anchors.left: parent.left
         anchors.right: parent.right
         anchors.top: parent.top
         anchors.bottom: displayContextWrite.top
         anchors.bottomMargin: 0
         anchors.topMargin: 0
         anchors.rightMargin: 0
         anchors.leftMargin: 0
         radius: 5

         Label{
             id: displayWordLabel

             font.pointSize: 15

             color: light_text_color
             anchors.fill: parent
             horizontalAlignment: Text.AlignHCenter
             verticalAlignment: Text.AlignVCenter
             wrapMode: Text.Wrap
         }
     }

     Rectangle{
         id: displayContextWrite

         height: 0

         color: darker_color
         anchors.left: parent.left
         anchors.right: parent.right
         anchors.bottom: parent.bottom
         anchors.bottomMargin: 137
         anchors.rightMargin: 0
         anchors.leftMargin: 0
         clip: true

         Label{
             id: displayContextLabel

             anchors.verticalCenter: parent.verticalCenter
             anchors.horizontalCenter: parent.horizontalCenter

             text: ""

             color: medium_text_color

             font.pointSize: 13

         }
         PropertyAnimation{
             id: animationContext
             target: displayContextWrite
             property: "height"
             to: if(displayContextWrite.height === 0) return 130; else return 0
             duration: 500
             easing.type: Easing.InOutQuint
         }
     }

     TextField{
         id: writeAnswer
         z: 2
         anchors.left: parent.left
         anchors.right: parent.right
         anchors.bottom: parent.bottom
         horizontalAlignment: Text.AlignHCenter
         font.pointSize: 12
         anchors.bottomMargin: 65.5
         anchors.rightMargin: 0
         anchors.leftMargin: 0
         color: light_text_color
         placeholderText: "Réponse"
         readOnly: !clickable

         background: Rectangle{
             opacity: if(clickable){writeAnswer.hovered ? 0.75 : 1}else{1}
             color: if(clickable){medium_color}else{if(result){accent_color}else{medium_color}}
             radius: 5
         }

         onAccepted: {
             backend.check_answer_write(writeAnswer.text, index, currentDirection)
         }
         PropertyAnimation {
             id: wrongAnswerAnimation
             target: writeAnswer
             property: "anchors.bottomMargin"
             to: 65.5 + (writeAnswer.height / 2)
             duration: 1000
             easing.type: Easing.InOutQuint
         }
         PropertyAnimation {
             id: iWasRightAnimation_
             target: writeAnswer
             property: "anchors.bottomMargin"
             to: 65.5
             duration: 1000
             easing.type: Easing.InOutQuint
         }
     }
     TextField{
         id: goodAnswerTextField
         z: 1
         anchors.left: parent.left
         anchors.right: parent.right
         anchors.bottom: parent.bottom
         horizontalAlignment: Text.AlignHCenter
         font.pointSize: 12
         anchors.bottomMargin: 65.5
         anchors.rightMargin: 0
         anchors.leftMargin: 0
         color: light_text_color
         readOnly: true
         visible: !clickable

         background: Rectangle{
             opacity: 1
             color: accent_color
             radius: 5
         }
         PropertyAnimation {
             id: goodAnswerAnimation
             target: goodAnswerTextField
             property: "anchors.bottomMargin"
             to: 65.5 - (writeAnswer.height / 2)
             duration: 1000
             easing.type: Easing.InOutQuint
         }
         PropertyAnimation {
             id: iWasRightAnimation
             target: goodAnswerTextField
             property: "anchors.bottomMargin"
             to: 65.5
             duration: 1000
             easing.type: Easing.InOutQuint
         }
     }

     SaveBtn{
         id: validateBtn

         text: "valider"

         anchors.right: parent.right
         anchors.bottom: parent.bottom
         anchors.bottomMargin: 0
         anchors.rightMargin: 0
         btnColor: accent_color
         btnTextColor: light_text_color

         visible: clickable

         onClicked: backend.check_answer_write(writeAnswer.text, index, currentDirection)
     }

     SaveBtn{
         id: iWasRightBtn

         text: "Ma réponse est correct"

         anchors.right: nextBtn.left
         anchors.bottom: parent.bottom
         anchors.bottomMargin: 0
         anchors.rightMargin: 15
         btnTextColor: light_text_color
         btnColor: medium_color

         visible: !clickable && !result

         onClicked: {
             writeAnswer.z = 1
             goodAnswerTextField.z = 2
             visible = false
             backend.was_right(index)
             iWasRightAnimation.running = true
             iWasRightAnimation_.running = true
         }
     }

     SaveBtn{
         id: nextBtn

         text: ""

         anchors.right: parent.right
         anchors.bottom: parent.bottom
         anchors.bottomMargin: 0
         anchors.rightMargin: 0
         btnColor: accent_color
         btnTextColor: light_text_color

         visible: !clickable

         background: Rectangle{
             id: bgBtn
             color: accent_color
             opacity: if(nextBtn.down){0.5}else{if(nextBtn.hovered || nextBtn.focus){0.7}else{1}}

             radius: 10
        }

         onClicked: nextBtn.activate()
         Keys.onReturnPressed: nextBtn.activate() // Enter key
         Keys.onEnterPressed: nextBtn.activate() // Numpad enter key

         function activate() {
             console.debug("oui")
             if(index != nbWord){
                 backend.call_next_word()
             }else{
                 stackView.replace(Qt.resolvedUrl("../../pages/ResultPage.qml"))
                 backend.finish(currentList, revisionMode, revisionDirection)
             }
         }
     }

     Connections{
         target: backend

         function onNew_word(info){
             // info:
             // {"displayWord" : "word",
             // "toFindWord": "corresponding word",
             // "context" : "if some context",
             // "hint" : ["word1", "word2", "word3_if_in_qcm_mode"],
             // "current_direction" = "default"}

             if(displayWordLabel.text === ""){
                 displayWordLabel.text = info["displayWord"]
             }

             if(displayContextLabel.text === ""){
                 displayContextLabel.text = info["context"]
             }
             if(nextBtn.text === ""){
                 if(index !=  nbWord){nextBtn.text = "Suivant"}else{nextBtn.text = "Terminer"}
             }
             currentDirection = info["current_direction"]
             writeAnswer.focus = true
         }

         function onSend_checked_answer(AnswerResult, goodAnswer){
             result = AnswerResult
             clickable = false
             nextBtn.focus = true

             if(displayContextLabel.text !== "false"){
                 animationContext.running = true
             }

             if(result){
                 writeAnswer.text = goodAnswer
             }else{
                 writeAnswer.font.strikeout = true
                 goodAnswerTextField.text = goodAnswer
                 goodAnswerAnimation.running = true
                 wrongAnswerAnimation.running = true

             }
         }
     }
}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorZoom:0.5;height:1000;width:1000}
}
##^##*/
