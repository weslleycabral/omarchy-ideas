import QtQuick
import Quickshell
import Quickshell.Io
import qs.Ui
import "I18n.js" as I18n

BarWidget {
  id: root
  moduleName: "weslleycabral.ideas"

  property int count: 0
  property string lang: I18n.resolve(Quickshell.env("LANG"))
  readonly property string dataHome: Quickshell.env("XDG_DATA_HOME") || Quickshell.env("HOME") + "/.local/share"
  readonly property string configHome: Quickshell.env("XDG_CONFIG_HOME") || Quickshell.env("HOME") + "/.config"

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  FileView {
    id: db
    path: root.dataHome + "/omarchy-ideas/ideas.json"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: {
      try { root.count = JSON.parse(text()).length } catch (e) { root.count = 0 }
    }
    onLoadFailed: root.count = 0
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

  // Recovers the watch when a file is created or replaced after the first load.
  Timer {
    interval: 30000
    running: true
    repeat: true
    onTriggered: {
      db.reload()
      settingsFile.reload()
    }
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󰌵"
    tooltipText: (root.count === 1 ? I18n.t(root.lang, "one") : I18n.t(root.lang, "many", root.count))
      + " · " + I18n.t(root.lang, "rightNew")
    onPressed: function(button) {
      if (!root.bar) return
      if (button === Qt.RightButton) root.bar.run("omarchy-shell shell summon weslleycabral.ideas '{\"mode\":\"new\"}'")
      else root.bar.run("omarchy-shell shell toggle weslleycabral.ideas '{\"mode\":\"list\"}'")
    }
  }
}
