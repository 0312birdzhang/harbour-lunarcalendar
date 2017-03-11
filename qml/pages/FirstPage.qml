/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/LunarCalendar.js" as Lunar
import "../js/chinese-lunar.js" as Clunar


Page {
    id: page

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: qsTr("Show Page 2")
                onClicked: pageStack.push(Qt.resolvedUrl("SecondPage.qml"))
            }
        }

        Item {
            property int cellWidth: width / 7
            property int cellHeight: cellWidth

            id: dateContainer
            width: parent.width
            height: datePicker.height + weekDaysSimulator.height
            Row {
                id: weekDaysSimulator
                height: Theme.paddingMedium + Theme.iconSizeExtraSmall + Theme.paddingSmall
                Repeater {
                    model: 7
                    delegate: Label {
                        // 2 Jan 2000 was a Sunday
                        text: Qt.formatDateTime(new Date(2000, 0, 3 + index, 12), "ddd")
                        width: dateContainer.cellWidth
                        font.pixelSize: Theme.fontSizeExtraSmall
                        color: Theme.highlightColor
                        opacity: 0.5
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
            Image {
                anchors.fill: parent
                source: "image://theme/graphic-gradient-edge"
                rotation: 180
                visible: isPortrait
            }
            DatePicker {
                id: datePicker
                //daysVisible: true
                anchors.top: weekDaysSimulator.bottom
                function getModelData(dateObject, primaryMonth) {
                    var y = dateObject.getFullYear()
                    var m = dateObject.getMonth() + 1
                    var d = dateObject.getDate()
                    var data = {'year': y, 'month': m, 'day': d,
                                'primaryMonth': primaryMonth,
                                'holiday': (m === 1 && d === 1) || (m === 12 && (d === 25 || d === 26))}
                    return data
                }

                modelComponent: Component {
                    ListModel { }
                }

                onUpdateModel: {
                    var i = 0
                    var dateObject = new Date(fromDate)
                    while (dateObject < toDate) {
                        if (i < modelObject.count) {
                            modelObject.set(i, getModelData(dateObject, primaryMonth))
                        } else {
                            modelObject.append(getModelData(dateObject, primaryMonth))
                        }
                        dateObject.setDate(dateObject.getDate() + 1)
                        i++
                    }
                }
                delegate: Component {
                    Rectangle {
                        id: rect
                        width: dateContainer.cellWidth
                        height: dateContainer.cellHeight
                        radius: 2
                        color: 'transparent';
                        function getLunar(){
                            return Lunar.LunarCalendar.solarToLunar(model.year, model.month, model.day);
                        }
                        Label {
                            id:label
                            property bool _today: {
                                return datePicker.day == model.day
                                    && datePicker.month == model.month
                                    && datePicker.year == model.year;
                                }
                            anchors{
                                top:parent.top
                                topMargin:Theme.paddingSmall
                                horizontalCenter: parent.horizontalCenter
                            }
                            text: model.day
                            font.pixelSize: Theme.fontSizeMedium
                            font.bold: _today
                            color: Theme.primaryColor
                        }

                        Label{
                            id:lunarday
                            anchors{
                                top:label.bottom
                                topMargin:Theme.paddingSmall*0.3
                                horizontalCenter: parent.horizontalCenter
                            }
                            text: //model.year+"-"+model.month+"-"+model.day
                                                        {
                                                           var lunar = Clunar.chineseLunar.solarToLunar(new Date(model.year,model.month-1,model.day));
                                                           console.log(Clunar.chineseLunar.format(lunar,'D'))
                                                           return Clunar.chineseLunar.format(lunar,'D')//model.year+"-"+model.month+"-"+model.day;

//                                                            if(lunar){
//                                                                var lunarDay = lunar.lunarDay
//                                                                if(lunarDay == 1||lunarDay == "1"){
//                                                                    return lunar.lunarMonthName
//                                                                }
//                                                                return lunar.lunarDayName
//                                                            }else{
//                                                                return ""
//                                                            }
                                                        }
                            font.pixelSize: Theme.fontSizeExtraSmall
                            font.bold: datePicker.day == model.day
                                       && datePicker.month == model.month
                                       && datePicker.year == model.year;

                            color: {
                                if (model.day === datePicker.day &&
                                    model.month === datePicker.month &&
                                    model.year === datePicker.year) {
                                    return Theme.highlightColor
                                } else if (lunarday.font.bold) {
                                    return Theme.highlightColor
                                } else if (model.month === model.primaryMonth) {
                                    return Theme.primaryColor
                                }
                                return Theme.secondaryColor
                            }
                        }
                        Rectangle {
                            id:workday


                            anchors{
                              top:label.baseline
                              topMargin: 5
                              right:parent.right
                              rightMargin: /*events.count > 0?parent.width/2/2:*/parent.width/2 - parent.width / 5 /2
                            }
                            width: parent.width / 5
                            height: 4
                            radius: 2
                            visible: {
                              var lunar = getLunar();
                              return lunar.worktime != 0||lunar.worktime != "0"
                            }
                            color: {
                              var lunar = getLunar();
                              var worktime = lunar.worktime;
                              var lunarfestival = lunar.lunarFestival;
                              if(worktime == 2||lunarfestival){
                                return "#00FF7F"
                              }else if(worktime == 1){
                                return "#FA8072"
                              }else{
                                return "transparent"
                              }

                            }
                        }

                        MouseArea{
                            anchors.fill: parent
                            onClicked: datePicker.date = new Date(year, month-1, day, 12, 0, 0)
                        }
                    }
                }
            }
            Component.onCompleted: {
                if (Object(datePicker).hasOwnProperty('daysVisible')) {
                    // SfOS 2
                    weekDaysSimulator.height = 0;
                    weekDaysSimulator.visible = false;
                    datePicker.daysVisible = true;
                    dateContainer.cellWidth = datePicker.cellWidth;
                    dateContainer.cellHeight = datePicker.cellHeight;
                }
            }
        }
    }
}

