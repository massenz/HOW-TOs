Things to remember
==================

Gnome Configuration
-------------------

To change applications settings, most notably where Rhytmbox keeps its music folders::

    $ gconf-editor & 

This opens a GUI editor.

To update where the screensavers picks it pictures from (XDK_PICTURES_DIR)::

    $ gedit .config/user-dirs.dirs 

The current contents are::

    XDG_DESKTOP_DIR="$HOME/Desktop"
    XDG_DOWNLOAD_DIR="$HOME/Downloads"
    XDG_TEMPLATES_DIR="$HOME/Templates"
    XDG_PUBLICSHARE_DIR="$HOME/Public"
    XDG_DOCUMENTS_DIR="$HOME/Documents"
    XDG_MUSIC_DIR="/mnt/shared/music"
    XDG_PICTURES_DIR="/mnt/shared/photos"
    XDG_VIDEOS_DIR="/media/multimedia/videos"
    
System Configuration
--------------------

Use ``dconf-editor`` (this needs to be installed, if not available) and navigate to::

    org.gnome.desktop.media-handling
    
to enable/disable auto-mount of media folders (eg, connected USB disks, loop devices)

