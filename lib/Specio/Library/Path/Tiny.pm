package Specio::Library::Path::Tiny;

use strict;
use warnings;

our $VERSION = '0.01';

use Path::Tiny;
use Specio 0.28 ();
use Specio::Declare;
use Specio::Library::Builtins;

use parent 'Specio::Exporter';

declare(
    'Path',
    parent => object_isa_type('Path::Tiny'),
);

declare(
    'AbsPath',
    parent => t('Path'),
    inline => sub {
        $_[0]->parent->inline_check( $_[1] ) . " && $_[1]->is_absolute";
    },
);

declare(
    'RealPath',
    parent => t('Path'),
    inline => sub {
        $_[0]->parent->inline_check( $_[1] ) . " && $_[1]->realpath eq $_[1]";
    },
);

declare(
    'File',
    parent => t('Path'),
    inline => sub {
        $_[0]->parent->inline_check( $_[1] ) . " && $_[1]->is_file";
    },
);

declare(
    'Dir',
    parent => t('Path'),
    inline => sub {
        $_[0]->parent->inline_check( $_[1] ) . " && $_[1]->is_dir";
    },
);

declare(
    'AbsFile',
    parent => t('Path'),
    inline => sub {
        $_[0]->parent->inline_check( $_[1] )
            . " && $_[1]->is_file && $_[1]->is_absolute";
    },
);

declare(
    'RealFile',
    parent => t('Path'),
    inline => sub {
        $_[0]->parent->inline_check( $_[1] )
            . " && $_[1]->is_file && $_[1]->realpath eq $_[1]";
    },
);

declare(
    'AbsDir',
    parent => t('Path'),
    inline => sub {
        $_[0]->parent->inline_check( $_[1] )
            . " && $_[1]->is_dir && $_[1]->is_absolute";
    },
);

declare(
    'RealDir',
    parent => t('Path'),
    inline => sub {
        $_[0]->parent->inline_check( $_[1] )
            . " && $_[1]->is_dir && $_[1]->realpath eq $_[1]";
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
        inline => sub {"$_[1]->absolute"},
    );

    coerce(
        $type,
        from   => t('Str'),
        inline => sub {"Path::Tiny::path( $_[1] )->absolute"},
    );

    coerce(
        $type,
        from   => t('ArrayRef'),
        inline => sub {"Path::Tiny::path( \@{ $_[1] } )->absolute"},
    );
}

for my $type ( map { t($_) } qw( RealPath RealFile RealDir ) ) {
    coerce(
        $type,
        from   => t('Path'),
        inline => sub {"$_[1]->realpath"},
    );

    coerce(
        $type,
        from   => t('Str'),
        inline => sub {"Path::Tiny::path( $_[1] )->realpath"},
    );

    coerce(
        $type,
        from   => t('ArrayRef'),
        inline => sub {"Path::Tiny::path( \@{ $_[1] } )->realpath"},
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
$path->is_file >>.

Will be coerced from a string or arrayref via C<Path::Tiny::path>.

=head2 AbsDir

A L<Path::Tiny> object which is a directory on disk according to C<<
$path->is_file >> where C<< $path->is_absolute >> returns true.

Will be coerced from a string or arrayref via C<Path::Tiny::path> followed by
call to C<< $path->absolute >>.

=head2 RealDir

A L<Path::Tiny> object which is a directory on disk according to C<<
$path->is_file >> where C<< $path->realpath eq $path >>.

Will be coerced from a string or arrayref via C<Path::Tiny::path> followed by
call to C<< $path->realpath >>.

=head1 CREDITS

The vast majority of the code in this distribution comes from David Golden's
L<Types::Path::Tiny> distribution.
