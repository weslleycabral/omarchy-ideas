import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "I18n.js" as I18n

Item {
  id: root

  property var shell: null
  property var manifest: null

  readonly property string script: decodeURIComponent(Qt.resolvedUrl("bin/ideas").toString().replace("file://", ""))
  readonly property string dataHome: Quickshell.env("XDG_DATA_HOME") || Quickshell.env("HOME") + "/.local/share"
  readonly property string configHome: Quickshell.env("XDG_CONFIG_HOME") || Quickshell.env("HOME") + "/.config"

  property bool opened: false
  property string mode: "list"   // list | new | detail
  property var ideas: []
  property int cursor: 0
  property string detailId: ""
  property string lang: I18n.resolve(Quickshell.env("LANG"))
  readonly property var detail: {
    for (var i = 0; i < ideas.length; i++) if (ideas[i].id === detailId) return ideas[i]
    return null
  }

  property color background: Commons.Color.menu.background
  property color foreground: Commons.Color.menu.text
  property color border: Commons.Color.menu.border
  property color accent: Commons.Color.accent
  property var borderSpec: Border.surfaceSpec("menu", "border", border, Math.max(1, Style.space(2)))
  property color scrim: Commons.Color.menu.scrim
  readonly property int pad: Style.spacing.panelPadding
  readonly property int gap: Style.space(10)
  property string fontFamily: Style.font.menuFamily

  function t(key, arg) {
    return I18n.t(root.lang, key, arg)
  }

  function open(payloadJson) {
    var payload = ({})
    try { payload = JSON.parse(payloadJson || "{}") } catch (e) { payload = ({}) }
    db.reload()
    settingsFile.reload()
    root.opened = true
    if (payload.mode === "detail" && payload.id) {
      root.detailId = payload.id
      root.setMode("detail")
    } else {
      root.setMode(payload.mode === "new" ? "new" : "list")
    }
  }

  function close() {
    root.opened = false
  }

  function dismiss() {
    root.opened = false
    if (root.shell && typeof root.shell.hide === "function")
      root.shell.hide((root.manifest && root.manifest.id) || "weslleycabral.ideas")
  }

  function toggle() {
    if (root.opened) root.dismiss()
    else root.open("{}")
  }

  function setMode(next) {
    root.mode = next
    if (next === "new") {
      input.text = ""
      Qt.callLater(function() { input.forceActiveFocus() })
    } else {
      if (next === "list") root.cursor = Math.min(root.cursor, Math.max(0, root.ideas.length - 1))
      Qt.callLater(function() { keyCatcher.forceActiveFocus() })
    }
  }

  function save() {
    var text = input.text.trim()
    if (text) Quickshell.execDetached(["python3", root.script, "add", text])
    root.setMode("list")
  }

  function showDetail(index) {
    if (index < 0 || index >= root.ideas.length) return
    root.cursor = index
    root.detailId = root.ideas[index].id
    root.setMode("detail")
  }

  function remove(id) {
    Quickshell.execDetached(["python3", root.script, "rm", id])
    root.setMode("list")
  }

  function formatDate(iso) {
    var d = new Date(iso)
    return isNaN(d) ? "" : Qt.formatDateTime(d, root.t("dateFormat"))
  }

  FileView {
    id: db
    path: root.dataHome + "/omarchy-ideas/ideas.json"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: {
      var list = []
      try { list = JSON.parse(text()) } catch (e) { list = [] }
      root.ideas = list.slice().reverse()
    }
    onLoadFailed: root.ideas = []
  }

  FileView {
    id: settingsFile
    path: root.configHome + "/omarchy-ideas/settings.json"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: {
      try { root.lang = I18n.resolve(JSON.parse(text()).lang || Quickshell.env("LANG")) } catch (e) {}
    }
  }

  PanelWindow {
    id: panel
    visible: root.opened
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    WlrLayershell.namespace: "weslleycabral-ideas"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore

    Rectangle {
      anchors.fill: parent
      color: root.scrim
    }

    MouseArea {
      anchors.fill: parent
      onClicked: root.dismiss()
    }

    BorderSurface {
      id: card
      width: Math.min(Style.space(560), panel.width - Style.gapsOut * 2)
      height: Math.min(Style.space(460), panel.height - Style.gapsOut * 2)
      radius: Style.cornerRadius
      anchors.centerIn: parent
      color: root.background
      borderSpec: root.borderSpec
      padding: root.pad

      MouseArea { anchors.fill: parent; onClicked: {} }

      Item {
        id: keyCatcher
        anchors.fill: parent
        focus: true

        Keys.onPressed: function(event) {
          if (event.key === Qt.Key_Escape) {
            if (root.mode === "detail") root.setMode("list")
            else root.dismiss()
          } else if (root.mode === "list") {
            if (event.key === Qt.Key_Down || event.key === Qt.Key_J) {
              root.cursor = Math.min(root.cursor + 1, root.ideas.length - 1)
              list.positionViewAtIndex(root.cursor, ListView.Contain)
            } else if (event.key === Qt.Key_Up || event.key === Qt.Key_K) {
              root.cursor = Math.max(root.cursor - 1, 0)
              list.positionViewAtIndex(root.cursor, ListView.Contain)
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
              root.showDetail(root.cursor)
            } else if (event.key === Qt.Key_N) {
              root.setMode("new")
            } else return
          } else if (root.mode === "detail") {
            if (event.key === Qt.Key_Backspace || event.key === Qt.Key_Left) root.setMode("list")
            else if (event.key === Qt.Key_Delete && root.detail) root.remove(root.detail.id)
            else return
          } else return
          event.accepted = true
        }
      }

      Item {
        anchors.fill: parent
        anchors.topMargin: card.contentTopInset
        anchors.rightMargin: card.contentRightInset
        anchors.bottomMargin: card.contentBottomInset
        anchors.leftMargin: card.contentLeftInset

        Item {
          id: header
          anchors { top: parent.top; left: parent.left; right: parent.right }
          height: Math.max(headerRow.implicitHeight, headerTitle.implicitHeight)

          Text {
            id: headerTitle
            anchors.left: parent.left
            anchors.right: headerRow.left
            anchors.rightMargin: root.gap
            anchors.verticalCenter: parent.verticalCenter
            textFormat: Text.PlainText
            wrapMode: Text.WordWrap
            maximumLineCount: 3
            elide: Text.ElideRight
            text: root.mode === "new" ? root.t("newIdea")
              : root.mode === "detail" ? (root.detail ? root.detail.title : "")
              : root.t("ideas", root.ideas.length)
            color: root.foreground
            font.family: root.fontFamily
            font.pixelSize: Style.font.heading
            font.bold: true
          }

          Row {
            id: headerRow
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.spacing.controlGap

            Button {
              visible: root.mode === "list"
              text: root.t("add")
              bordered: true
              onClicked: root.setMode("new")
            }
            Button {
              visible: root.mode === "detail"
              text: root.t("copy")
              bordered: true
              onClicked: if (root.detail) Quickshell.execDetached(["wl-copy", root.detail.title + "\n\n" + root.detail.text])
            }
            Button {
              visible: root.mode === "detail"
              text: root.t("remove")
              bordered: true
              onClicked: if (root.detail) root.remove(root.detail.id)
            }
            Button {
              visible: root.mode !== "list"
              text: root.t("back")
              bordered: true
              onClicked: root.setMode("list")
            }
          }
        }

        Item {
          anchors { top: header.bottom; topMargin: root.gap; left: parent.left; right: parent.right; bottom: footer.top; bottomMargin: root.gap }

          ListView {
            id: list
            anchors.fill: parent
            visible: root.mode === "list"
            clip: true
            spacing: Style.space(2)
            model: root.ideas
            boundsBehavior: Flickable.StopAtBounds

            delegate: Button {
              required property var modelData
              required property int index
              width: list.width
              leftAlign: true
              hasCursor: index === root.cursor
              iconText: modelData.status === "processing" ? "󰔟" : "󰌵"
              text: modelData.title
              onClicked: root.showDetail(index)
              onHovered: function(h) { if (h) root.cursor = index }
            }

            Text {
              anchors.centerIn: parent
              visible: root.ideas.length === 0
              text: root.t("empty")
              color: root.foreground
              opacity: 0.58
              font.family: root.fontFamily
              font.pixelSize: Style.font.body
            }
          }

          ScrollView {
            anchors.fill: parent
            visible: root.mode === "new"

            TextArea {
              id: input
              wrapMode: TextEdit.Wrap
              placeholderText: root.t("placeholder")
              placeholderTextColor: Qt.darker(root.foreground, 1.6)
              color: root.foreground
              selectionColor: Style.selectionFillFor(root.foreground, root.accent)
              font.family: root.fontFamily
              font.pixelSize: Style.font.title
              padding: Style.spacing.controlPaddingX
              background: BorderSurface {
                color: Style.controlFill(input.activeFocus, false, root.foreground, root.accent)
                borderSpec: Border.controlSpec(input.activeFocus ? "focus" : "normal", root.foreground, root.accent)
                radius: Style.cornerRadius
              }

              Keys.onPressed: function(event) {
                if (event.key === Qt.Key_Escape) {
                  root.dismiss()
                  event.accepted = true
                } else if ((event.key === Qt.Key_Return || event.key === Qt.Key_Enter) && !(event.modifiers & Qt.ShiftModifier)) {
                  root.save()
                  event.accepted = true
                }
              }
            }
          }

          ScrollView {
            anchors.fill: parent
            visible: root.mode === "detail"

            TextArea {
              readOnly: true
              selectByMouse: true
              wrapMode: TextEdit.Wrap
              text: root.detail ? root.detail.text : ""
              color: root.foreground
              selectionColor: Style.selectionFillFor(root.foreground, root.accent)
              font.family: root.fontFamily
              font.pixelSize: Style.font.title
              background: null
            }
          }
        }

        Text {
          id: footer
          anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
          textFormat: Text.PlainText
          elide: Text.ElideRight
          text: root.mode === "new" ? root.t("footerNew")
            : root.mode === "detail" ? ((root.detail ? root.formatDate(root.detail.created)
                + (root.detail.agent ? " · " + root.t("fixedBy", root.detail.agent)
                  : root.detail.status === "processing" ? " · " + root.t("fixing") : "") : "")
                + " · " + root.t("footerDetail"))
            : root.t("footerList")
          color: root.foreground
          opacity: 0.58
          font.family: root.fontFamily
          font.pixelSize: Style.font.bodySmall
        }
      }
    }
  }
}
