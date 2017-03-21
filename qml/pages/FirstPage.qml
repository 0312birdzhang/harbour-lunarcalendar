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

    allowedOrientations: Orientation.All

    ListModel{
        id:eventsModel
    }

    function getLunar(year,month,day){
        return Lunar.LunarCalendar.solarToLunar(year,month,day);
    }
    function getCLunar(year,month,day){
        return Clunar.chineseLunar.solarToLunar(new Date(year,month-1,day));
    }

    function showLunarInfo(year,month,day){
        var info = getCLunar(year,month,day);
        return Clunar.chineseLunar.format(info,'T[A]YMd');
    }
    function showFestival(year,month,day){
        var info = getLunar(year,month,day);
        var solarFestival = info.solarFestival;
        var lunarFestival = info.lunarFestival;
        var term = info.term;
        var showtext="";
        if(solarFestival)showtext+=solarFestival+",";
        if(lunarFestival)showtext+=lunarFestival+",";
        if(term){
            showtext+=term;
        }else{
            showtext=showtext.substring(0,showtext.length-1)
        }
        return showtext;
    }
    SilicaFlickable {
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("About.qml"));
            }
            MenuItem {
                text: qsTr("Return Today")
                onClicked: {
                    datePicker.date = new Date();
                    var year = datePicker.year;
                    var month = datePicker.month;
                    var day = datePicker.day;
                    eventsModel.clear();
                    eventsModel.append({
                                            "note":year+"-"+month+"-"+day
                                        });
                    eventsModel.append({
                                            "note":showLunarInfo(year,month,day)
                                        });
                    var festival = showFestival(year,month,day)
                    for(var i in festival.split(" ")){
                        eventsModel.append({
                                            "note":festival.split(" ")[i]
                                        });
                    }
                }
            }
        }


        contentHeight: isPortrait? dateColumn.height + lunaColumn.height : dateColumn.height
        Column {
            id: dateColumn
            width: isPortrait? parent.width : Screen.width//parent.width * 0.55;
            spacing: 0
            PageHeader {
                id: header
                title: qsTr("Lunar")
                visible: isPortrait
            }
            Item {
                id: landscapeSpacing
                visible: isLandscape
                width: parent.width
                height: Theme.paddingMedium
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
                    daysVisible: true
                    anchors.top: weekDaysSimulator.bottom
                    onMonthChanged:{
                        console.log("changed")
                        eventsModel.clear()
                        eventsModel.append({
                                               "note":datePicker.year+"-"+datePicker.month+"-"+datePicker.day
                                           })
                        eventsModel.append({
                                               "note":showLunarInfo(datePicker.year,datePicker.month,datePicker.day)
                                           });
                        var festival = showFestival(datePicker.year,datePicker.month,datePicker.day);
                        for(var i in festival.split(" ")){
                            eventsModel.append({
                                               "note":festival.split(" ")[i]
                                           });
                        }
                    }


//                    function getModelData(dateObject, primaryMonth) {
//                        var y = dateObject.getFullYear()
//                        var m = dateObject.getMonth() + 1
//                        var d = dateObject.getDate()
//                        var data = {'year': y, 'month': m, 'day': d,
//                            'primaryMonth': primaryMonth,
//                            'holiday': (m === 1 && d === 1) || (m === 12 && (d === 25 || d === 26))}
//                        return data
//                    }

//                    modelComponent: Component {
//                        ListModel { }
//                    }

//                    onUpdateModel: {
//                        var i = 0
//                        var dateObject = new Date(fromDate)
//                        while (dateObject < toDate) {
//                            if (i < modelObject.count) {
//                                modelObject.set(i, getModelData(dateObject, primaryMonth))
//                            } else {
//                                modelObject.append(getModelData(dateObject, primaryMonth))
//                            }
//                            dateObject.setDate(dateObject.getDate() + 1)
//                            i++
//                        }
//                    }
                    delegate: Component {
                        Rectangle {
                            id: rect
                            width: dateContainer.cellWidth
                            height: dateContainer.cellHeight
                            radius: 2
                            color: 'transparent';

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
                                text: {
                                    return Clunar.chineseLunar.format(getCLunar(year,month,day),'D')
                                }
                                font.pixelSize: Theme.fontSizeExtraSmall * 0.7
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
                                    rightMargin: parent.width/2 - parent.width / 5 /2
                                }
                                width: parent.width / 5
                                height: width/5
                                radius: 2
                                visible: {
                                    var lunar = getLunar(year,month,day);
                                    return lunar.worktime != 0||lunar.worktime != "0"
                                }
                                color: {
                                    var lunar = getLunar(year,month,day);
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
                                onClicked: {
//                                    console.log(year+"-"+month+"-"+day)
                                    datePicker.date = new Date(year, month-1, day, 12, 0, 0);
                                    eventsModel.clear();
                                    eventsModel.append({
                                                           "note":year+"-"+month+"-"+day
                                                       });
                                    eventsModel.append({
                                                           "note":showLunarInfo(year,month,day)
                                                       });
                                    var festival = showFestival(year,month,day)
                                    for(var i in festival.split(" ")){
                                        eventsModel.append({
                                                           "note":festival.split(" ")[i]
                                                       });
                                    }
                                }
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
                    eventsModel.clear()
                    eventsModel.append({
                                           "note":datePicker.year+"-"+datePicker.month+"-"+datePicker.day
                                       })
                    eventsModel.append({
                                           "note":showLunarInfo(datePicker.year,datePicker.month,datePicker.day)
                                       });
                    var festival = showFestival(datePicker.year,datePicker.month,datePicker.day);
                    for(var i in festival.split(" ")){
                        eventsModel.append({
                                           "note":festival.split(" ")[i]
                                       });
                    }

                }
            }


        }
        Item {
            id: lunaColumn
            x: isPortrait? 0 : dateColumn.width
            y: isPortrait? dateColumn.height + dateColumn.y : Theme.paddingLarge
            width: isPortrait? page.width : page.width - dateColumn.width
            height: isPortrait? page.height - dateColumn.height : page.height
            clip: true
            SectionHeader{
                id:extHeader
                text: lunaView.currentIndex == 0?qsTr("Festival information"):qsTr("Custom events")
            }

            SlideshowView {
                id: lunaView
                y: extHeader.y
                width: parent.width
                height:parent.height
                model:VisualItemModel {
                    SilicaListView{
                        height: lunaView.height
                        width: lunaView.width
                        clip: true
                        header:Item{width: 1;height: Theme.itemSizeExtraSmall}
                        model: eventsModel
                        delegate: BackgroundItem {
                            Label {
                                x: Theme.horizontalPageMargin
                                text: model.note
                                font.pixelSize: Theme.fontSizeSmall
                                horizontalAlignment: Text.AlignRight
                                color: Theme.primaryColor
                                wrapMode: Text.WordWrap
                                anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                    }
                    Item{
                        width: lunaView.width
                        height: lunaView.height
                        SilicaListView{
                            id:userEventView
                            height: lunaView.height
                            width: lunaView.width
                            header:Item{width: 1;height: Theme.itemSizeExtraSmall}
                            clip: true
                            model: 0
                            delegate: BackgroundItem {
                                Label {
                                    x: Theme.horizontalPageMargin
                                    text: "Item" + " " + index
                                    font.pixelSize: Theme.fontSizeSmall
                                    horizontalAlignment: Text.AlignRight
                                    color: Theme.primaryColor
                                    wrapMode: Text.WordWrap
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }

                        Label {
                            id: noLunaPlaceholder
                            anchors.fill: parent
                            wrapMode: Text.Wrap
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font {
                                pixelSize: Theme.fontSizeLarge
                                family: Theme.fontFamilyHeading
                            }
                            color: Theme.rgba(Theme.highlightColor, 0.6)
                            visible: userEventView.count === 0
                            text: qsTr("Comming soon")
                        }
                    }

                }
            }

        }
    }
}

