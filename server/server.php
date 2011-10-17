<?php

	error_reporting(E_ALL);
	set_time_limit(0);
	ob_implicit_flush();
	$_listening = true;
	$_master = posix_getpid();
	$maxconnections = 5;
	$totalconnections = 0;
	
	$clients = array();
	
	pcntl_signal( SIGTERM, "sig_handler" );
	pcntl_signal( SIGINT, "sig_handler" );
	pcntl_signal( SIGCHLD, "sig_handler" );
	
	server_loop( '50.56.98.99', 10000 );
	
	function server_loop( $address, $port ) {
		GLOBAL $_listening, $totalconnections, $maxconnections, $clients;
		
		if (($sock = socket_create(AF_INET, SOCK_STREAM, SOL_TCP)) === false) {
			echo "socket_create() failed: reason: " . socket_strerror(socket_last_error()) . "\n";
		}
		if (socket_bind($sock, $address, $port) === false) {
			echo "socket_bind() failed: reason: " . socket_strerror(socket_last_error($sock)) . "\n";
		}
		if (socket_listen($sock, 5) === false) {
			echo "socket_listen() failed: reason: " . socket_strerror(socket_last_error($sock)) . "\n";
		}
		socket_set_nonblock( $sock );
		
		echo "Waiting for clients to connect\n";
		do {
			for( $i = 0; $i < $totalconnections; $i++ ) {
				read_client( $clients[$i], $i );
			}
			$connection = @socket_accept( $sock );
			if( $connection === false ) {
				usleep(100);
			} else if( $connection > 0 ) {
				if( $totalconnections >= $maxconnections ) {
					reject_client( $sock, $connection );
				} else {
					socket_set_nonblock( $connection );
					handle_client( $sock, $connection );
					$totalconnections++;
				}
			} else {
				echo "\nsocket_accept() failed: reason: " . socket_strerror(socket_last_error($sock)) . "\n";
				die;
			}
		} while ($_listening);

		if( $sock ) {
			socket_close($sock);
		}
	}
	
	function sig_handler( $sig ) {
		switch( $sig ) {
			case SIGTERM:
			case SIGINT:
				exit();
			break;
			
			case SIGCHLD:
				pcntl_waitpid( -1, $status );
			break;
		}
	}
	
	function read_client( $sock, $id ) {
		global $clients, $totalconnections;
		if (false === ($buf = socket_read($sock, 2048, PHP_NORMAL_READ))) {
			echo "\nsocket_read() failed: reason: " . socket_strerror(socket_last_error($sock)) . "\n";
			return;
		}
		if( $buf === "" ) {
			echo "Client disconnected from host...\n";
			socket_shutdown( $sock );
			socket_close( $sock );
			array_splice( $clients, $i, 1 );
			$totalconnections--;
			return;
		}
		if (!$buf = trim($buf)) {
			continue;
		}
		if ($buf == 'quit') {
			socket_shutdown( $sock );
			socket_close($sock);
			array_splice( $clients, $i, 1 );
			$totalconnections--;
			return;
		}
		$talkback = "$buf\n";
		socket_write($sock, $talkback, strlen($talkback));
		echo "Client " . $id . ": $buf\n";
	}
	
	function handle_client( $ssock, $csock ) {
		global $_listening, $clients;
		$clients[] = array(
			"socket" => $csock,
			"authenticated" => false
		);
		
		
		/*$pid = pcntl_fork();		
		if( $pid == -1 ) {
			echo "Fork failure!\n";
			die;
		} else if( $pid == 0 ) {
			$_listening = false;
			socket_close( $ssock );
			socket_close( $ary[0] );
			$ipcsocket = $ary[1];
			interact( $csock );
			socket_close( $csock );
		} else {
			socket_close( $ary[1] );
			$ipcsocket = $ary[0];
			socket_close( $csock );
		}*/
	}
	
	function reject_client( $sock, $csock ) {
		$msg = "0\n";
		socket_write( $csock, $msg, strlen($msg) );
		socket_shutdown( $sock );
		socket_shutdown( $csock );
		socket_close( $sock );
		socket_close( $csock );
		return;
	}
	
	function interact( $sock ) {
		$msg = "1\n";
		socket_write($sock, $msg, strlen($msg));
		do {
			echo "Server receiving message...\n";
			if (false === ($buf = socket_read($sock, 2048, PHP_NORMAL_READ))) {
				echo "\nsocket_read() failed: reason: " . socket_strerror(socket_last_error($sock)) . "\n";
				return;
			}
			if( $buf === "" ) {
				echo "Client disconnected from host...\n";
				socket_shutdown( $sock );
				socket_close( $sock );
				return;
			}
			if (!$buf = trim($buf)) {
				continue;
			}
			if ($buf == 'quit') {
				socket_shutdown( $sock );
				socket_close($sock);
				return;
			}
			if ($buf == 'shutdown') {
				socket_shutdown( $sock );
				socket_close($sock);
				return;
			}
			$talkback = "$buf\n";
			socket_write($sock, $talkback, strlen($talkback));
			echo "$buf\n";
		} while (true);
	}

?>