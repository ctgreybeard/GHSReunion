<?php /**  * @copyright  Copyright (C) 2012 JoomlaThemes.co - All Rights Reserved. **/
defined( '_JEXEC' ) or die( 'Restricted access' ); define( 'YOURBASEPATH', dirname(__FILE__) );
$jquery = $this->params->get('jquery');$scrolltop = $this->params->get('scrolltop');$superfish = $this->params->get('superfish');$logo = $this->params->get('logo');$logotype = $this->params->get('logotype');
$fonts = $this->params->get('fonts');
$fluid = $this->params->get('fluid');$width = $this->params->get('width'); $headerheight = $this->params->get('headerheight');
$bgcolor = $this->params->get('bgcolor');$textcolor = $this->params->get('textcolor');$headerbgcolor  = $this->params->get('headerbgcolor');$headertextcolor  = $this->params->get('headertextcolor');$contentbgcolor  = $this->params->get('contentbgcolor');
$headingcolor = $this->params->get('headingcolor');$articleinfo = $this->params->get('articleinfo');
$menubg = $this->params->get('menubg');
$menubghover = $this->params->get('menubghover');
$menulink = $this->params->get('menulink');
$menulinkhover = $this->params->get('menulinkhover');
$sideh3color = $this->params->get('sideh3color');$sideh3bgcolor = $this->params->get('sideh3bgcolor');
$sidemenucolor = $this->params->get('sidemenucolor');$sidemenuhovercolor = $this->params->get('sidemenuhovercolor');
$sidemenubordercolor = $this->params->get('sidemenubordercolor');
$linkcolor  = $this->params->get('linkcolor');$linkhovercolor = $this->params->get('linkhovercolor');
$sitedesc   = $this->params->get('sitedesc');
$app = JFactory::getApplication();$doc  = JFactory::getDocument();
$templateparams  = $app->getTemplate(true)->params; ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="<?php echo $this->language; ?>" lang="<?php echo $this->language; ?>" dir="<?php echo $this->direction; ?>">
<head>
<jdoc:include type="head" />
<?php if ($fonts == 'Averia Sans Libre' ) { ?><link href='http://fonts.googleapis.com/css?family=Averia+Sans+Libre' rel='stylesheet' type='text/css'><?php }; ?>
<?php if ($fonts == 'Fredoka One' ) { ?><link href='http://fonts.googleapis.com/css?family=Fredoka+One' rel='stylesheet' type='text/css'><?php }; ?>
<?php if ($fonts == 'Orbitron' ) { ?><link href='http://fonts.googleapis.com/css?family=Orbitron' rel='stylesheet' type='text/css'><?php }; ?>
<?php if ($fonts == 'Berkshire Swash' ) { ?><link href='http://fonts.googleapis.com/css?family=Berkshire+Swash' rel='stylesheet' type='text/css'><?php }; ?>
<?php if ($fonts == 'Londrina Shadow' ) { ?><link href='http://fonts.googleapis.com/css?family=Londrina+Shadow' rel='stylesheet' type='text/css'><?php }; ?>
<?php if ($fonts == 'Seaweed Script' ) { ?><link href='http://fonts.googleapis.com/css?family=Seaweed+Script' rel='stylesheet' type='text/css'><?php }; ?>
<?php if ($fonts == 'Electrolize' ) { ?><link href='http://fonts.googleapis.com/css?family=Electrolize' rel='stylesheet' type='text/css'><?php }; ?>
<?php if ($fonts == 'Yanone Kaffeesatz' ) { ?><link href='http://fonts.googleapis.com/css?family=Yanone+Kaffeesatz' rel='stylesheet' type='text/css'><?php }; ?>
<?php if ($fonts == 'Audiowide' ) { ?><link href='http://fonts.googleapis.com/css?family=Audiowide' rel='stylesheet' type='text/css'><?php }; ?>
<?php if ($fonts == 'Chau Philomene One' ) { ?><link href='http://fonts.googleapis.com/css?family=Chau+Philomene+One' rel='stylesheet' type='text/css'><?php }; ?>
<?php if ($fonts == 'Crushed' ) { ?><link href='http://fonts.googleapis.com/css?family=Crushed' rel='stylesheet' type='text/css'><?php }; ?>

