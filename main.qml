import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: window

    visible: true

    width: 1280
    height: 800

    minimumWidth: 1000
    minimumHeight: 650

    title: "NEXORA Design System v0.1"

    color: NexoraTheme.background

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: NexoraTheme.xxxl

        spacing: NexoraTheme.xl

        Text {
            text: "NEXORA"

            color: NexoraTheme.textPrimary

            font.family: "Inter"
            font.pixelSize: NexoraTheme.display
            font.bold: true
        }

        Text {
            text: "Design System v0.1"

            color: NexoraTheme.textSecondary

            font.family: "Inter"
            font.pixelSize: NexoraTheme.body
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1

            color: NexoraTheme.border
        }

        Text {
            text: "Color System"

            color: NexoraTheme.textPrimary

            font.family: "Inter"
            font.pixelSize: NexoraTheme.heading2
            font.bold: true
        }

        GridLayout {
            Layout.fillWidth: true

            columns: 4

            columnSpacing: NexoraTheme.lg
            rowSpacing: NexoraTheme.lg

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 100

                color: NexoraTheme.surface
                radius: NexoraTheme.radiusMedium
                border.color: NexoraTheme.border

                Column {
                    anchors.fill: parent
                    anchors.margins: NexoraTheme.lg

                    Text {
                        text: "Surface"
                        color: NexoraTheme.textPrimary
                        font.pixelSize: NexoraTheme.bodyLarge
                        font.bold: true
                    }

                    Text {
                        text: "#111820"
                        color: NexoraTheme.textSecondary
                        font.pixelSize: NexoraTheme.caption
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 100

                color: NexoraTheme.surfaceElevated
                radius: NexoraTheme.radiusMedium
                border.color: NexoraTheme.border

                Column {
                    anchors.fill: parent
                    anchors.margins: NexoraTheme.lg

                    Text {
                        text: "Elevated"
                        color: NexoraTheme.textPrimary
                        font.pixelSize: NexoraTheme.bodyLarge
                        font.bold: true
                    }

                    Text {
                        text: "#18212C"
                        color: NexoraTheme.textSecondary
                        font.pixelSize: NexoraTheme.caption
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 100

                color: NexoraTheme.primary
                radius: NexoraTheme.radiusMedium

                Column {
                    anchors.fill: parent
                    anchors.margins: NexoraTheme.lg

                    Text {
                        text: "Primary"
                        color: "white"
                        font.pixelSize: NexoraTheme.bodyLarge
                        font.bold: true
                    }

                    Text {
                        text: "#5B8CFF"
                        color: "white"
                        font.pixelSize: NexoraTheme.caption
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 100

                color: NexoraTheme.success
                radius: NexoraTheme.radiusMedium

                Column {
                    anchors.fill: parent
                    anchors.margins: NexoraTheme.lg

                    Text {
                        text: "Success"
                        color: NexoraTheme.background
                        font.pixelSize: NexoraTheme.bodyLarge
                        font.bold: true
                    }

                    Text {
                        text: "#45D483"
                        color: NexoraTheme.background
                        font.pixelSize: NexoraTheme.caption
                    }
                }
            }
        }

        Text {
            text: "Components"

            color: NexoraTheme.textPrimary

            font.family: "Inter"
            font.pixelSize: NexoraTheme.heading2
            font.bold: true
        }

        RowLayout {
            spacing: NexoraTheme.md

            NexoraButton {
                text: "Primary Action"
            }

            Button {
                text: "Secondary"

                implicitWidth: 130
                implicitHeight: 44

                contentItem: Text {
                    text: parent.text

                    color: NexoraTheme.textPrimary

                    font.pixelSize: NexoraTheme.body

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: NexoraTheme.surfaceElevated
                    radius: NexoraTheme.radiusMedium
                    border.color: NexoraTheme.border
                }
            }
        }

Text {
    text: "Typography"

    color: NexoraTheme.textPrimary

    font.family: "Inter"
    font.pixelSize: NexoraTheme.heading2
    font.bold: true
}

Column {
    spacing: NexoraTheme.sm

    Text {
        text: "Display — NEXORA"

        color: NexoraTheme.textPrimary

        font.family: "Inter"
        font.pixelSize: NexoraTheme.display
        font.bold: true
    }

    Text {
        text: "Heading — Desktop Experience"

        color: NexoraTheme.textPrimary

        font.pixelSize: NexoraTheme.heading2
        font.bold: true
    }

    Text {
        text: "Body — Clean, readable interface text."

        color: NexoraTheme.textSecondary

        font.pixelSize: NexoraTheme.body
    }

    Text {
        text: "Caption — Supporting information"

        color: NexoraTheme.textMuted

        font.pixelSize: NexoraTheme.caption
    }
}

Text {
    text: "Elevation"

    color: NexoraTheme.textPrimary

    font.family: "Inter"
    font.pixelSize: NexoraTheme.heading2
    font.bold: true
}

RowLayout {
    spacing: NexoraTheme.lg

    Rectangle {
        Layout.preferredWidth: 180
        Layout.preferredHeight: 70

        color: NexoraTheme.surface

        radius: NexoraTheme.radiusMedium

        border.color: NexoraTheme.border

        Text {
            anchors.centerIn: parent

            text: "Low"
            color: NexoraTheme.textSecondary
        }
    }

    Rectangle {
        Layout.preferredWidth: 180
        Layout.preferredHeight: 70

        color: NexoraTheme.surfaceElevated

        radius: NexoraTheme.radiusMedium

        border.color: NexoraTheme.border

        Text {
            anchors.centerIn: parent

            text: "Medium"
            color: NexoraTheme.textPrimary
        }
    }

    Rectangle {
        Layout.preferredWidth: 180
        Layout.preferredHeight: 70

        color: NexoraTheme.surfaceElevated

        radius: NexoraTheme.radiusMedium

        border.color: NexoraTheme.primary

        Text {
            anchors.centerIn: parent

            text: "High"
            color: NexoraTheme.textPrimary
        }
    }
}

        NexoraCard {
            Layout.fillWidth: true
            Layout.fillHeight: true

            title: "NEXORA Interface"

            description: "A clean, consistent foundation for the NEXORA desktop shell."
        }
    }
}
