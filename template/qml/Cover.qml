import QtQuick 2.0
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.3

CoverBackground {
    CoverPlaceholder {
      id: coverLabel
      text: "Sailfish Python"
    }

    CoverActionList {
        id: coverAction

        CoverAction {
            iconSource: "image://theme/icon-cover-next"
            onTriggered: python.call('main.hello_world', [], function(message) {
                coverLabel.text = message;
            });
        }
    }

    Python{
      id: python
      Component.onCompleted: {
          addImportPath(Qt.resolvedUrl('../src'));
          importModule('main',function(){})
      }
    }
}
