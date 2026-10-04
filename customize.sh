#!/system/bin/sh

ui_print "========================================"
ui_print "       Installing BlueAngel-SE          "
ui_print "========================================"

# System Infos während des Flash-Vorgangs anzeigen
ui_print "OS: Android $(getprop ro.build.version.release)"
ui_print "Device: $(getprop ro.product.manufacturer) $(getprop ro.product.model)"

# Berechtigungen für die service.sh setzen, damit sie ausgeführt werden darf
if [ -f "$MODPATH/service.sh" ]; then
    set_perm 0 0 0755 "$MODPATH/service.sh"
    ui_print "-> service.sh permissions set successfully."
else
    ui_print "! Warning: service.sh not found!"
fi

ui_print "========================================"
ui_print " Installation completed! Enjoy. 😊      "
ui_print "========================================"
