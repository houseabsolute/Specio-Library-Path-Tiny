## no critic (Modules::ProhibitExcessMainComplexity)
package Specio::Library::Path::Tiny;

use strict;
use warnings;

our $VERSION = '0.04';

use overload ();
use Path::Tiny 0.087;
use Scalar::Util qw( blessed );
use Specio 0.28 ();
use Specio::Declare;
use Specio::Library::Builtins;
use Specio::PartialDump qw( partial_dump );

use parent 'Specio::Exporter';

my $not_blessed = sub {
    return blessed $_[0] ? q{} : "$_[1] is not an object";
};

my $not_path_tiny = sub {
    return $_[0]->isa('Path::Tiny')
        ? q{}
        : "$_[1] is not a Path::Tiny object";
};

my $not_absolute = sub {
    return $_[0]->is_absolute ? q{} : "$_[0] is not an absolute path";
};

my $not_real = sub {
    return $_[0]->is_realpath ne $_[0] ? q{} : "$_[0] is not a real path";
};

my $not_file = sub {
    return $_[0]->is_file ? q{} : "$_[0] is not a file on disk";
};

my $not_dir = sub {
    return $_[0]->is_dir ? q{} : "$_[0] is not a dir on disk";
};

declare(
    'Path',
    parent            => object_isa_type('Path::Tiny'),
    message_generator => sub {
        my $dump = partial_dump( $_[1] );
        return $not_blessed->( $_[1], $dump )
            || $not_path_tiny->( $_[1], $dump );
    },
);

declare(
    'AbsPath',
    parent => t('Path'),
    inline => sub {
        return sprintf(
            '( %s && %s->is_absolute )',
            $_[0]->parent->inline_check( $_[1] ),
            $_[1]
        );
    },
    message_generator => sub {
        my $dump = partial_dump( $_[1] );
        return
               $not_blessed->( $_[1], $dump )
            || $not_path_tiny->( $_[1], $dump )
            || $not_absolute->( $_[1], $dump );
    },
);

declare(
    'RealPath',
    parent => t('Path'),
    inline => sub {
        return sprintf(
            '( %s && %s->realpath eq %s )',
            $_[0]->parent->inline_check( $_[1] ),
            $_[1], $_[1]
        );
    },
    message_generator => sub {
        my $dump = partial_dump( $_[1] );
        return
               $not_blessed->( $_[1], $dump )
            || $not_path_tiny->( $_[1], $dump )
            || $not_real->( $_[1], $dump );
    },
);

declare(
    'File',
    parent => t('Path'),
    inline => sub {
        return sprintf(
            '( %s && %s->is_file )',
            $_[0]->parent->inline_check( $_[1] ),
            $_[1]
        );
    },
    message_generator => sub {
        my $dump = partial_dump( $_[1] );
        return
               $not_blessed->( $_[1], $dump )
            || $not_path_tiny->( $_[1], $dump )
            || $not_file->( $_[1], $dump );
    },
);

declare(
    'AbsFile',
    parent => t('Path'),
    inline => sub {
        return sprintf(
            '( %s && %s->is_file && %s->is_absolute )',
            $_[0]->parent->inline_check( $_[1] ),
            $_[1], $_[1]
        );
    },
    message_generator => sub {
        my $dump = partial_dump( $_[1] );
        return
               $not_blessed->( $_[1], $dump )
            || $not_path_tiny->( $_[1], $dump )
            || $not_file->( $_[1], $dump )
            || $not_absolute->( $_[1], $dump );
    },
);

declare(
    'RealFile',
    parent => t('Path'),
    inline => sub {
        return sprintf(
            '( %s && %s->is_file && %s->realpath eq %s )',
            $_[0]->parent->inline_check( $_[1] ),
            $_[1], $_[1], $_[1]
        );
    },
    message_generator => sub {
        my $dump = partial_dump( $_[1] );
        return
               $not_blessed->( $_[1], $dump )
            || $not_path_tiny->( $_[1], $dump )
            || $not_file->( $_[1], $dump )
            || $not_real->( $_[1], $dump );
    },
);

declare(
    'Dir',
    parent => t('Path'),
    inline => sub {
        return sprintf(
            '( %s && %s->is_dir )',
            $_[0]->parent->inline_check( $_[1] ),
            $_[1]
        );
    },
    message_generator => sub {
        my $dump = partial_dump( $_[1] );
        return
               $not_blessed->( $_[1], $dump )
            || $not_path_tiny->( $_[1], $dump )
            || $not_dir->( $_[1], $dump );
    },
);

declare(
    'AbsDir',
    parent => t('Path'),
    inline => sub {
        return sprintf(
            '( %s && %s->is_dir && %s->is_absolute )',
            $_[0]->parent->inline_check( $_[1] ),
            $_[1], $_[1],
        );
    },
    message_generator => sub {
        my $dump = partial_dump( $_[1] );
        return
               $not_blessed->( $_[1], $dump )
            || $not_path_tiny->( $_[1], $dump )
            || $not_dir->( $_[1], $dump )
            || $not_absolute->( $_[1], $dump );
    },
);

