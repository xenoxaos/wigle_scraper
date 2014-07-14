#!/usr/bin/perl -w
use strict;


    #!/usr/bin/perl
    use strict;
    use warnings;
    use LWP::UserAgent;
    use HTTP::Request::Common;
    use HTTP::Cookies;
    use DBI;

    my $dbUser = "wigle";
    my $dbPass = "db_pass";
    my $wigleUser = "wigleuser";
    my $wiglePass = "wiglepass";
    my $dbh = DBI->connect('dbi:mysql:database=wigle', $dbUser, $dbPass);

    my $ua = LWP::UserAgent->new;

    # Define user agent type
    $ua->agent('Mozilla/8.0');

    # Cookies
    $ua->cookie_jar(
        HTTP::Cookies->new(
            file => 'mycookies.txt',
            autosave => 1
        )
    );

    # Request object
    my $req = POST 'https://wigle.net//gps/gps/main/login', [credential_0 => $wigleuser, credential_1 => wiglepass, destination => '/gps/gps/main'];

    # Make the request
    my $res = $ua->request($req);
    $req = GET 'https://wigle.net/gps/gps/main/mytrans/';
    $res = $ua->request($req);
    
    # Check the response
    if ($res->is_success) {
        my $page = $res->content;
        $page =~ s/.*uploaddata/</;
        $page =~ s/,//g;
        $page =~ s/<[^>]*>/,/g;
        $page =~ s/,,/,/g;
        
        
        my @result = grep(/100\%/,split ( /^/ ,$page));

        #print @result;
        foreach my $string (@result){
            my @string = split (/,/ , $string);
            my $statement = "INSERT IGNORE INTO `wigle`.`completed` (`trans_id`, `elapsed_time`, `uploaded_date`, " .
            "`file_name`, `file_size`, `file_lines`, `wifi_discovered_gps`, `wifi_discovered`, `wifi_in_file_gps`, " .
            "`wifi_in_file`, `wifi_new_locations`, `cell_discovered_gps`, `cell_discovered`, `cell_in_file_gps`, " .
            "`cell_in_file`, `cell_new_locations`) VALUES (\"" .
            $string[1] . "\", \"" . $string[4] . "\", \"" . $string[5] . "\", \"" .
            $string[6] . "\", \"" . $string[7] . "\", \"" . $string[8] . "\", \"" . $string[9] . "\", \"" .
            $string[10] . "\", \"" . $string[11] . "\", \"" . $string[12] . "\", \"" . $string[13] . "\", \"" .
            $string[14] . "\", \"" . $string[15] . "\", \"" . $string[16] . "\", \"" . $string[17] . "\", \"" .
            $string[18] . 
            
            "\")";
            
            my $sth = $dbh->prepare($statement);
            my $date =  $sth->execute;
            
            
        }
        
        
    } else {
        print $res->status_line . "\n";
    }

    exit 0;
