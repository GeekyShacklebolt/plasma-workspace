/*
*   Copyright 2011 Sebastian Kügler <sebas@kde.org>
*   Copyright 2011 Viranch Mehta <viranch.mehta@gmail.com>
*   Copyright 2013 Kai Uwe Broulik <kde@privat.broulik.de>
*
*   This program is free software; you can redistribute it and/or modify
*   it under the terms of the GNU Library General Public License as
*   published by the Free Software Foundation; either version 2 or
*   (at your option) any later version.
*
*   This program is distributed in the hope that it will be useful,
*   but WITHOUT ANY WARRANTY; without even the implied warranty of
*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*   GNU General Public License for more details
*
*   You should have received a copy of the GNU Library General Public
*   License along with this program; if not, write to the
*   Free Software Foundation, Inc.,
*   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as Components
import org.kde.plasma.workspace.components 2.0
import "plasmapackage:/code/logic.js" as Logic

MouseArea {
    id: root
    Layout.minimumWidth: units.iconSizes.small * view.count
    Layout.minimumHeight: units.iconSizes.small
    property real itemSize: Math.min(root.height, root.width/view.count)

    onClicked: plasmoid.expanded = !plasmoid.expanded

    readonly property bool isConstrained: plasmoid.formFactor == PlasmaCore.Types.Vertical || plasmoid.formFactor == PlasmaCore.Types.Horizontal

    //Should we consider turning this into a Flow item?
    Row {
        Repeater {
            id: view

            property bool hasBattery: batterymonitor.pmSource.data["Battery"]["Has Battery"]

            property bool singleBattery: isConstrained || !hasBattery

            model: singleBattery ? 1 : batterymonitor.batteries

            Item {
                id: batteryContainer

                property bool hasBattery: view.singleBattery ? batterymonitor.batteries.count : model["Plugged in"]
                property int percent: view.singleBattery ? batterymonitor.batteries.cumulativePercent : model["Percent"]
                property bool pluggedIn: pmSource.data["AC Adapter"] != undefined && pmSource.data["AC Adapter"]["Plugged in"] && (view.singleBattery || model["Is Power Supply"])

                height: root.itemSize
                width: root.width/view.count

                property real iconSize: Math.min(width, height)

                Column {
                    anchors.centerIn: parent

                    BatteryIcon {
                        id: batteryIcon
                        anchors.horizontalCenter: isConstrained ? undefined : parent.horizontalCenter
                        hasBattery: batteryContainer.hasBattery
                        percent: batteryContainer.percent
                        pluggedIn: batteryContainer.pluggedIn
                        height: isConstrained ? batteryContainer.iconSize : batteryContainer.iconSize - batteryLabel.height
                        width: height
                    }

                    Components.Label {
                        id: batteryLabel
                        width: parent.width
                        height: visible ? paintedHeight : 0
                        horizontalAlignment: Text.AlignHCenter
                        text: i18nc("battery percentage below battery icon", "%1%", percent)
                        font.pixelSize: Math.max(batteryContainer.iconSize/8, theme.mSize(theme.smallestFont).height)
                        visible: false//!isConstrained()
                    }
                }
            }
        }
    }
}
