use Mojo::Base -strict;

BEGIN {
  $ENV{MOJO_MODE}    = 'development';
  $ENV{MOJO_REACTOR} = 'Mojo::Reactor::Poll';
}

use Test::Mojo;
use Test::More;
use Mojo::File 'path';
use Mojolicious::Lite;

# Default
app->config(it => 'works');
is_deeply app->config, {it => 'works'}, 'right value';

# Invalid config file
eval { plugin JSONConfig => {file => 'public/hello.txt'} };
like $@, qr/JSON/, 'right error';

# Load plugins
my $config
  = plugin j_s_o_n_config => {default => {foo => 'baz', hello => 'there'}};
my $path = path(__FILE__)->to_abs->sibling('json_config_lite_app_abs.json');
plugin JSONConfig => {file => $path};
is $config->{foo},          'bar',            'right value';
is $config->{hello},        'there',          'right value';
is $config->{utf},          'утф',         'right value';
is $config->{absolute},     'works too!',     'right value';
is $config->{absolute_dev}, 'dev works too!', 'right value';
is app->config->{foo},          'bar',            'right value';
is app->config->{hello},        'there',          'right value';
is app->config->{utf},          'утф',         'right value';
is app->config->{absolute},     'works too!',     'right value';
is app->config->{absolute_dev}, 'dev works too!', 'right value';
is app->config('foo'),          'bar',            'right value';
is app->config('hello'),        'there',          'right value';
is app->config('utf'),          'утф',         'right value';
is app->config('absolute'),     'works too!',     'right value';
is app->config('absolute_dev'), 'dev works too!', 'right value';
is app->config('it'),           'works',          'right value';

get '/' => 'index';

my $t = Test::Mojo->new;

$t->get_ok('/')->status_is(200)->content_is("barbarbar\n");

# No config file, default only
$config
  = plugin JSONConfig => {file => 'nonexistent', default => {foo => 'qux'}};
is $config->{foo}, 'qux', 'right value';
is app->config->{foo}, 'qux', 'right value';
is app->config('foo'), 'qux',   'right value';
is app->config('it'),  'works', 'right value';

# No config file, no default
{
  ok !(eval { plugin JSONConfig => {file => 'nonexistent'} }), 'no config file';
  local $ENV{MOJO_CONFIG} = 'nonexistent';
  ok !(eval { plugin 'JSONConfig' }), 'no config file';
}

done_testing();

__DATA__
@@ index.html.ep
<%= $config->{foo} %><%= config->{foo} %><%= config 'foo' %>
