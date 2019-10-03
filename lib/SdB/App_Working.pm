package SdB::App;
#package Dancer5::App;
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

set 'session'      => 'Simple';
set 'template'     => 'template_toolkit';
set 'logger'       => 'console';
set 'log'          => 'debug';
set 'show_errors'  => 1;
set 'startup_info' => 1;
set 'warnings'     => 1;
set 'username'     => 'admin';
set 'password'     => 'password';
set 'layout'       => 'main';

our $VERSION = '0.1';
my @column_header = qw(
MOVIE_ID
TITLE
RATING
PHASE
YEAR_PUB
DESC
);


my $flash;

get '/INDEX' => sub {
    template 'index';
};

sub set_flash {
     my $message = shift;
     $flash = $message;
}

sub get_flash {
     my $msg = $flash;
     $flash = "";
     return $msg;
}

my($driver,$dbs,$table,$host,$port,$user,$pass);
$driver = 'mysql';
$dbs = 'movies';
$host = '10.251.7.68';
$port = '3306';
$user = 'infradmin';
$pass = 'prdweb01';

sub connect_db {
                 my $sth = database({driver => 'mysql',
                                     database => 'movies',
                                     host => '10.251.7.68',
                                     port => '3306',
                                     username => 'infradmin',
                                     password => 'prdweb01'});
                             return $sth;
};

sub init_db {
     my $db = connect_db();
     my $filename = 'lib/SdB/schema.sql';

     foreach my $item (@column_header){
           print "$item\n";
            };     

     print "\nLooking for schema filename:\n\n$filename\n";
      my $pwd =`pwd`;
      print "\$pwd =$pwd\n";
       my $out = `/usr/bin/ls -al`;
        if ($out){ print "File exist!\n\t\$out = $out\n";};
          my $schema = read_file( $filename );
          $db->do($schema) or die $db->errstr;
             # print "Trying second create: $filename2!\n\n"; 
             # create type table
             # my $db2 = connect_db(); 
             # my $schema2 = read_file( $filename2 );
             # $db2->do($schema2) or die $db2->errstr;
};

hook before_template => sub {
     my $tokens = shift;
         # $tokens->{'formbaseaddstrategy'} = request->base . 'addstrategy';
         # $tokens->{'formbaseaddinitiative'} = request->base . 'addinitiative';
         # $tokens->{'formbaseaddproject'} = request->base . 'addproject';
         # $tokens->{'formbaseaddtask'} = request->base . 'addtask';
     $tokens->{'css_url'} = request->base . 'css/style.css';
     $tokens->{'login_url'} = uri_for('/login');
     $tokens->{'logout_url'} = uri_for('/logout');
};

get '/' => sub {
     my $db = connect_db();
     # my $sql = 'select id, req_n_id, req_n_parent, req_n_tag, req_n_type, req_n_progress, req_n_statusfile, req_n_note from req_note order by req_n_id';
     my $sql = 'select movie_id, title, rating, phase, year_pub, left(description, 26) from movies';
     my $sth = $db->prepare($sql) or die $db->errstr;
      print "$db->errstr\n\n";

       $sth->execute or die $sth->errstr;
        print "$sth->errstr\n\n";
        print "$sth->fetchall_hashref()\n\n";
         #print Dumper \$sth->fetchall_hashref('req_n_id');
          template 'show_entries.tt', {
                                        'msg' => get_flash(),
                              'add_entry_url' => uri_for('/add'),
                                   #'req_note' => $sth->fetchall_hashref('req_n_id'),
                                     'movies' => $sth->fetchall_hashref('movie_id'),
                                #'req_n_note' => $sth->fetchall_hashref('req_n_id'),
                                    'cheader' =>\@column_header
     }
|| die Template->error(), "\n";

};

