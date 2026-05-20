# Clear DNS so captive portals can hijack (public wifi login pages)
export def captive [] {
  ^networksetup -setdnsservers "Wi-Fi" empty
  print "DNS cleared — open any page to trigger the portal. Run `captive-done` when logged in."
}

# Restore privacy DNS servers
export def captive-done [] {
  ^networksetup -setdnsservers "Wi-Fi" "86.54.11.13" "86.54.11.213" "2a13:1001::86:54:11:13" "2a13:1001::86:54:11:213"
  print "Privacy DNS restored."
}
