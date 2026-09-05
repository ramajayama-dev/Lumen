pragma Singleton

import QtQuick

QtObject {
    // Colors
    readonly property color background: "#0B0F14"
    readonly property color surface: "#111820"
    readonly property color surfaceElevated: "#18212C"

    readonly property color primary: "#5B8CFF"
    readonly property color primaryHover: "#739DFF"

    readonly property color textPrimary: "#F5F7FA"
    readonly property color textSecondary: "#A8B1BD"
    readonly property color textMuted: "#687381"

    readonly property color border: "#26313D"

    readonly property color success: "#45D483"
    readonly property color warning: "#FFB84D"
    readonly property color danger: "#FF6678"

    // Spacing
    readonly property int xs: 4
    readonly property int sm: 8
    readonly property int md: 12
    readonly property int lg: 16
    readonly property int xl: 24
    readonly property int xxl: 32
    readonly property int xxxl: 48

    // Radius
    readonly property int radiusSmall: 6
    readonly property int radiusMedium: 10
    readonly property int radiusLarge: 16
    readonly property int radiusXLarge: 24

    // Typography
    readonly property int display: 32
    readonly property int heading1: 26
    readonly property int heading2: 22
    readonly property int heading3: 18
    readonly property int bodyLarge: 16
    readonly property int body: 14
    readonly property int caption: 12
}
