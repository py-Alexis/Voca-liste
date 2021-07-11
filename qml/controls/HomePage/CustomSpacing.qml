import QtQuick 2.0

Item {
    property int itemWidth : 10
    property int itemHeight: 10
    property int reload: 0

    onReloadChanged: destroy()

    width: itemWidth
    height: itemHeight

}