declare(
    'RealDir',
    parent => t('Path'),
    inline => sub {
        return sprintf(
            '( %s && %s->is_dir && %s->realpath eq %s )',
            $_[0]->parent->inline_check( $_[1] ),
            $_[1], $_[1], $_[1]
        );
    },
    message_generator => sub {
        my $dump = partial_dump( $_[1] );
        return
               $not_blessed->( $_[1], $dump )
            || $not_path_tiny->( $_[1], $dump )
            || $not_dir->( $_[1], $dump )
            || $not_real->( $_[1], $dump );
    },
);

for my $type ( map { t($_) } qw( Path File Dir ) ) {
    coerce(
        $type,
        from   => t('Str'),
        inline => sub {"Path::Tiny::path( $_[1] )"},
    );

    coerce(
        $type,
        from   => t('ArrayRef'),
        inline => sub {"Path::Tiny::path( \@{ $_[1] } )"},
    );
}

for my $type ( map { t($_) } qw( AbsPath AbsFile AbsDir ) ) {
    coerce(
        $type,
        from   => t('Path'),
        inline => sub { sprintf( '%s->absolute', $_[1] ) },
    );

    coerce(
        $type,
        from => t('Str'),
        inline =>
            sub { sprintf( 'Path::Tiny::path( %s )->absolute', $_[1] ) },
    );

    coerce(
        $type,
        from => t('ArrayRef'),
        inline =>
            sub { sprintf( 'Path::Tiny::path( @{ %s } )->absolute', $_[1] ) },
    );
}

for my $type ( map { t($_) } qw( RealPath RealFile RealDir ) ) {
    coerce(
        $type,
        from   => t('Path'),
        inline => sub { sprintf( '%s->realpath', $_[1] ) },
    );

    coerce(
        $type,
        from => t('Str'),
        inline =>
            sub { sprintf( 'Path::Tiny::path( %s )->realpath', $_[1] ) },
    );

    coerce(
        $type,
        from => t('ArrayRef'),
        inline =>
            sub { sprintf( 'Path::Tiny::path( @{ %s } )->realpath', $_[1] ) },
    );
}

1;

# ABSTRACT: Path::Tiny types and coercions for Specio

__END__

=head1 SYNOPSIS

  use Specio::Library::Path::Tiny;

  has path => ( isa => t('Path') );

=head1 DESCRIPTION

This library provides a set of L<Path::Tiny> types and coercions for
L<Specio>. These types can be used with L<Moose>, L<Moo>,
L<Params::ValidationCompiler>, and other modules.

=head1 TYPES

This library provides the following types:

=head2 Path

A L<Path::Tiny> object.

Will be coerced from a string or arrayref via C<Path::Tiny::path>.

=head2 AbsPath

A L<Path::Tiny> object where C<< $path->is_absolute >> returns true.

Will be coerced from a string or arrayref via C<Path::Tiny::path> followed by
call to C<< $path->absolute >>.

=head2 RealPath

A L<Path::Tiny> object where C<< $path->realpath eq $path >>.

Will be coerced from a string or arrayref via C<Path::Tiny::path> followed by
call to C<< $path->realpath >>.

=head2 File

A L<Path::Tiny> object which is a file on disk according to C<< $path->is_file
>>.

Will be coerced from a string or arrayref via C<Path::Tiny::path>.

=head2 AbsFile

A L<Path::Tiny> object which is a file on disk according to C<< $path->is_file
>> where C<< $path->is_absolute >> returns true.

Will be coerced from a string or arrayref via C<Path::Tiny::path> followed by
call to C<< $path->absolute >>.

=head2 RealFile

A L<Path::Tiny> object which is a file on disk according to C<< $path->is_file
>> where C<< $path->realpath eq $path >>.

Will be coerced from a string or arrayref via C<Path::Tiny::path> followed by
call to C<< $path->realpath >>.

=head2 Dir

A L<Path::Tiny> object which is a directory on disk according to C<<
$path->is_dir >>.

Will be coerced from a string or arrayref via C<Path::Tiny::path>.

=head2 AbsDir

A L<Path::Tiny> object which is a directory on disk according to C<<
$path->is_dir >> where C<< $path->is_absolute >> returns true.

Will be coerced from a string or arrayref via C<Path::Tiny::path> followed by
call to C<< $path->absolute >>.

=head2 RealDir

A L<Path::Tiny> object which is a directory on disk according to C<<
$path->is_dir >> where C<< $path->realpath eq $path >>.

Will be coerced from a string or arrayref via C<Path::Tiny::path> followed by
call to C<< $path->realpath >>.

=head1 CREDITS

The vast majority of the code in this distribution comes from David Golden's
L<Types::Path::Tiny> distribution.
