# This script was generated by new bing to convert sh to nushell
# @see https://superuser.com/a/1575609

# //// CONFIGURABLE VARIABLES ////////////
let need_loop = false
let current_scripts_path = $env.FILE_PWD
# pausetime between iterations
let sleeptime = 90min
# location of wallpapers folder
let location = ($current_scripts_path | path dirname | path join "assets/wallpapers")
# ////////////////////////////////////////

def random_wallpaper [] {
    let array = (ls $location) # populate array with directory contents
    echo $array # list array content for debug

    let size = ($array | length)

    let index = (random int) mod $size
    echo $index

    let wallpaper = ($array | get $index) # randomly select

    echo $"($wallpaper.name) is SELLECTED WALLPAPER"

    let plasma_shell_script = $"string:var Desktops = desktops\();
    for \(i=0;i<Desktops.length;i++) {
        desktop = Desktops[i];
        desktop.wallpaperPlugin = 'org.kde.image';
        desktop.currentConfigGroup = Array\('Wallpaper',
                                    'org.kde.image',
                                    'General');
        desktop.writeConfig\('Image', 'file:///($wallpaper.name)');
    }"
    dbus-send --session --dest=org.kde.plasmashell --type=method_call /PlasmaShell org.kde.PlasmaShell.evaluateScript $plasma_shell_script
}


if $need_loop {
    while true {
        random_wallpaper
        sleep $sleeptime
    }
} else {
    random_wallpaper
}