<?php require(YOURBASEPATH . DS . "functions.php"); ?>
<link rel="stylesheet" href="<?php echo $this->baseurl ?>/templates/<?php echo $this->template ?>/css/styles.css" type="text/css" />
<?php if ($jquery == 'yes' ) : ?><script type="text/javascript" src="http://code.jquery.com/jquery-latest.pack.js"></script><?php endif; ?> 
<?php if ($scrolltop == 'yes' ) : ?><script type="text/javascript" src="<?php echo $this->baseurl ?>/templates/<?php echo $this->template ?>/js/scrolltopcontrol.js"></script><?php endif; ?>
<?php if ($superfish == 'yes' ) : ?>
<script type="text/javascript" src="<?php echo $this->baseurl ?>/templates/<?php echo $this->template ?>/js/hoverIntent.js"></script>
<script type="text/javascript" src="<?php echo $this->baseurl ?>/templates/<?php echo $this->template ?>/js/superfish.js"></script>
<script type="text/javascript">
    jQuery(function(){
      jQuery('#nav ul').superfish({
      pathLevels  : 3,
      delay    : 800,
      animation  : {opacity:'show',height:'show',width:'show'},
      speed    : 'normal',
      autoArrows  : false,
      dropShadows : false,
      });    
    });
</script>
<?php endif; ?>
<style>
body { color:<?php echo $textcolor ?>; font:normal <?php echo $this->params->get('psize') ?>px/180% Arial, Helvetica, sans-serif; }
h1,h2,h3,h4,h5,h6 {color:<?php echo $headingcolor ?>;}
h1{font-size:<?php echo $this->params->get('h1') ?>px;}h2 {font-size:<?php echo $this->params->get('h2') ?>px;}h3 {font-size:<?php echo $this->params->get('h3') ?>px;}
h4,h5,h6 {font-size:<?php echo $this->params->get('h4') ?>px;}
#nav ul li a, #sidebar .module ul.menu li a{font-size:<?php echo $this->params->get('menusize') ?>px;}
#nav ul li ul li a {font-size:<?php echo $this->params->get('menusize')-5 ?>px;}
blockquote,h1,h2,h3,h4,h5,h6,#nav ul li a,.logo,.sitedescription,.readmore,#sidebar .module ul.menu li a{ font-family:'<?php echo $fonts ?>',Arial, Helvetica, sans-serif;}
a,#mods1 ul li, #mods2 ul li  {color: <?php echo $linkcolor ?>;}
.iteminfo {color:<?php echo $articleinfo ?>;}
#navr {background-color:<?php echo $menubg ?>}
#nav ul li a,
#nav ul li ul li a,
#nav ul li ul li ul li a,
#nav ul li a:active,
#nav ul li ul li a:active,
#nav ul li ul li ul li a:active { color:<?php echo $menulink ?>; background-color:<?php echo $menubg ?> },
#nav ul li a:hover,
#nav ul li ul li a:hover,
#nav ul li ul li ul li a:hover {color:<?php echo $menulinkhover ?>; background-color:<?php echo $menubghover ?>  }
#sidebar a { color:<?php echo $sidemenucolor ?>; background-color:<?php echo $menubg ?>; }
#sidebar a:hover {color:<?php echo $sidemenuhovercolor ?>; background-color:<?php echo $menubghover ?>;  }
a:hover {color:<?php echo $linkhovercolor ?>;}
.logo a, #top a,.sitedescription {color:<?php echo $headertextcolor ?>;}
.logo, .logo a { font-size:<?php echo $this->params->get('logosize') ?>px; line-height:110%}
.sitedescription {font-size:<?php echo $this->params->get('descsize') ?>px; line-height:110%}
#sidebar .module-title {color: <?php echo $sideh3color ?>; background-color:<?php echo $sideh3bgcolor ?>; border:1px solid #<?php echo $sideh3bgcolor ?>;}
.button, .validate { color:<?php echo $sideh3color ?>;background-color:<?php echo $sideh3bgcolor ?>;border:1px solid <?php echo $sideh3bgcolor ?>; } 
.button:hover, .validate:hover {background-color:<?php echo $sideh3bgcolor ?> }
#topcontrol { background-color:<?php echo $sideh3bgcolor ?>}
</style>
</head>
<body class="background" style="background-color:<?php echo $bgcolor ?>">
<div id="main">
  <div id="wrapper" style="width:<?php if ($fluid == 'yes' ) { echo '100%'; } else { echo $width.'px'; }  ?>"><?php if ($fluid == 'yes' ) {}  else { ?><div id="wrapper-l"></div><div id="wrapper-r"></div><?php } ?> 
         <div id="header" style="height:<?php echo $headerheight ?>px;background-color:<?php echo $headerbgcolor ?>;color:<?php echo $headertextcolor ?>">
    <?php if ($logotype == 'image' ) : ?>
    <?php if ($logo != null ) : ?>
    <div class="logo"><a href="<?php echo $this->baseurl ?>"><img src="<?php echo $this->baseurl ?>/<?php echo htmlspecialchars($logo); ?>" alt="<?php echo htmlspecialchars($templateparams->get('sitetitle'));?>"/></a></div>
    <?php else : ?>
    <div class="logo"><a href="<?php echo $this->baseurl ?>/"><img src="<?php echo $this->baseurl; ?>/templates/<?php echo $this->template; ?>/images/logo.png" border="0"></a></div>
    <?php endif; ?><?php endif; ?> 
    <?php if ($logotype == 'text' ) : ?>
    <div class="logo text"><a href="<?php echo $this->baseurl ?>"><?php echo htmlspecialchars($templateparams->get('sitetitle'));?></a></div>
    <?php endif; ?>
    <?php if ($sitedesc !== '' ) : ?>
    <div class="sitedescription"><?php echo htmlspecialchars($templateparams->get('sitedesc'));?></div>
    <?php endif; ?> 
        
        <?php if ($this->countModules('top')) : ?>
            <div id="top">
                <jdoc:include type="modules" name="top" style="none" />
            </div>
        <?php endif; ?>                       
        </div>          
          <?php if ($this->countModules('menu')) : ?>
          <div id="navr"><div id="navl"><div id="nav">
          <jdoc:include type="modules" name="menu" style="none" />
      </div></div></div>
          <?php endif; ?>    
    <?php if ($this->countModules('slideshow')) : ?> 
            <div id="slide-w">
                <jdoc:include type="modules" name="slideshow"  style="none"/>           
            </div>
        <?php endif; ?>    
     <div id="comp" style="background-color:<?php echo $contentbgcolor ?>">
        <?php if ($this->countModules('breadcrumbs')) : ?>
          <jdoc:include type="modules" name="breadcrumbs"  style="none"/>
        <?php endif; ?>
          <?php if ($this->countModules('user1 or user2 or user3')) : ?>
                    <div id="mods1" class="spacer<?php echo $mainmod1_width; ?>">
                        <jdoc:include type="modules" name="user1" style="jaw" />
                        <jdoc:include type="modules" name="user2" style="jaw" />
                        <jdoc:include type="modules" name="user3" style="jaw" /> 
                    </div>
                    <?php endif; ?>        
        <div class="full">
                    <?php if ($this->countModules('left')) : ?>
                    <div id="leftbar-w">
                    <div id="sidebar">
                        <jdoc:include type="modules" name="left" style="jaw" />
                    </div>
                    </div>
                    <?php endif; ?>                          
                        <div id="comp_<?php echo $compwidth ?>">
                            <div id="comp-i">
                              <jdoc:include type="message" />
                                <?php include "html/template.php"; ?>
                                <jdoc:include type="component" />
                                <div class="clr"></div>
                            </div>
                        </div>                     
                    </div>
                    <?php if ($this->countModules('right')) : ?>
                    <div id="rightbar-w">
                    <div id="sidebar">
                        <jdoc:include type="modules" name="right" style="jaw" />
                    </div>
                    </div>
                    <?php endif; ?>
    <div class="clr"></div>
    <?php if ($this->countModules('user4 or user5 or user6')) : ?>
        <div id="footer">
    <div id="mods2" class="spacer<?php echo $mainmod2_width; ?>">
      <jdoc:include type="modules" name="user4" style="jaw" />
      <jdoc:include type="modules" name="user5" style="jaw" />
      <jdoc:include type="modules" name="user6" style="jaw" />
    </div>
        </div>
    <?php endif; ?>  
        <div class="clr"></div>       
        </div>
        <div class="clr"></div>
        <div class="shadow2"></div>
  
<?php if ($this->countModules('user7 or user8 or user9 or user10')) : ?>
<div id="footer">
    <div id="mods2" class="spacer<?php echo $mainmod3_width; ?>">
      <jdoc:include type="modules" name="user7" style="jaw" />
      <jdoc:include type="modules" name="user8" style="jaw" />
      <jdoc:include type="modules" name="user9" style="jaw" />
            <jdoc:include type="modules" name="user10" style="jaw" />
    </div>  
</div>        
<?php endif; ?>
    <div id="bottom">
            <?php if ($this->countModules('copyright')) : ?>
                <div class="copy">
                    <jdoc:include type="modules" name="copyright"/>
                </div>
            <?php endif; ?>
<?php $app = JFactory::getApplication(); $menu = $app->getMenu(); if ($menu->getActive() == $menu->getDefault()) { ?>
<div class="design"><a href="http://joomlathemes.co" target="_blank" title="free joomla templates">Joomla Themes</a> designed by <a href="http://webhostingtop.org" target="_blank" title="web hosting reviews">Web Hosting Top</a></div><?php } ?>
    </div>
</div>
</div>

</body>
</html>