get '/new' => sub {
     my $db = connect_db();
     # my $sql = 'select id, req_n_id, req_n_tag, req_n_type, req_n_progress, req_n_statusfile, req_n_note from req_note order by id desc';
     my $sql = 'select movie_id, title, rating, phase, year_pub, left(description, 26) from movies';
     my $sth = $db->prepare($sql) or die $db->errstr;
     $sth->execute or die $sth->errstr;
     template 'show_entries.tt', {
                                     'msg' => get_flash(),
                           'add_entry_url' => uri_for('/add'),
                                  'movies' => $sth->fetchall_hashref('movie_id'),
                                 'cheader' =>\@column_header
     };
       ## print "<tt>",$sth->fetchall_hashref('id'),"</tt>\n";
};

get '/show' => sub {
     my $db = connect_db();
     # my $sql = 'select id, req_n_id, req_n_parent, req_n_tag, req_n_type, req_n_progress, req_n_statusfile, req_n_note from req_note order by id desc';
     my $sql = 'select movie_id, title, rating, phase, year_pub, left(description, 26) from movies';
     my $sth = $db->prepare($sql) or die $db->errstr;
     $sth->execute or die $sth->errstr;
     template 'just_show_entries.tt', {
                                       'msg' => get_flash(),
                                    'movies' => $sth->fetchall_hashref('movie_id'),
                                 #'req_note' => $sth->fetchall_hashref('id'),
     };
};


post '/add' => sub {
     if ( not session('logged_in') ) {
         send_error("Not logged in", 401);
     }

     my $db = connect_db();
     # my $sql = 'insert into req_note (req_n_id, req_n_parent, req_n_tag, req_n_type, req_n_progress, req_n_statusfile, req_n_note) values (?, ?, ?, ?, ?, ?, ?)';
     my $sql = 'insert into movies (movie_id,title,rating,phase,year_pub,description) values (?, ?, ?, ?, ?, ?)'
     my $sth = $db->prepare($sql) or die $db->errstr;
     # $sth->execute(params->{'req_n_id'}, params->{'req_n_parent'}, params->{'req_n_tag'}, params->{'req_n_type'}, params->{'req_n_progress'}, params->{'req_n_statusfile'}, params->{'req_n_note'}) or die $sth->errstr;
       $sth->execute(params->{'movie_id'}, params->{'title'}, params->{'rating'}, params->{'phase'}, params->{'year_pub'}, params->{'req_n_statusfile'}, params->{'req_n_note'}) or die $sth->errstr;

       set_flash('Nice!  New entry posted!');
       redirect '/';
};
## Attempting to create EDIT route???
#post '/edit' => sub {
#     if ( not session('logged_in') ) {
#         send_error("Not logged in", 401);
#     }
#
#     my $db = connect_db();
#     my $sql ='select id, req_n_id, req_n_tag, req_n_type, req_n_progress, req_n_statusfile, req_n_note from req_note order by id desc';
#     my $sth = $db->prepare($sql) or die $db->errstr;
#      $sth->execute(params->{'req_n_id'}, params->{'req_n_tag'}, params->{'req_n_type'}, params->{'req_n_progress'}, params->{'req_n_statusfile'}, params->{'req_n_note'}) or die $sth->errstr;
#
#     set_flash('New entry posted!');
#     redirect '/';
#};
## Attempting to create EDIT route???


any ['get', 'post'] => '/login' => sub {
     my $err;

     if ( request->method() eq "POST" ) {
         # process form input
         if ( params->{'username'} ne setting('username') ) {
             $err = "Invalid username";
         }
         elsif ( params->{'password'} ne setting('password') ) {
             $err = "Invalid password";
         }
         else {
             session 'logged_in' => true;
             set_flash('You are NOW logged in.  You have the power!');
             return redirect '/';
         }
    }
    # display login form
         template 'login.tt', {
                             'err' => $err,
                             };
};

get '/logout' => sub {
    app->destroy_session;
    set_flash('Later.  You are logged out.');
    redirect '/';
};

init_db();

start;

true;
