import QtQuick 2.15
import QtQuick.Controls.Basic 2.15 as C

Rectangle {
    id: root
    width: 1366
    height: 768
    color: "#2d353b"
    property bool signingIn: false
    property string notice: ""
    property bool failed: false
    property date now: new Date()
    property string pendingPower: ""

    function submit() {
        if (signingIn) return;
        if (!username.text.trim()) {
            notice = "Enter your username.";
            username.forceActiveFocus();
            return;
        }
        if (session.currentIndex < 0) {
            notice = "Choose a desktop session.";
            return;
        }
        failed = false;
        notice = "Signing in…";
        signingIn = true;
        sddm.login(username.text.trim(), password.text, session.currentIndex);
    }

    Timer { interval: 1000; running: true; repeat: true; onTriggered: root.now = new Date() }
    Connections {
        target: sddm
        function onLoginFailed() {
            root.signingIn = false;
            root.failed = true;
            root.notice = "Could not sign in. Check your username and password.";
            password.clear();
            password.forceActiveFocus();
        }
        function onLoginSucceeded() {
            password.clear();
            root.notice = "Welcome back.";
        }
    }

    component ThemeButton: C.Button {
        id: button
        property bool accent: false
        implicitHeight: 42
        font.family: "Adwaita Sans"
        font.pixelSize: 14
        hoverEnabled: true
        contentItem: Text {
            text: button.text
            font: button.font
            color: button.accent ? "#2d353b" : "#d3c6aa"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            opacity: button.enabled ? 1 : 0.5
        }
        background: Rectangle {
            radius: 9
            color: button.accent ? (button.down ? "#8da76b" : button.hovered ? "#b7d094" : "#a7c080")
                                 : (button.hovered ? "#475258" : "#343f44")
            border.width: button.activeFocus ? 2 : 1
            border.color: button.activeFocus ? "#a7c080" : "#475258"
        }
    }

    component ThemeField: C.TextField {
        id: field
        implicitHeight: 46
        font.family: "Adwaita Sans"
        font.pixelSize: 16
        color: "#d3c6aa"
        placeholderTextColor: "#859289"
        selectionColor: "#a7c080"
        selectedTextColor: "#2d353b"
        leftPadding: 14
        rightPadding: 14
        selectByMouse: true
        background: Rectangle {
            radius: 9
            color: "#343f44"
            border.width: field.activeFocus ? 2 : 1
            border.color: field.activeFocus ? "#a7c080" : "#475258"
        }
    }

    Column {
        id: form
        width: Math.min(360, root.width - 48)
        spacing: 12
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -10
        Text {
            width: parent.width
            text: Qt.formatTime(root.now, "HH:mm")
            color: "#d3c6aa"
            font.family: "Adwaita Sans"
            font.pixelSize: 68
            font.weight: Font.Light
            horizontalAlignment: Text.AlignHCenter
        }
        Text {
            width: parent.width
            text: Qt.formatDate(root.now, "dddd, d MMMM")
            color: "#859289"
            font.family: "Adwaita Sans"
            font.pixelSize: 16
            horizontalAlignment: Text.AlignHCenter
        }
        Item { width: 1; height: 12 }
        Text {
            width: parent.width
            text: "Welcome back"
            color: "#d3c6aa"
            font.family: "Adwaita Sans"
            font.pixelSize: 23
            horizontalAlignment: Text.AlignHCenter
        }
        ThemeField {
            id: username
            objectName: "username"
            width: parent.width
            placeholderText: "Username"
            text: userModel.lastUser
            enabled: !root.signingIn
            onAccepted: password.forceActiveFocus()
        }
        ThemeField {
            id: password
            objectName: "password"
            width: parent.width
            placeholderText: "Password"
            echoMode: C.TextField.Password
            enabled: !root.signingIn
            onAccepted: root.submit()
        }
        Text {
            width: parent.width
            height: 18
            text: keyboard.capsLock ? "Caps Lock is on" : ""
            color: "#dbbc7f"
            font.family: "Adwaita Sans"
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
        }
        C.ComboBox {
            id: session
            objectName: "session"
            width: parent.width
            height: 42
            model: sessionModel
            textRole: "name"
            currentIndex: sessionModel.lastIndex
            enabled: !root.signingIn
            font.family: "Adwaita Sans"
            font.pixelSize: 14
            leftPadding: 14
            rightPadding: 32
            contentItem: Text {
                text: session.displayText
                font: session.font
                color: "#d3c6aa"
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
            indicator: Text {
                x: session.width - width - 14
                y: (session.height - height) / 2
                text: "⌄"
                color: "#a7c080"
                font.pixelSize: 18
            }
            background: Rectangle {
                radius: 9
                color: "#343f44"
                border.color: session.activeFocus ? "#a7c080" : "#475258"
                border.width: session.activeFocus ? 2 : 1
            }
            delegate: C.ItemDelegate {
                width: session.width
                text: model.name
                font: session.font
                highlighted: session.highlightedIndex === index
                contentItem: Text {
                    text: parent.text
                    font: session.font
                    color: "#d3c6aa"
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle { color: parent.highlighted ? "#475258" : "#343f44" }
            }
            popup: C.Popup {
                y: session.height + 4
                width: session.width
                padding: 4
                implicitHeight: Math.min(contentItem.implicitHeight + 8, 220)
                background: Rectangle { color: "#343f44"; radius: 9; border.color: "#475258" }
                contentItem: ListView {
                    clip: true
                    implicitHeight: contentHeight
                    model: session.popup.visible ? session.delegateModel : null
                    currentIndex: session.highlightedIndex
                }
            }
        }
        ThemeButton {
            objectName: "signIn"
            width: parent.width
            height: 46
            text: root.signingIn ? "Signing in…" : "Sign in"
            accent: true
            enabled: !root.signingIn
            onClicked: root.submit()
        }
        Text {
            width: parent.width
            height: 38
            text: root.notice || "Press Enter to sign in"
            color: root.failed ? "#e67e80" : "#859289"
            font.family: "Adwaita Sans"
            font.pixelSize: 12
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }
    }

    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 26
        spacing: 12
        ThemeButton {
            width: 110
            objectName: "restart"
            text: "Restart"
            visible: sddm.canReboot
            onClicked: { root.pendingPower = "restart"; powerDialog.open(); }
        }
        ThemeButton {
            width: 110
            objectName: "shutdown"
            text: "Shut down"
            visible: sddm.canPowerOff
            onClicked: { root.pendingPower = "shutdown"; powerDialog.open(); }
        }
    }
    C.Dialog {
        id: powerDialog
        objectName: "powerDialog"
        anchors.centerIn: parent
        width: Math.min(340, root.width - 40)
        modal: true
        padding: 24
        background: Rectangle { color: "#343f44"; radius: 14; border.color: "#475258" }
        contentItem: Column {
            spacing: 20
            Text {
                text: root.pendingPower === "restart" ? "Restart your laptop?" : "Shut down your laptop?"
                color: "#d3c6aa"
                font.family: "Adwaita Sans"
                font.pixelSize: 18
            }
            Row {
                spacing: 12
                ThemeButton { objectName: "cancelPower"; width: 130; text: "Cancel"; onClicked: powerDialog.close() }
                ThemeButton {
                    objectName: "confirmPower"
                    width: 130
                    accent: true
                    text: "Confirm"
                    onClicked: {
                        powerDialog.close();
                        if (root.pendingPower === "restart") sddm.reboot();
                        else sddm.powerOff();
                    }
                }
            }
        }
    }
    Component.onCompleted: {
        if (username.text) password.forceActiveFocus();
        else username.forceActiveFocus();
    }
}
