<?php

	$pid = pcntl_fork();
  if ($pid != -1) {
    if ($pid) {
      print "In the parent: child PID is $pid\n";
    } else {
			sleep(1);
      print "In the child\n";
    }
  } else {
    echo "Fork failed!\n";
  }

?>