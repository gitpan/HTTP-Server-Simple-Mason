use Test::More;
BEGIN {
    if (eval { require LWP::Simple }) {
	plan tests => 5;
    } else {
	Test::More->import(skip_all =>"LWP::Simple not installed: $@");
    }
}

use_ok( HTTP::Server::Simple::Mason);

my $s=MyApp::Server->new(13432);
is($s->port(),13432,"Constructor set port correctly");
my $pid=$s->background();
like($pid, qr/^-?\d+$/,'pid is numeric');
sleep(1);
my $content=LWP::Simple::get("http://localhost:13432");
is($content,'',"Returns an empty page");
is(kill(9,$pid),1,'Signaled 1 process successfully');




package MyApp::Server;
use base qw/HTTP::Server::Simple::Mason/;
use File::Spec;

sub mason_config {
    my $root = File::Spec->catdir(File::Spec->tmpdir, "mason-pages-$$");
    mkdir( $root ) or die $!;
    open (PAGE, '>', File::Spec->catfile($root, 'index.html')) or die $!;
    print PAGE '<%die%>';
    close (PAGE);
    return ( comp_root => $root, error_mode => 'fatal', error_format => 'line' );
}

1;
