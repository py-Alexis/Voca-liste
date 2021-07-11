import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import "controls"
import "pages"


Window {

    property string currentList: ""
    property string currentMode: ""

    // PROPERTY FOR CUSTOM TOP BAR
    property bool isActiveTopBar: false
    property var flag: Qt.Window & ~Qt.FramelessWindowHint

    property bool windowIsMaximised: false
    property int windowMargin: 10
    property int topBarHeight: 35
    property bool topBarIsVisible: true
    property bool resizeIsVisible: true

    // COLOR PROPERTY
    property color light_text_color: "#ffffff"
    property color medium_text_color: "#5f6a82"
    property color light_color: "#2C313C"
    property color medium_color: "#282C34"
    property color darker_color: "#1C1D20"
    property color accent_color: "#00a1f1"
    property color dark_accent_color: "#00527A"
    property color mouseOver_color: "#23282e"


    QtObject{
        id: internal

        function toggleTopBar(){
            if(isActiveTopBar){
                flag = Qt.Window | Qt.FramelessWindowHint
                windowMargin = 10

                window.showNormal()
                windowIsMaximised = true
                internal.toggleMaximized()

                topBarHeight = 35
                topBarIsVisible = true

                resizeIsVisible = true

            }else{
                flag = Qt.Window & ~Qt.FramelessWindowHint
                windowMargin = 0

                topBarHeight = 0
                topBarIsVisible = false

                resizeIsVisible = false

                if(windowIsMaximised){
                    window.showMaximized()
                }
            }
        }// end toggleTopBar


        function toggleMaximized(){
            if(windowIsMaximised){
                window.showNormal()

                windowIsMaximised = false
                btnMaximize.btnIconSource = "../images/maximize_icon.svg"
                windowMargin = 10

                resizeIsVisible = true
            }else{
                window.showMaximized()

                windowIsMaximised = true
                btnMaximize.btnIconSource = "../images/maximized_icon.svg"
                windowMargin = 0

                resizeIsVisible = false
            }
        } // End toggle maximized

        function createSettingsTarButton(ButtonName, activeTheme){
            // Creation of the TabButton String
            var style = "contentItem: Text {color: parent.checked ? light_text_color :medium_text_color;text: parent.text;font: parent.font;horizontalAlignment: Text.AlignHCenter;verticalAlignment: Text.AlignVCenter;}background: Rectangle{color: parent.checked ? accent_color: medium_color;opacity: parent.down ? 0.75: 1;}"
            var isActive = ButtonName === activeTheme ? true: false
            var objectString = `import QtQuick 2.0; import QtQuick.Controls 2.15; TabButton {text: qsTr('${ButtonName}');checked: ${isActive}; onClicked: backend.changeTheme(text); ${style}}`

            var newObject = Qt.createQmlObject(objectString,themeSelector,"main"); // Creation of the tabButton
        }
    }


    flags: flag

    id: window
    width: 1500
    height: 750
    minimumWidth: 1000
    minimumHeight: 650
    visible: true
    color: "#00000000"
    title: "Voca-list"



    Rectangle {
        z: 0
        id: bg
        color: light_color
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.rightMargin: windowMargin
        anchors.leftMargin: windowMargin
        anchors.bottomMargin: windowMargin
        anchors.topMargin: windowMargin

        Rectangle {
            id: topBar
            x: 10
            y: 10
            height: topBarHeight
            visible: topBarIsVisible
            color: darker_color
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.rightMargin: 0
            anchors.leftMargin: 0
            anchors.topMargin: 0

            Row {
                id: row
                width: 105
                height: 400
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                anchors.topMargin: 0
                anchors.rightMargin: 0
                visible: topBarIsVisible

                CustomTopBarBtn{
                    id: btnMinimize

                    visible: topBarIsVisible
                    btnColorDefault: topBar.color
                    btnColorMouseOver: mouseOver_color
                    btnColorClicked: accent_color
                    btnLogo: light_text_color

                    onClicked: window.showMinimized()
                }

                CustomTopBarBtn {
                    id: btnMaximize

                    visible: topBarIsVisible
                    btnColorDefault: topBar.color
                    btnColorMouseOver: mouseOver_color
                    btnColorClicked: accent_color
                    btnLogo: light_text_color
                    btnIconSource: "../images/maximize_icon.svg"

                    onClicked: internal.toggleMaximized()

                }

                CustomTopBarBtn {
                    id: btnClose

                    visible: topBarIsVisible
                    btnColorDefault: topBar.color
                    btnColorMouseOver: mouseOver_color
                    btnColorClicked: "#ff007f"
                    btnLogo: light_text_color
                    btnIconSource: "../images/close_icon.svg"
                    onClicked: backend.closeAsk()
                    /* closeAsk ask the current page if it's ok to close (with a pop up message in modify for example)
                    and if it's ok the page do backend.close() that emit a sendClose signal that close the page */
                }
            }
            Rectangle{
                id: titleBar
                height: 100
                anchors.left: parent.left
                anchors.right: row.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.rightMargin: 0
                anchors.leftMargin: 0
                anchors.bottomMargin: 0
                anchors.topMargin: 0
                visible: topBar.visible
                color: "#00000000"

                MouseArea {
                    id: mouseArea

                    visible: topBar.visible
                    anchors.fill: parent

                    onDoubleClicked: internal.toggleMaximized()

                }
                Image {
                    id: appIcon
                    width: 20
                    height: 20
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    source: "../images/icon_app_top.svg"
                    anchors.leftMargin: 15
                    fillMode: Image.PreserveAspectFit

                    ColorOverlay {
                        anchors.fill: appIcon
                        source: appIcon
                        antialiasing: false
                        color: light_text_color
                    }
                }

                Label {
                    id: label
                    color: light_text_color
                    text: qsTr("Voca-liste")
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: appIcon.right
                    font.pointSize: 12
                    anchors.leftMargin: 8
                }

                DragHandler{
                    onActiveChanged: if(active){
                                         window.startSystemMove()
                                         if(windowIsMaximised){
                                             internal.toggleMaximized()
                                             window.y = 5
                                         }
                                     }
                }
            }
        }

        Item {
            id: topDescription
            anchors.left: parent.left
            anchors.right: settingsLeftPanel.left
            anchors.top: topBar.bottom
            anchors.rightMargin: 35
            anchors.leftMargin: 35
            height: 25

            Rectangle {
                id: topDescriptionRectangle1
                height: 15
                color: medium_color
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: 0
                anchors.rightMargin: 0
                anchors.leftMargin: 0

            }
            Rectangle {
                id: topDescriptionRectangle2
                anchors.fill: parent
                color: medium_color
                radius: 5

            }

            CustomTopDescriptionBtn {
                id: settingsBtn
                x: 243
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: -1
                anchors.rightMargin: 4

                btnLogoColor: medium_text_color
                btnColorMouseOver: light_text_color
                btnColorClicked: accent_color

                onClicked: animationSettingsPannel.running = true


            }

        }

        Rectangle {
            id: settingsLeftPanel
            x: 627
            width: 0
            color: medium_color
            anchors.right: parent.right
            anchors.top: topBar.bottom
            anchors.bottom: bottomBar.top
            clip: true
            anchors.bottomMargin: 0
            anchors.topMargin: 0
            anchors.rightMargin: 0

            PropertyAnimation{
                id: animationSettingsPannel
                target: settingsLeftPanel
                property: "width"
                to: if(settingsLeftPanel.width == 0) return 250; else return 0
                duration: 750
                easing.type: Easing.InOutQuint
            }


            ScrollView {
                id: settingsScrollView
                anchors.fill: parent
                clip: true

                Column {
                    id: settingsColumn
                    anchors.fill: parent

                    Item{
                        height: 20
                        width: 1
                    }

                    Rectangle {
                        id: settingsInterfaceGraphique
                        width: settingsGraphiqueLabel.width + 20
                        height: settingsGraphiqueLabel.height + 20
                        color: light_color
                        anchors.left: parent.left
                        anchors.leftMargin: 10

                        radius: 5

                        Label {
                            id: settingsGraphiqueLabel
                            text: qsTr("Interface Graphique")
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            font.pointSize: 10
                            antialiasing: false
                            smooth: false
                            color: light_text_color
                        }
                    }

                    CustomSwitch {
                        id: settingsToggleTopBar

                        text: "Afficher la barre de titre \npersonnalisé"
                        anchors.left: parent.left
                        anchors.leftMargin: 40

                        topPadding: 15

                        size: 0.8
                        textPadding: 10
                        textColor: medium_text_color
                        backgroundChecked: accent_color
                        backgroundUnChecked: light_color
                        circleDown: medium_color
                        circleUnChecked: accent_color
                        circleChecked: light_color


                        onClicked: {
                            backend.switchTopBar(settingsToggleTopBar.checked)
                        }
                    }

                    Item{
                        height: 15
                        width: 1
                    }

                    TabBar {
                        id: themeSelector

                        anchors.left: parent.left
                        anchors.leftMargin: 40

                        background: Rectangle {
                            color: medium_text_color // Couleur de la séparation
                        }
                        TabButton {
                            id: temporaryButton
                        }
                    }
                }
            }
        }

        StackView {
            id: stackView
            anchors.left: parent.left
            anchors.right: settingsLeftPanel.left
            anchors.top: topDescription.bottom
            anchors.bottom: bottomBar.top
            anchors.bottomMargin: 0
            anchors.rightMargin: 0
            anchors.leftMargin: 0
            anchors.topMargin: 0
            initialItem: Qt.resolvedUrl("pages/HomePage.qml")
            clip: true


            
            replaceEnter: Transition {
                    XAnimator {
                        from: (stackView.mirrored ? -1 : 1) * stackView.width
                        to: 0
                        duration: 850
                        easing.type: Easing.InOutQuint
                    }
            }

            replaceExit: Transition {
                    XAnimator {
                        from: 0
                        to: (stackView.mirrored ? -1 : 1) * -stackView.width
                        duration: 850
                        easing.type: Easing.InOutQuint
                    }
            }
        }

        Rectangle {
            id: bottomBar
            height: 25
            color: medium_color
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: 0
            anchors.leftMargin: 0
            anchors.bottomMargin: 0

            Label {
                id: labelBottomInfo
                color: medium_text_color
                text: qsTr("Version d'essai par py-Alexis")
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                verticalAlignment: Text.AlignVCenter
                antialiasing: false
                anchors.leftMargin: 10
                anchors.rightMargin: 100
                anchors.bottomMargin: 0
                anchors.topMargin: 0
            }

            Label {
                id: bottomRightInfo1
                color: medium_text_color
                text: qsTr("| Beta 1.0")
                anchors.left: labelBottomInfo.right
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
                antialiasing: false
                anchors.rightMargin: 5
                anchors.leftMargin: 0
                anchors.bottomMargin: 0
                anchors.topMargin: 0
            }
        }


    }

    DropShadow{
        id: dropShadow
        anchors.fill: bg
        horizontalOffset: 0
        verticalOffset: 0
        radius: 10
        samples: 16
        color: "#80000000"
        source: bg
        z:-1
        visible: true

    }

    Item {
        id: resize
        anchors.fill: parent
        MouseArea {
            id: resizeRight
            width: 10
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.rightMargin: 0
            anchors.bottomMargin: 25
            anchors.topMargin: 10
            cursorShape: Qt.SizeHorCursor
            visible: resizeIsVisible

            DragHandler{
                target: null
                onActiveChanged: if (active) {window.startSystemResize(Qt.RightEdge)}
            }
        }

        MouseArea {
            id: resizeLeft
            width: 10
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.leftMargin: 0
            anchors.bottomMargin: 25
            anchors.topMargin: 25
            cursorShape: Qt.SizeHorCursor
            visible: resizeIsVisible

            DragHandler{
                target: null
                onActiveChanged: if (active) {window.startSystemResize(Qt.LeftEdge)}
            }
        }

        MouseArea {
            id: resizeBottom
            height: 10
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.leftMargin: 25
            anchors.rightMargin: 25
            anchors.bottomMargin: 0
            cursorShape: Qt.SizeVerCursor
            visible: resizeIsVisible

            DragHandler{
                target: null
                onActiveChanged: if (active) {window.startSystemResize(Qt.BottomEdge)}
            }
        }

        MouseArea {
            id: resizeTop
            height: 10
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.leftMargin: 25
            anchors.rightMargin: 10
            anchors.topMargin: 0
            cursorShape: Qt.SizeVerCursor
            visible: resizeIsVisible

            DragHandler{
                target: null
                onActiveChanged: if (active) {window.startSystemResize(Qt.TopEdge)}
            }
        }

        MouseArea {
            id: resizeBottomRight
            width: 25
            height: 25
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: 0
            anchors.bottomMargin: 0
            cursorShape: Qt.SizeFDiagCursor
            visible: resizeIsVisible

            DragHandler{
                target: null
                onActiveChanged: if (active) {window.startSystemResize(Qt.RightEdge | Qt.BottomEdge)}
            }
        }

        MouseArea {
            id: resizeBottomLeft
            width: 25
            height: 25
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.leftMargin: 0
            anchors.bottomMargin: 0
            cursorShape: Qt.SizeBDiagCursor
            visible: resizeIsVisible

            DragHandler{
                target: null
                onActiveChanged: if (active) {window.startSystemResize(Qt.LeftEdge | Qt.BottomEdge)}
            }
        }

        MouseArea {
            id: resizeTopLeft
            width: 25
            height: 25
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: 0
            anchors.topMargin: 0
            cursorShape: Qt.SizeFDiagCursor
            visible: resizeIsVisible

            DragHandler{
                target: null
                onActiveChanged: if (active) {window.startSystemResize(Qt.LeftEdge | Qt.TopEdge)}
            }
        }

        MouseArea {
            id: resizeTopRight
            width: 10
            height: 10
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.rightMargin: 0
            anchors.topMargin: 0
            cursorShape: Qt.SizeBDiagCursor
            visible: resizeIsVisible

            DragHandler{
                target: null
                onActiveChanged: if (active) {window.startSystemResize(Qt.RightEdge | Qt.TopEdge)}
            }
        }
    }



    Connections{
        target: backend
        // Custom Top Bar
        function onIntializeCustomTopBar(statut){
            isActiveTopBar = statut
            internal.toggleTopBar()

            if(statut === false){
                settingsToggleTopBar.checked = true
            }
        }

        function onSendCustomTopBar(boolSignal){
            isActiveTopBar = boolSignal
            internal.toggleTopBar()
        }

        // Theme
        function onSendThemeList(themeList, activeTheme){
            for (const property in themeList) {
                internal.createSettingsTarButton(themeList[property], activeTheme);
                }
            temporaryButton.destroy()
        }

        function onSendTheme(theme){
            light_text_color = theme["light_text_color"]
            medium_text_color = theme["medium_text_color"]
            light_color = theme["light_color"]
            medium_color = theme["medium_color"]
            darker_color = theme["darker_color"]
            accent_color = theme["accent_color"]
            dark_accent_color = theme["dark_accent_color"]
            mouseOver_color = theme["mouseOver_color"]
        }

        function onSendClose(){
            window.close()
        }
    }
}

/*##^##
Designer {
    D{i:0;height:500;width:1000}
}
##^##*/
