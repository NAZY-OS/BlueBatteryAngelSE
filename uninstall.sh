#!/system/bin/sh
# BlueAngel-SE - Uninstallation Script

# Log-Verzeichnis und temporäre Dateien löschen, die vom Modul erstellt wurden
rm -rf /data/adb/batteryblueangel-se
rm -rf /data/local/tmp/blueangel_*

# Optional: Falls du möchtest, dass bestimmte System-Settings beim Deinstallieren 
# zurückgesetzt werden, könntest du das hier tun (Standardwerte wiederherstellen).
# In den meisten Fällen ist es aber gewünscht, dass Tweaks beim Entfernen aktiv bleiben 
# oder vom System selbst neu geregelt werden.

exit 0
