package UserBlogAssociation::Plugin;

use strict;

sub blog_config_template {
    my ($plugin, $param, $scope) = @_;

    my @roles = MT->model('role')->load();
    $param->{roles} = \@roles;

    my $html = <<'HTML';
<mtapp:Setting
    id="select-role"
    label="Select Role"
    hint="Select a role to assign to users when they interact with this blog."
    show_hint="1">
    <select name="saved_role_id">
        <option value="">None</option>
    <mt:Loop name="roles">
        <option value="<mt:Var name="id">"<mt:If name="saved_role_id" eq="$id"> selected="selected"</mt:If>><mt:Var name="name"></option>
    </mt:Loop>
    </select>
</mtapp:Setting>
HTML
    return $html;
}

sub post_save {
    my ($cb, $app, $obj, $original) = @_;

    # Validate the user.
    use MT::App::Community;
    my $user = MT::App::Community::_login_user_commenter($app)
        or return $app->errtrans("Login required");

    # Create the association
    _create_association($app->param('blog_id'), $user);
}

sub _create_association {
    my ($blog_id, $user) = @_;

    # Just give up if a blog ID isn't supplied -- no way to create a user-
    # blog association if there's no blog!
    my $blog = MT->model('blog')->load($blog_id);
    return unless $blog;

    # Check if a role has been marked to be used to create the user-blog
    # association. If not, just give up.
    my $plugin = MT->component('userblogassociation');
    my $role_id = $plugin->get_config_value(
        'saved_role_id', 
        'blog:'.$blog_id
    );
    return unless $role_id;

    # Try to load the role from the saved role_id.
    my $role = MT->model('role')->load($role_id);
    return unless $role;

    # Create the user-role-blog association.
    require MT::Association;
    MT::Association->link( $user, $role, $blog );
}

1;

__END__
