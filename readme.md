# User-Blog Association plugin

Assign a role and blog to a user specifically (and only) when the user interacts with that blog.

This is different from using the "(newly created user)" functionality, because "(newly created user)" will associate a user with *every* blog that has a "(newly created user)" defined. Also, "(newly created user)" will only create associations for new users; existing users are never updated.

Visit the blog-level plugin Settings screen to select a Role to be associated with any user who logs in. When a user logs in, the `blog_id` parameter should be included; this parameter is used to associate the user with that blog.
