cmake_minimum_required(VERSION 3.16)

project(NEXORA VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.8)

qt_policy(SET QTP0001 NEW)
qt_policy(SET QTP0004 NEW)

qt_add_executable(nexora-app
    main.cpp
)

set_source_files_properties(
    theming/NexoraTheme.qml
    PROPERTIES
        QT_QML_SINGLETON_TYPE TRUE
)

qt_add_qml_module(nexora-app
    URI NEXORA
    VERSION 1.0

    QML_FILES
        main.qml

        components/NexoraButton.qml
        components/NexoraCard.qml

        shell/Shell.qml
        boot/Boot.qml

        theming/NexoraTheme.qml
        theming/Colors.qml
        theming/Spacing.qml
        theming/Typography.qml
)

target_link_libraries(nexora-app
    PRIVATE
        Qt6::Quick
)
