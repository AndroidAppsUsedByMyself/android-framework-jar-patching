#!/usr/bin/env bash

# functions
source $(dirname $(realpath "$0"))/_.sh

# patch #1: ExtconStateObserver
PATCH_IDENTITY=fdd446b9aca6ed3e7cc0f7379b890f0e
LIB='services.jar'
FILE="com/android/server/ExtconStateObserver.smali"
REGEX='const-string v0, "NAME"\s*invoke-virtual {p2, v0}, Landroid\/os\/UEventObserver\$UEvent;->get\(Ljava\/lang\/String;\)Ljava\/lang\/String;\s*move-result-object (\w+)\s*\.line \d+'
PATCH=$(cat << EOF
    $(android_logcat $LIB"_bypass_ExtconStateObserver_NullName" | sed 's/[][\.*^$(){}?+|\/]/\\&/g')

    if-nez \2, :ExtconStateObserver_NameNotNull

    return-void

    :ExtconStateObserver_NameNotNull
EOF
)
# we use CODE_WITHOUT_ESCAPE bcs we want to insert regex \2, so we have to use it and manual escape when need
patch_insert_after "$PATCH_IDENTITY" "$LIB" "$REGEX" "$PATCH" "$FILE" "CODE_WITHOUT_ESCAPE"

# patch #2: WiredAccessoryManager$WiredAccessoryObserver
PATCH_IDENTITY=1647eb2ff10901e5380be698edb22872
LIB='services.jar'
FILE='com/android/server/WiredAccessoryManager$WiredAccessoryObserver.smali'
REGEX='const-string \w+, "SWITCH_NAME"\s*invoke-virtual {\w+, \w+}, Landroid\/os\/UEventObserver\$UEvent;->get\(Ljava\/lang\/String;\)Ljava\/lang\/String;\s*move-result-object (\w+)\s*\.line \d+'
PATCH=$(cat << EOF
    $(android_logcat $LIB"_bypass_WiredAccessoryObserver_NullName" | sed 's/[][\.*^$(){}?+|\/]/\\&/g')

    if-nez \2, :WiredAccessoryObserver_NameNotNull

    return-void

    :WiredAccessoryObserver_NameNotNull
EOF
)
# we use CODE_WITHOUT_ESCAPE bcs we want to insert regex \2, so we have to use it and manual escape when need
patch_insert_after "$PATCH_IDENTITY" "$LIB" "$REGEX" "$PATCH" "$FILE" "CODE_WITHOUT_ESCAPE"
