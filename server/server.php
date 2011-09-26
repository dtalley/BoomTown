<?php

	error_reporting(E_ALL);

	/* Allow the script to hang around waiting for connections. */
	set_time_limit(0);

	/* Turn on implicit output flushing so we see what we're getting
	 * as it comes in. */
	ob_implicit_flush();

	$address = '50.56.98.99';
	$port = 10000;

	if (($sock = socket_create(AF_INET, SOCK_STREAM, SOL_TCP)) === false) {
			echo "socket_create() failed: reason: " . socket_strerror(socket_last_error()) . "\n";
	}

	if (socket_bind($sock, $address, $port) === false) {
			echo "socket_bind() failed: reason: " . socket_strerror(socket_last_error($sock)) . "\n";
	}

	if (socket_listen($sock, 5) === false) {
			echo "socket_listen() failed: reason: " . socket_strerror(socket_last_error($sock)) . "\n";
	}
	echo "\n";
	do {
		echo "\rServer waiting for connections...";
			if (($msgsock = socket_accept($sock)) === false) {
					echo "\nsocket_accept() failed: reason: " . socket_strerror(socket_last_error($sock)) . "\n";
					break;
			}
			/* Send instructions. */
			$msg = "\nWelcome to the PHP Test Server. \n" .
					"To quit, type 'quit'. To shut down the server type 'shutdown'.\n";
			socket_write($msgsock, $msg, strlen($msg));
			do {
				echo "\nServer receiving message...\n";
					if (false === ($buf = socket_read($msgsock, 2048, PHP_NORMAL_READ))) {
							echo "\nsocket_read() failed: reason: " . socket_strerror(socket_last_error($msgsock)) . "\n";
							break 2;
					}
					if (!$buf = trim($buf)) {
							continue;
					}
					if ($buf == 'quit') {
							break;
					}
					if ($buf == 'shutdown') {
							socket_close($msgsock);
							break 2;
					}
					$talkback = "PHP: You said '$buf'.\n";
					socket_write($msgsock, $talkback, strlen($talkback));
					echo "$buf\n";
			} while (true);
			socket_close($msgsock);
	} while (true);

	socket_close($sock);

?>