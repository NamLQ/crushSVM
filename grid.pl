#!/usr/bin/perl

use Term::ANSIColor;
use Term::ANSIColor qw(:constants);


$errThreshold = 2.0;
$train = "~/lab/data/protein/protein.train";
$test = "~/lab/data/protein/protein.test";

$train = "~/lab/data/australian/australian.train";
$test = "~/lab/data/australian/australian.test";

$CV = 5;
for ($lg = -15; $lg < 15; $lg++) {
	for ($lC = -15; $lC < 15; $lC++) {
		$g = 2**$lg;
		$C = 2**$lC;
		#print ("g: $g, C: $C\n");
		$o = (`bin/SharkSVM-train -i 0 -s 0 -t 2 -g $g -c $C --cv $CV --cvrand false  --cvsavemodels true  $train ~/tmp/sharksvm.model`);
#		print($o);
		$o = (`bin/SharkSVM-predict --cv $CV  $test   ~/tmp/sharksvm.model ~/tmp/predictions;`);
#		print($o);
		$o =~ m#Ensemble .avg/majority vote. error rate: (.*)#gis;
		$ensemble = $1;
		#print ("ENSEMBLE ERROR: $ensemble");
		$o = (`bin/SharkSVM-predict $test ~/tmp/sharksvm.model_$CV.alpha ~/tmp/predictions;`);
		$o =~ m#Test error rate: (.*)#gis;
		$average = $1;

		$o = (`bin/SharkSVM-train -i 0  -s 0 -t 2 -g $g -c $C  $train ~/tmp/sharkA.model;`);
		$o = (`bin/SharkSVM-predict  $test  ~/tmp/sharkA.model ~/tmp/predictions`);
#		print($o);
		$o =~ m#Test error rate: (.*)#gis;
		$normal = $1;
		#print ("NORMAL ERROR: $normal");
		if ($ensemble > $normal + $errThreshold) { 
			print RED, "-";
		} else {
			if ($normal > $ensemble + $errThreshold) { 
				print GREEN, "+";
			} else {
				print BLACK, ".";
			}
		}
		if ($average > $normal + $errThreshold) { 
			print RED, "-";
		} else {
			if ($normal > $average + $errThreshold) { 
				print GREEN, "+";
			} else {
				print BLACK, ".";
			}
		}
                print BLACK, " ";
	}
}


#bin/SharkSVM-train -s 0 -t 2 -g 0.0001 -c 10 --cv 5 --cvrand false  --cvsavemodels true  ~/lab/data/australian/australian.train ~/tmp/sharksvm.model; bin/SharkSVM-predict --cv 5  ~/lab/data/australian/australian.test ~/tmp/sharksvm.model ~/tmp/predictions; bin/SharkSVM-train -s 0 -t 2 -g 0.0001 -c 10  ~/lab/data/australian/australian.train ~/tmp/sharkA.model; bin/SharkSVM-predict   ~/lab/data/australian/australian.test ~/tmp/sharkA.model ~/tmp/predictions;

