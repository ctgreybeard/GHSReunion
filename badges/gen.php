<?php
	$blockn = 0;
	$rown = 0;
	function startrow() {
		global $rown;
		$rown++;
		echo "<div class=\"badge-row row$rown wireframe\">\n";
	}
	function endrow() {
		echo "</div>\n";
	}
	function genblock($fn, $mn, $ln, $city) {
		global $blockn, $rown;
		$tname = strtolower($fn . $mn . $ln);
		$iname = preg_replace( "/[^a-z]/" , '', $tname );
		if ( $mn != '') { 
			$sn = '(' . $mn . ') ' . $ln;
		} else {
			$sn = $ln;
		}
		$blockn++;
		$pb = " badge$blockn";

		if ( $blockn == 6) {
			$blockn = 0;
			$rown = 0;
		}
?><div class="badge wireframe<?= $pb ?>">
	<!-- <?php echo "fn=$fn, $mn=$mn, ln=$ln, tname=$tname, iname=$iname" ?> -->
	<div class="badge-header wireframe">
		Greenwich High School Class of '64 50th Reunion
	</div>
	<div class="badge-footer wireframe">
		May 30-31, 2014
	</div>
	<div class="hs wireframe">
		<img src="../Photos/<?= $iname ?>-hs.png" class="hs-img" />
	</div>
	<div class="fn wireframe">
		<?= $fn ?>
	</div>
	<div class="ln wireframe">
		<?= $sn ?>
	</div>
	<div class="city wireframe">
		<?= $city ?>
	</div>
</div>
<?php	}

?><!DOCTYPE html>
<html lang="en">
<head>
<!-- 	<base href="file:///Users/dad/Dropbox/Projects/GHSReunion/" /> -->
	<meta charset="utf-8" />
	<title>Badges</title>
	<meta name="generator" content="BBEdit 10.5" />
	<link href="../css/styles.css" rel="stylesheet" type="text/css" />
	<!--[if IE]>
		<link href="css/ie.css" media="screen, projection" rel="stylesheet" type="text/css" />
	<![endif]-->
</head>
<body>
<!-- <div class="page-box wireframe"> -->
<?php
	include "badges.php";
?>
<!-- </div> -->
</body>
</html>
