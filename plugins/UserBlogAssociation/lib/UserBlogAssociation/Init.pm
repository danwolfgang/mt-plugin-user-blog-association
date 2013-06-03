package UserBlogAssociation::Init;

use strict;
use Sub::Install;

use MT::Util qw( remove_html is_url );


sub init_app {
    my ( $cb, $app ) = @_;
    return
      unless $app->isa('MT::App')
          && ( $app->can('query') || $app->can('param') );

    Sub::Install::reinstall_sub({
        code => \&_commenter_loggedin,
        into => 'MT::App::Community',
        as   => 'commenter_loggedin',
    });
}

# The following is lifted from the Community Pack 1.63, from
# MT::App::Community. commenter_loggedin is called at the end of the user
# log-in process, so I'm overriding that to add the ability to tie a user
# and blog together.
sub _commenter_loggedin {
    my $app = shift;
    my $q   = $app->param;
    my ($commenter, $commenter_blog_id) = @_;

    # Create the user-blog association before returning the user to
    # wherever they came from.
    require UserBlogAssociation::Plugin;
    UserBlogAssociation::Plugin::_create_association(
        $commenter_blog_id,
        $commenter
    );

    my $return_to = $q->param('return_to') || $q->param('return_url');
    if ( $return_to ) {
        $return_to = remove_html($return_to);
        $return_to =~ s/#.+//;
        return $app->errtrans('Invalid request.')
          unless is_url( $return_to );
    }

    my $url;
    $app->make_commenter_session($commenter);
    if ($return_to) {
        $url = $return_to . '#_login';
    }
    else {
        if ($commenter_blog_id) {
            my $blog
                = $app->model('blog.community')->load( $q->param('blog_id') )
                or return $app->errtrans("Invalid parameter");
            $url = $blog->site_url . '#_login';
        }
        else {
            my $cfg = $app->config;
            $url
                = $cfg->ReturnToURL
                ? $cfg->ReturnToURL
                : $app->uri( mode => 'edit' );
        }
    }
    return $url if $url;
    $app->SUPER::commenter_loggedin(@_);
}

1;

__END__
