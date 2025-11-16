import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root
    property string time

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData

            screen: modelData
            implicitHeight: 30

            anchors {
                top: true
                left: true
                right: true
            }

            Text {
                id: clock
                text: root.time

                anchors.centerIn: parent
            }
        }
    }

    Process {
        id: dateProcess

        command: ["date"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: root.time = this.text
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: dateProcess.running = true
    }
}
