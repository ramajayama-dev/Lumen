import QtQuick

Rectangle {
    id: card

    color: NexoraTheme.surface

    radius: NexoraTheme.radiusLarge

    border.color: NexoraTheme.border
    border.width: 1

    property alias title: titleText.text
    property alias description: descriptionText.text

    // Elevation
    layer.enabled: true
    layer.smooth: true

    Column {
        anchors.fill: parent
        anchors.margins: NexoraTheme.xl

        spacing: NexoraTheme.sm

        Text {
            id: titleText

            color: NexoraTheme.textPrimary

            font.family: "Inter"
            font.pixelSize: NexoraTheme.heading2
            font.bold: true
        }

        Text {
            id: descriptionText

            color: NexoraTheme.textSecondary

            font.family: "Inter"
            font.pixelSize: NexoraTheme.body

            wrapMode: Text.WordWrap
        }
    }
}
