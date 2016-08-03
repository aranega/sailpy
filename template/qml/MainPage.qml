import QtQuick 2.0
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.3

Page {
    id: main

    Label{
      id: mainLabel
      anchors.centerIn: parent
      text:""
    }

    Python {
        id: python
        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../src'));
            importModule('main',function(){
              call('main.hello_world', [], function(message){
                mainLabel.text = message;
              })
            });
        }
    }
}
