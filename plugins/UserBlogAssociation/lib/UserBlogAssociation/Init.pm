package UserBlogAssociation::Init;

use strict;
use warnings;
use Sub::Install;

sub init_app {
    my ( $cb, $app ) = @_;
    my $plugin = $cb;

    return
        unless $app->isa('MT::App')
            && ( $app->can('query') || $app->can('param') );

    # Save the original method in a request object.
    $plugin->{mt_app_make_commenter_session} = \&MT::App::make_commenter_session;

    Sub::Install::reinstall_sub({
      code => 'make_commenter_session',
      into => 'MT::App',
    });
}

sub make_commenter_session {
    my $app = shift;
    # my ( $session_key, $email, $name, $nick, $id, $url ) = @_;
    my ($commenter) = @_;

    my $plugin = MT->component('userblogassociation');
    my $q      = $app->can('query') ? $app->query : $app->param;

    # If a blog ID can be found, use it to set the user-blog association.
    if ( $q->param('blog_id') ) {
        require UserBlogAssociation::Plugin;
        UserBlogAssociation::Plugin::_create_association( $q->param('blog_id'), $commenter);
    }

    # Get the original method stashed in the plugin object
    my $original_method = $plugin->{mt_app_make_commenter_session}
        or die "Original MT::App::make_commenter_session method was not saved ";

    # Call it immediately with all arguments and get back exactly what we need
    $original_method->( $app, @_ );
}

1;

__END__
