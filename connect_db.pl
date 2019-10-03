use Dancer2;
use DBI;
use File::Spec;
use File::Slurp;
use Template;
use Dancer2::Plugin::Database;
use DBD::mysql;
use Template;
use Template::Plugin;
use HTML::Entities qw( encode_entities );
use Data::Dumper;
use Sort::Naturally;
use Template::Plugin::SortNatural;



sub connect_db {
                 my $sth = database({driver => 'mysql',
                                     database => 'marvel',
                                     host => '10.251.7.68',
                                     port => '3306',
                                     username => 'infradmin',
                                     password => 'prdweb01'
                                   #  database => 'nfr_m1',
                                   #  host => 'localhost',
                                   #  port => '3306',
                                   #  username => 'phaigh',
                                   #  password => 'v22osprey'});
                                 });
                             return $sth;
};




my $db = connect_db();
 #my $sql = 'select movie_id, title, rating, phase, year_pub, left(description, 26) from movies';
 my $sql = 'select movie_id, title, rating, phase, year_pub, description from movies';

# my $sql = 'select id, req_n_id, req_n_parent, req_n_tag, req_n_type, req_n_progress, req_n_statusfile, req_n_note from req_note order by req_n_id';
 my $sth = $db->prepare($sql) or die $db->errstr;
      ##print $db->errstr,"\n\n";

 $sth->execute or die $sth->errstr;
        print "$sth->errstr\n\n";
        #print "$sth->fetchall_hashref()\n\n";
        my $movies = $sth->fetchall_hashref('movie_id');
        print "\n--------------------------------------\nList of MCU Movies:\n";


       $sth->finish();

           foreach my $key (sort keys %$movies) {
                            my $movie_id = $movies->{$key}->{'movie_id'};
                            my $title = $movies->{$key}->{'title'};
                            my $rating = ();
                            $rating = "NULL" unless $movies->{$key}->{'rating'};
                            #if( $movies->{$key}->{'rating'} ne "" ) { $rating = $movies->{$key}->{'rating'}; } else { $rating = "NULL" };
                            my $phase = $movies->{$key}->{'phase'};
                            my $year_pub = $movies->{$key}->{'year_pub'};
                            my $description = $movies->{$key}->{'description'};
                                print "$movie_id: $title (year_pub) phase: $phase, rating: $rating\ndescription: $description\n\n";
};
        print "\n--------------------------------------\n";




##
##

        
       #print Dumper \$sth->fetchall_hashref('movie_id');
       #print Dumper \$sth->fetchall_hashref('req_n_id');


