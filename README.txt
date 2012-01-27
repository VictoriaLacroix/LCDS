El Cheapo Library signage
=========================
Dan Scott <dscott@laurentian.ca>
:toc:
:numbered:

*Problem*: we had a shiny new TV mounted in our library for the purposes of
digital signage. Much less expensive than commercial digital signage options.
Unfortunately, it was too high for most people to reach to replace the USB key;
we were relying on the built-in slideshow to display a series of images from
the USB key, but it was quickly becoming a drag to have to climb on various
sturdy objects to swap the USB key for every change of hours or new
announcement.

*Problem*: one of our loaner netbooks was dropped, resulting in a
non-functional screen - but the netbook would still run and could generate an
image on an external monitor.

*Solution*: stick the netbook behind the TV, plug in a Linux-on-a-stick USB key
set up to display a web page on boot, and point it at a basic web site that
automatically assembles a slideshow based on the images in a user-editable
directory.

*Key ingredients*:
  * http://webconverger.org[Webconverger] Linux distribution that provides a
    Web kiosk solution.
  * http://buildinternet.com/project/supersized/[Supersized] web application
    that provides a fullscreen background slideshow.
  * Gumption.

Creating a digital signage Linux-on-a-stick
-------------------------------------------
. Get the http://webconverger.org[Webconverger] ISO image, mount it, and make
  an editable copy. We used a nightly build because the developer added the
  Realtek firmware within one day of making the initial request. You will
  probably need to grab a later nightly build or a subsequent release build.
+
[source,bash]
------------------------------------------------------------------------------
wget http://build.webconverger.org/webconverger.2012-01-26.iso
mount -o loop webconverger.2012-01-26.iso /mnt/webc
rsync -av /mnt/webc/ /mnt/custom/
------------------------------------------------------------------------------
+
. Edit the boot configuration to include your desired parameters; in this case
  kiosk mode with the desired homepage:
+
[source,bash]
------------------------------------------------------------------------------
chmod +w /mnt/custom/isolinux/live.cfg
vim /mnt/custom/isolinux/live.cfg
------------------------------------------------------------------------------
+
The contents of `live.cfg`:
+
------------------------------------------------------------------------------
include::live.cfg[tabsize=2]
------------------------------------------------------------------------------
+
. Generate the customized ISO image:
+
[source,bash]
------------------------------------------------------------------------------
genisoimage -J -l -cache-inodes -allow-multidot -no-emul-boot -boot-load-size 4 \
  -boot-info-table -r -b isolinux/isolinux.bin -c isolinux/boot.cat \
  -o custom.iso /mnt/custom/
isohybrid custom.iso
------------------------------------------------------------------------------
+
. Write the image to the USB key in `/dev/sdc`:
+
[source,bash]
------------------------------------------------------------------------------
dd bs=1M if=custom.iso of=/dev/sdc
------------------------------------------------------------------------------

Setting up the display web site
-------------------------------
We rely on the http://buildinternet.com/project/supersized/[SuperSized]
project to provide almost everything for us. Our goal is to set up a
basic Web server and an automated process that generates updated signage
display with minimal human intervention. Here's what we did:

. Set up a Web server. Debian, naturally.
. Download and unzip the http://buildinternet.com/project/supersized/download.html[SuperSized
  zip file].
. Move the `slideshow` subdirectory of the unzipped directory to
  `/var/www/display`
. Create a user named *welcome* and lock it down so that it can only be
  accessed for SFTP purposes by editing `/etc/ssh/sshd_config` to include:
+
[source,bash]
------------------------------------------------------------------------------
Match User welcome
        ChrootDirectory /home
        AllowTCPForwarding no
        X11Forwarding no
        ForceCommand internal-sftp
        PasswordAuthentication yes
------------------------------------------------------------------------------
. Drop the `gen_slides.pl` script into the *welcome* user's home directory.
. Create directories and set permissions as the *root* user:
+
[source,bash]
------------------------------------------------------------------------------
/etc/init.d/sshd reload
mkdir /var/www/display/images
touch /var/www/display/index.html
chown -R www-data:www-data /var/www/display
chown welcome /var/www/display/index.html
chown welcome /var/www/display/images
------------------------------------------------------------------------------
. Add a `cron` job to run the `gen_slides.pl` script every ten minutes.
  This script checks the contents of the *welcome* user's `images` directory
  and generates a new `/var/www/display/index.html` based on the contents. As
  the *welcome* user, run `crontab -e` and add the following entry:
+
[source,bash]
------------------------------------------------------------------------------
*/10 * * * * /home/welcome/gen_slides.pl
------------------------------------------------------------------------------
. Webconverger displays an image on the desktop background between browser 
  refreshes, using whatever it finds at `$HOMEPAGE/bg.png` and falling back
  to the Webconverger logo if nothing is found there. As the *welcome* user,
  copy your institutional logo into place:
+
[source,bash]
------------------------------------------------------------------------------
cp logo.png /var/www/display/bg.png
------------------------------------------------------------------------------

Signage update process
----------------------
. Install http://filezilla-project.org/[FileZilla] or http://winscp.net[WinSCP]
  so that you can use SFTP to transfer files. 
. Set up a connection in your SFTP client to:
  * hostname: `hostname`
  * user name: `welcome`
  * password: `password`
. Transfer the new images (`.jpg`, `.jpeg`, `.png`, `.gif`) that you want into
  the "images" folder of the "welcome" user, and remove the old files that you no
  longer want to display. 

Every 10 minutes, a script will automatically regenerate the list of images to
display at http://hostname/display based on the contents of the
"images" folder for the "welcome" user. 

Every 15 minutes, the laptop connected to the digital sign will reload the
web page so that it picks up any new images. 
