#!/usr/bin/perl
use strict;
use warnings;
use File::Copy;
use File::Spec::Functions;

my $imgsrc = '/home/welcome/images';
my $display_dir= '/var/www/display';
my @pics;

my $header = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">

        <!--
                Supersized - Fullscreen Slideshow jQuery Plugin
                Version : 3.2.6
                Site    : www.buildinternet.com/project/supersized

                Author  : Sam Dunn
                Company : One Mighty Roar (www.onemightyroar.com)
                License : MIT License / GPL License
        -->

        <head>

                <title>J.N. Desmarais Library - Welcome</title>
                <meta http-equiv="content-type" content="text/html; charset=UTF-8" />

                <link rel="stylesheet" href="css/supersized.css" type="text/css" media="screen" />
                <link rel="stylesheet" href="theme/supersized.shutter.css" type="text/css" media="screen" />

                <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.6.1/jquery.min.js"></script>
                <script type="text/javascript" src="js/jquery.easing.min.js"></script>

                <script type="text/javascript" src="js/supersized.3.2.6.min.js"></script>
                <script type="text/javascript" src="theme/supersized.shutter.min.js"></script>

                <script type="text/javascript">

                        jQuery(function($){

                                $.supersized({

                                        // Functionality
                                        slide_interval          :   6000,               // Length between transitions
                                        transition              :   3,                  // 0-None, 1-Fade, 2-Slide Top, 3-Slide Right, 4-Slide Bottom, 5-Slide Left, 6-Carousel Right, 7-Carousel Left
                                        transition_speed                :       700,            // Speed of transition

                                        // Components
                                        slide_links                             :       "blank",        // Individual links for each slide (Options: false, "num", "name", "blank")
                                        slides  : [
';

my $footer = '                          ]

                                });
                    });

                </script>

        </head>

        <style type="text/css">
                ul#demo-block{ margin:0 15px 15px 15px; }
                        ul#demo-block li{ margin:0 0 10px 0; padding:10px; display:inline; float:left; clear:both; color:#aaa; background:url("img/bg-black.png"); font:11px Helvetica, Arial, sans-serif; }
                        ul#demo-block li a{ color:#eee; font-weight:bold; }
        </style>

<body>

</body>
</html>'; 

sub update_pics {
    my $extensions = '*.jpg *.JPG *.jpeg *.JPEG *.png *.PNG *.gif *.GIF';
    my $resolution = '1920x1080'; # as consumed by 'convert' command
    chdir($imgsrc);
    @pics = glob($extensions);
    if (!@pics) {
        return 0;
    }

    chdir(catdir($display_dir, 'images'));
    my @old_pics = glob($extensions);
    foreach my $old_pic (@old_pics) {
        system("rm", "-f", $old_pic);
    }

    foreach my $pic (@pics) {
        system("convert", "-resize", $resolution, catfile($imgsrc, $pic), catfile($display_dir, 'images', $pic));
    }
    return 1;
}

sub update_index {
    chdir($display_dir);
    my $slides;

    foreach my $pic (@pics) {
        $slides .= "\n{image : 'images/$pic'},";
    }
    chop($slides);

    open(SLIDE, '>', catfile($display_dir, 'index.html')) or die $!;
    print SLIDE $header;
    print SLIDE $slides;
    print SLIDE $footer;
}

my $success = update_pics();
if ($success) {
    update_index();
}
