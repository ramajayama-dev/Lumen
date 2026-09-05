import QtQuick
import QtQuick.Controls

Button {
    id: control

    implicitWidth: 150
    implicitHeight: 44

    contentItem: Text {
        text: control.text

        color: NexoraTheme.textPrimary

        font.family: "Inter"
        font.pixelSize: NexoraTheme.body
        font.bold: true

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    background: Rectangle {
        color: control.down
               ? NexoraTheme.primaryHover
               : NexoraTheme.primary

        radius: NexoraTheme.radiusMedium
    }
}
