# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-lunarcalendar

CONFIG += sailfishapp_qml

OTHER_FILES += qml/harbour-lunarcalendar.qml \
    qml/cover/CoverPage.qml \
    qml/pages/FirstPage.qml \
    rpm/harbour-lunarcalendar.spec \
    rpm/harbour-lunarcalendar.yaml \
    rpm/harbour-lunarcalendar.changes \
    qml/js/LunarCalendar.js \
    qml/js/chinese-lunar.js \
    translations/harbour-lunarcalendar-zh_CN.ts \
    translations/harbour-lunarcalendar.ts \
    harbour-lunarcalendar.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 256x256

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-lunarcalendar-zh_CN.ts

DISTFILES += \
    qml/pages/About.qml
zh.path = /usr/share/$${TARGET}/translations
zh.files += $$PWD/translations/harbour-lunarcalendar-zh_CN.qm
INSTALLS += zh


